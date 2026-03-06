//
//  SlateTheme.swift
//  21Reflex
//
//  Default glass morphism theme - refined slate gray
//

import SwiftUI

/// Default glass morphism theme - refined, professional slate gray
final class SlateTheme: GlassTheme {
    override var id: String { "slate" }
    override var name: String { "Slate" }
    override var cost: Int { 0 }
    override var description: String { "Refined glass morphism with subtle slate tones" }
    override var previewImageName: String? { "preview_slate" }

    override var backgroundColor: Color { Color(hex: "#1C1C1E") }
    override var accentColor: Color { Color(hex: "#0A84FF") }
    override var secondaryColor: Color { Color(hex: "#8E8E93") }
    override var textColor: Color { .white }
}
