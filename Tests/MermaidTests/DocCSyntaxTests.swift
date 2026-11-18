// SPDX-License-Identifier: Apache-2.0
#if os(macOS)
import Foundation
@testable import Mermaid
import Testing

extension WebKitTestSuite {
@Suite struct DocCSyntax {
    /// The catalog is present in a source checkout, not in simulator test bundles.
    @MainActor @Test func syntaxGuideExamplesRender() async throws {
        let catalog = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            .appending(path: "Sources/Mermaid/Mermaid.docc")
        let guides = [
            "FlowchartSyntax", "SequenceSyntax", "ClassSyntax", "StateSyntax",
            "EntityRelationshipSyntax", "GanttSyntax", "PieSyntax", "MindmapSyntax",
        ]
        let expression = try NSRegularExpression(pattern: "(?ms)^```mermaid\\n(.*?)^```[ \\t]*$")
        let renderer = MermaidRenderer.shared
        for guide in guides {
            let text = try String(contentsOf: catalog.appending(path: "\(guide).md"), encoding: .utf8)
            let textRange = NSRange(text.startIndex..., in: text)
            let matches = expression.matches(in: text, range: textRange)
            #expect(!matches.isEmpty, "\(guide) must contain a complete Mermaid example")
            for (index, match) in matches.enumerated() {
                let range = try #require(Range(match.range(at: 1), in: text))
                do {
                    let artwork = try await renderer.render(String(text[range]))
                    #expect(artwork.page != nil, "\(guide), example \(index + 1)")
                    #expect(artwork.svg.contains("<svg"), "\(guide), example \(index + 1)")
                } catch {
                    Issue.record("\(guide), example \(index + 1) failed to render: \(error)")
                }
            }
        }
    }
}
}
#endif
