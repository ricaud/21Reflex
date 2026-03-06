//
//  ArcadeTheme.swift
//  21Reflex
//
//  Arcade cabinet theme with neon colors
//

import SwiftUI

/// Retro arcade cabinet theme with neon accents
final class ArcadeTheme: PlayfulTheme {
    override var id: String { "arcade" }
    override var name: String { "Arcade" }
    override var cost: Int { 0 } // Was: 50
    override var description: String { "Retro arcade cabinet with neon glow" }
    override var previewImageName: String? { "preview_arcade" }

    override var backgroundColor: Color { Color(hex: "#0A0A2E") }
    override var primaryButtonColor: Color { Color(hex: "#39FF14") }  // Neon green
    override var secondaryButtonColor: Color { Color(hex: "#FF00FF") }  // Magenta
    override var accentColor: Color { Color(hex: "#00FFFF") }  // Cyan
    override var borderColor: Color { Color(hex: "#00FFFF") }  // Electric blue
    override var textColor: Color { .white }

    override var animationStyle: AnimationStyle { .glitch }
    override var soundEffectStyle: SoundEffectStyle { .arcade }
}
