# Rendering and exporting artwork

Render a diagram independently of a SwiftUI view and write its vector PDF.

## Render on the main actor

``MermaidRenderer`` is main-actor isolated. Call its asynchronous
``MermaidRenderer/render(_:dark:)`` method from a main-actor context and handle
errors at the call site. This example returns the PDF data; an app can pass it
to its own export or sharing flow.

```swift
import Foundation
import Mermaid

@MainActor
func diagramPDF(source: String) async throws -> Data {
    let artwork = try await MermaidRenderer.shared.render(source, dark: false)
    return artwork.pdf
}
```

``Artwork/pdf`` contains a single-page vector PDF, and ``Artwork/svg`` contains
SVG markup from the same render; ``Artwork/size`` is its
natural size in points. ``Artwork/baseline`` is measured from the top and is
the bottom edge for a Mermaid diagram. The artwork is immutable and can be
passed to another task. Choose the light theme for a white page: the background
is transparent, so dark-theme lines and text can be hard to see on white.

For example, after obtaining the data, an app can write it to a URL chosen by
the user:

```swift
try pdfData.write(to: destinationURL)
```

The app is responsible for selecting the destination and handling file errors.
SVG isn't a general-purpose sanitized HTML fragment, and support for fonts and
SVG features varies by destination. See <doc:SecurityAndLimits> before
embedding it in another context.
