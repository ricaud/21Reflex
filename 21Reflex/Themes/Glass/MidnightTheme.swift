//
//  MidnightTheme.swift
//  21Reflex
//
//  Deep midnight purple glass theme
//

import SwiftUI

/// Midnight purple glass morphism theme
final class MidnightTheme: GlassTheme {
    override var id: String { "midnight" }
    override var name: String { "Midnight" }
    override var cost: Int { 0 } // Was: 250
    override var description: String { "Deep midnight purples with violet accents" }
    override var previewImageName: String? { "preview_midnight" }

    override var backgroundColor: Color { Color(hex: "#0D0D1A") }
    override var accentColor: Color { Color(hex: "#8B5CF6") }
    override var secondaryColor: Color { Color(hex: "#6B7280") }
    override var textColor: Color { Color(hex: "#F3E8FF") }
}
