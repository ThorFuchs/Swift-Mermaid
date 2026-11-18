# Tree view syntax

Learn the essentials of Mermaid's tree view diagrams.

> Note: Mermaid marks this diagram family or syntax as experimental or beta; its syntax and rendering may change.

## Structure

Start with `treeView-beta` and use indentation to organize nodes into a tree. Each deeper level belongs under its preceding parent.

```mermaid
treeView-beta
Story Studio/
  Stories/
    A Quiet Morning.md
    The Long Way Home.md
  Illustrations/
    sunrise.png
    constellations.png
  README.md
```

## Considerations

A tree view visualizes text; it does not read or validate a real filesystem. The upstream reference also describes connectors, icons, and styling.

Swift-Mermaid renders the diagram with its bundled Mermaid engine in strict
security mode; see <doc:SecurityAndLimits>. For the full grammar, options,
and edge cases, see the [Mermaid 12.3.0 tree view reference](https://github.com/mermaid-js/mermaid/blob/mermaid%4012.3.0/packages/mermaid/src/docs/syntax/treeView.md).
