# Cynefin diagram syntax

Learn the essentials of Mermaid's cynefin diagram diagrams.

> Note: Mermaid marks this diagram family or syntax as experimental or beta; its syntax and rendering may change.

## Structure

Start with `cynefin-beta`, optionally add a title, then place quoted items under domains such as `clear`, `complicated`, `complex`, `chaotic`, and `confusion`.

```mermaid
cynefin-beta
    title A creative project in motion
    clear
      "Follow the checklist"
    complicated
      "Ask a specialist"
    complex
      "Try a small experiment"
    chaotic
      "Stabilize the situation"
    confusion
      "Learn what is happening"
```

## Considerations

The diagram supports a conversation about context; domain placement is a judgment rather than an automatic classification.

Swift-Mermaid renders the diagram with its bundled Mermaid engine in strict
security mode; see <doc:SecurityAndLimits>. For the full grammar, options,
and edge cases, see the [Mermaid 12.3.0 cynefin diagram reference](https://github.com/mermaid-js/mermaid/blob/mermaid%4012.3.0/packages/mermaid/src/docs/syntax/cynefin.md).
