// SPDX-License-Identifier: Apache-2.0
import SwiftUI

/// A SwiftUI view that displays a Mermaid diagram as vector artwork.
///
/// The view uses ``MermaidRenderer/shared`` and follows the environment's
/// color scheme. It fits artwork to the available width without enlarging it
/// past its natural size. While rendering, it shows a progress indicator; on
/// failure, it displays the source and an explanation.
///
/// The context menu offers **Show Source** and **Copy Source**. VoiceOver reads
/// the diagram source. For an example, see <doc:DisplayingDiagrams>.
public struct MermaidView: View {
    private let source: String
    @Environment(\.colorScheme) private var colorScheme
    @State private var state: Phase = .rendering
    @State private var showSource = false

    enum Phase { case rendering, ready(Artwork), failed(String) }

    /// Creates a view from Mermaid source without a Markdown code fence.
    /// - Parameter source: The diagram source to render.
    public init(_ source: String) { self.source = source }

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
                    ArtworkCanvas(artwork: artwork)
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
        .task(id: "\(source)|\(colorScheme == .dark)") { await render() }
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
        let dark = colorScheme == .dark
        if let hit = MermaidRenderer.shared.cached(source, dark: dark) { apply(hit); return }
        state = .rendering
        do {
            let artwork = try await MermaidRenderer.shared.render(source, dark: dark)
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
