import CoreGraphics
import Foundation
@testable import Mermaid
import PDFKit
import Testing

@MainActor @Suite(.serialized) struct MermaidRendering {
    let renderer = MermaidRenderer.shared

    nonisolated static let diagrams = [
        "graph TD\n  A[Start] --> B{Ok?}\n  B -->|yes| C[Done]\n  B -->|no| A",
        "sequenceDiagram\n  participant U as User\n  participant A as Assistant\n  U->>A: Question\n  A-->>U: Answer",
        "classDiagram\n  class Library {\n    +String id\n    +open()\n  }\n  Library <|-- Corpus",
        "stateDiagram-v2\n  [*] --> Idle\n  Idle --> Building: update\n  Building --> Idle: activate",
        "erDiagram\n  CONVERSATION ||--o{ SECTION : has\n  SECTION ||--|{ MESSAGE : holds",
        "gantt\n  dateFormat YYYY-MM-DD\n  section RC1\n  Phase A :a1, 2026-11-14, 2d\n  M6.1 :after a1, 5d",
        "pie title Work modes\n  \"Research\" : 845\n  \"Build\" : 443",
        "mindmap\n  root((Chat Library))\n    Reader\n    Export\n    Search",
    ]

    @Test(arguments: diagrams) func rendersCommonDiagramTypes(_ source: String) async throws {
        let art = try await renderer.render(source)
        #expect(art.pdf.starts(with: Array("%PDF".utf8)))
        #expect(art.size.width > 40 && art.size.height > 20)
        #expect(art.page != nil)
    }

    @Test func invalidSourceIsAParseError() async {
        await #expect(throws: MermaidError.self) { try await renderer.render("graph TD\n  A -->") }
        do { _ = try await renderer.render("this is not mermaid") } catch MermaidError.parse(let message) {
            #expect(!message.isEmpty)
        } catch { Issue.record("unexpected \(error)") }
    }

    @Test func strictSecurityLeavesNoLinksOrScripts() async throws {
        let source = """
        graph TD
          A["<img src=x onerror=alert(1)> <b>bold</b>"] --> B[Next]
          click A "https://example.com" "tooltip"
          click B call alert()
        """
        let art = try await renderer.render(source)
        let page = try #require(PDFDocument(data: art.pdf)?.page(at: 0))
        #expect(page.annotations.isEmpty, "strict mode: no link annotations")
    }

    @Test(arguments: [
        "flowchart LR\nA-->B",
        "sequenceDiagram\nAlice->>Bob: Hello",
        "classDiagram\nA <|-- B",
        "stateDiagram-v2\n[*] --> Active",
        "erDiagram\nUSER ||--o{ POST : writes",
        "gantt\n title A\n dateFormat YYYY-MM-DD\n section X\n Task :a, 2020-01-01, 2d",
        "pie\n \"A\" : 2\n \"B\" : 3",
        "mindmap\n  root((Root))\n    Child",
    ]) func rendersSwiftMDCompatibilitySamples(_ source: String) async throws {
        // Shared syntax examples, not a guarantee that Mermaid and Pele render identically.
        let artwork = try await renderer.render(source)
        #expect(artwork.page != nil && artwork.size.width > 0 && artwork.size.height > 0)
    }

    @Test func darkAndLightAreSeparateRenders() async throws {
        let light = try await renderer.render(Self.diagrams[0], dark: false)
        let again = try await renderer.render(Self.diagrams[0], dark: false)
        let dark = try await renderer.render(Self.diagrams[0], dark: true)
        #expect(light === again)
        #expect(light !== dark)
    }

    @Test func overlongSourceIsRejected() async {
        await #expect(throws: MermaidError.tooLong) { try await renderer.render(String(repeating: "a", count: MermaidRenderer.maximumSourceLength + 1)) }
    }

    @Test func cancellationIsPreservedEvenForCachedArtwork() async throws {
        let renderer = MermaidRenderer()
        let source = Self.diagrams[0]
        _ = try await renderer.render(source)
        let task = Task { @MainActor in try await renderer.render(source) }
        task.cancel()
        await #expect(throws: CancellationError.self) { try await task.value }
    }

    @Test func concurrentRequestsRenderDistinctDiagrams() async throws {
        let renderer = MermaidRenderer()
        async let first = renderer.render(Self.diagrams[0])
        async let second = renderer.render(Self.diagrams[1])
        let (a, b) = try await (first, second)
        #expect(a.page != nil && b.page != nil)
        #expect(a !== b)
    }

    @Test func wideDiagramKeepsItsNaturalSize() async throws {
        let nodes = (0..<30).map { "  N\($0)[Node \($0)] --> N\($0 + 1)[Node \($0 + 1)]" }.joined(separator: "\n")
        let art = try await renderer.render("graph LR\n" + nodes)
        #expect(art.size.width > 1500, "LR chain of 31 nodes is wider than the initial view")
        let box = try #require(art.page?.getBoxRect(.mediaBox))
        #expect(abs(box.width - art.size.width) < 2, "the PDF covers the whole diagram")
    }
}

/// Writes sample artwork for visual review when `SWIFT_MERMAID_SAMPLES` names a directory.
@MainActor @Suite struct MermaidSamples {
    @Test(.enabled(if: ProcessInfo.processInfo.environment["SWIFT_MERMAID_SAMPLES"] != nil))
    func writeSamples() async throws {
        let dir = URL(filePath: ProcessInfo.processInfo.environment["SWIFT_MERMAID_SAMPLES"]!)
        for (i, source) in MermaidRendering.diagrams.prefix(4).enumerated() {
            for dark in [false, true] {
                try await MermaidRenderer.shared.render(source, dark: dark).pdf.write(to: dir.appending(path: "mermaid-\(i)-\(dark ? "dark" : "light").pdf"))
            }
        }
    }
}
