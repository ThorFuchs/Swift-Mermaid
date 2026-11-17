# Displaying diagrams

Show a diagram in SwiftUI and let it respond to appearance and source changes.

## Use a Mermaid view

``MermaidView`` accepts a source string. Changing the string or the environment's
color scheme triggers a render for the new input. During rendering the view
shows a progress indicator; if rendering fails, it shows the original source
and a short explanation.

```swift
import Mermaid
import SwiftUI

struct EditableDiagram: View {
    @State private var source = "graph LR\n  A --> B"
    @State private var renderer = MermaidRenderer()
    @State private var svg: String?

    var body: some View {
        VStack {
            TextField("Mermaid source", text: $source)
            MermaidView($source, renderer: renderer, theme: .forest)
                .resizable()
                .onRender { result in svg = try? result.get().svg }
                .frame(maxWidth: 600, maxHeight: 400)
        }
    }
}
```

Both `MermaidView(source)` and `MermaidView($source)` follow changes to parent
state. The view only reads a binding; it doesn't edit it. The shared renderer is
used by default; pass a renderer to share a separate host and cache among
multiple views. Keep that renderer alive in parent-owned state.
The optional ``MermaidView/onRender(_:)`` handler receives the current artwork
or error, including cached results, so an app can offer its own SVG or PDF
export. Cancelled renders don't call the handler.

The artwork fits the offered space while preserving its aspect ratio. It doesn't
grow beyond its natural width unless you use ``MermaidView/resizable()``. The view offers **Show Source**
and **Copy Source** in its context menu, and its accessibility value contains
the source. Provide surrounding context or an explanatory description when the
source alone doesn't adequately describe a diagram.

By default, the diagram uses Mermaid's default theme in light appearance and
its dark theme in dark appearance. Pass a fixed ``MermaidTheme`` to override
that choice. The PDF background is transparent; dark artwork is intended for a
dark background.
