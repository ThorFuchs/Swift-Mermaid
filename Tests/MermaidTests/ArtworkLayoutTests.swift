// SPDX-License-Identifier: Apache-2.0
import CoreGraphics
@testable import Mermaid
import SwiftUI
import Testing

extension WebKitTestSuite {
@MainActor @Suite struct ArtworkLayoutTests {
    @Test func drawingPreservesAspectRatioInWideAndTallSpaces() {
        let page = CGRect(x: 10, y: 20, width: 200, height: 100)
        #expect(ArtworkCanvas.drawingRect(page: page, canvas: CGSize(width: 300, height: 300)) ==
                CGRect(x: 0, y: 75, width: 300, height: 150))
        #expect(ArtworkCanvas.drawingRect(page: page, canvas: CGSize(width: 400, height: 100)) ==
                CGRect(x: 100, y: 0, width: 200, height: 100))
        #expect(ArtworkCanvas.drawingRect(page: page, canvas: .zero) == .zero)
    }

    @Test func upscalingIsOptInUnderARealSwiftUIProposal() async throws {
        let artwork = try await MermaidRenderer().render("graph LR\n  A --> B")
        let proposal = ProposedViewSize(width: artwork.size.width * 3, height: artwork.size.height * 3)
        let natural = ImageRenderer(content: ArtworkCanvas(artwork: artwork))
        natural.scale = 1
        natural.proposedSize = proposal
        let resized = ImageRenderer(content: ArtworkCanvas(artwork: artwork, allowsUpscaling: true))
        resized.scale = 1
        resized.proposedSize = proposal
        let naturalImage = try #require(natural.cgImage)
        let resizedImage = try #require(resized.cgImage)
        #expect(abs(CGFloat(naturalImage.width) - artwork.size.width) < 2)
        #expect(CGFloat(resizedImage.width) > artwork.size.width * 2.5)
        #expect(abs(CGFloat(resizedImage.width) / CGFloat(resizedImage.height) - artwork.size.width / artwork.size.height) < 0.05)
    }
}
}
