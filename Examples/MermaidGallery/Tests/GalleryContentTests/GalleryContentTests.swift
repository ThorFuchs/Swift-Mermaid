// SPDX-License-Identifier: Apache-2.0
import GalleryContent
import Mermaid
import Testing

@MainActor @Suite(.serialized) struct GalleryContentTests {
    @Test func diagramIdentifiersAreUnique() {
        let identifiers = DiagramSample.all.map(\.id)
        #expect(Set(identifiers).count == identifiers.count)
    }

    @Test(arguments: DiagramSample.all) func everyBundledExampleRenders(_ sample: DiagramSample) async throws {
        let source = try sample.source()
        #expect(!source.isEmpty)
        let artwork = try await MermaidRenderer.shared.render(source)
        #expect(artwork.size.width > 0 && artwork.size.height > 0)
        #expect(artwork.pdf.starts(with: Array("%PDF".utf8)))
        #expect(artwork.svg.contains("<svg"))
    }
}
