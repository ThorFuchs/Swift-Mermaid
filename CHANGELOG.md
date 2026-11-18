# Changelog

## 0.1.3 (2026-11-18)

- Add DocC syntax guides for flowcharts, sequence, class, state, entity relationship, Gantt, pie, and mindmap diagrams, with links to Mermaid 12.3.0's complete documentation.
- Render the guides' Mermaid examples in the macOS test suite and type-check the Swift introduction example during DocC validation.
- Clarify the relationship between Swift-Mermaid and the separate Pele renderer. Mermaid remains at version 12.3.0.

## 0.1.2 (2026-11-18)

- Add a macOS SwiftUI gallery app with eight bundled, editable Mermaid examples and a shared renderer.
- Add a visual README gallery and a tool to regenerate its images from the example views.
- Test every bundled gallery example in CI. Mermaid remains at version 12.3.0.

## 0.1.1 (2026-11-18)

- Bound WebKit operations and queue waits, recover after timeouts, and preserve task cancellation.
- Prevent stale SwiftUI rendering results after source or appearance changes.
- Add public repository documentation, CI, and renderer regression tests.
- Allow more time for Mermaid rendering on slower systems and cover strict security and shared Swift-MD diagram examples.
- Update bundled Mermaid to 12.3.0 (npm `sha512-4113TdXeLAsMruJ79OpFL5O8+LTFXhQqZ260rF3tgUmiNAtRm4Uume04I+65PRN6yZ69J4f8rVYWW8zRk65UYw==`), including its DOMPurify update.
- Add a DocC catalog, complete public API documentation, and automated documentation checks.
- Add binding input, injectable renderers, built-in themes, opt-in upscaling, render callbacks, and SVG artwork while retaining the existing API.

## 0.1.0 (2026-11-16)

- First version: `MermaidRenderer` renders to vector PDF artwork in one shared offscreen WKWebView; `MermaidView` shows it in SwiftUI with light and dark, scale-to-fit, Show/Copy Source and VoiceOver.
- Bundles mermaid 12.2.0 (npm `sha512-w7nr/SFrLO7BaVTs3dQTvYSV6nYSBj0Yy9DjBhsIJtAcHqRzXSq4Pg32ujHZ/AdWsAMNEvvhbm5dt9E2tOiHzw==`).
