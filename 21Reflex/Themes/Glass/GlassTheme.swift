//
//  GlassTheme.swift
//  21Reflex
//
//  Base class for glass morphism themes - elegant, refined, modern
//

import SwiftUI

/// Base class for all glass morphism themes
class GlassTheme: BaseTheme, GlassThemed {
    // MARK: - Identity (override in subclasses)
    var id: String { "glass_base" }
    var name: String { "Glass Base" }
    var cost: Int { 0 }
    var description: String { "Base glass theme" }
    var previewImageName: String? { nil }

    // MARK: - Theme Colors (override in subclasses)
    override open var backgroundColor: Color { Color(hex: "#1C1C1E") }
    override open var accentColor: Color { Color(hex: "#0A84FF") }
    override open var secondaryColor: Color { Color(hex: "#8E8E93") }
    override open var textColor: Color { .white }

    // MARK: - Animation & Audio
    var animationStyle: AnimationStyle { .smooth }
    var hapticStyle: HapticStyle { .standard }
    var themeSongFilename: String? { nil }
    var soundEffectStyle: SoundEffectStyle { .standard }

    // MARK: - Component Factory Methods

    func makeBackground() -> AnyView {
        AnyView(
            backgroundColor
                .overlay(.ultraThinMaterial)
                .ignoresSafeArea()
        )
    }

    func makeButton(style: ThemeButtonStyle, title: String, icon: String?, action: @escaping () -> Void) -> AnyView {
        AnyView(
            ThemeComponentFactory.glassButton(
                title: title,
                icon: icon,
                style: style,
                colors: buttonColors(),
                action: action
            )
        )
    }

    func makeCardView(card: Card) -> AnyView {
        AnyView(
            ThemeComponentFactory.modernCardView(
                card: card,
                cardColors: .default
            )
        )
    }

    func makeCardBack() -> AnyView {
        AnyView(
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [accentColor.opacity(0.3), accentColor.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Image(systemName: "waveform")
                    .font(.system(size: 32))
                    .foregroundStyle(accentColor.opacity(0.5))
            }
            .frame(width: 70, height: 100)
        )
    }

    func makeGameCardContainer(content: AnyView) -> AnyView {
        AnyView(
            content
                .padding(.horizontal, 30)
                .padding(.vertical, 24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                )
        )
    }

    func makeTimerBar(progress: Double) -> AnyView {
        AnyView(
            ThemeComponentFactory.glassTimerBar(progress: progress)
        )
    }

    func makeScoreBadge(score: Int) -> AnyView {
        AnyView(
            HStack(spacing: 4) {
                Text("\(score)")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                Text("pts")
                    .font(.caption)
                    .opacity(0.7)
            }
            .foregroundStyle(textColor)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
        )
    }

    func makeStreakIndicator(streak: Int) -> AnyView {
        AnyView(
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(.orange)
                Text("\(streak)")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(textColor)
        )
    }

    func makeHealthIndicator(health: Int, maxHealth: Int) -> AnyView {
        AnyView(
            HStack(spacing: 4) {
                ForEach(0..<maxHealth, id: \.self) { index in
                    Image(systemName: index < health ? "heart.fill" : "heart")
                        .font(.system(size: 14))
                        .foregroundStyle(index < health ? .red : .gray.opacity(0.3))
                }
            }
        )
    }

    func makePauseOverlay() -> AnyView {
        AnyView(
            Color.black.opacity(0.6)
                .ignoresSafeArea()
        )
    }

    func makeGameOverCard(stats: GameOverStats) -> AnyView {
        AnyView(
            VStack(spacing: 20) {
                Text("Final Score")
                    .font(.headline)
                    .foregroundStyle(textColor)

                Text("\(stats.score)")
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundStyle(accentColor)

                HStack(spacing: 24) {
                    StatItem(title: "Accuracy", value: "\(Int(stats.accuracy * 100))%")
                    StatItem(title: "Best Streak", value: "\(stats.bestStreak)")
                    StatItem(title: "Hands", value: "\(stats.handsPlayed)")
                }

                if stats.coinsEarned > 0 {
                    HStack {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundStyle(.yellow)
                        Text("+\(stats.coinsEarned) coins")
                            .font(.headline)
                    }
                    .foregroundStyle(textColor)
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
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
            primary: accentColor,
            secondary: secondaryColor,
            destructive: .red,
            correct: .green,
            wrong: .red,
            neutral: secondaryColor,
            special: .orange,
            border: textColor.opacity(0.2),
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
                .font(.system(size: 20, weight: .semibold, design: .rounded))
            Text(title)
                .font(.caption)
                .opacity(0.7)
        }
    }
}
