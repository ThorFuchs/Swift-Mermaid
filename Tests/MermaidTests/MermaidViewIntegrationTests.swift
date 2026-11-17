// SPDX-License-Identifier: Apache-2.0
#if os(macOS)
import AppKit
import Combine
@testable import Mermaid
import SwiftUI
import Testing

@MainActor private final class DiagramModel: ObservableObject {
    @Published var source = "graph LR\n  A[First] --> B"
    @Published var renderer = MermaidRenderer()
    @Published var theme: MermaidTheme = .default
    var lastSVG: String?
    var lastError: MermaidError?
}

@MainActor private struct DiagramHost: View {
    @ObservedObject var model: DiagramModel
    let valueRenderer: MermaidRenderer

    var body: some View {
        VStack {
            MermaidView($model.source, renderer: model.renderer, theme: model.theme).resizable()
                .onRender { result in
                    switch result {
                    case .success(let artwork): model.lastSVG = artwork.svg; model.lastError = nil
                    case .failure(let error): model.lastSVG = nil; model.lastError = error as? MermaidError
                    }
                }
            MermaidView(model.source, renderer: valueRenderer, theme: .default)
        }
    }
}

extension WebKitTestSuite {
@MainActor @Suite(.serialized) struct MermaidViewIntegrationTests {
    @Test func sourceThemeAndRendererChangesTriggerRendering() async throws {
        _ = NSApplication.shared
        let model = DiagramModel()
        let firstRenderer = model.renderer
        let valueRenderer = MermaidRenderer()
        let view = NSHostingView(rootView: DiagramHost(model: model, valueRenderer: valueRenderer))
        let window = NSWindow(contentRect: CGRect(x: 0, y: 0, width: 480, height: 360),
                              styleMask: [.borderless], backing: .buffered, defer: false)
        window.contentView = view
        window.orderFront(nil)
        defer { window.orderOut(nil); window.contentView = nil }

        try await waitForRender(firstRenderer, source: model.source, theme: .default)
        try await waitForRender(valueRenderer, source: model.source, theme: .default)
        #expect(model.lastSVG?.contains("First") == true)
        model.source = "graph LR\n  A[Changed] --> C"
        try await waitForRender(firstRenderer, source: model.source, theme: .default)
        try await waitForRender(valueRenderer, source: model.source, theme: .default)
        #expect(model.lastSVG?.contains("Changed") == true)
        model.theme = .forest
        try await waitForRender(firstRenderer, source: model.source, theme: .forest)
        model.lastSVG = nil
        model.theme = .default
        try await waitUntil { model.lastSVG != nil }
        #expect(model.lastSVG?.contains("Changed") == true)
        model.source = "not a diagram"
        try await waitUntil { model.lastError != nil }
        if case .parse = model.lastError {} else { Issue.record("Expected a parse error from the view") }
        model.source = "graph LR\n  A[Changed] --> C"
        model.theme = .forest
        let replacement = MermaidRenderer()
        model.renderer = replacement
        try await waitForRender(replacement, source: model.source, theme: .forest)
    }

    private func waitForRender(_ renderer: MermaidRenderer, source: String, theme: MermaidTheme) async throws {
        let deadline = ContinuousClock.now + .seconds(20)
        while renderer.cached(source, theme: theme) == nil {
            guard ContinuousClock.now < deadline else {
                Issue.record("View did not render \(source) with theme \(theme)")
                return
            }
            try await Task.sleep(for: .milliseconds(20))
        }
        let result = try #require(renderer.cached(source, theme: theme))
        _ = try result.get()
    }

    private func waitUntil(_ condition: @MainActor () -> Bool) async throws {
        let deadline = ContinuousClock.now + .seconds(20)
        while !condition() {
            guard ContinuousClock.now < deadline else {
                Issue.record("View did not report the expected result")
                return
            }
            try await Task.sleep(for: .milliseconds(20))
        }
    }
}
}
#endif
