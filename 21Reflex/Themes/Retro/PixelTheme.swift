//
//  PixelTheme.swift
//  21Reflex
//
//  8-bit pixel art theme
//

import SwiftUI

/// 8-bit pixel art theme with sharp edges and bright colors
final class PixelTheme: RetroTheme {
    override var id: String { "pixel" }
    override var name: String { "Pixel" }
    override var cost: Int { 0 } // Was: 100
    override var description: String { "8-bit pixel art with sharp edges" }
    override var previewImageName: String? { "preview_pixel" }

    override var backgroundColor: Color { Color(hex: "#1a1a2e") }
    override var primaryColor: Color { Color(hex: "#4ade80") }  // Bright green
    override var secondaryColor: Color { Color(hex: "#f472b6") }  // Pink
    override var accentColor: Color { Color(hex: "#22d3ee") }  // Cyan
    override var borderColor: Color { .white }
    override var textColor: Color { .white }

    override var pixelSize: CGFloat { 4 }

    override var animationStyle: AnimationStyle { .instant }
    override var soundEffectStyle: SoundEffectStyle { .arcade }
}
