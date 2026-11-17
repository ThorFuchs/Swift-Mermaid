# Errors, cancellation, and caching

Handle failures and understand how renderers share work.

## Handle errors

``MermaidRenderer/render(_:dark:)`` throws ``MermaidError`` when source is too
long, Mermaid rejects it, or the engine fails. Cancellation is reported as
`CancellationError`. Error messages can change and shouldn't be treated as
stable error codes.

```swift
import Mermaid

@MainActor
func renderDiagram(_ source: String) async {
    do {
        let artwork = try await MermaidRenderer.shared.render(source)
        // Use artwork.pdf or artwork.size here.
        _ = artwork
    } catch is CancellationError {
        // The caller no longer needs the result.
    } catch MermaidError.tooLong {
        // Ask for a shorter source.
    } catch MermaidError.parse(let message) {
        // Present the engine's explanation.
        _ = message
    } catch {
        // Handle an engine or other unexpected failure.
    }
}
```

An already running WebKit operation may take until it finishes or its deadline
before cancellation is observed. Waiting for the renderer is also bounded; see
<doc:SecurityAndLimits>.

## Use the cache

Each renderer caches successful artwork and parse errors by exact source and
light or dark theme. The cache may evict entries, and engine failures aren't
cached. ``MermaidRenderer/cached(_:dark:)`` inspects it without starting work;
`nil` means no entry is currently available. Calling `render` directly is
usually sufficient because it checks the cache first.

``MermaidRenderer/shared`` is used by ``MermaidView``. Creating a new renderer
provides a separate WebKit host and cache. Requests to one renderer are
serialized, while distinct instances don't share a cache or queue.
