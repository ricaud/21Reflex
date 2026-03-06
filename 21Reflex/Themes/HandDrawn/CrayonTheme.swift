//
//  CrayonTheme.swift
//  21Reflex
//
//  Bold crayon strokes on construction paper
//

import SwiftUI

/// Bold crayon theme with bright colors
final class CrayonTheme: HandDrawnTheme {
    override var id: String { "crayon" }
    override var name: String { "Crayon" }
    override var cost: Int { 0 } // Was: 200
    override var description: String { "Bold crayon strokes on bright paper" }
    override var previewImageName: String? { "preview_crayon" }

    override var backgroundColor: Color { Color(hex: "#2E8B57") }  // Construction paper green
    override var paperLineColor: Color { Color(hex: "#228B22").opacity(0.3) }
    override var marginLineColor: Color { Color(hex: "#FFD700") }
    override var pencilColor: Color { Color(hex: "#F0F0F0") }
    override var accentColor: Color { Color(hex: "#FF6347") }  // Tomato red

    override var roughness: CGFloat { 2.5 }  // Rougher lines for crayon effect

    override var animationStyle: AnimationStyle { .bouncy }
}
