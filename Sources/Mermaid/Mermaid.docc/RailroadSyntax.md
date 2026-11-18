# Railroad diagram syntax

Learn the essentials of Mermaid's railroad diagram diagrams.

> Note: Mermaid marks this diagram family or syntax as experimental or beta; its syntax and rendering may change.

## Structure

Start with `railroad-ebnf-beta`, then define named grammar rules using `=`, alternatives with `|`, grouping, repetition in braces, and a terminating semicolon.

```mermaid
railroad-ebnf-beta
    title A simple story identifier
    identifier = letter, { letter | digit | "-" } ;
    letter = "a" | "b" | "c" ;
    digit = "0" | "1" | "2" ;
```

## Considerations

Mermaid also documents other grammar variants. Verify a grammar with its own parser; the visual diagram is not a language implementation.

Swift-Mermaid renders the diagram with its bundled Mermaid engine in strict
security mode; see <doc:SecurityAndLimits>. For the full grammar, options,
and edge cases, see the [Mermaid 12.3.0 railroad diagram reference](https://github.com/mermaid-js/mermaid/blob/mermaid%4012.3.0/packages/mermaid/src/docs/syntax/railroad.md).
