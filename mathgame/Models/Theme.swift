//
//  Theme.swift
//  mathgame
//
//  Visual theme definitions for the game
//

import SwiftUI
import SwiftData

import UIKit

@Model
class Theme {
    var id: String
    var name: String
    var cost: Int
    var isUnlocked: Bool
    var isEquipped: Bool
    var supportsDarkMode: Bool

    // Light mode colors stored as hex strings
    var bgColorHex: String
    var textColorHex: String
    var accentColorHex: String
    var buttonColorHex: String
    var buttonTextColorHex: String
    var correctColorHex: String
    var wrongColorHex: String
    var borderColorHex: String

    // Dark mode colors stored as hex strings (optional)
    var bgColorDarkHex: String?
    var textColorDarkHex: String?
    var accentColorDarkHex: String?
    var buttonColorDarkHex: String?
    var buttonTextColorDarkHex: String?
    var correctColorDarkHex: String?
    var wrongColorDarkHex: String?
    var borderColorDarkHex: String?

    init(id: String, name: String, cost: Int, isUnlocked: Bool = false, isEquipped: Bool = false,
         supportsDarkMode: Bool = false,
         bgColor: Color, textColor: Color, accentColor: Color, buttonColor: Color,
         buttonTextColor: Color, correctColor: Color, wrongColor: Color, borderColor: Color,
         bgColorDark: Color? = nil, textColorDark: Color? = nil, accentColorDark: Color? = nil,
         buttonColorDark: Color? = nil, buttonTextColorDark: Color? = nil, correctColorDark: Color? = nil,
         wrongColorDark: Color? = nil, borderColorDark: Color? = nil) {
        self.id = id
        self.name = name
        self.cost = cost
        self.isUnlocked = isUnlocked
        self.isEquipped = isEquipped
        self.supportsDarkMode = supportsDarkMode
        self.bgColorHex = bgColor.toHex()
        self.textColorHex = textColor.toHex()
        self.accentColorHex = accentColor.toHex()
        self.buttonColorHex = buttonColor.toHex()
        self.buttonTextColorHex = buttonTextColor.toHex()
        self.correctColorHex = correctColor.toHex()
        self.wrongColorHex = wrongColor.toHex()
        self.borderColorHex = borderColor.toHex()
        self.bgColorDarkHex = bgColorDark?.toHex()
        self.textColorDarkHex = textColorDark?.toHex()
        self.accentColorDarkHex = accentColorDark?.toHex()
        self.buttonColorDarkHex = buttonColorDark?.toHex()
        self.buttonTextColorDarkHex = buttonTextColorDark?.toHex()
        self.correctColorDarkHex = correctColorDark?.toHex()
        self.wrongColorDarkHex = wrongColorDark?.toHex()
        self.borderColorDarkHex = borderColorDark?.toHex()
    }

    // Light mode colors
    var bgColor: Color { Color(hex: bgColorHex) }
    var textColor: Color { Color(hex: textColorHex) }
    var accentColor: Color { Color(hex: accentColorHex) }
    var buttonColor: Color { Color(hex: buttonColorHex) }
    var buttonTextColor: Color { Color(hex: buttonTextColorHex) }
    var correctColor: Color { Color(hex: correctColorHex) }
    var wrongColor: Color { Color(hex: wrongColorHex) }
    var borderColor: Color { Color(hex: borderColorHex) }

    // Dark mode colors (fallback to light mode if not specified)
    var bgColorDark: Color { bgColorDarkHex.map { Color(hex: $0) } ?? bgColor }
    var textColorDark: Color { textColorDarkHex.map { Color(hex: $0) } ?? textColor }
    var accentColorDark: Color { accentColorDarkHex.map { Color(hex: $0) } ?? accentColor }
    var buttonColorDark: Color { buttonColorDarkHex.map { Color(hex: $0) } ?? buttonColor }
    var buttonTextColorDark: Color { buttonTextColorDarkHex.map { Color(hex: $0) } ?? buttonTextColor }
    var correctColorDark: Color { correctColorDarkHex.map { Color(hex: $0) } ?? correctColor }
    var wrongColorDark: Color { wrongColorDarkHex.map { Color(hex: $0) } ?? wrongColor }
    var borderColorDark: Color { borderColorDarkHex.map { Color(hex: $0) } ?? borderColor }

    /// Returns the appropriate color for the current color scheme
    func effectiveBgColor(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark && supportsDarkMode ? bgColorDark : bgColor
    }

    func effectiveTextColor(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark && supportsDarkMode ? textColorDark : textColor
    }

    func effectiveAccentColor(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark && supportsDarkMode ? accentColorDark : accentColor
    }

    func effectiveButtonColor(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark && supportsDarkMode ? buttonColorDark : buttonColor
    }

    func effectiveButtonTextColor(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark && supportsDarkMode ? buttonTextColorDark : buttonTextColor
    }

    func effectiveCorrectColor(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark && supportsDarkMode ? correctColorDark : correctColor
    }

    func effectiveWrongColor(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark && supportsDarkMode ? wrongColorDark : wrongColor
    }

    func effectiveBorderColor(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark && supportsDarkMode ? borderColorDark : borderColor
    }

    // MARK: - Light Mode Themes

    static let classic = Theme(
        id: "classic",
        name: "Classic",
        cost: 0,
        isUnlocked: true,
        isEquipped: true,
        supportsDarkMode: true,
        bgColor: Color(red: 0.95, green: 0.95, blue: 0.90),
        textColor: Color(red: 0.20, green: 0.20, blue: 0.25),
        accentColor: Color(red: 0.20, green: 0.60, blue: 0.90),
        buttonColor: Color(red: 0.90, green: 0.90, blue: 0.85),
        buttonTextColor: Color(red: 0.20, green: 0.20, blue: 0.25),
        correctColor: Color(red: 0.30, green: 0.85, blue: 0.30),
        wrongColor: Color(red: 0.90, green: 0.30, blue: 0.30),
        borderColor: Color(red: 0.15, green: 0.15, blue: 0.20),
        // Dark mode variants
        bgColorDark: Color(red: 0.10, green: 0.10, blue: 0.15),
        textColorDark: Color(red: 0.95, green: 0.95, blue: 0.90),
        accentColorDark: Color(red: 0.40, green: 0.70, blue: 1.00),
        buttonColorDark: Color(red: 0.20, green: 0.20, blue: 0.30),
        buttonTextColorDark: Color(red: 0.95, green: 0.95, blue: 0.90),
        correctColorDark: Color(red: 0.40, green: 0.90, blue: 0.40),
        wrongColorDark: Color(red: 1.00, green: 0.40, blue: 0.40),
        borderColorDark: Color(red: 0.30, green: 0.30, blue: 0.40)
    )

    static let candy = Theme(
        id: "candy",
        name: "Candy",
        cost: 100,
        supportsDarkMode: true,
        bgColor: Color(red: 1.00, green: 0.90, blue: 0.95),
        textColor: Color(red: 0.30, green: 0.20, blue: 0.30),
        accentColor: Color(red: 1.00, green: 0.40, blue: 0.70),
        buttonColor: Color(red: 1.00, green: 0.80, blue: 0.90),
        buttonTextColor: Color(red: 0.30, green: 0.20, blue: 0.30),
        correctColor: Color(red: 0.40, green: 0.90, blue: 0.50),
        wrongColor: Color(red: 0.95, green: 0.40, blue: 0.40),
        borderColor: Color(red: 0.25, green: 0.15, blue: 0.25),
        // Dark mode variants
        bgColorDark: Color(red: 0.20, green: 0.10, blue: 0.20),
        textColorDark: Color(red: 1.00, green: 0.85, blue: 0.95),
        accentColorDark: Color(red: 1.00, green: 0.50, blue: 0.80),
        buttonColorDark: Color(red: 0.35, green: 0.20, blue: 0.35),
        buttonTextColorDark: Color(red: 1.00, green: 0.85, blue: 0.95),
        correctColorDark: Color(red: 0.50, green: 1.00, blue: 0.60),
        wrongColorDark: Color(red: 1.00, green: 0.50, blue: 0.50),
        borderColorDark: Color(red: 0.40, green: 0.25, blue: 0.40)
    )

    static let ocean = Theme(
        id: "ocean",
        name: "Ocean",
        cost: 200,
        supportsDarkMode: true,
        bgColor: Color(red: 0.85, green: 0.95, blue: 1.00),
        textColor: Color(red: 0.10, green: 0.20, blue: 0.35),
        accentColor: Color(red: 0.00, green: 0.60, blue: 0.80),
        buttonColor: Color(red: 0.75, green: 0.90, blue: 0.95),
        buttonTextColor: Color(red: 0.10, green: 0.20, blue: 0.35),
        correctColor: Color(red: 0.20, green: 0.80, blue: 0.60),
        wrongColor: Color(red: 0.90, green: 0.40, blue: 0.40),
        borderColor: Color(red: 0.05, green: 0.15, blue: 0.30),
        // Dark mode variants
        bgColorDark: Color(red: 0.05, green: 0.15, blue: 0.25),
        textColorDark: Color(red: 0.80, green: 0.95, blue: 1.00),
        accentColorDark: Color(red: 0.20, green: 0.80, blue: 1.00),
        buttonColorDark: Color(red: 0.10, green: 0.30, blue: 0.45),
        buttonTextColorDark: Color(red: 0.80, green: 0.95, blue: 1.00),
        correctColorDark: Color(red: 0.30, green: 1.00, blue: 0.80),
        wrongColorDark: Color(red: 1.00, green: 0.50, blue: 0.50),
        borderColorDark: Color(red: 0.15, green: 0.40, blue: 0.60)
    )

    // Retro and Neon are dark-first themes with light mode fallbacks
    static let retro = Theme(
        id: "retro",
        name: "Retro",
        cost: 300,
        supportsDarkMode: false, // Already a dark theme
        bgColor: Color(red: 0.15, green: 0.15, blue: 0.20),
        textColor: Color(red: 0.00, green: 1.00, blue: 0.00),
        accentColor: Color(red: 1.00, green: 0.00, blue: 1.00),
        buttonColor: Color(red: 0.25, green: 0.25, blue: 0.35),
        buttonTextColor: Color(red: 0.00, green: 1.00, blue: 0.00),
        correctColor: Color(red: 0.00, green: 1.00, blue: 0.00),
        wrongColor: Color(red: 1.00, green: 0.00, blue: 0.00),
        borderColor: Color(red: 0.50, green: 0.50, blue: 0.50)
    )

    static let neon = Theme(
        id: "neon",
        name: "Neon",
        cost: 500,
        supportsDarkMode: false, // Already a dark theme
        bgColor: Color(red: 0.05, green: 0.05, blue: 0.10),
        textColor: Color(red: 1.00, green: 1.00, blue: 1.00),
        accentColor: Color(red: 0.00, green: 1.00, blue: 1.00),
        buttonColor: Color(red: 0.20, green: 0.00, blue: 0.40),
        buttonTextColor: Color(red: 1.00, green: 1.00, blue: 1.00),
        correctColor: Color(red: 0.00, green: 1.00, blue: 0.50),
        wrongColor: Color(red: 1.00, green: 0.00, blue: 0.50),
        borderColor: Color(red: 0.00, green: 1.00, blue: 1.00)
    )

    // MARK: - Common Themes (100-300 coins)

    static let forest = Theme(
        id: "forest",
        name: "Forest",
        cost: 150,
        supportsDarkMode: true,
        bgColor: Color(red: 0.90, green: 0.95, blue: 0.88),
        textColor: Color(red: 0.15, green: 0.30, blue: 0.15),
        accentColor: Color(red: 0.20, green: 0.60, blue: 0.30),
        buttonColor: Color(red: 0.80, green: 0.90, blue: 0.75),
        buttonTextColor: Color(red: 0.15, green: 0.30, blue: 0.15),
        correctColor: Color(red: 0.30, green: 0.80, blue: 0.30),
        wrongColor: Color(red: 0.90, green: 0.30, blue: 0.30),
        borderColor: Color(red: 0.20, green: 0.40, blue: 0.20),
        bgColorDark: Color(red: 0.10, green: 0.20, blue: 0.10),
        textColorDark: Color(red: 0.85, green: 0.95, blue: 0.85),
        accentColorDark: Color(red: 0.40, green: 0.80, blue: 0.50),
        buttonColorDark: Color(red: 0.20, green: 0.35, blue: 0.20),
        buttonTextColorDark: Color(red: 0.85, green: 0.95, blue: 0.85),
        correctColorDark: Color(red: 0.50, green: 0.90, blue: 0.50),
        wrongColorDark: Color(red: 1.00, green: 0.40, blue: 0.40),
        borderColorDark: Color(red: 0.30, green: 0.50, blue: 0.30)
    )

    static let sunset = Theme(
        id: "sunset",
        name: "Sunset",
        cost: 200,
        supportsDarkMode: true,
        bgColor: Color(red: 1.00, green: 0.92, blue: 0.85),
        textColor: Color(red: 0.40, green: 0.20, blue: 0.20),
        accentColor: Color(red: 1.00, green: 0.50, blue: 0.20),
        buttonColor: Color(red: 1.00, green: 0.80, blue: 0.70),
        buttonTextColor: Color(red: 0.40, green: 0.20, blue: 0.20),
        correctColor: Color(red: 0.40, green: 0.80, blue: 0.40),
        wrongColor: Color(red: 0.90, green: 0.35, blue: 0.35),
        borderColor: Color(red: 0.50, green: 0.30, blue: 0.25),
        bgColorDark: Color(red: 0.25, green: 0.15, blue: 0.15),
        textColorDark: Color(red: 1.00, green: 0.85, blue: 0.75),
        accentColorDark: Color(red: 1.00, green: 0.60, blue: 0.30),
        buttonColorDark: Color(red: 0.40, green: 0.25, blue: 0.20),
        buttonTextColorDark: Color(red: 1.00, green: 0.85, blue: 0.75),
        correctColorDark: Color(red: 0.50, green: 0.90, blue: 0.50),
        wrongColorDark: Color(red: 1.00, green: 0.45, blue: 0.45),
        borderColorDark: Color(red: 0.60, green: 0.40, blue: 0.35)
    )

    static let midnight = Theme(
        id: "midnight",
        name: "Midnight",
        cost: 250,
        supportsDarkMode: false, // Dark-first theme
        bgColor: Color(red: 0.08, green: 0.10, blue: 0.20),
        textColor: Color(red: 0.80, green: 0.85, blue: 1.00),
        accentColor: Color(red: 0.50, green: 0.60, blue: 1.00),
        buttonColor: Color(red: 0.15, green: 0.20, blue: 0.35),
        buttonTextColor: Color(red: 0.80, green: 0.85, blue: 1.00),
        correctColor: Color(red: 0.40, green: 0.90, blue: 0.60),
        wrongColor: Color(red: 0.90, green: 0.40, blue: 0.40),
        borderColor: Color(red: 0.30, green: 0.40, blue: 0.70)
    )

    // MARK: - Rare Themes (500-1000 coins)

    static let halloween = Theme(
        id: "halloween",
        name: "Halloween",
        cost: 500,
        supportsDarkMode: false, // Dark-first theme
        bgColor: Color(red: 0.10, green: 0.08, blue: 0.05),
        textColor: Color(red: 1.00, green: 0.55, blue: 0.00),
        accentColor: Color(red: 0.90, green: 0.30, blue: 0.00),
        buttonColor: Color(red: 0.20, green: 0.15, blue: 0.10),
        buttonTextColor: Color(red: 1.00, green: 0.55, blue: 0.00),
        correctColor: Color(red: 0.40, green: 0.90, blue: 0.20),
        wrongColor: Color(red: 0.80, green: 0.20, blue: 0.20),
        borderColor: Color(red: 0.60, green: 0.30, blue: 0.00)
    )

    static let christmas = Theme(
        id: "christmas",
        name: "Christmas",
        cost: 600,
        supportsDarkMode: true,
        bgColor: Color(red: 0.95, green: 0.98, blue: 0.95),
        textColor: Color(red: 0.10, green: 0.35, blue: 0.15),
        accentColor: Color(red: 0.80, green: 0.15, blue: 0.15),
        buttonColor: Color(red: 0.85, green: 0.95, blue: 0.85),
        buttonTextColor: Color(red: 0.10, green: 0.35, blue: 0.15),
        correctColor: Color(red: 0.20, green: 0.70, blue: 0.25),
        wrongColor: Color(red: 0.90, green: 0.25, blue: 0.25),
        borderColor: Color(red: 0.60, green: 0.15, blue: 0.15),
        bgColorDark: Color(red: 0.08, green: 0.20, blue: 0.10),
        textColorDark: Color(red: 0.90, green: 0.98, blue: 0.90),
        accentColorDark: Color(red: 0.90, green: 0.20, blue: 0.20),
        buttonColorDark: Color(red: 0.15, green: 0.35, blue: 0.18),
        buttonTextColorDark: Color(red: 0.90, green: 0.98, blue: 0.90),
        correctColorDark: Color(red: 0.30, green: 0.80, blue: 0.35),
        wrongColorDark: Color(red: 1.00, green: 0.35, blue: 0.35),
        borderColorDark: Color(red: 0.70, green: 0.25, blue: 0.25)
    )

    static let galaxy = Theme(
        id: "galaxy",
        name: "Galaxy",
        cost: 800,
        supportsDarkMode: false, // Dark-first theme
        bgColor: Color(red: 0.05, green: 0.03, blue: 0.15),
        textColor: Color(red: 0.90, green: 0.80, blue: 1.00),
        accentColor: Color(red: 0.70, green: 0.40, blue: 1.00),
        buttonColor: Color(red: 0.15, green: 0.10, blue: 0.30),
        buttonTextColor: Color(red: 0.90, green: 0.80, blue: 1.00),
        correctColor: Color(red: 0.40, green: 1.00, blue: 0.60),
        wrongColor: Color(red: 1.00, green: 0.40, blue: 0.60),
        borderColor: Color(red: 0.50, green: 0.30, blue: 0.80)
    )

    // MARK: - Epic Themes (2000-5000 coins)

    static let gold = Theme(
        id: "gold",
        name: "Gold",
        cost: 2000,
        supportsDarkMode: false, // Dark-first luxury theme
        bgColor: Color(red: 0.10, green: 0.08, blue: 0.03),
        textColor: Color(red: 1.00, green: 0.85, blue: 0.20),
        accentColor: Color(red: 1.00, green: 0.75, blue: 0.00),
        buttonColor: Color(red: 0.25, green: 0.20, blue: 0.08),
        buttonTextColor: Color(red: 1.00, green: 0.85, blue: 0.20),
        correctColor: Color(red: 0.60, green: 0.90, blue: 0.30),
        wrongColor: Color(red: 0.90, green: 0.30, blue: 0.30),
        borderColor: Color(red: 0.80, green: 0.60, blue: 0.10)
    )

    static let diamond = Theme(
        id: "diamond",
        name: "Diamond",
        cost: 3000,
        supportsDarkMode: false, // Dark-first ice theme
        bgColor: Color(red: 0.05, green: 0.10, blue: 0.15),
        textColor: Color(red: 0.85, green: 0.95, blue: 1.00),
        accentColor: Color(red: 0.40, green: 0.80, blue: 1.00),
        buttonColor: Color(red: 0.10, green: 0.20, blue: 0.30),
        buttonTextColor: Color(red: 0.85, green: 0.95, blue: 1.00),
        correctColor: Color(red: 0.30, green: 0.90, blue: 0.70),
        wrongColor: Color(red: 0.90, green: 0.40, blue: 0.50),
        borderColor: Color(red: 0.50, green: 0.80, blue: 0.95)
    )

    static let cyberpunk = Theme(
        id: "cyberpunk",
        name: "Cyberpunk",
        cost: 5000,
        supportsDarkMode: false, // Dark-first neon theme
        bgColor: Color(red: 0.03, green: 0.02, blue: 0.08),
        textColor: Color(red: 1.00, green: 0.90, blue: 0.95),
        accentColor: Color(red: 1.00, green: 0.00, blue: 0.80),
        buttonColor: Color(red: 0.12, green: 0.00, blue: 0.20),
        buttonTextColor: Color(red: 1.00, green: 0.90, blue: 0.95),
        correctColor: Color(red: 0.00, green: 1.00, blue: 0.60),
        wrongColor: Color(red: 1.00, green: 0.20, blue: 0.40),
        borderColor: Color(red: 0.90, green: 0.00, blue: 1.00)
    )

    static var allThemes: [Theme] {
        [
            classic, candy, ocean, retro, neon,
            forest, sunset, midnight,
            halloween, christmas, galaxy,
            gold, diamond, cyberpunk
        ]
    }
}

// Color extensions for hex conversion
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    func toHex() -> String {
        let uic = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        uic.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return String(format: "%02X%02X%02X",
                     Int(red * 255),
                     Int(green * 255),
                     Int(blue * 255))
    }
}

import UIKit
