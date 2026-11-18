# Mermaid Gallery

A small macOS SwiftUI app for exploring 32 bundled Mermaid diagrams. Select
an example in the sidebar and choose **Show source** to see and copy its Mermaid
text. The cards use `MermaidView` and share one `MermaidRenderer`.

From the repository root, build and open the app:

```sh
./script/build_and_run.sh
```

The app requires macOS 14 or later and the Swift/Xcode version listed in the
[main README](../../README.md#requirements). It is a separate example package;
the Swift-Mermaid library also supports iOS and visionOS.

The editable `.mmd` files are in
[`Sources/GalleryContent/Diagrams`](Sources/GalleryContent/Diagrams). To check
that every bundled example renders to PDF and SVG, run:

```sh
swift test --package-path Examples/MermaidGallery
```

To regenerate the README images on macOS, run the following from the repository
root. It renders the same SwiftUI cards used by the app and writes PNGs to the
gallery directory; temporary windows may appear while it runs.

```sh
swift run --package-path Examples/MermaidGallery GallerySnapshots Documentation/Images/Gallery
```
