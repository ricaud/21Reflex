//
//  GoldTheme.swift
//  21Reflex
//
//  Gold luxury theme with golden accents
//

import SwiftUI

/// Gold luxury theme with rich golden aesthetics
final class GoldTheme: LuxuryTheme {
    override var id: String { "gold" }
    override var name: String { "Gold" }
    override var cost: Int { 0 } // Was: 1000
    override var description: String { "Luxurious gold theme with rich golden accents" }
    override var previewImageName: String? { "preview_gold" }

    override var backgroundColor: Color { Color(hex: "#0A0A0A") }
    override var primaryColor: Color { Color(hex: "#FFD700") }  // Gold
    override var secondaryColor: Color { Color(hex: "#C0C0C0") }  // Silver
    override var accentColor: Color { Color(hex: "#B8860B") }  // Dark goldenrod
    override var textColor: Color { Color(hex: "#FFD700") }

    override var animationStyle: AnimationStyle { .smooth }
    override var soundEffectStyle: SoundEffectStyle { .minimal }
}
