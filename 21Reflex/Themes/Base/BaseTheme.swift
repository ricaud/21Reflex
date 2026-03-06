//
//  BaseTheme.swift
//  21Reflex
//
//  Abstract base class with shared theme helper methods
//

import SwiftUI
import Combine

/// Base class providing common functionality for all themes.
/// Themes should inherit from this class and override methods as needed.
class BaseTheme: ObservableObject {

    // MARK: - Unlock Status

    /// Whether this theme is unlocked (managed by GameState)
    @Published public var isUnlocked: Bool = false

    /// Whether this theme is currently equipped (managed by GameState)
    @Published public var isEquipped: Bool = false

    // MARK: - Initialization

    init() {}

    // MARK: - Color Helpers

    /// Determines if a color is dark (for choosing contrasting text)
    func isColorDark(_ color: Color) -> Bool {
        let uiColor = UIColor(color)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: nil)

        // Calculate relative luminance
        let luminance = 0.299 * red + 0.587 * green + 0.114 * blue
        return luminance < 0.5
    }

    /// Returns black or white based on background color for contrast
    func contrastingTextColor(for background: Color) -> Color {
        isColorDark(background) ? .white : .black
    }

    /// Interpolates between two colors based on progress (0.0 to 1.0)
    func interpolateColor(from: Color, to: Color, progress: Double) -> Color {
        let fromUIColor = UIColor(from)
        let toUIColor = UIColor(to)

        var fromRed: CGFloat = 0, fromGreen: CGFloat = 0, fromBlue: CGFloat = 0, fromAlpha: CGFloat = 0
        var toRed: CGFloat = 0, toGreen: CGFloat = 0, toBlue: CGFloat = 0, toAlpha: CGFloat = 0

        fromUIColor.getRed(&fromRed, green: &fromGreen, blue: &fromBlue, alpha: &fromAlpha)
        toUIColor.getRed(&toRed, green: &toGreen, blue: &toBlue, alpha: &toAlpha)

        let red = fromRed + (toRed - fromRed) * CGFloat(progress)
        let green = fromGreen + (toGreen - fromGreen) * CGFloat(progress)
        let blue = fromBlue + (toBlue - fromBlue) * CGFloat(progress)
        let alpha = fromAlpha + (toAlpha - fromAlpha) * CGFloat(progress)

        return Color(red: Double(red), green: Double(green), blue: Double(blue), opacity: Double(alpha))
    }

    // MARK: - Timer Color Helpers

    /// Returns a color indicating time pressure (green -> yellow -> red)
    func timerColor(for progress: Double) -> Color {
        if progress > 0.6 {
            return .green
        } else if progress > 0.3 {
            return .yellow
        } else {
            return .red
        }
    }

    /// Returns a theme-agnostic timer color that works with any background
    func neutralTimerColor(for progress: Double) -> Color {
        if progress > 0.6 {
            return Color.green.opacity(0.8)
        } else if progress > 0.3 {
            return Color.orange.opacity(0.8)
        } else {
            return Color.red.opacity(0.8)
        }
    }

    // MARK: - Animation Helpers

    /// Returns the animation configuration for this theme's style
    func animations(for style: AnimationStyle) -> ThemeAnimations {
        ThemeAnimations(style: style)
    }

    // MARK: - Theme Colors (Override in subclasses)

    /// Background color (light mode)
    open var backgroundColor: Color { Color(hex: "F2F2F7") }

    /// Background color (dark mode)
    open var backgroundColorDark: Color { Color(hex: "1C1C1E") }

    /// Text color (light mode)
    open var textColor: Color { Color(hex: "000000") }

    /// Text color (dark mode)
    open var textColorDark: Color { Color(hex: "FFFFFF") }

    /// Accent color (light mode)
    open var accentColor: Color { Color(hex: "007AFF") }

    /// Accent color (dark mode)
    open var accentColorDark: Color { Color(hex: "0A84FF") }

    /// Secondary color (light mode)
    open var secondaryColor: Color { Color(hex: "E5E5EA") }

    /// Secondary color (dark mode)
    open var secondaryColorDark: Color { Color(hex: "2C2C2E") }

    /// Correct answer color (light mode)
    open var correctColor: Color { Color(hex: "34C759") }

    /// Correct answer color (dark mode)
    open var correctColorDark: Color { Color(hex: "30D158") }

    /// Wrong answer color (light mode)
    open var wrongColor: Color { Color(hex: "FF3B30") }

    /// Wrong answer color (dark mode)
    open var wrongColorDark: Color { Color(hex: "FF453A") }

    /// Card background color (light mode)
    open var cardBgColor: Color { Color(hex: "FFFFFF") }

    /// Card background color (dark mode)
    open var cardBgColorDark: Color { Color(hex: "2C2C2E") }

    // MARK: - Standard Button Colors

    /// Standard color for primary buttons
    open var primaryButtonColor: Color { accentColor }

    /// Standard color for secondary buttons
    open var secondaryButtonColor: Color { secondaryColor }

    /// Standard color for destructive actions
    open var destructiveButtonColor: Color { wrongColor }

    /// Standard color for correct answers
    open var correctAnswerColor: Color { correctColor }

    /// Standard color for wrong answers
    open var wrongAnswerColor: Color { wrongColor }

    /// Standard color for neutral answer buttons
    open var neutralAnswerColor: Color { secondaryColor }

    /// Border color for UI elements (override in themes that use borders)
    open var borderColor: Color { textColor.opacity(0.2) }

    // MARK: - Effective Colors (Color Scheme Aware)

    /// Returns the background color for the current color scheme
    func effectiveBgColor(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? backgroundColorDark : backgroundColor
    }

    /// Returns the text color for the current color scheme
    func effectiveTextColor(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? textColorDark : textColor
    }

    /// Returns the accent color for the current color scheme
    func effectiveAccentColor(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? accentColorDark : accentColor
    }

    /// Returns the secondary color for the current color scheme
    func effectiveSecondaryColor(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? secondaryColorDark : secondaryColor
    }

    /// Returns the correct answer color for the current color scheme
    func effectiveCorrectColor(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? correctColorDark : correctColor
    }

    /// Returns the wrong answer color for the current color scheme
    func effectiveWrongColor(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? wrongColorDark : wrongColor
    }

    /// Returns the card background color for the current color scheme
    func effectiveCardBgColor(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? cardBgColorDark : cardBgColor
    }

    // MARK: - Typography Defaults

    /// Standard font sizes used across all themes for consistency
    static let standardFontSizes: [FontStyle: CGFloat] = [
        .titleLarge: 40,
        .titleMedium: 24,
        .body: 16,
        .headline: 20,
        .caption: 12,
        .button: 17,
        .numericLarge: 32,
        .numericSmall: 15,
        .cardRank: 20,
        .cardSuit: 20
    ]

    /// Default font for a style - used by all themes for consistency
    func defaultFont(for style: FontStyle) -> Font {
        let size = Self.standardFontSizes[style] ?? 16
        switch style {
        case .titleLarge, .numericLarge:
            return .system(size: size, weight: .bold, design: .rounded)
        case .titleMedium, .headline:
            return .system(size: size, weight: .semibold, design: .rounded)
        case .numericSmall, .button:
            return .system(size: size, weight: .semibold, design: .rounded)
        case .cardRank:
            return .system(size: size, weight: .bold)
        case .cardSuit, .body, .caption:
            return .system(size: size, weight: .regular)
        }
    }

    /// Default text color for a style
    func defaultFontColor(for style: FontStyle) -> Color {
        .primary
    }
}

// MARK: - Hex Color Support

extension Color {
    /// Creates a Color from a hex string (e.g., "#FF0000" or "FF0000")
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
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
