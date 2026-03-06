//
//  SketchbookTheme.swift
//  21Reflex
//
//  Sketchbook theme - pencil drawings on notebook paper
//

import SwiftUI

/// Sketchbook theme with pencil drawings on lined paper
final class SketchbookTheme: HandDrawnTheme {
    override var id: String { "sketchbook" }
    override var name: String { "Sketchbook" }
    override var cost: Int { 0 } // Was: 150
    override var description: String { "Hand-drawn cards on notebook paper" }
    override var previewImageName: String? { "preview_sketchbook" }

    override var backgroundColor: Color { Color(hex: "#F8F6F0") }
    override var paperLineColor: Color { Color(hex: "#A4C2F4") }
    override var marginLineColor: Color { Color(hex: "#FF6B6B") }
    override var pencilColor: Color { Color(hex: "#2C2C2C") }
    override var accentColor: Color { Color(hex: "#4A90D9") }

    override var roughness: CGFloat { 1.5 }

    override var animationStyle: AnimationStyle { .wobbly }
    override var hapticStyle: HapticStyle { .subtle }
    override var soundEffectStyle: SoundEffectStyle { .paper }
}
