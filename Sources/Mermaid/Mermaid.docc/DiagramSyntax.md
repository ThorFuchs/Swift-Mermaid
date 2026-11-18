# Mermaid diagram syntax

Choose a diagram type and learn how to write source for Swift-Mermaid.

## Start with a diagram

A diagram begins with a type declaration, followed by the statements for that
type. Pass the source itself to ``MermaidView`` or ``MermaidRenderer``; don't
include the Markdown code fences used to display examples in these guides.

```swift
import Mermaid
import SwiftUI

struct ProcessDiagram: View {
    var body: some View {
        MermaidView("""
        flowchart LR
            Idea --> Prototype --> Product
        """)
    }
}
```

The eight guides below cover the types exercised by the package and its example
gallery. Mermaid 12.3.0 supports additional types; this list is not an exclusive
list of everything the bundled engine can parse. The guides explain common
constructs and link to the complete version-pinned upstream documentation for
less common forms, configuration, grammar details, and edge cases.

## Choose a type

| Type | Declaration | Use it for |
| --- | --- | --- |
| <doc:FlowchartSyntax> | `flowchart` or `graph` | Decisions and processes |
| <doc:SequenceSyntax> | `sequenceDiagram` | Messages over time |
| <doc:ClassSyntax> | `classDiagram` | Types and their relationships |
| <doc:StateSyntax> | `stateDiagram-v2` | States and transitions |
| <doc:EntityRelationshipSyntax> | `erDiagram` | Data entities and cardinalities |
| <doc:GanttSyntax> | `gantt` | Tasks on a timeline |
| <doc:PieSyntax> | `pie` | Parts of a whole |
| <doc:MindmapSyntax> | `mindmap` | Hierarchical ideas |

## Shared considerations

A `%%` comment is ignored by Mermaid in diagram types that support comments.
Some types support titles, accessibility metadata, per-diagram configuration,
and styles, but the syntax and coverage differ by type. See the individual
reference before reusing a construct. The engine reports parsing failures through
``MermaidError``; a successful parse alone doesn't guarantee that a diagram
communicates its intended meaning.

Swift-Mermaid runs Mermaid in strict security mode: HTML labels are encoded,
and click directives don't execute. It limits source length and blocks HTTP and
HTTPS loads from the rendering page. See <doc:SecurityAndLimits>. Use
``MermaidView/resizable()`` to opt into enlarging the artwork beyond its natural
size; the view preserves its aspect ratio.

## Mermaid and Pele

Swift-Mermaid bundles **Mermaid 12.3.0**, not Pele. The separate experimental
Swift-MD adapter uses Pele and has its own restrictions. Similar input can have
different parsing, features, layout, and output. The eight shared compatibility
smoke tests don't establish complete cross-renderer equivalence. Consult
[Pele's compatibility documentation](https://pele.run/compatibility) and the
[Swift-MD adapter documentation](https://github.com/ThorFuchs/Swift-MD/blob/feature/restore-compiler-cli/Adapters/SwiftMDBlocks/README.md)
when targeting both renderers.

## Topics

### Syntax guides

- <doc:FlowchartSyntax>
- <doc:SequenceSyntax>
- <doc:ClassSyntax>
- <doc:StateSyntax>
- <doc:EntityRelationshipSyntax>
- <doc:GanttSyntax>
- <doc:PieSyntax>
- <doc:MindmapSyntax>
