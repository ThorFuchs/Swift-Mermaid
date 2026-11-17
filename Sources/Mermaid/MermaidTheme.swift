// SPDX-License-Identifier: Apache-2.0

/// A built-in Mermaid color theme.
///
/// Pass a theme to ``MermaidRenderer/render(_:theme:)`` or to ``MermaidView``.
/// If a view has no explicit theme, it chooses ``default`` or ``dark`` from
/// the SwiftUI color scheme. Mermaid source can also contain its own supported
/// configuration, subject to Mermaid's strict security settings.
public enum MermaidTheme: Hashable, Sendable {
    /// Mermaid's default light theme.
    case `default`
    /// Mermaid's dark theme, intended for a dark background.
    case dark
    /// Mermaid's green forest theme.
    case forest
    /// Mermaid's grayscale neutral theme.
    case neutral

    var engineName: String {
        switch self {
        case .default: "default"
        case .dark: "dark"
        case .forest: "forest"
        case .neutral: "neutral"
        }
    }
}
