# ``Mermaid``

Render Mermaid diagrams in SwiftUI or export them as vector PDF and SVG artwork.

## Overview

Swift-Mermaid bundles Mermaid and uses an offscreen WebKit renderer. Display a
diagram with ``MermaidView`` or use ``MermaidRenderer`` to obtain ``Artwork``
for export. Mermaid source is passed without a Markdown code fence.

```swift
import Mermaid

MermaidView("""
graph LR
    Start --> Finish
""")
```

The package supports macOS 14, iOS 17, and visionOS 1 or later. It requires
Swift 6.4 tools, SwiftUI, and WebKit. It doesn't support Linux or tvOS.

## Topics

### Guides

- <doc:GettingStarted>
- <doc:DisplayingDiagrams>
- <doc:RenderingAndExport>
- <doc:ErrorsAndCaching>
- <doc:SecurityAndLimits>

### Mermaid syntax

- <doc:DiagramSyntax>
- <doc:FlowchartSyntax>
- <doc:SequenceSyntax>
- <doc:ClassSyntax>
- <doc:StateSyntax>
- <doc:EntityRelationshipSyntax>
- <doc:GanttSyntax>
- <doc:PieSyntax>
- <doc:MindmapSyntax>

### Display and rendering

- ``MermaidView``
- ``MermaidRenderer``
- ``MermaidTheme``
- ``Artwork``
- ``MermaidError``
