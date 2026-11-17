# Swift-Mermaid

[Mermaid](https://mermaid.js.org) diagrams for SwiftUI, rendered by bundled
Mermaid 12.2.0 into **vector PDF artwork**. Rendering uses a local, offscreen
WebKit view; the SwiftUI view draws the resulting PDF natively.

## Installation

Add `https://github.com/ThorFuchs/Swift-Mermaid.git` in Xcode and select the
`Mermaid` library, or add it to a Swift package:

```swift
dependencies: [
    .package(url: "https://github.com/ThorFuchs/Swift-Mermaid.git", from: "0.1.0"),
],
targets: [
    .target(name: "YourTarget", dependencies: [
        .product(name: "Mermaid", package: "Swift-Mermaid"),
    ]),
]
```

## Usage

```swift
import Mermaid

MermaidView("""
graph TD
  A[Start] --> B{Ok?}
  B -->|yes| C[Done]
""")

// In an async, main-actor context:
let artwork = try await MermaidRenderer.shared.render(source, dark: true)
artwork.pdf   // one-page vector PDF, for export or printing
artwork.size  // natural size in points
```

The shared renderer serializes requests and caches successful renders and
parse errors by source and appearance. You can also create a separate
`MermaidRenderer` with its own host and cache. Renderer APIs are main-actor
isolated. `render` throws `MermaidError` for invalid input or engine failures,
and `CancellationError` if the task is cancelled.

`MermaidView` follows the light or dark appearance, scales down to fit without
scaling beyond the natural size, and offers **Show Source** and **Copy Source**
in its context menu. VoiceOver reads the diagram source. A rejected diagram
shows its source and a reason. The tested diagram types are flowchart,
sequence, class, state, ER, Gantt, pie and mindmap; support for other syntax is
inherited from the bundled Mermaid version and is not exhaustively tested.
Artwork has a transparent background. Dark-theme artwork is intended for a
dark background; light lines and text can be difficult to see on a white PDF
viewer or printed page. Choose the light theme when exporting for white paper.

## Requirements

- Swift 6.4 tools and Xcode 27.2 or newer.
- macOS 14, iOS 17 or visionOS 1. Runtime tests have been run on macOS and the iOS simulator; the visionOS
  simulator build has been checked, but runtime tests are pending. Check CI
  for the current result.
- SwiftUI and WebKit are required; Linux and tvOS are not supported.

## Security and limits

Diagram text is passed as data, Mermaid uses strict security mode, and the
local page uses a restrictive content policy and blocks HTTP/HTTPS loads.
Sources are limited to 50,000 Swift characters. Queue and WebKit operations
have separate deadlines, rather than one end-to-end deadline. See the
[security model](Documentation/SECURITY-MODEL.md) for details and limitations;
report vulnerabilities using [SECURITY.md](SECURITY.md).

## Related project

[Swift-MD](https://github.com/ThorFuchs/Swift-MD) offers an experimental,
opt-in server-side adapter for `mermaid` code fences. It runs Pele 1.13.0 in
an explicitly configured local Node process and emits validated SVG into HTML;
Swift-Mermaid uses Mermaid 12.2.0 in WebKit and produces PDF artwork. Eight
basic diagram examples are exercised by both projects, but their supported
syntax, rendering and error behavior can differ. Swift-MD disables links and
images, fixes its Gantt clock and limits source to 16,384 UTF-8 bytes; see its
[adapter documentation](https://github.com/ThorFuchs/Swift-MD/tree/main/Adapters/SwiftMDBlocks)
for its current security and resource limits.

## Development and releases

See [CONTRIBUTING.md](CONTRIBUTING.md), [testing](Documentation/TESTING.md),
[RELEASING.md](RELEASING.md), and [CHANGELOG.md](CHANGELOG.md). To update the
bundled engine, run `Scripts/update-upstream.sh <exact-version>` and follow the
release checklist. The script verifies npm's integrity and reports the upstream
publication date; the maintainer checks the two-week waiting period manually.

## License

Swift-Mermaid is licensed under [Apache-2.0](LICENSE). The bundled Mermaid is
MIT-licensed; see [Licenses/Mermaid-LICENSE](Licenses/Mermaid-LICENSE) and
[NOTICE](NOTICE).
