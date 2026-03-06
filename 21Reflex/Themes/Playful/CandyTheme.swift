//
//  CandyTheme.swift
//  21Reflex
//
//  Sweet candy theme with pastel pinks
//

import SwiftUI

/// Sweet candy theme with pastel pinks and playful colors
final class CandyTheme: PlayfulTheme {
    override var id: String { "candy" }
    override var name: String { "Candy" }
    override var cost: Int { 0 } // Was: 30
    override var description: String { "Sweet candy colors with playful pink tones" }
    override var previewImageName: String? { "preview_candy" }

    override var backgroundColor: Color { Color(hex: "#FFD1DC") }
    override var primaryButtonColor: Color { Color(hex: "#FF69B4") }
    override var secondaryButtonColor: Color { Color(hex: "#FFF0F5") }
    override var accentColor: Color { Color(hex: "#00CED1") }
    override var borderColor: Color { Color(hex: "#C71585") }
    override var textColor: Color { Color(hex: "#8B008B") }

    override var animationStyle: AnimationStyle { .bouncy }
    override var hapticStyle: HapticStyle { .subtle }
}
