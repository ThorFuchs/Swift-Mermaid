// SPDX-License-Identifier: Apache-2.0
import CoreGraphics
import Foundation
import SwiftUI

/// A rendered diagram as vector PDF and SVG, with its natural dimensions.
///
/// Obtain artwork from ``MermaidRenderer/render(_:dark:)``. The PDF has a
/// transparent background; choose a background appropriate to the selected
/// theme when displaying, exporting, or printing it. ``MermaidView`` draws the
/// same PDF, scaling it down when the available width is smaller.
///
/// Artwork is immutable after creation and can be passed between tasks.
public final class Artwork: @unchecked Sendable {
    /// A single-page vector PDF with a transparent background.
    public let pdf: Data
    /// SVG markup produced by Mermaid for the same render as ``pdf``.
    ///
    /// The SVG is generated in strict mode but isn't a general-purpose sanitized
    /// HTML fragment. Apply appropriate policies before embedding it elsewhere.
    /// Fonts and some SVG features depend on the destination renderer.
    public let svg: String
    /// The diagram's natural size in points.
    public let size: CGSize
    /// The baseline in points from the top of the artwork.
    ///
    /// For a Mermaid diagram, the baseline is the bottom of the artwork and
    /// equals ``size``'s height. ``MermaidView`` doesn't define custom baseline
    /// alignment with adjacent SwiftUI text.
    public let baseline: CGFloat
    /// Immutable after creation; only read for drawing.
    let page: CGPDFPage?

    init(pdf: Data, svg: String, size: CGSize, baseline: CGFloat) {
        self.pdf = pdf
        self.svg = svg
        self.size = size
        self.baseline = baseline
        page = CGDataProvider(data: pdf as CFData).flatMap(CGPDFDocument.init)?.page(at: 1)
    }
}

/// Draws an `Artwork` at its natural size, scaled down uniformly when narrower space is offered.
struct ArtworkCanvas: View {
    let artwork: Artwork
    var allowsUpscaling = false

    /// Fit the PDF inside the offered canvas, even if a parent forces its size.
    static func drawingRect(page: CGRect, canvas: CGSize) -> CGRect {
        guard page.width > 0, page.height > 0, canvas.width > 0, canvas.height > 0 else { return .zero }
        let scale = min(canvas.width / page.width, canvas.height / page.height)
        let size = CGSize(width: page.width * scale, height: page.height * scale)
        return CGRect(x: (canvas.width - size.width) / 2, y: (canvas.height - size.height) / 2,
                      width: size.width, height: size.height)
    }

    var body: some View {
        Canvas { context, size in
            guard let page = artwork.page else { return }
            let box = page.getBoxRect(.mediaBox)
            guard box.width > 0, box.height > 0 else { return }
            let rect = Self.drawingRect(page: box, canvas: size)
            guard !rect.isEmpty else { return }
            context.withCGContext { cg in
                cg.translateBy(x: rect.minX, y: rect.maxY)
                cg.scaleBy(x: rect.width / box.width, y: -rect.height / box.height)
                cg.translateBy(x: -box.minX, y: -box.minY)
                cg.drawPDFPage(page)
            }
        }
        .aspectRatio(artwork.size, contentMode: .fit)
        .frame(maxWidth: allowsUpscaling ? .infinity : artwork.size.width)
    }
}

/// A small bounded cache shared by a renderer's views.
final class ArtworkCache: @unchecked Sendable {
    private final class Box { let value: Result<Artwork, any Error>; init(_ v: Result<Artwork, any Error>) { value = v } }
    private let cache: NSCache<NSString, Box> = { let c = NSCache<NSString, Box>(); c.countLimit = 4_000; return c }()

    func value(_ key: String) -> Result<Artwork, any Error>? { cache.object(forKey: key as NSString)?.value }
    func store(_ key: String, _ value: Result<Artwork, any Error>) { cache.setObject(Box(value), forKey: key as NSString) }
}

extension Color {
    /// `#rrggbb` (or `#rrggbbaa`) for passing a resolved SwiftUI color to the page.
    /// `Color.Resolved` stores linear components, so convert through sRGB first.
    static func cssHex(_ resolved: Color.Resolved) -> String {
        let srgb = CGColorSpace(name: CGColorSpace.sRGB)!
        let comps = resolved.cgColor.converted(to: srgb, intent: .defaultIntent, options: nil)?.components ?? [0, 0, 0, 1]
        func c(_ v: CGFloat) -> String { String(format: "%02x", Int((max(0, min(1, v)) * 255).rounded())) }
        let alpha = comps.count > 3 ? comps[3] : 1
        return "#" + c(comps[0]) + c(comps[1]) + c(comps[2]) + (alpha < 1 ? c(alpha) : "")
    }
}
