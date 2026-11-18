# Agent flow syntax

Learn the essentials of Mermaid's agent flow diagrams.

> Note: Mermaid marks this diagram family or syntax as experimental or beta; its syntax and rendering may change.

## Structure

Start with `agentflow-beta` and a direction. A `flow` block groups nodes, `@{ shape: ... }` selects a node role, and arrows connect steps.

```mermaid
agentflow-beta TB
    flow guide["Story Guide"]
        draft["Read the draft"]@{ shape: input }
        review["Look for clarity"]@{ shape: task }
        ready["Ready to share?"]@{ shape: decision }
        draft --> review --> ready
    end
```

## Considerations

This is a visualization, not an execution engine. The diagram does not call tools or implement agent behavior.

Swift-Mermaid renders the diagram with its bundled Mermaid engine in strict
security mode; see <doc:SecurityAndLimits>. For the full grammar, options,
and edge cases, see the [Mermaid 12.3.0 agent flow reference](https://github.com/mermaid-js/mermaid/blob/mermaid%4012.3.0/packages/mermaid/src/docs/syntax/agentflow.md).
