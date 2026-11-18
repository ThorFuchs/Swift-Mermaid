# Use case diagram syntax

Learn the essentials of Mermaid's use case diagram diagrams.

> Note: Mermaid marks this diagram family or syntax as experimental or beta; its syntax and rendering may change.

## Structure

Start with `usecase-beta`. Declare actors and use cases, group use cases inside a `systemBoundary`, and connect identifiers with relationships.

```mermaid
usecase-beta
    direction LR
    actor Reader("Reader")
    actor Editor("Editor")
    systemBoundary "Story Studio"
      Browse("Browse stories")
      Save("Save a favorite")
      Curate("Curate a collection")
    end
    Reader --> Browse
    Reader --> Save
    Editor --> Curate
```

## Considerations

Use cases describe intended interactions, not access-control guarantees. Refer to the upstream documentation for relationships and layout details.

Swift-Mermaid renders the diagram with its bundled Mermaid engine in strict
security mode; see <doc:SecurityAndLimits>. For the full grammar, options,
and edge cases, see the [Mermaid 12.3.0 use case diagram reference](https://github.com/mermaid-js/mermaid/blob/mermaid%4012.3.0/packages/mermaid/src/docs/syntax/usecase.md).
