//
//  ThemeComponents.swift
//  21Reflex
//
//  Shared reusable theme component builders
//

import SwiftUI

/// Factory for creating common theme components with consistent styling
enum ThemeComponentFactory {

    // MARK: - Standard Buttons

    /// Creates a glass morphism style button
    static func glassButton(
        title: String,
        icon: String?,
        style: ThemeButtonStyle,
        colors: ButtonColors,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
            }
            .foregroundStyle(foregroundColor(for: style, colors: colors))
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(.ultraThinMaterial)
            .background(backgroundColor(for: style, colors: colors).opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(borderColor(for: style, colors: colors), lineWidth: 0.5)
            )
        }
    }

    /// Creates a playful button with thick borders
    static func playfulButton(
        title: String,
        icon: String?,
        style: ThemeButtonStyle,
        colors: ButtonColors,
        borderWidth: CGFloat = 4,
        shadowOffset: CGFloat = 4,
        cornerRadius: CGFloat = 12,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
            }
            .foregroundStyle(foregroundColor(for: style, colors: colors))
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(backgroundColor(for: style, colors: colors))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor(for: style, colors: colors), lineWidth: borderWidth)
            )
        }
    }

    /// Creates a hand-drawn sketch button
    static func sketchButton(
        title: String,
        icon: String?,
        style: ThemeButtonStyle,
        colors: ButtonColors,
        roughness: CGFloat = 1.5,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 16))
                }
                Text(title)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(foregroundColor(for: style, colors: colors))
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .padding(.horizontal, 16)
            .background(
                RoughRectangle(cornerRadius: 6, roughness: roughness)
                    .fill(backgroundColor(for: style, colors: colors))
                    .shadow(color: .gray.opacity(0.3), radius: 2, x: 2, y: 2)
            )
            .overlay(
                RoughRectangle(cornerRadius: 6, roughness: roughness)
                    .stroke(borderColor(for: style, colors: colors), lineWidth: 2)
            )
        }
    }

    /// Creates a pixel art button
    static func pixelButton(
        title: String,
        icon: String?,
        style: ThemeButtonStyle,
        colors: ButtonColors,
        pixelSize: CGFloat = 4,
        pressed: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 12))
                }
                Text(title.uppercased())
                    .font(.custom("PressStart2P-Regular", size: 10))
            }
            .foregroundStyle(foregroundColor(for: style, colors: colors))
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(
                ZStack {
                    // Shadow
                    PixelRectangle(pixelSize: pixelSize)
                        .fill(borderColor(for: style, colors: colors))
                        .offset(x: pressed ? 0 : pixelSize, y: pressed ? 0 : pixelSize)

                    // Main button
                    PixelRectangle(pixelSize: pixelSize)
                        .fill(backgroundColor(for: style, colors: colors))
                        .offset(x: pressed ? pixelSize : 0, y: pressed ? pixelSize : 0)
                }
            )
        }
    }

    // MARK: - Standard Cards

    /// Creates a modern glass-style playing card
    static func modernCardView(card: Card, cardColors: CardColors) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(cardColors.background)
                .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)

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
    }

    /// Creates a hand-drawn sketch card
    static func sketchCardView(card: Card, roughness: CGFloat = 1.0) -> some View {
        ZStack {
            RoughRectangle(cornerRadius: 6, roughness: roughness)
                .fill(Color.white)
                .shadow(color: .gray.opacity(0.2), radius: 1, x: 1, y: 1)

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
    }

    /// Creates a pixel art card
    static func pixelCardView(card: Card, pixelSize: CGFloat = 4) -> some View {
        ZStack {
            PixelRectangle(pixelSize: pixelSize)
                .fill(Color.white)

            PixelRectangle(pixelSize: pixelSize)
                .stroke(Color.black, lineWidth: pixelSize)

            VStack(spacing: 4) {
                Text(card.rank.rawValue)
                    .font(.custom("PressStart2P-Regular", size: 10))
                    .foregroundStyle(card.suit.color)

                PixelSuitIcon(suit: card.suit, size: 24)
                    .foregroundStyle(card.suit.color)
            }
        }
        .frame(width: 64, height: 88)
    }

    // MARK: - Timer Bars

    /// Creates a smooth glass-style timer bar
    static func glassTimerBar(progress: Double, color: Color = .green) -> some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(.white.opacity(0.2))

                RoundedRectangle(cornerRadius: 4)
                    .fill(timerColor(progress: progress, baseColor: color))
                    .frame(width: geo.size.width * progress)
                    .animation(.linear(duration: 0.1), value: progress)
            }
        }
        .frame(height: 8)
    }

    /// Creates a sketch-style timer bar
    static func sketchTimerBar(progress: Double, color: Color = .green) -> some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoughRectangle(cornerRadius: 4, roughness: 1)
                    .stroke(Color.black, lineWidth: 1.5)

                HStack(spacing: 2) {
                    ForEach(0..<Int(progress * 20), id: \.self) { _ in
                        Rectangle()
                            .fill(timerColor(progress: progress, baseColor: color).opacity(0.6))
                            .frame(width: max(4, (geo.size.width / 20) - 2))
                    }
                }
                .padding(2)
            }
        }
        .frame(height: 20)
    }

    /// Creates a pixel-style discrete block timer
    static func pixelTimerBar(progress: Double, color: Color = .green, pixelSize: CGFloat = 4) -> some View {
        HStack(spacing: pixelSize) {
            ForEach(0..<10) { index in
                PixelRectangle(pixelSize: pixelSize)
                    .fill(Double(index) / 10.0 < progress ? color : Color.gray.opacity(0.3))
                    .frame(height: pixelSize * 3)
            }
        }
    }

    // MARK: - Helper Types

    struct ButtonColors {
        var primary: Color
        var secondary: Color
        var destructive: Color
        var correct: Color
        var wrong: Color
        var neutral: Color
        var special: Color
        var border: Color
        var text: Color

        static var `default`: ButtonColors {
            ButtonColors(
                primary: .blue,
                secondary: .gray,
                destructive: .red,
                correct: .green,
                wrong: .red,
                neutral: .gray,
                special: .orange,
                border: .black,
                text: .primary
            )
        }
    }

    struct CardColors {
        var background: Color
        var border: Color
        var redSuit: Color
        var blackSuit: Color

        static var `default`: CardColors {
            CardColors(
                background: .white,
                border: .black,
                redSuit: .red,
                blackSuit: .black
            )
        }
    }

    // MARK: - Private Helpers

    private static func foregroundColor(for style: ThemeButtonStyle, colors: ButtonColors) -> Color {
        switch style {
        case .primary, .answerCorrect, .specialAction:
            return colors.text
        case .secondary, .answerNeutral:
            return colors.text.opacity(0.8)
        case .destructive, .answerWrong:
            return .white
        }
    }

    private static func backgroundColor(for style: ThemeButtonStyle, colors: ButtonColors) -> Color {
        switch style {
        case .primary:
            return colors.primary
        case .secondary:
            return colors.secondary.opacity(0.2)
        case .destructive:
            return colors.destructive
        case .answerCorrect:
            return colors.correct
        case .answerWrong:
            return colors.wrong
        case .answerNeutral:
            return colors.neutral.opacity(0.2)
        case .specialAction:
            return colors.special
        }
    }

    private static func borderColor(for style: ThemeButtonStyle, colors: ButtonColors) -> Color {
        switch style {
        case .primary:
            return colors.primary.opacity(0.5)
        case .secondary:
            return colors.border.opacity(0.2)
        case .destructive:
            return colors.destructive.opacity(0.5)
        case .answerCorrect:
            return colors.correct.opacity(0.5)
        case .answerWrong:
            return colors.wrong.opacity(0.5)
        case .answerNeutral:
            return colors.border.opacity(0.1)
        case .specialAction:
            return colors.special.opacity(0.5)
        }
    }

    private static func timerColor(progress: Double, baseColor: Color) -> Color {
        if progress > 0.6 {
            return .green
        } else if progress > 0.3 {
            return .orange
        } else {
            return .red
        }
    }

    private static func suitIcon(for suit: Suit) -> String {
        switch suit {
        case .hearts: return "suit.heart.fill"
        case .diamonds: return "suit.diamond.fill"
        case .clubs: return "suit.club.fill"
        case .spades: return "suit.spade.fill"
        }
    }
}
