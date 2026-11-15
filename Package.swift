// swift-tools-version: 6.4
// SPDX-License-Identifier: Apache-2.0
import PackageDescription

let package = Package(
    name: "Swift-Mermaid",
    platforms: [.macOS(.v14), .iOS(.v17), .visionOS(.v1)],
    products: [
        .library(name: "Mermaid", targets: ["Mermaid"]),
    ],
    targets: [
        .target(name: "Mermaid", resources: [.copy("Resources/render.html"), .copy("Resources/render.js"), .copy("Resources/mermaid")]),
        .testTarget(name: "MermaidTests", dependencies: ["Mermaid"]),
    ],
    swiftLanguageModes: [.v6]
)
