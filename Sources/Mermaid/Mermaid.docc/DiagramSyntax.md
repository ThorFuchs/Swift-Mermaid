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

The guides below cover the diagram examples exercised by the package and its
gallery. Mermaid 12.3.0 may support additional syntax; this list is not a promise
of complete support for every Mermaid feature or plugin. The guides explain common
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
| <doc:JourneySyntax> | `journey` | Experience over time |
| <doc:QuadrantSyntax> | `quadrantChart` | Two-axis comparisons |
| <doc:RequirementSyntax> | `requirementDiagram` | Requirement traceability |
| <doc:GitGraphSyntax> | `gitGraph` | Branch histories |
| <doc:C4Syntax> | `C4Context` | System context |
| <doc:TimelineSyntax> | `timeline` | Ordered milestones |
| <doc:SankeySyntax> | `sankey-beta` | Flows between categories |
| <doc:XYChartSyntax> | `xychart-beta` | Bar and line series |
| <doc:BlockSyntax> | `block-beta` | Structured blocks |
| <doc:PacketSyntax> | `packet-beta` | Bit field layouts |
| <doc:KanbanSyntax> | `kanban` | Tasks by stage |
| <doc:ArchitectureSyntax> | `architecture-beta` | Services and connections |
| <doc:RadarSyntax> | `radar-beta` | Multiaxis comparisons |
| <doc:TreemapSyntax> | `treemap-beta` | Nested quantities |
| <doc:VennSyntax> | `venn-beta` | Overlapping sets |
| <doc:SwimlaneSyntax> | `swimlane-beta` | Cross-team processes |
| <doc:EventModelingSyntax> | `eventmodeling` | Events and views |
| <doc:IshikawaSyntax> | `ishikawa-beta` | Contributing factors |
| <doc:WardleySyntax> | `wardley-beta` | Value chain mapping |
| <doc:CynefinSyntax> | `cynefin-beta` | Situational domains |
| <doc:TreeViewSyntax> | `treeView-beta` | Hierarchical lists |
| <doc:AgentFlowSyntax> | `agentflow-beta` | Agent workflows |
| <doc:RailroadSyntax> | `railroad-ebnf-beta` | Grammar visualization |
| <doc:UseCaseSyntax> | `usecase-beta` | Actors and interactions |

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
- <doc:JourneySyntax>
- <doc:QuadrantSyntax>
- <doc:RequirementSyntax>
- <doc:GitGraphSyntax>
- <doc:C4Syntax>
- <doc:TimelineSyntax>
- <doc:SankeySyntax>
- <doc:XYChartSyntax>
- <doc:BlockSyntax>
- <doc:PacketSyntax>
- <doc:KanbanSyntax>
- <doc:ArchitectureSyntax>
- <doc:RadarSyntax>
- <doc:TreemapSyntax>
- <doc:VennSyntax>
- <doc:SwimlaneSyntax>
- <doc:EventModelingSyntax>
- <doc:IshikawaSyntax>
- <doc:WardleySyntax>
- <doc:CynefinSyntax>
- <doc:TreeViewSyntax>
- <doc:AgentFlowSyntax>
- <doc:RailroadSyntax>
- <doc:UseCaseSyntax>
