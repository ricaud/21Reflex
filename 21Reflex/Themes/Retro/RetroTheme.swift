//
//  RetroTheme.swift
//  21Reflex
//
//  Base class for retro themes (pixel art, CRT, etc.)
//

import SwiftUI

/// Base class for retro themes
class RetroTheme: BaseTheme, RetroThemed {
    // MARK: - Identity (override in subclasses)
    var id: String { "retro_base" }
    var name: String { "Retro Base" }
    var cost: Int { 0 }
    var description: String { "Base retro theme" }
    var previewImageName: String? { nil }

    // MARK: - Colors (retro specific)
    override open var borderColor: Color { .white }

    // Core color overrides that leaf themes can customize
    override open var backgroundColor: Color { .black }
    override open var accentColor: Color { .green }
    override open var secondaryColor: Color { .cyan }
    override open var textColor: Color { .white }
    open var primaryColor: Color { .green }

    // MARK: - Styling
    var pixelSize: CGFloat { 4 }

    // MARK: - Animation & Audio
    var animationStyle: AnimationStyle { .instant }
    var hapticStyle: HapticStyle { .sharp }
    var themeSongFilename: String? { nil }
    var soundEffectStyle: SoundEffectStyle { .arcade }

    // MARK: - Component Factory Methods

    func makeBackground() -> AnyView {
        AnyView(
            backgroundColor
                .ignoresSafeArea()
        )
    }

    func makeButton(style: ThemeButtonStyle, title: String, icon: String?, action: @escaping () -> Void) -> AnyView {
        AnyView(
            ThemeComponentFactory.pixelButton(
                title: title,
                icon: icon,
                style: style,
                colors: buttonColors(),
                pixelSize: pixelSize,
                action: action
            )
        )
    }

    func makeCardView(card: Card) -> AnyView {
        AnyView(
            ThemeComponentFactory.pixelCardView(card: card, pixelSize: pixelSize)
        )
    }

    func makeCardBack() -> AnyView {
        AnyView(
            ZStack {
                PixelRectangle(pixelSize: pixelSize)
                    .fill(accentColor.opacity(0.3))

                PixelRectangle(pixelSize: pixelSize)
                    .stroke(borderColor, lineWidth: pixelSize)

                Image(systemName: "questionmark")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(accentColor)
            }
            .frame(width: 64, height: 88)
        )
    }

    func makeGameCardContainer(content: AnyView) -> AnyView {
        AnyView(
            content
                .padding(.horizontal, 30)
                .padding(.vertical, 24)
                .background(
                    PixelRectangle(pixelSize: pixelSize)
                        .stroke(borderColor.opacity(0.5), lineWidth: pixelSize)
                )
        )
    }

    func makeTimerBar(progress: Double) -> AnyView {
        AnyView(
            ThemeComponentFactory.pixelTimerBar(
                progress: progress,
                color: timerColor(for: progress),
                pixelSize: pixelSize
            )
        )
    }

    func makeScoreBadge(score: Int) -> AnyView {
        AnyView(
            HStack(spacing: 4) {
                Text("\(score)")
                    .font(.custom("PressStart2P-Regular", size: 10))
                Text("PTS")
                    .font(.custom("PressStart2P-Regular", size: 8))
            }
            .foregroundStyle(textColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                PixelRectangle(pixelSize: pixelSize)
                    .stroke(borderColor, lineWidth: pixelSize)
            )
        )
    }

    func makeStreakIndicator(streak: Int) -> AnyView {
        AnyView(
            HStack(spacing: 4) {
                Text("★")
                    .font(.custom("PressStart2P-Regular", size: 10))
                    .foregroundStyle(.yellow)
                Text("\(streak)")
                    .font(.custom("PressStart2P-Regular", size: 10))
            }
            .foregroundStyle(textColor)
        )
    }

    func makeHealthIndicator(health: Int, maxHealth: Int) -> AnyView {
        AnyView(
            HStack(spacing: 4) {
                ForEach(0..<maxHealth, id: \.self) { index in
                    Text(index < health ? "♥" : "♡")
                        .font(.custom("PressStart2P-Regular", size: 10))
                        .foregroundStyle(index < health ? .red : .gray.opacity(0.5))
                }
            }
        )
    }

    func makePauseOverlay() -> AnyView {
        AnyView(
            Color.black.opacity(0.8)
                .ignoresSafeArea()
        )
    }

    func makeGameOverCard(stats: GameOverStats) -> AnyView {
        AnyView(
            VStack(spacing: 16) {
                Text("GAME OVER")
                    .font(.custom("PressStart2P-Regular", size: 12))

                Text("\(stats.score)")
                    .font(.custom("PressStart2P-Regular", size: 24))
                    .foregroundStyle(primaryColor)

                HStack(spacing: 16) {
                    StatItem(title: "ACC", value: "\(Int(stats.accuracy * 100))%")
                    StatItem(title: "STR", value: "\(stats.bestStreak)")
                }

                if stats.coinsEarned > 0 {
                    Text("+\(stats.coinsEarned) COINS")
                        .font(.custom("PressStart2P-Regular", size: 10))
                        .foregroundStyle(.yellow)
                }
            }
            .padding()
            .background(
                PixelRectangle(pixelSize: pixelSize)
                    .stroke(borderColor, lineWidth: pixelSize)
            )
        )
    }

    // MARK: - Typography

    func font(for style: FontStyle) -> Font {
        // Use standard font sizes for consistency across themes
        let size = BaseTheme.standardFontSizes[style] ?? 16
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

    func fontColor(for style: FontStyle) -> Color {
        textColor
    }

    // MARK: - Private Helpers

    private func buttonColors() -> ThemeComponentFactory.ButtonColors {
        ThemeComponentFactory.ButtonColors(
            primary: primaryColor,
            secondary: secondaryColor,
            destructive: .red,
            correct: .green,
            wrong: .red,
            neutral: borderColor.opacity(0.5),
            special: accentColor,
            border: borderColor,
            text: textColor
        )
    }

}

// MARK: - Supporting Views

private struct StatItem: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.custom("PressStart2P-Regular", size: 12))
            Text(title)
                .font(.custom("PressStart2P-Regular", size: 8))
                .opacity(0.7)
        }
    }
}
