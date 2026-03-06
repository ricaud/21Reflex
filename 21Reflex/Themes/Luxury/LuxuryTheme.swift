//
//  LuxuryTheme.swift
//  21Reflex
//
//  Base class for luxury/premium themes
//

import SwiftUI

/// Base class for luxury themes with premium aesthetics
class LuxuryTheme: BaseTheme, LuxuryThemed {
    // MARK: - Identity (override in subclasses)
    var id: String { "luxury_base" }
    var name: String { "Luxury Base" }
    var cost: Int { 1000 }
    var description: String { "Base luxury theme" }
    var previewImageName: String? { nil }

    // MARK: - Colors (luxury specific)
    open var primaryColor: Color { Color(hex: "#FFD700") }

    // MARK: - Animation & Audio
    var animationStyle: AnimationStyle { .smooth }
    var hapticStyle: HapticStyle { .subtle }
    var themeSongFilename: String? { nil }
    var soundEffectStyle: SoundEffectStyle { .minimal }

    // MARK: - Component Factory Methods

    func makeBackground() -> AnyView {
        AnyView(
            ZStack {
                backgroundColor

                // Subtle gradient overlay
                RadialGradient(
                    colors: [
                        primaryColor.opacity(0.1),
                        Color.clear
                    ],
                    center: .topLeading,
                    startRadius: 0,
                    endRadius: 600
                )
            }
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
                        .font(.system(size: 17, weight: .semibold))
                }
                .foregroundStyle(buttonForeground(for: style))
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    LinearGradient(
                        colors: [primaryColor.opacity(0.3), primaryColor.opacity(0.1)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    LinearGradient(
                        colors: [primaryColor, primaryColor.opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .mask(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(lineWidth: 1)
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: primaryColor.opacity(0.3), radius: 8, x: 0, y: 4)
            }
        )
    }

    func makeCardView(card: Card) -> AnyView {
        AnyView(
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "#1A1A1A"),
                                Color(hex: "#0A0A0A")
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(primaryColor.opacity(0.5), lineWidth: 1)
                    )
                    .shadow(color: primaryColor.opacity(0.2), radius: 4, x: 0, y: 2)

                VStack(spacing: 4) {
                    Text(card.rank.rawValue)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(card.suit.color == .red ? Color(hex: "#FF4444") : .white)

                    Image(systemName: suitIcon(for: card.suit))
                        .font(.system(size: 24))
                        .foregroundStyle(card.suit.color == .red ? Color(hex: "#FF4444") : .white)
                }
            }
            .frame(width: 70, height: 100)
        )
    }

    func makeCardBack() -> AnyView {
        AnyView(
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "#1A1A1A"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                LinearGradient(
                                    colors: [primaryColor, primaryColor.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )

                Image(systemName: "crown.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(primaryColor.opacity(0.6))
            }
            .frame(width: 70, height: 100)
            .shadow(color: primaryColor.opacity(0.3), radius: 4, x: 0, y: 2)
        )
    }

    func makeGameCardContainer(content: AnyView) -> AnyView {
        AnyView(
            content
                .padding(.horizontal, 30)
                .padding(.vertical, 24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(hex: "#111111").opacity(0.8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(primaryColor.opacity(0.2), lineWidth: 1)
                        )
                )
        )
    }

    func makeTimerBar(progress: Double) -> AnyView {
        AnyView(
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(hex: "#1A1A1A"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(self.primaryColor.opacity(0.3), lineWidth: 1)
                        )

                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [self.primaryColor, self.accentColor],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * progress)
                        .animation(.linear(duration: 0.1), value: progress)
                }
            }
            .frame(height: 8)
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
            .foregroundStyle(primaryColor)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(hex: "#1A1A1A"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(primaryColor.opacity(0.5), lineWidth: 1)
                    )
            )
        )
    }

    func makeStreakIndicator(streak: Int) -> AnyView {
        AnyView(
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(primaryColor)
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
                    Image(systemName: index < health ? "diamond.fill" : "diamond")
                        .font(.system(size: 14))
                        .foregroundStyle(index < health ? self.primaryColor : self.secondaryColor.opacity(0.3))
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
            VStack(spacing: 20) {
                Text("Final Score")
                    .font(.headline)
                    .foregroundStyle(primaryColor)

                Text("\(stats.score)")
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundStyle(primaryColor)
                    .shadow(color: primaryColor.opacity(0.5), radius: 8, x: 0, y: 0)

                HStack(spacing: 24) {
                    StatItem(title: "Accuracy", value: "\(Int(stats.accuracy * 100))%")
                    StatItem(title: "Best Streak", value: "\(stats.bestStreak)")
                    StatItem(title: "Hands", value: "\(stats.handsPlayed)")
                }

                if stats.coinsEarned > 0 {
                    HStack {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundStyle(primaryColor)
                        Text("+\(stats.coinsEarned) coins")
                            .font(.headline)
                    }
                    .foregroundStyle(textColor)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(hex: "#0A0A0A"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [primaryColor.opacity(0.5), primaryColor.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
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
        primaryColor
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

// MARK: - Supporting Views

private struct StatItem: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(hex: "#FFD700"))
            Text(title)
                .font(.caption)
                .opacity(0.7)
        }
    }
}
