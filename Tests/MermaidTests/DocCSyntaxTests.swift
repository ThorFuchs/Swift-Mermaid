// SPDX-License-Identifier: Apache-2.0
#if os(macOS)
import Foundation
@testable import Mermaid
import Testing

extension WebKitTestSuite {
@Suite struct DocCSyntax {
    @MainActor @Test func externalZenUMLPluginIsNotBundled() async {
        do {
            _ = try await MermaidRenderer.shared.render("zenuml\n  Alice->Bob: Hello")
            Issue.record("ZenUML unexpectedly rendered without its external plugin")
        } catch MermaidError.parse {
            // ZenUML is a separate plugin and isn't registered by this package.
        } catch {
            Issue.record("Expected a parse error for the unavailable plugin, got \(error)")
        }
    }

    /// The catalog is present in a source checkout, not in simulator test bundles.
    @MainActor @Test func syntaxGuideExamplesRender() async throws {
        let catalog = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            .appending(path: "Sources/Mermaid/Mermaid.docc")
        let guides = [
            "FlowchartSyntax", "SequenceSyntax", "ClassSyntax", "StateSyntax",
            "EntityRelationshipSyntax", "GanttSyntax", "PieSyntax", "MindmapSyntax",
            "JourneySyntax",
            "QuadrantSyntax",
            "RequirementSyntax",
            "GitGraphSyntax",
            "C4Syntax",
            "TimelineSyntax",
            "SankeySyntax",
            "XYChartSyntax",
            "BlockSyntax",
            "PacketSyntax",
            "KanbanSyntax",
            "ArchitectureSyntax",
            "RadarSyntax",
            "TreemapSyntax",
            "VennSyntax",
            "SwimlaneSyntax",
            "EventModelingSyntax",
            "IshikawaSyntax",
            "WardleySyntax",
            "CynefinSyntax",
            "TreeViewSyntax",
            "AgentFlowSyntax",
            "RailroadSyntax",
            "UseCaseSyntax",
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
