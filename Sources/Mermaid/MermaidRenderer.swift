// SPDX-License-Identifier: Apache-2.0
import CoreGraphics
import Foundation

/// Why a diagram could not be rendered. The view shows the source instead, never a blank.
public enum MermaidError: Error, Sendable, Equatable {
    /// Mermaid rejected the source. The message is Mermaid's.
    case parse(String)
    /// The source exceeds `MermaidRenderer.maximumSourceLength`.
    case tooLong
    /// The page could not load, timed out, or returned no measurable result.
    case engine(String)
}

/// Renders Mermaid source to vector artwork with the bundled Mermaid, one diagram at a time,
/// in one hidden WebView shared by all callers. `securityLevel: 'strict'`: labels cannot carry
/// HTML and click handlers are off. Results are cached by source and appearance.
@MainActor public final class MermaidRenderer {
    public static let shared = MermaidRenderer()
    /// Exact upstream version bundled in this package.
    public nonisolated static let mermaidVersion = "12.2.0"
    public nonisolated static let maximumSourceLength = 50_000
    nonisolated static let fontFamily = #"-apple-system, "Helvetica Neue", Helvetica, Arial, sans-serif"#

    private let host: WebRenderHost
    private let cache = ArtworkCache()

    public init() {
        let page = Bundle.module.url(forResource: "render", withExtension: "html")!
        host = WebRenderHost(page: page, readAccess: page.deletingLastPathComponent())
    }

    public func cached(_ source: String, dark: Bool = false) -> Result<Artwork, any Error>? {
        cache.value(Self.key(source, dark))
    }

    /// - Parameters:
    ///   - source: Mermaid source, as inside a ```mermaid fence.
    ///   - dark: Mermaid's dark theme instead of the default one.
    public func render(_ source: String, dark: Bool = false) async throws -> Artwork {
        let key = Self.key(source, dark)
        if let hit = cache.value(key) { return try hit.get() }
        let result: Result<Artwork, any Error>
        do {
            result = .success(try await draw(source, dark))
        } catch let error as MermaidError {
            result = .failure(error)
        } catch {
            throw MermaidError.engine(String(describing: error)) // transient: not cached
        }
        if case .failure(MermaidError.engine) = result {} else { cache.store(key, result) }
        return try result.get()
    }

    private func draw(_ source: String, _ dark: Bool) async throws -> Artwork {
        guard source.count <= Self.maximumSourceLength else { throw MermaidError.tooLong }
        return try await host.exclusive { view in
            let r = try await host.call(view, "return await window.renderMermaid(source, dark, fontFamily);",
                                        arguments: ["source": source, "dark": dark, "fontFamily": Self.fontFamily],
                                        timeout: .seconds(20))
            if let message = r["error"] as? String { throw MermaidError.parse(message) }
            guard let x = r["x"] as? Double, let y = r["y"] as? Double, let w = r["width"] as? Double, let h = r["height"] as? Double,
                  w > 0, h > 0 else { throw MermaidError.engine("no measurable result") }
            let pdf = try await host.pdf(view, rect: CGRect(x: x, y: y, width: w, height: h))
            return Artwork(pdf: pdf, size: CGSize(width: w, height: h), baseline: h)
        }
    }

    static func key(_ source: String, _ dark: Bool) -> String { "\(dark ? "D" : "L")|\(source)" }
}
