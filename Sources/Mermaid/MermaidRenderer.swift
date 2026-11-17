// SPDX-License-Identifier: Apache-2.0
import CoreGraphics
import Foundation

/// An input or rendering failure reported by a Mermaid renderer.
///
/// ``MermaidView`` displays the source and an explanation if rendering fails.
/// Task cancellation is reported separately as `CancellationError`.
public enum MermaidError: Error, Sendable, Equatable {
    /// Mermaid rejected the source, with a message from the engine.
    case parse(String)
    /// The source exceeds `MermaidRenderer.maximumSourceLength`.
    case tooLong
    /// The rendering engine failed, timed out, or returned no measurable result.
    ///
    /// Engine failures are transient and aren't cached. The associated string
    /// describes the failure; don't rely on it as a stable error code.
    case engine(String)
}

/// Renders Mermaid source into vector PDF artwork.
///
/// Use ``shared`` for a renderer shared by ``MermaidView`` and other callers,
/// or create an instance when you need a separate host and cache. Each instance
/// owns an offscreen WebKit view and serializes its rendering operations. Its
/// APIs are isolated to the main actor.
///
/// The renderer caches successful results and parse errors by exact source and
/// appearance. The cache can evict entries at any time. Mermaid uses its strict
/// security mode; see <doc:SecurityAndLimits> for safeguards and limitations.
///
/// ```swift
/// let artwork = try await MermaidRenderer.shared.render("graph LR\n  A --> B")
/// let pdf = artwork.pdf
/// ```
@MainActor public final class MermaidRenderer {
    /// The renderer used by `MermaidView`.
    public static let shared = MermaidRenderer()
    /// The version of Mermaid bundled in this package.
    public nonisolated static let mermaidVersion = "12.3.0"
    /// The maximum source length, measured in Swift characters.
    ///
    /// Mermaid also applies its own text and edge limits; a source within this
    /// limit isn't guaranteed to render successfully.
    public nonisolated static let maximumSourceLength = 50_000
    nonisolated static let fontFamily = #"-apple-system, "Helvetica Neue", Helvetica, Arial, sans-serif"#

    private let host: WebRenderHost
    private let cache = ArtworkCache()

    /// Creates a renderer with its own WebKit host and artwork cache.
    public init() {
        let page = Bundle.module.url(forResource: "render", withExtension: "html")!
        host = WebRenderHost(page: page, readAccess: page.deletingLastPathComponent())
    }

    /// Returns a cached result without starting a render.
    ///
    /// Cache entries are keyed by exact source and theme and can be evicted.
    /// A cached failure is a parse error; transient engine failures aren't cached.
    /// - Parameters:
    ///   - source: The exact Mermaid source to look up.
    ///   - dark: Whether to look up the dark theme.
    /// - Returns: The cached success or failure, or `nil` when no entry exists.
    public func cached(_ source: String, dark: Bool = false) -> Result<Artwork, any Error>? {
        cache.value(Self.key(source, dark))
    }

    /// Renders Mermaid source into vector PDF artwork.
    ///
    /// Requests to the same instance are serialized. A matching cached result
    /// may be returned without invoking WebKit. Waiting and individual WebKit
    /// operations have separate deadlines; cancellation of an operation already
    /// running in WebKit may not complete until that operation finishes or times out.
    /// - Parameters:
    ///   - source: Mermaid source without a Markdown code fence.
    ///   - dark: Use Mermaid's dark theme instead of its default light theme.
    /// - Returns: The generated artwork and its natural size.
    /// - Throws: `MermaidError` for invalid input or rendering failures, or
    ///   `CancellationError` when the task is cancelled.
    public func render(_ source: String, dark: Bool = false) async throws -> Artwork {
        try Task.checkCancellation()
        guard source.count <= Self.maximumSourceLength else { throw MermaidError.tooLong }
        let key = Self.key(source, dark)
        if let hit = cache.value(key) { return try hit.get() }
        let result: Result<Artwork, any Error>
        do {
            result = .success(try await draw(source, dark))
        } catch is CancellationError {
            throw CancellationError()
        } catch let error as MermaidError {
            result = .failure(error)
        } catch {
            try Task.checkCancellation()
            throw MermaidError.engine(String(describing: error)) // transient: not cached
        }
        try Task.checkCancellation()
        if case .failure(MermaidError.engine) = result {} else { cache.store(key, result) }
        return try result.get()
    }

    private func draw(_ source: String, _ dark: Bool) async throws -> Artwork {
        return try await host.exclusive { view in
            let r = try await host.call(view, "return await window.renderMermaid(source, dark, fontFamily);",
                                        arguments: ["source": source, "dark": dark, "fontFamily": Self.fontFamily],
                                        timeout: .seconds(30))
            if let message = r["error"] as? String { throw MermaidError.parse(message) }
            guard let x = r["x"] as? Double, let y = r["y"] as? Double, let w = r["width"] as? Double, let h = r["height"] as? Double,
                  w > 0, h > 0 else { throw MermaidError.engine("no measurable result") }
            let pdf = try await host.pdf(view, rect: CGRect(x: x, y: y, width: w, height: h))
            return Artwork(pdf: pdf, size: CGSize(width: w, height: h), baseline: h)
        }
    }

    static func key(_ source: String, _ dark: Bool) -> String { "\(dark ? "D" : "L")|\(source)" }
}
