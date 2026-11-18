# Wardley map syntax

Learn the essentials of Mermaid's wardley map diagrams.

> Note: Mermaid marks this diagram family or syntax as experimental or beta; its syntax and rendering may change.

## Structure

Start with `wardley-beta`. Add a title, an `anchor`, positioned `component` entries, and connections between them. Coordinates locate items on the map.

```mermaid
wardley-beta
    title A creative publishing studio
    anchor Reader [0.92, 0.45]
    component Stories [0.78, 0.40]
    component Curation [0.62, 0.38]
    component Publishing [0.47, 0.66]
    component Storage [0.22, 0.82]
    Reader -> Stories
    Stories -> Curation
    Curation -> Publishing
    Publishing -> Storage
```

## Considerations

Positions are an interpretation of visibility and evolution, not objectively measured values. Consult the reference for evolution, notes, and styling.

Swift-Mermaid renders the diagram with its bundled Mermaid engine in strict
security mode; see <doc:SecurityAndLimits>. For the full grammar, options,
and edge cases, see the [Mermaid 12.3.0 wardley map reference](https://github.com/mermaid-js/mermaid/blob/mermaid%4012.3.0/packages/mermaid/src/docs/syntax/wardley.md).
