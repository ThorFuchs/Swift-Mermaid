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
    private var waiters: [CheckedContinuation<Void, Never>] = []

    init(page: URL, readAccess: URL) {
        self.page = page
        self.readAccess = readAccess
    }

    /// Runs `body` with exclusive use of the loaded page.
    func exclusive<T>(_ body: (WKWebView) async throws -> T) async throws -> T {
        if busy { await withCheckedContinuation { waiters.append($0) } } else { busy = true }
        defer { if waiters.isEmpty { busy = false } else { waiters.removeFirst().resume() } }
        let view = try await loadedView()
        return try await body(view)
    }

    /// Calls an async page function with JSON-safe arguments, bounded by `timeout`.
    func call(_ view: WKWebView, _ body: String, arguments: [String: Any], timeout: Duration) async throws -> [String: Any] {
        let deadline = Task { @MainActor [weak self] in
            try await Task.sleep(for: timeout)
            self?.discard() // a hung page is replaced on the next call
        }
        defer { deadline.cancel() }
        let value = try await view.callAsyncJavaScript(body, arguments: arguments, in: nil, contentWorld: .page)
        guard !deadline.isCancelled, webView === view else { throw Failure.timeout }
        guard let result = value as? [String: Any] else { throw Failure.badResult }
        return result
    }

    /// Vector PDF of `rect` (CSS pixels = points), after growing the view to contain it.
    func pdf(_ view: WKWebView, rect: CGRect) async throws -> Data {
        let needed = CGSize(width: max(view.frame.width, rect.maxX + 8), height: max(view.frame.height, rect.maxY + 8))
        if needed != view.frame.size { resize(view, to: needed) }
        let configuration = WKPDFConfiguration()
        configuration.rect = rect
        return try await view.pdf(configuration: configuration)
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
        if let list = try await WKContentRuleListStore.default()?.compileContentRuleList(forIdentifier: "swift-webrender-offline", encodedContentRuleList: rules) {
            configuration.userContentController.add(list)
        }
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

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loading?.resume(); loading = nil
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: any Error) {
        loading?.resume(throwing: Failure.load(String(describing: error))); loading = nil
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: any Error) {
        loading?.resume(throwing: Failure.load(String(describing: error))); loading = nil
    }

    /// Only the bundled page may load; nothing navigates away from it.
    func webView(_ webView: WKWebView, decidePolicyFor action: WKNavigationAction) async -> WKNavigationActionPolicy {
        action.request.url == page ? .allow : .cancel
    }
}
