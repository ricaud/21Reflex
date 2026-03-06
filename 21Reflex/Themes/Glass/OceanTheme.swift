//
//  OceanTheme.swift
//  21Reflex
//
//  Ocean glass theme - deep blue tones
//

import SwiftUI

/// Ocean-inspired glass morphism theme
final class OceanTheme: GlassTheme {
    override var id: String { "ocean" }
    override var name: String { "Ocean" }
    override var cost: Int { 0 } // Was: 200
    override var description: String { "Deep ocean blues with seafoam accents" }
    override var previewImageName: String? { "preview_ocean" }

    override var backgroundColor: Color { Color(hex: "#0A1628") }
    override var accentColor: Color { Color(hex: "#00D4AA") }
    override var secondaryColor: Color { Color(hex: "#4A90D9") }
    override var textColor: Color { Color(hex: "#E0F7FA") }
}
