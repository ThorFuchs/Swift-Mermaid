# Swimlane diagram syntax

Learn the essentials of Mermaid's swimlane diagram diagrams.

> Note: Mermaid marks this diagram family or syntax as experimental or beta; its syntax and rendering may change.

## Structure

Start with `swimlane-beta` and a direction. Define lanes using `subgraph` blocks, then connect node IDs with arrows.

```mermaid
swimlane-beta LR
    subgraph Writer
      Idea[Find an idea]
      Draft[Write a draft]
    end
    subgraph Editor
      Review[Review the story]
      Refine[Refine together]
    end
    subgraph Reader
      Discover[Discover the story]
    end
    Idea --> Draft --> Review --> Refine --> Discover
```

## Considerations

Lanes describe responsibilities or phases; connections can cross lane boundaries. This syntax is distinct from ordinary flowchart subgraphs.

Swift-Mermaid renders the diagram with its bundled Mermaid engine in strict
security mode; see <doc:SecurityAndLimits>. For the full grammar, options,
and edge cases, see the [Mermaid 12.3.0 swimlane diagram reference](https://github.com/mermaid-js/mermaid/blob/mermaid%4012.3.0/packages/mermaid/src/docs/syntax/swimlanes.md).
