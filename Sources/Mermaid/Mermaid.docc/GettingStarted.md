# Getting started

Add Swift-Mermaid to an Apple-platform app and display your first diagram.

## Add the package

In Xcode, add `https://github.com/ThorFuchs/Swift-Mermaid.git` as a package
dependency and select the `Mermaid` library. For a Swift package, add the
following dependency and product to your manifest:

```swift
.package(url: "https://github.com/ThorFuchs/Swift-Mermaid.git", from: "0.1.1")
```

```swift
.product(name: "Mermaid", package: "Swift-Mermaid")
```

The package requires Swift 6.4 tools and supports macOS 14, iOS 17, and
visionOS 1 or later.

## Show a diagram

Import `Mermaid` and `SwiftUI`, then pass Mermaid source to ``MermaidView``:

```swift
import Mermaid
import SwiftUI

struct DiagramScreen: View {
    var body: some View {
        MermaidView("""
        graph TD
            A[Start] --> B{Ready?}
            B -->|Yes| C[Done]
        """)
    }
}
```

Pass only the source, without the surrounding Markdown `mermaid` code fence.
The view renders asynchronously and follows the environment's light or dark
appearance. See <doc:DisplayingDiagrams> for layout and accessibility details.
