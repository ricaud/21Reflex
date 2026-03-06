//
//  ComicTheme.swift
//  21Reflex
//
//  Comic book theme with bold colors and heavy outlines
//

import SwiftUI

/// Comic book theme with bold primary colors
final class ComicTheme: PlayfulTheme {
    override var id: String { "comic" }
    override var name: String { "Comic" }
    override var cost: Int { 0 } // Was: 75
    override var description: String { "Bold comic book colors with heavy outlines" }
    override var previewImageName: String? { "preview_comic" }

    override var backgroundColor: Color { Color(hex: "#FFE135") }  // Bright yellow
    override var primaryButtonColor: Color { Color(hex: "#FF0000") }  // Red
    override var secondaryButtonColor: Color { Color(hex: "#0066CC") }  // Blue
    override var accentColor: Color { Color(hex: "#FF6600") }  // Orange
    override var borderColor: Color { .black }
    override var textColor: Color { .black }

    override var borderWidth: CGFloat { 5 }
    override var cornerRadius: CGFloat { 4 }  // Sharper corners for comic look
    override var shadowOffset: CGFloat { 5 }

    override var animationStyle: AnimationStyle { .elastic }
}
