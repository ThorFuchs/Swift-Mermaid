// SPDX-License-Identifier: Apache-2.0
import SwiftUI

/// A SwiftUI view that displays a Mermaid diagram as vector artwork.
///
/// By default, the view uses ``MermaidRenderer/shared`` and follows the
/// environment's color scheme. Pass a renderer or theme to the initializer to
/// customize them. It fits artwork to the available space without enlarging it
/// past its natural size; use ``resizable()`` to permit upscaling. While rendering, it shows a progress indicator; on
/// failure, it displays the source and an explanation.
///
/// The context menu offers **Show Source** and **Copy Source**. VoiceOver reads
/// the diagram source. For an example, see <doc:DisplayingDiagrams>.
public struct MermaidView: View {
    @Binding private var source: String
    private let renderer: MermaidRenderer
    private let theme: MermaidTheme?
    private var allowsUpscaling = false
    private var renderAction: (@MainActor (Result<Artwork, any Error>) -> Void)?
    @Environment(\.colorScheme) private var colorScheme
    @State private var state: Phase = .rendering
    @State private var showSource = false

    enum Phase { case rendering, ready(Artwork), failed(String) }

    /// Creates a view from Mermaid source without a Markdown code fence.
    /// - Parameter source: The diagram source to render.
    public init(_ source: String) {
        self.init(source, renderer: .shared, theme: nil)
    }

    /// Creates a view with an optional custom renderer and Mermaid theme.
    /// - Parameters:
    ///   - source: The diagram source to render.
    ///   - renderer: The renderer to use; defaults to the shared renderer.
    ///   - theme: A fixed Mermaid theme, or `nil` to follow the color scheme.
    public init(_ source: String, renderer: MermaidRenderer = .shared, theme: MermaidTheme? = nil) {
        self._source = .constant(source)
        self.renderer = renderer
        self.theme = theme
    }

    /// Creates a view that follows a binding to Mermaid source.
    ///
    /// The view reads the binding but doesn't edit it. Changes to the bound
    /// source trigger a new render. Passing a changing `String` also updates
    /// the view; a binding is a convenience for existing SwiftUI state.
    /// - Parameters:
    ///   - source: A binding to diagram source without a Markdown code fence.
    ///   - renderer: The renderer to use; defaults to the shared renderer.
    ///   - theme: A fixed Mermaid theme, or `nil` to follow the color scheme.
    public init(_ source: Binding<String>, renderer: MermaidRenderer = .shared, theme: MermaidTheme? = nil) {
        self._source = source
        self.renderer = renderer
        self.theme = theme
    }

    /// Allows artwork to scale beyond its natural size when space is available.
    ///
    /// The diagram retains its aspect ratio and is fitted within the proposed
    /// size. Without this modifier it only scales down.
    public func resizable() -> MermaidView {
        var view = self
        view.allowsUpscaling = true
        return view
    }

    /// Observes the artwork or error produced when an input is rendered.
    ///
    /// The action also runs when the result comes from the renderer's cache.
    /// It runs on the main actor and isn't called for a cancelled render. Use
    /// the artwork's PDF or SVG for an app's own export or sharing interface.
    /// - Parameter action: A handler for the current render result.
    /// - Returns: A view that reports subsequent render results.
    public func onRender(_ action: @escaping @MainActor (Result<Artwork, any Error>) -> Void) -> MermaidView {
        var view = self
        view.renderAction = action
        return view
    }

    private var resolvedTheme: MermaidTheme { theme ?? (colorScheme == .dark ? .dark : .default) }

    private struct RenderID: Equatable {
        let source: String
        let theme: MermaidTheme
        let renderer: ObjectIdentifier
    }

    /// The view's content and interaction behavior.
    public var body: some View {
        Group {
            if showSource {
                sourceView(note: nil)
            } else {
                switch state {
                case .rendering:
                    ProgressView().controlSize(.small).frame(maxWidth: .infinity, minHeight: 80)
                case .ready(let artwork):
                    ArtworkCanvas(artwork: artwork, allowsUpscaling: allowsUpscaling)
                case .failed(let reason):
                    sourceView(note: reason)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .contextMenu {
            Button(showSource ? "Show Rendered" : "Show Source") { showSource.toggle() }
            Button("Copy Source") { copy(source) }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Diagram"))
        .accessibilityValue(Text(source))
        .task(id: RenderID(source: source, theme: resolvedTheme, renderer: ObjectIdentifier(renderer))) { await render() }
    }

    private func sourceView(note: String?) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(source).font(.system(.callout, design: .monospaced)).textSelection(.enabled)
            if let note {
                Label(note, systemImage: "exclamationmark.triangle").font(.caption).foregroundStyle(.secondary).lineLimit(3)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func render() async {
        guard !Task.isCancelled else { return }
        let theme = resolvedTheme
        if let hit = renderer.cached(source, theme: theme) { apply(hit); return }
        state = .rendering
        do {
            let artwork = try await renderer.render(source, theme: theme)
            guard !Task.isCancelled else { return }
            apply(.success(artwork))
        } catch {
            guard !Task.isCancelled else { return }
            apply(.failure(error))
        }
    }

    private func apply(_ result: Result<Artwork, any Error>) {
        switch result {
        case .success(let artwork): state = .ready(artwork)
        case .failure(MermaidError.parse(let message)): state = .failed(message)
        case .failure(MermaidError.tooLong): state = .failed("Diagram too long to render")
        case .failure: state = .failed("Diagram could not be rendered")
        }
        renderAction?(result)
    }

    private func copy(_ text: String) {
        #if canImport(AppKit)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        #else
        UIPasteboard.general.string = text
        #endif
    }
}
