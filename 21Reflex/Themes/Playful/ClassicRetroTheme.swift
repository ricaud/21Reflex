//
//  ClassicRetroTheme.swift
//  21Reflex
//
//  Classic retro theme - cream background with thick dark borders
//

import SwiftUI

/// Classic retro theme with cream background and bold borders
final class ClassicRetroTheme: PlayfulTheme {
    override var id: String { "classic_retro" }
    override var name: String { "Classic Retro" }
    override var cost: Int { 0 }
    override var description: String { "Classic cream background with bold retro styling" }
    override var previewImageName: String? { "preview_classic_retro" }

    override var backgroundColor: Color { Color(hex: "#F5F5DC") }
    override var primaryButtonColor: Color { Color(hex: "#90EE90") }  // Light green for visibility
    override var secondaryButtonColor: Color { Color(hex: "#FAF9F6") }
    override var accentColor: Color { Color(hex: "#FF6B6B") }
    override var borderColor: Color { Color(hex: "#3D3D3D") }
    override var textColor: Color { Color(hex: "#3D3D3D") }
}
