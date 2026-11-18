// swift-tools-version: 6.4
// SPDX-License-Identifier: Apache-2.0
import PackageDescription

let package = Package(
    name: "MermaidGallery",
    platforms: [.macOS(.v14)],
    dependencies: [.package(path: "../..")],
    targets: [
        .target(name: "GalleryContent", dependencies: [.product(name: "Mermaid", package: "Swift-Mermaid")], resources: [.copy("Diagrams")]),
        .executableTarget(name: "MermaidGallery", dependencies: [
            "GalleryContent", .product(name: "Mermaid", package: "Swift-Mermaid"),
        ]),
        .executableTarget(name: "GallerySnapshots", dependencies: ["GalleryContent", .product(name: "Mermaid", package: "Swift-Mermaid")]),
        .testTarget(name: "GalleryContentTests", dependencies: [
            "GalleryContent", .product(name: "Mermaid", package: "Swift-Mermaid"),
        ]),
    ],
    swiftLanguageModes: [.v6]
)
