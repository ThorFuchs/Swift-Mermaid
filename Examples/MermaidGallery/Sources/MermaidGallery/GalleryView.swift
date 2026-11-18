// SPDX-License-Identifier: Apache-2.0
import GalleryContent
import Mermaid
import SwiftUI

struct GalleryView: View {
    @State private var selection: String? = DiagramSample.all.first?.id
    @State private var renderer = MermaidRenderer()
    @State private var showSource = false

    private var selected: DiagramSample { DiagramSample.all.first { $0.id == selection } ?? DiagramSample.all[0] }

    var body: some View {
        NavigationSplitView {
            List(DiagramSample.all, selection: $selection) { sample in
                Label(sample.title, systemImage: sample.symbol).tag(sample.id)
            }
            .navigationTitle("Mermaid Gallery")
            .navigationSplitViewColumnWidth(min: 220, ideal: 245)
        } detail: {
            DiagramDetail(sample: selected, renderer: renderer, showSource: $showSource)
        }
        .frame(minWidth: 820, minHeight: 560)
    }
}

private struct DiagramDetail: View {
    let sample: DiagramSample
    let renderer: MermaidRenderer
    @Binding var showSource: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("EXPLORE THE EXAMPLES")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .tracking(1.2)
                    .foregroundStyle(.secondary)
                Spacer()
                Toggle("Show source", isOn: $showSource).toggleStyle(.button)
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 15)

            if let source = try? sample.source() {
                if showSource {
                    ScrollView {
                        Text(source).font(.system(.body, design: .monospaced)).textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .leading).padding(28)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.background, in: RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 20).padding(.bottom, 20)
                } else {
                    GalleryCard(sample: sample, source: source, renderer: renderer)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .shadow(color: .black.opacity(0.06), radius: 20, y: 6)
                        .padding(.horizontal, 20).padding(.bottom, 20)
                }
            } else {
                ContentUnavailableView("Diagram unavailable", systemImage: "exclamationmark.triangle", description: Text("The bundled example could not be loaded."))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color(red: 0.96, green: 0.965, blue: 0.98))
    }
}
