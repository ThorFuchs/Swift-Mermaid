// SPDX-License-Identifier: Apache-2.0
import CoreGraphics
import Foundation
import SwiftUI

/// A rendered diagram as a single-page vector PDF and its natural dimensions.
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

    init(pdf: Data, size: CGSize, baseline: CGFloat) {
        self.pdf = pdf
        self.size = size
        self.baseline = baseline
        page = CGDataProvider(data: pdf as CFData).flatMap(CGPDFDocument.init)?.page(at: 1)
    }
}

/// Draws an `Artwork` at its natural size, scaled down uniformly when narrower space is offered.
struct ArtworkCanvas: View {
    let artwork: Artwork

    var body: some View {
        Canvas { context, size in
            guard let page = artwork.page else { return }
            let box = page.getBoxRect(.mediaBox)
            guard box.width > 0, box.height > 0 else { return }
            context.withCGContext { cg in
                cg.translateBy(x: 0, y: size.height)
                cg.scaleBy(x: size.width / box.width, y: -size.height / box.height)
                cg.translateBy(x: -box.minX, y: -box.minY)
                cg.drawPDFPage(page)
            }
        }
        .aspectRatio(artwork.size, contentMode: .fit)
        .frame(maxWidth: artwork.size.width)
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
