//
//  PlayfulTheme.swift
//  21Reflex
//
//  Base class for playful themes with thick borders and solid fills
//

import SwiftUI

/// Base class for playful themes with thick borders and fun aesthetics
class PlayfulTheme: BaseTheme, PlayfulThemed {
    // MARK: - Identity (override in subclasses)
    var id: String { "playful_base" }
    var name: String { "Playful Base" }
    var cost: Int { 0 }
    var description: String { "Base playful theme" }
    var previewImageName: String? { nil }

    // MARK: - Colors (playful specific)
    override open var borderColor: Color { .black }

    // MARK: - Styling Parameters
    var borderWidth: CGFloat { 4 }
    var cornerRadius: CGFloat { 12 }
    var shadowOffset: CGFloat { 4 }

    // MARK: - Animation & Audio
    var animationStyle: AnimationStyle { .bouncy }
    var hapticStyle: HapticStyle { .heavy }
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
            Button(action: action) {
                HStack(spacing: 8) {
                    if let icon {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .semibold))
                    }
                    Text(title)
                        .font(.system(size: 17, weight: .bold))
                }
                .foregroundStyle(buttonForeground(for: style))
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(buttonBackground(for: style))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(self.borderColor, lineWidth: borderWidth)
                )
            }
            .buttonStyle(PlayfulButtonStyle(shadowOffset: shadowOffset, borderColor: borderColor))
        )
    }

    func makeCardView(card: Card) -> AnyView {
        AnyView(
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white)
                    .shadow(color: borderColor.opacity(0.2), radius: 2, x: 2, y: 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(self.borderColor, lineWidth: 2)
                    )

                VStack(spacing: 4) {
                    Text(card.rank.rawValue)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(card.suit.color)

                    Image(systemName: suitIcon(for: card.suit))
                        .font(.system(size: 24))
                        .foregroundStyle(card.suit.color)
                }
            }
            .frame(width: 70, height: 100)
        )
    }

    func makeCardBack() -> AnyView {
        AnyView(
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(accentColor.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(self.borderColor, lineWidth: 2)
                    )

                Image(systemName: "star.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(accentColor)
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
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.5))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(self.borderColor, lineWidth: 2)
                        )
                )
        )
    }

    func makeTimerBar(progress: Double) -> AnyView {
        AnyView(
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(self.borderColor, lineWidth: 2)
                        )

                    RoundedRectangle(cornerRadius: 2)
                        .fill(self.timerColor(for: progress))
                        .frame(width: max(0, geo.size.width * progress - 4))
                        .padding(2)
                }
            }
            .frame(height: 16)
        )
    }

    func makeScoreBadge(score: Int) -> AnyView {
        AnyView(
            HStack(spacing: 4) {
                Text("\(score)")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                Text("pts")
                    .font(.caption)
            }
            .foregroundStyle(textColor)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(self.borderColor, lineWidth: 2)
                    )
            )
        )
    }

    func makeStreakIndicator(streak: Int) -> AnyView {
        AnyView(
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(.orange)
                Text("\(streak)")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
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
            Color.black.opacity(0.4)
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
                    .foregroundStyle(primaryButtonColor)

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
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(self.borderColor, lineWidth: 3)
                    )
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

    private func buttonForeground(for style: ThemeButtonStyle) -> Color {
        switch style {
        case .primary, .answerCorrect, .specialAction:
            return isColorDark(buttonBackground(for: style)) ? .white : textColor
        case .secondary, .answerNeutral:
            return textColor
        case .destructive, .answerWrong:
            return .white
        }
    }

    private func buttonBackground(for style: ThemeButtonStyle) -> Color {
        switch style {
        case .primary, .answerCorrect:
            return primaryButtonColor
        case .secondary, .answerNeutral:
            return secondaryButtonColor
        case .destructive, .answerWrong:
            return .red
        case .specialAction:
            return accentColor
        }
    }

    private func suitIcon(for suit: Suit) -> String {
        switch suit {
        case .hearts: return "suit.heart.fill"
        case .diamonds: return "suit.diamond.fill"
        case .clubs: return "suit.club.fill"
        case .spades: return "suit.spade.fill"
        }
    }
}

// MARK: - Playful Button Style

private struct PlayfulButtonStyle: ButtonStyle {
    let shadowOffset: CGFloat
    let borderColor: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .offset(y: configuration.isPressed ? shadowOffset : 0)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(borderColor)
                    .offset(y: configuration.isPressed ? 0 : shadowOffset)
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
                .font(.system(size: 20, weight: .bold, design: .rounded))
            Text(title)
                .font(.caption)
                .opacity(0.7)
        }
    }
}
