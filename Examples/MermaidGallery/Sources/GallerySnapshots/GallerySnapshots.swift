// SPDX-License-Identifier: Apache-2.0
import AppKit
import Foundation
import GalleryContent
import Mermaid
import SwiftUI

/// Renders the very same SwiftUI cards as the app into PNGs for the README.
@main enum GallerySnapshots {
    @MainActor static func main() async throws {
        let arguments = CommandLine.arguments
        guard arguments.count == 2 else {
            fputs("Usage: GallerySnapshots <output-directory>\n", stderr)
            exit(2)
        }
        let output = URL(filePath: arguments[1], directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)
        let application = NSApplication.shared
        application.setActivationPolicy(.accessory)
        let renderer = MermaidRenderer()
        for sample in DiagramSample.all {
            var renderResult: Result<Artwork, any Error>?
            let card = GalleryCard(sample: sample, source: try sample.source(), renderer: renderer) { result in
                renderResult = result
            }
            let host = NSHostingView(rootView: card)
            let frame = NSRect(x: 0, y: 0, width: 1040, height: 680)
            let window = NSWindow(contentRect: frame, styleMask: [.borderless], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            window.contentView = host
            window.orderFront(nil)
            defer { window.orderOut(nil); window.contentView = nil }

            let deadline = ContinuousClock.now + .seconds(45)
            while renderResult == nil {
                guard ContinuousClock.now < deadline else { throw SnapshotError.timeout(sample.id) }
                try await Task.sleep(for: .milliseconds(30))
            }
            _ = try renderResult!.get()
            // The completion arrives as SwiftUI updates state; allow its next layout pass.
            try await Task.sleep(for: .milliseconds(250))
            host.layoutSubtreeIfNeeded()
            host.displayIfNeeded()
            guard let bitmap = host.bitmapImageRepForCachingDisplay(in: host.bounds) else { throw SnapshotError.image(sample.id) }
            host.cacheDisplay(in: host.bounds, to: bitmap)
            guard let png = bitmap.representation(using: .png, properties: [:]) else { throw SnapshotError.image(sample.id) }
            try png.write(to: output.appending(path: "\(sample.id).png"), options: .atomic)
            print("Captured \(sample.id)")
        }
    }

    enum SnapshotError: Error { case timeout(String), image(String) }
}
