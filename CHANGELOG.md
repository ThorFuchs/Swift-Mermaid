# Changelog

## 0.1.1 (unreleased)

- Bound WebKit operations and queue waits, recover after timeouts, and preserve task cancellation.
- Prevent stale SwiftUI rendering results after source or appearance changes.
- Add public repository documentation, CI, and renderer regression tests.
- Allow more time for Mermaid rendering on slower systems and cover strict security and shared Swift-MD diagram examples.

## 0.1.0 (2026-11-16)

- First version: `MermaidRenderer` renders to vector PDF artwork in one shared offscreen WKWebView; `MermaidView` shows it in SwiftUI with light and dark, scale-to-fit, Show/Copy Source and VoiceOver.
- Bundles mermaid 12.2.0 (npm `sha512-w7nr/SFrLO7BaVTs3dQTvYSV6nYSBj0Yy9DjBhsIJtAcHqRzXSq4Pg32ujHZ/AdWsAMNEvvhbm5dt9E2tOiHzw==`).
