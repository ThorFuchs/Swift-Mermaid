// SPDX-License-Identifier: Apache-2.0
import CoreGraphics
import Foundation
import WebKit
#if canImport(AppKit)
import AppKit
#endif

/// One hidden WKWebView that renders bundled pages to vector PDF artwork.
///
/// - Content is passed as `callAsyncJavaScript` arguments, never interpolated into script.
/// - Every `http`/`https` load is blocked; the page reads only its own resource directory.
/// - Calls are serialized: one render at a time owns the page.
@MainActor final class WebRenderHost: NSObject, WKNavigationDelegate {
    enum Failure: Error, Sendable { case load(String), timeout, badResult }

    private let page: URL
    private let readAccess: URL
    private var webView: WKWebView?
    #if canImport(AppKit)
    private var window: NSWindow?
    #endif
    private var loading: CheckedContinuation<Void, any Error>?
    private var busy = false
    private struct Waiter {
        let id: UUID
        let continuation: CheckedContinuation<Void, any Error>
        let deadline: Task<Void, Never>
    }
    private var waiters: [Waiter] = []

    init(page: URL, readAccess: URL) {
        self.page = page
        self.readAccess = readAccess
    }

    /// Runs `body` with exclusive use of the loaded page.
    func exclusive<T>(queueTimeout: Duration = .seconds(60), _ body: (WKWebView) async throws -> T) async throws -> T {
        try await acquire(timeout: queueTimeout)
        defer { release() }
        try Task.checkCancellation()
        let view = try await loadedView()
        try Task.checkCancellation()
        return try await body(view)
    }

    private func acquire(timeout: Duration) async throws {
        try Task.checkCancellation()
        guard busy else { busy = true; return }
        let id = UUID()
        try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, any Error>) in
                guard !Task.isCancelled else { continuation.resume(throwing: CancellationError()); return }
                let deadline = Task { @MainActor in
                    do { try await Task.sleep(for: timeout) } catch { return }
                    self.removeWaiter(id, error: Failure.timeout)
                }
                waiters.append(Waiter(id: id, continuation: continuation, deadline: deadline))
            }
        } onCancel: {
            Task { @MainActor in self.removeWaiter(id, error: CancellationError()) }
        }
    }

    private func removeWaiter(_ id: UUID, error: any Error) {
        guard let index = waiters.firstIndex(where: { $0.id == id }) else { return }
        let waiter = waiters.remove(at: index)
        waiter.deadline.cancel()
        waiter.continuation.resume(throwing: error)
    }

    private func release() {
        guard !waiters.isEmpty else { busy = false; return }
        let waiter = waiters.removeFirst()
        waiter.deadline.cancel()
        waiter.continuation.resume()
    }

    /// Calls an async page function with JSON-safe arguments, bounded by `timeout`.
    func call(_ view: WKWebView, _ body: String, arguments: [String: Any], timeout: Duration) async throws -> [String: Any] {
        let wrapped = try await withDeadline(timeout, onTimeout: { self.discard() }) {
            JavaScriptValue(try await view.callAsyncJavaScript(body, arguments: arguments, in: nil, contentWorld: .page))
        }
        try Task.checkCancellation()
        guard let result = wrapped.value as? [String: Any] else { throw Failure.badResult }
        return result
    }

    /// The value is produced and consumed only on the main actor.
    private struct JavaScriptValue: @unchecked Sendable {
        let value: Any?
        init(_ value: Any?) { self.value = value }
    }

    /// Resolves a race between WebKit and a deadline exactly once.
    private final class Completion<Value: Sendable> {
        private var continuation: CheckedContinuation<Value, any Error>?
        var deadline: Task<Void, Never>?
        init(_ continuation: CheckedContinuation<Value, any Error>) { self.continuation = continuation }
        @discardableResult func finish(_ result: Result<Value, any Error>) -> Bool {
            guard let continuation else { return false }
            self.continuation = nil
            deadline?.cancel()
            deadline = nil
            continuation.resume(with: result)
            return true
        }
    }

    /// Bounds an asynchronous WebKit operation even if its completion never arrives.
    func withDeadline<Value: Sendable>(_ timeout: Duration, onTimeout: @escaping @MainActor () -> Void = {}, operation: @escaping @MainActor () async throws -> Value) async throws -> Value {
        try await withCheckedThrowingContinuation { continuation in
            let completion = Completion(continuation)
            let worker = Task { @MainActor in
                do { completion.finish(.success(try await operation())) }
                catch { completion.finish(.failure(error)) }
            }
            completion.deadline = Task { @MainActor in
                do { try await Task.sleep(for: timeout) } catch { return }
                guard completion.finish(.failure(Failure.timeout)) else { return }
                worker.cancel()
                onTimeout()
            }
        }
    }

    /// Vector PDF of `rect` (CSS pixels = points), after growing the view to contain it.
    func pdf(_ view: WKWebView, rect: CGRect, timeout: Duration = .seconds(30), createPDF: @escaping @MainActor (WKWebView, WKPDFConfiguration) async throws -> Data = { view, configuration in
        try await view.pdf(configuration: configuration)
    }) async throws -> Data {
        let needed = CGSize(width: max(view.frame.width, rect.maxX + 8), height: max(view.frame.height, rect.maxY + 8))
        if needed != view.frame.size { resize(view, to: needed) }
        let configuration = WKPDFConfiguration()
        configuration.rect = rect
        let data = try await withDeadline(timeout, onTimeout: { self.discard() }) {
            try await createPDF(view, configuration)
        }
        try Task.checkCancellation()
        return data
    }

    private func resize(_ view: WKWebView, to size: CGSize) {
        view.frame = CGRect(origin: .zero, size: size)
        #if canImport(AppKit)
        window?.setContentSize(size)
        #endif
    }

    private func discard() {
        webView?.navigationDelegate = nil
        webView = nil
        #if canImport(AppKit)
        window = nil
        #endif
    }

    private func loadedView() async throws -> WKWebView {
        if let webView { return webView }
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .nonPersistent()
        let rules = #"[{"trigger":{"url-filter":"^https?:"},"action":{"type":"block"}}]"#
        let compiled = try await withDeadline(.seconds(30)) {
            RuleList(try await WKContentRuleListStore.default()?.compileContentRuleList(forIdentifier: "swift-webrender-offline", encodedContentRuleList: rules))
        }
        guard let list = compiled.value else {
            throw Failure.load("Unable to install offline content rules")
        }
        configuration.userContentController.add(list)
        let frame = CGRect(x: 0, y: 0, width: 1200, height: 800)
        let view = WKWebView(frame: frame, configuration: configuration)
        view.navigationDelegate = self
        #if canImport(AppKit)
        view.setValue(false, forKey: "drawsBackground")
        let window = NSWindow(contentRect: frame, styleMask: [.borderless], backing: .buffered, defer: false)
        window.contentView = view
        self.window = window
        #else
        view.isOpaque = false
        view.backgroundColor = .clear
        #endif
        webView = view
        let deadline = Task { @MainActor in
            do { try await Task.sleep(for: .seconds(30)) } catch { return }
            guard self.webView === view, let loading = self.loading else { return }
            self.loading = nil
            self.discard()
            loading.resume(throwing: Failure.timeout)
        }
        defer { deadline.cancel() }
        do {
            try await withCheckedThrowingContinuation { (c: CheckedContinuation<Void, any Error>) in
                loading = c
                view.loadFileURL(page, allowingReadAccessTo: readAccess)
            }
        } catch {
            discard()
            throw error
        }
        return view
    }

    /// The list is created and used only on the main actor.
    private struct RuleList: @unchecked Sendable {
        let value: WKContentRuleList?
        init(_ value: WKContentRuleList?) { self.value = value }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard self.webView === webView else { return }
        loading?.resume(); loading = nil
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: any Error) {
        guard self.webView === webView else { return }
        loading?.resume(throwing: Failure.load(String(describing: error))); loading = nil
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: any Error) {
        guard self.webView === webView else { return }
        loading?.resume(throwing: Failure.load(String(describing: error))); loading = nil
    }

    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        guard self.webView === webView else { return }
        let pending = loading
        loading = nil
        discard()
        pending?.resume(throwing: Failure.load("Web content process terminated"))
    }

    /// Only the bundled page may load; nothing navigates away from it.
    func webView(_ webView: WKWebView, decidePolicyFor action: WKNavigationAction) async -> WKNavigationActionPolicy {
        action.request.url == page ? .allow : .cancel
    }
}
