// SPDX-License-Identifier: Apache-2.0
import Mermaid
import SwiftUI

/// The same diagram card used in the app and in the gallery images.
public struct GalleryCard: View {
    let sample: DiagramSample
    let source: String
    let renderer: MermaidRenderer
    let onRender: @MainActor (Result<Artwork, any Error>) -> Void

    public init(sample: DiagramSample, source: String, renderer: MermaidRenderer,
                onRender: @escaping @MainActor (Result<Artwork, any Error>) -> Void = { _ in }) {
        self.sample = sample
        self.source = source
        self.renderer = renderer
        self.onRender = onRender
    }

    private var accent: Color { Color(hex: sample.accent) }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                HStack(spacing: 10) {
                    Image(systemName: sample.symbol)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(accent)
                        .frame(width: 30, height: 30)
                        .background(accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 9))
                    Text(sample.category)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .tracking(1.5)
                        .foregroundStyle(accent)
                }
                Spacer()
                HStack(spacing: 5) {
                    Image(systemName: "sparkle")
                    Text("SWIFT MERMAID")
                }
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .tracking(1.2)
                .foregroundStyle(Color(red: 0.62, green: 0.64, blue: 0.71))
            }
            .padding(.bottom, 17)

            Text(sample.title)
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(Color(red: 0.16, green: 0.17, blue: 0.24))
            Text(sample.subtitle)
                .font(.system(size: 14))
                .foregroundStyle(Color(red: 0.48, green: 0.49, blue: 0.56))
                .padding(.top, 6)
                .padding(.bottom, 23)

            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(red: 0.976, green: 0.977, blue: 0.988))
                MermaidView(source, renderer: renderer, theme: .default)
                    .resizable()
                    .onRender(onRender)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(24)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            HStack {
                Text("A LITTLE CLARITY GOES A LONG WAY")
                    .font(.system(size: 9, weight: .semibold, design: .rounded))
                    .tracking(1.05)
                Spacer()
                Text("MADE WITH MERMAID + SWIFTUI")
                    .font(.system(size: 9, weight: .semibold, design: .rounded))
                    .tracking(0.9)
            }
            .foregroundStyle(Color(red: 0.64, green: 0.65, blue: 0.71))
            .padding(.top, 20)
        }
        .padding(32)
        .background(.white)
        .environment(\.colorScheme, .light)
    }
}

private extension Color {
    init(hex: String) {
        let value = UInt64(hex.dropFirst(), radix: 16) ?? 0
        self.init(red: Double((value >> 16) & 255) / 255,
                  green: Double((value >> 8) & 255) / 255,
                  blue: Double(value & 255) / 255)
    }
}
