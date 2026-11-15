# Swift-Mermaid

[Mermaid](https://mermaid.js.org) diagrams for SwiftUI, rendered by the bundled Mermaid 12.2.0 to **vector PDF artwork**.

```swift
import Mermaid

MermaidView("""
graph TD
  A[Start] --> B{Ok?}
  B -->|yes| C[Done]
""")

let art = try await MermaidRenderer.shared.render(source, dark: true)
art.pdf   // one-page vector PDF, for export or printing
art.size  // natural size in points
```

## How it works

- **One shared renderer.** One hidden `WKWebView` serves the whole app. It loads Mermaid once from the package's own files, renders one diagram at a time, and returns a PDF of the diagram's natural size. Results are cached by source and theme.
- **The view draws artwork, not a WebView.** `MermaidView` draws that PDF natively:
  - Mermaid's default theme in light mode, its dark theme in dark mode;
  - it scales down to fit, never beyond its natural size;
  - its context menu has **Show Source** and **Copy Source**;
  - VoiceOver reads the source.
- **Rejected diagrams stay visible.** A diagram Mermaid rejects shows its source with Mermaid's reason, never a blank.
- **Tested diagram types:** flowchart, sequence, class, state, ER, Gantt, pie and mindmap.

## Safety

- **The source is data.** It is passed as an argument to the page, never interpolated into script.
- **Mermaid runs with `securityLevel: 'strict'`:** HTML in labels is encoded, and `click` directives do nothing.
- **Nothing is loaded from the network.** Every `http`/`https` load is blocked, and the CSP allows only the package's own script.
- **Source size is limited** to 50,000 characters, and each render to 20 s.

## Requirements

- macOS 14, iOS 17 or visionOS 1, and Swift 6.4 tools.
- Tested on macOS.

## Updating Mermaid

```bash
Scripts/update-upstream.sh 12.2.0
```

- The script checks the npm registry integrity before it replaces anything, and rewrites `Upstream.json`.
- `swift test` then verifies the bundled file against `Upstream.json`.
- Adopt a new version only after it has been public for two weeks.
- Set `SWIFT_MERMAID_SAMPLES=<dir>` while running `swift test` to write sample PDFs for a visual check.

## License

- Apache-2.0 for this package.
- Mermaid is MIT-licensed; see `Licenses/Mermaid-LICENSE` and `NOTICE`.
