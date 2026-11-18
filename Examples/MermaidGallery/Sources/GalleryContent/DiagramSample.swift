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
        .init(id: "journey", title: "The path to a first story", category: "USER JOURNEY", subtitle: "A small experience, from curiosity to delight.", symbol: "figure.walk", accent: "#B987C5"),
        .init(id: "quadrant", title: "Choose what matters", category: "QUADRANT", subtitle: "Find the sweet spot between effort and impact.", symbol: "square.grid.2x2", accent: "#DB8179"),
        .init(id: "requirement", title: "From promise to proof", category: "REQUIREMENT", subtitle: "Connect a product need with its verification.", symbol: "checkmark.seal", accent: "#78AA9A"),
        .init(id: "gitgraph", title: "A story in branches", category: "GIT GRAPH", subtitle: "Follow an idea from its first commit to release.", symbol: "point.topleft.down.to.point.bottomright.curvepath", accent: "#A183D1"),
        .init(id: "c4", title: "A little story studio", category: "C4 CONTEXT", subtitle: "See how people and systems work together.", symbol: "square.3.layers.3d", accent: "#7298CF"),
        .init(id: "timeline", title: "A year of little milestones", category: "TIMELINE", subtitle: "Celebrate the moments that make a project.", symbol: "calendar", accent: "#D59679"),
        .init(id: "sankey", title: "Where creative energy goes", category: "SANKEY", subtitle: "Follow ideas as they flow into finished work.", symbol: "arrow.triangle.branch", accent: "#78AA9A"),
        .init(id: "xychart", title: "A little progress every day", category: "XY CHART", subtitle: "Watch an idea grow, one week at a time.", symbol: "chart.xyaxis.line", accent: "#8886CF"),
        .init(id: "block", title: "A thoughtful little system", category: "BLOCK DIAGRAM", subtitle: "See how simple pieces fit together.", symbol: "square.grid.3x3", accent: "#A183D1"),
        .init(id: "packet", title: "A message in pieces", category: "PACKET", subtitle: "Give a binary format a clear visual shape.", symbol: "rectangle.split.3x1", accent: "#7E9DD3"),
        .init(id: "kanban", title: "A gentle plan for making", category: "KANBAN", subtitle: "Keep the next small steps in view.", symbol: "rectangle.split.3x1", accent: "#D59679"),
        .init(id: "architecture", title: "A place for stories", category: "ARCHITECTURE", subtitle: "Connect the services behind a creative space.", symbol: "server.rack", accent: "#78AA9A"),
        .init(id: "radar", title: "A balanced creative practice", category: "RADAR", subtitle: "Compare the qualities that shape a project.", symbol: "chart.pie", accent: "#DB8179"),
        .init(id: "treemap", title: "A mosaic of creative time", category: "TREEMAP", subtitle: "See the pieces that make up a week.", symbol: "square.grid.2x2", accent: "#A183D1"),
        .init(id: "venn", title: "Where good ideas meet", category: "VENN", subtitle: "Find a shared space for people, craft, and play.", symbol: "circle.lefthalf.filled", accent: "#DB8179"),
        .init(id: "swimlane", title: "A story moves through the studio", category: "SWIMLANE", subtitle: "Follow the handoffs behind a shared project.", symbol: "rectangle.split.3x1", accent: "#7E9DD3"),
        .init(id: "eventmodeling", title: "A story finds its reader", category: "EVENT MODELING", subtitle: "Trace actions, events, and the resulting view.", symbol: "rectangle.stack", accent: "#78AA9A"),
        .init(id: "ishikawa", title: "Make space for focus", category: "ISHIKAWA", subtitle: "Explore the many roots of one challenge.", symbol: "arrow.triangle.branch", accent: "#D59679"),
        .init(id: "wardley", title: "A story studio value chain", category: "WARDLEY MAP", subtitle: "Map the pieces of an experience as they evolve.", symbol: "map", accent: "#7E9DD3"),
        .init(id: "cynefin", title: "Choose how to respond", category: "CYNEFIN", subtitle: "Match a response to the situation at hand.", symbol: "square.grid.2x2", accent: "#A183D1"),
        .init(id: "treeview", title: "A little library of stories", category: "TREE VIEW", subtitle: "Give a collection an easy-to-scan shape.", symbol: "list.bullet.indent", accent: "#78AA9A"),
        .init(id: "agentflow", title: "A thoughtful review", category: "AGENT FLOW", subtitle: "Make the steps of an assistant visible.", symbol: "sparkles", accent: "#8886CF"),
        .init(id: "railroad", title: "The shape of a story title", category: "RAILROAD", subtitle: "Turn a small grammar into a readable path.", symbol: "point.3.connected.trianglepath.dotted", accent: "#D59679"),
        .init(id: "usecase", title: "A reader meets a story", category: "USE CASE", subtitle: "Describe what people can do with a system.", symbol: "person.2", accent: "#7E9DD3"),
    ]
}
