// SPDX-License-Identifier: Apache-2.0
import GalleryContent
import Mermaid
import SwiftUI

@main struct MermaidGalleryApp: App {
    var body: some Scene {
        WindowGroup("Mermaid Gallery") {
            GalleryView()
        }
        .defaultSize(width: 1180, height: 780)
    }
}
