//
//  ForestTheme.swift
//  21Reflex
//
//  Forest green glass theme
//

import SwiftUI

/// Forest green glass morphism theme
final class ForestTheme: GlassTheme {
    override var id: String { "forest" }
    override var name: String { "Forest" }
    override var cost: Int { 0 } // Was: 150
    override var description: String { "Deep forest greens with emerald accents" }
    override var previewImageName: String? { "preview_forest" }

    override var backgroundColor: Color { Color(hex: "#0F1F15") }
    override var accentColor: Color { Color(hex: "#22C55E") }
    override var secondaryColor: Color { Color(hex: "#4ADE80") }
    override var textColor: Color { Color(hex: "#DCFCE7") }
}
