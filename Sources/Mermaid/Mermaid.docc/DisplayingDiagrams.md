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

    var body: some View {
        VStack {
            TextField("Mermaid source", text: $source)
            MermaidView(source)
        }
    }
}
```

The artwork scales down to fit the offered width while preserving its aspect
ratio. It doesn't grow beyond its natural width. The view offers **Show Source**
and **Copy Source** in its context menu, and its accessibility value contains
the source. Provide surrounding context or an explanatory description when the
source alone doesn't adequately describe a diagram.

The diagram uses Mermaid's default theme in light appearance and its dark
theme in dark appearance. The PDF background is transparent; dark artwork is
intended for a dark background.
