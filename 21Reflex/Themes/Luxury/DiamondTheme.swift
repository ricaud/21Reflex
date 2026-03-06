//
//  DiamondTheme.swift
//  21Reflex
//
//  Diamond luxury theme with sparkle effects
//

import SwiftUI

/// Diamond luxury theme with diamond sparkle effects
final class DiamondTheme: LuxuryTheme {
    override var id: String { "diamond" }
    override var name: String { "Diamond" }
    override var cost: Int { 0 } // Was: 3000
    override var description: String { "Ultra-premium diamond theme with icy brilliance" }
    override var previewImageName: String? { "preview_diamond" }

    override var backgroundColor: Color { Color(hex: "#0D1B2A") }  // Deep navy
    override var primaryColor: Color { Color(hex: "#E0F7FA") }  // Ice blue
    override var secondaryColor: Color { Color(hex: "#B2EBF2") }  // Light cyan
    override var accentColor: Color { Color(hex: "#4DD0E1") }  // Cyan accent
    override var textColor: Color { Color(hex: "#E0F7FA") }

    override var animationStyle: AnimationStyle { .smooth }
    override var soundEffectStyle: SoundEffectStyle { .minimal }

    override func makeBackground() -> AnyView {
        AnyView(
            ZStack {
                backgroundColor

                // Sparkle overlay
                SparkleOverlay()

                // Gradient glow
                RadialGradient(
                    colors: [
                        primaryColor.opacity(0.1),
                        Color.clear
                    ],
                    center: .topLeading,
                    startRadius: 0,
                    endRadius: 800
                )
            }
            .ignoresSafeArea()
        )
    }

    override func makeCardView(card: Card) -> AnyView {
        AnyView(
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "#1A3A4A"),
                                Color(hex: "#0D1B2A")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                LinearGradient(
                                    colors: [primaryColor.opacity(0.6), accentColor.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: primaryColor.opacity(0.3), radius: 6, x: 0, y: 2)

                VStack(spacing: 4) {
                    Text(card.rank.rawValue)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(card.suit.color == .red ? Color(hex: "#FF6B6B") : primaryColor)

                    Image(systemName: suitIcon(for: card.suit))
                        .font(.system(size: 24))
                        .foregroundStyle(card.suit.color == .red ? Color(hex: "#FF6B6B") : primaryColor)
                }
            }
            .frame(width: 70, height: 100)
        )
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

// MARK: - Sparkle Overlay

private struct SparkleOverlay: View {
    @State private var sparkles: [Sparkle] = []

    struct Sparkle: Identifiable {
        let id = UUID()
        var position: CGPoint
        var scale: CGFloat
        var opacity: Double
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(sparkles) { sparkle in
                    Image(systemName: "sparkle")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.white.opacity(sparkle.opacity))
                        .scaleEffect(sparkle.scale)
                        .position(sparkle.position)
                }
            }
            .onAppear {
                // Generate random sparkles
                var newSparkles: [Sparkle] = []
                for _ in 0..<15 {
                    newSparkles.append(Sparkle(
                        position: CGPoint(
                            x: CGFloat.random(in: 0...geo.size.width),
                            y: CGFloat.random(in: 0...geo.size.height)
                        ),
                        scale: CGFloat.random(in: 0.5...1.5),
                        opacity: Double.random(in: 0.2...0.6)
                    ))
                }
                sparkles = newSparkles

                // Animate sparkles
                Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
                    withAnimation(.easeInOut(duration: 1)) {
                        sparkles = sparkles.map { sparkle in
                            var updated = sparkle
                            updated.opacity = Double.random(in: 0.2...0.6)
                            updated.scale = CGFloat.random(in: 0.5...1.5)
                            return updated
                        }
                    }
                }
            }
        }
    }
}
