// SPDX-License-Identifier: Apache-2.0
import Foundation

/// A bundled example and its presentation in the gallery.
public struct DiagramSample: Identifiable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let category: String
    public let subtitle: String
    public let symbol: String
    public let accent: String

    public func source() throws -> String {
        guard let url = Bundle.module.url(forResource: id, withExtension: "mmd", subdirectory: "Diagrams") else {
            throw CocoaError(.fileNoSuchFile)
        }
        return try String(contentsOf: url, encoding: .utf8)
    }

    public static let all: [DiagramSample] = [
        .init(id: "flowchart", title: "From idea to impact", category: "FLOWCHART", subtitle: "Give a good idea somewhere to go.", symbol: "point.3.connected.trianglepath.dotted", accent: "#DB8179"),
        .init(id: "sequence", title: "A little collaboration", category: "SEQUENCE", subtitle: "A conversation, beautifully in sync.", symbol: "arrow.left.arrow.right", accent: "#8886CF"),
        .init(id: "class", title: "Stories and their parts", category: "CLASS", subtitle: "The building blocks behind a good story.", symbol: "square.stack.3d.up", accent: "#A67BC2"),
        .init(id: "state", title: "The creative process", category: "STATE", subtitle: "Every great idea has a journey.", symbol: "arrow.triangle.branch", accent: "#E29479"),
        .init(id: "er", title: "A world of stories", category: "ENTITY RELATIONSHIP", subtitle: "A little universe, thoughtfully connected.", symbol: "circle.grid.cross", accent: "#78AA9A"),
        .init(id: "gantt", title: "A plan comes together", category: "GANTT", subtitle: "From the first spark to launch day.", symbol: "chart.bar.xaxis", accent: "#A183D1"),
        .init(id: "pie", title: "Make room for joy", category: "PIE CHART", subtitle: "A little balance makes all the difference.", symbol: "chart.pie", accent: "#DC9B85"),
        .init(id: "mindmap", title: "A creative life", category: "MINDMAP", subtitle: "Follow a thought and see where it leads.", symbol: "sparkles", accent: "#7E9DD3"),
    ]
}
