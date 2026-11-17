// SPDX-License-Identifier: Apache-2.0
import CoreGraphics
import Foundation
@testable import Mermaid
import Testing
import WebKit

@MainActor @Suite(.serialized) struct WebRenderHostTests {
    @Test func javascriptTimeoutReleasesTheHost() async throws {
        let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString, directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let page = directory.appending(path: "index.html")
        try Data("<!doctype html><title>test</title>".utf8).write(to: page)
        let host = WebRenderHost(page: page, readAccess: directory)
        do {
            _ = try await host.exclusive { view in
                try await host.call(view, "await new Promise(() => {}); return {};", arguments: [:], timeout: .milliseconds(100))
            }
            Issue.record("a never-resolving JavaScript promise should time out")
        } catch WebRenderHost.Failure.timeout {
            // A subsequent request must get a fresh, usable page.
        }
        let result = try await host.exclusive { view in
            try await host.call(view, "return { ok: true };", arguments: [:], timeout: .seconds(10))
        }
        #expect(result["ok"] as? Bool == true)
    }

    @Test func deadlineBoundsAnUnfinishedOperation() async throws {
        let host = WebRenderHost(page: URL(filePath: "/unused"), readAccess: URL(filePath: "/"))
        var timedOut = false
        do {
            let _: Data = try await host.withDeadline(.milliseconds(100), onTimeout: { timedOut = true }) {
                try await Task.sleep(for: .seconds(30))
                return Data()
            }
            Issue.record("unfinished operation should time out")
        } catch WebRenderHost.Failure.timeout {}
        #expect(timedOut)
        let value = try await host.withDeadline(.seconds(2)) { Data([42]) }
        #expect(value == Data([42]))
    }

    @Test func pdfTimeoutReleasesAndReplacesThePage() async throws {
        let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString, directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let page = directory.appending(path: "index.html")
        try Data("<!doctype html><title>test</title>".utf8).write(to: page)
        let host = WebRenderHost(page: page, readAccess: directory)
        var oldView: WKWebView?
        do {
            _ = try await host.exclusive { view in
                oldView = view
                return try await host.pdf(view, rect: CGRect(x: 0, y: 0, width: 10, height: 10), timeout: .milliseconds(100)) { _, _ in
                    try await Task.sleep(for: .seconds(30))
                    return Data()
                }
            }
            Issue.record("unfinished PDF operation should time out")
        } catch WebRenderHost.Failure.timeout {}
        try await host.exclusive { view in
            #expect(view !== oldView)
            let result = try await host.call(view, "return { ok: true };", arguments: [:], timeout: .seconds(10))
            #expect(result["ok"] as? Bool == true)
        }
    }

    @Test func queuedRequestsTimeOutOrCancelWithoutBlockingOthers() async throws {
        let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString, directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let page = directory.appending(path: "index.html")
        try Data("<!doctype html><title>test</title>".utf8).write(to: page)
        let host = WebRenderHost(page: page, readAccess: directory)
        var holding = false
        let holder = Task { @MainActor in
            try await host.exclusive { _ in
                holding = true
                try await Task.sleep(for: .seconds(30))
            }
        }
        defer { holder.cancel() }
        let startupDeadline = ContinuousClock.now + .seconds(15)
        while !holding {
            guard ContinuousClock.now < startupDeadline else {
                Issue.record("host did not start")
                return
            }
            try Task.checkCancellation()
            try await Task.sleep(for: .milliseconds(10))
        }
        do {
            try await host.exclusive(queueTimeout: .milliseconds(100)) { _ in }
            Issue.record("queued request should time out")
        } catch WebRenderHost.Failure.timeout {}

        let cancelled = Task { @MainActor in try await host.exclusive { _ in } }
        await Task.yield()
        cancelled.cancel()
        await #expect(throws: CancellationError.self) { try await cancelled.value }
        holder.cancel()
        _ = try? await holder.value
        let result = try await host.exclusive { view in
            try await host.call(view, "return { ok: true };", arguments: [:], timeout: .seconds(10))
        }
        #expect(result["ok"] as? Bool == true)
    }

}
