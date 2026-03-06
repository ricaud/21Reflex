//
//  AppTheme.swift
//  21Reflex
//
//  Core theme protocol - defines the complete visual personality of the app
//

import SwiftUI

/// Main protocol for all themes. Each theme provides complete visual rendering
/// for all UI components, allowing transformative visual experiences.
protocol AppTheme: ObservableObject {
    // MARK: - Identity
    var id: String { get }
    var name: String { get }
    var cost: Int { get }
    var description: String { get }
    var previewImageName: String? { get }

    // MARK: - Unlock Status (managed by GameState)
    var isUnlocked: Bool { get set }
    var isEquipped: Bool { get set }

    // MARK: - Component Factory Methods

    /// Creates the background view for all screens
    func makeBackground() -> AnyView

    /// Creates a themed button
    /// - Parameters:
    ///   - style: The semantic style of the button
    ///   - title: Button text
    ///   - icon: Optional SF Symbol name
    ///   - action: Closure to execute on tap
    func makeButton(style: ThemeButtonStyle, title: String, icon: String?, action: @escaping () -> Void) -> AnyView

    /// Creates a view for a playing card
    func makeCardView(card: Card) -> AnyView

    /// Creates the back of a playing card
    func makeCardBack() -> AnyView

    /// Wraps card content in a themed container
    func makeGameCardContainer(content: AnyView) -> AnyView

    /// Creates a timer progress bar
    func makeTimerBar(progress: Double) -> AnyView

    /// Creates a score display badge
    func makeScoreBadge(score: Int) -> AnyView

    /// Creates a streak indicator
    func makeStreakIndicator(streak: Int) -> AnyView

    /// Creates a health/lives indicator
    func makeHealthIndicator(health: Int, maxHealth: Int) -> AnyView

    /// Creates the pause overlay background
    func makePauseOverlay() -> AnyView

    /// Creates the game over stats card
    func makeGameOverCard(stats: GameOverStats) -> AnyView

    // MARK: - Typography

    /// Returns the themed font for a specific text style
    func font(for style: FontStyle) -> Font

    /// Returns the themed color for a specific text style
    func fontColor(for style: FontStyle) -> Color

    // MARK: - Animation & Haptics

    /// The animation personality for this theme
    var animationStyle: AnimationStyle { get }

    /// The haptic feedback style for this theme
    var hapticStyle: HapticStyle { get }

    // MARK: - Audio

    /// Optional theme song filename (without extension)
    var themeSongFilename: String? { get }

    /// Sound effect style for this theme
    var soundEffectStyle: SoundEffectStyle { get }

    // MARK: - Color Accessors (for backward compatibility)

    /// Background color for the current color scheme
    func effectiveBgColor(_ colorScheme: ColorScheme) -> Color

    /// Text color for the current color scheme
    func effectiveTextColor(_ colorScheme: ColorScheme) -> Color

    /// Accent color for the current color scheme
    func effectiveAccentColor(_ colorScheme: ColorScheme) -> Color

    /// Secondary color for the current color scheme
    func effectiveSecondaryColor(_ colorScheme: ColorScheme) -> Color

    /// Correct answer color for the current color scheme
    func effectiveCorrectColor(_ colorScheme: ColorScheme) -> Color

    /// Wrong answer color for the current color scheme
    func effectiveWrongColor(_ colorScheme: ColorScheme) -> Color

    /// Card background color for the current color scheme
    func effectiveCardBgColor(_ colorScheme: ColorScheme) -> Color

    /// Optional gradient for themed backgrounds (returns nil if theme doesn't use gradients)
    func effectiveGradient(_ colorScheme: ColorScheme) -> LinearGradient?
}

// MARK: - Supporting Types

/// Semantic button styles - themes interpret these visually
enum ThemeButtonStyle {
    case primary
    case secondary
    case destructive
    case answerCorrect
    case answerWrong
    case answerNeutral
    case specialAction  // For Bust, Blackjack buttons
}

/// Text style categories for theming
enum FontStyle {
    case titleLarge     // "Paused", "Game Over"
    case titleMedium    // Section headers
    case body
    case headline       // Card titles, emphasis
    case caption
    case button
    case numericLarge   // Scores, card values
    case numericSmall   // Stats
    case cardRank       // Card rank display
    case cardSuit       // Card suit display
}

/// Animation personalities
enum AnimationStyle {
    case smooth         // iOS default - elegant, subtle
    case bouncy         // Playful - springy, energetic
    case instant        // No animation
    case wobbly         // Hand-drawn feel
    case glitch         // Cyberpunk/retro
    case flip           // Card flip emphasis
    case elastic        // Exaggerated spring
}

/// Haptic feedback intensities
enum HapticStyle {
    case standard
    case heavy          // Strong feedback
    case subtle         // Gentle taps
    case sharp          // Crisp, precise
    case none
}

/// Sound effect style categories
enum SoundEffectStyle {
    case standard
    case arcade
    case paper          // Page flip, pencil sounds
    case minimal
    case futuristic
}

/// Stats displayed in game over screen
struct GameOverStats {
    let score: Int
    let accuracy: Double
    let bestStreak: Int
    let coinsEarned: Int
    let handsPlayed: Int

    init(score: Int, accuracy: Double, bestStreak: Int, coinsEarned: Int, handsPlayed: Int) {
        self.score = score
        self.accuracy = accuracy
        self.bestStreak = bestStreak
        self.coinsEarned = coinsEarned
        self.handsPlayed = handsPlayed
    }
}

// MARK: - Default Implementations

extension AppTheme {
    /// Default animation based on style
    var animationStyle: AnimationStyle { .smooth }

    /// Default haptic style
    var hapticStyle: HapticStyle { .standard }

    /// Default sound effects
    var soundEffectStyle: SoundEffectStyle { .standard }

    /// Default theme song (none)
    var themeSongFilename: String? { nil }

    /// Default preview image
    var previewImageName: String? { nil }

    /// Default gradient (none - themes can override to provide custom gradients)
    func effectiveGradient(_ colorScheme: ColorScheme) -> LinearGradient? {
        nil
    }
}

// MARK: - Theme Category Protocols (for filtering)

/// Marker protocol for glass morphism themes
protocol GlassThemed: AppTheme {}

/// Marker protocol for playful/retro themes with thick borders
protocol PlayfulThemed: AppTheme {}

/// Marker protocol for hand-drawn/sketch themes
protocol HandDrawnThemed: AppTheme {}

/// Marker protocol for retro/pixel themes
protocol RetroThemed: AppTheme {}

/// Marker protocol for luxury/premium themes
protocol LuxuryThemed: AppTheme {}
