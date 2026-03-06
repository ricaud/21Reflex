//
//  HandDrawnTheme.swift
//  21Reflex
//
//  Base class for hand-drawn sketch themes
//

import SwiftUI

/// Base class for hand-drawn sketch themes
class HandDrawnTheme: BaseTheme, HandDrawnThemed {
    // MARK: - Identity (override in subclasses)
    var id: String { "handdrawn_base" }
    var name: String { "Hand Drawn Base" }
    var cost: Int { 0 }
    var description: String { "Base hand-drawn theme" }
    var previewImageName: String? { nil }

    // MARK: - Colors (hand-drawn specific)
    open var paperLineColor: Color { Color(hex: "#A4C2F4") }
    open var marginLineColor: Color { Color(hex: "#FF6B6B") }
    open var pencilColor: Color { Color(hex: "#2C2C2C") }

    // MARK: - Styling
    var roughness: CGFloat { 1.5 }

    // MARK: - Animation & Audio
    var animationStyle: AnimationStyle { .wobbly }
    var hapticStyle: HapticStyle { .subtle }
    var themeSongFilename: String? { nil }
    var soundEffectStyle: SoundEffectStyle { .paper }

    // MARK: - Component Factory Methods

    func makeBackground() -> AnyView {
        AnyView(
            GeometryReader { geo in
                ZStack {
                    // Paper background
                    self.backgroundColor

                    // Notebook lines
                    VStack(spacing: 28) {
                        ForEach(0..<60, id: \.self) { _ in
                            Rectangle()
                                .fill(self.paperLineColor.opacity(0.4))
                                .frame(height: 1)
                        }
                    }
                    .offset(y: 50)

                    // Red margin line
                    Rectangle()
                        .fill(self.marginLineColor.opacity(0.3))
                        .frame(width: 1)
                        .position(x: 40, y: geo.size.height / 2)
                }
            }
            .ignoresSafeArea()
        )
    }

    func makeButton(style: ThemeButtonStyle, title: String, icon: String?, action: @escaping () -> Void) -> AnyView {
        AnyView(
            ThemeComponentFactory.sketchButton(
                title: title,
                icon: icon,
                style: style,
                colors: buttonColors(),
                roughness: roughness,
                action: action
            )
        )
    }

    func makeCardView(card: Card) -> AnyView {
        AnyView(
            ThemeComponentFactory.sketchCardView(card: card, roughness: roughness)
        )
    }

    func makeCardBack() -> AnyView {
        AnyView(
            ZStack {
                RoughRectangle(cornerRadius: 6, roughness: roughness)
                    .fill(backgroundColor)
                    .shadow(color: .gray.opacity(0.2), radius: 1, x: 1, y: 1)

                Image(systemName: "scribble")
                    .font(.system(size: 32))
                    .foregroundStyle(pencilColor.opacity(0.5))
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
                    RoughRectangle(cornerRadius: 12, roughness: roughness)
                        .fill(Color.white.opacity(0.7))
                )
        )
    }

    func makeTimerBar(progress: Double) -> AnyView {
        AnyView(
            ThemeComponentFactory.sketchTimerBar(progress: progress)
        )
    }

    func makeScoreBadge(score: Int) -> AnyView {
        AnyView(
            HStack(spacing: 4) {
                Text("\(score)")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                Text("pts")
                    .font(.system(size: 12, weight: .regular))
            }
            .foregroundStyle(pencilColor)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoughRectangle(cornerRadius: 16, roughness: roughness)
                    .fill(Color.white)
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
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(pencilColor)
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
            Color.black.opacity(0.3)
                .ignoresSafeArea()
        )
    }

    func makeGameOverCard(stats: GameOverStats) -> AnyView {
        AnyView(
            VStack(spacing: 20) {
                Text("Final Score")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))

                Text("\(stats.score)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
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
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
            }
            .padding()
            .background(
                RoughRectangle(cornerRadius: 12, roughness: roughness)
                    .fill(Color.white)
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
        pencilColor
    }

    // MARK: - Private Helpers

    private func buttonColors() -> ThemeComponentFactory.ButtonColors {
        ThemeComponentFactory.ButtonColors(
            primary: accentColor,
            secondary: backgroundColor,
            destructive: .red,
            correct: .green,
            wrong: .red,
            neutral: pencilColor.opacity(0.3),
            special: .orange,
            border: pencilColor,
            text: pencilColor
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
                .font(.system(size: 12, weight: .regular))
                .opacity(0.7)
        }
    }
}
