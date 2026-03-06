//
//  CRTTheme.swift
//  21Reflex
//
//  CRT monitor theme with scanlines and phosphor glow
//

import SwiftUI

/// CRT monitor theme with scanlines and phosphor glow
final class CRTTheme: RetroTheme {
    override var id: String { "crt" }
    override var name: String { "CRT Monitor" }
    override var cost: Int { 0 } // Was: 150
    override var description: String { "Retro CRT with scanlines and phosphor glow" }
    override var previewImageName: String? { "preview_crt" }

    override var backgroundColor: Color { .black }
    override var primaryColor: Color { Color(hex: "#33ff00") }  // Phosphor green
    override var secondaryColor: Color { Color(hex: "#00ff33") }
    override var accentColor: Color { Color(hex: "#66ff66") }
    override var borderColor: Color { Color(hex: "#33ff00") }
    override var textColor: Color { Color(hex: "#33ff00") }

    override var pixelSize: CGFloat { 2 }

    override var animationStyle: AnimationStyle { .glitch }
    override var soundEffectStyle: SoundEffectStyle { .arcade }

    override func makeBackground() -> AnyView {
        AnyView(
            ZStack {
                backgroundColor

                ScanlineOverlay(
                    lineSpacing: 4,
                    lineOpacity: 0.4,
                    glowIntensity: 0.15
                )
            }
            .ignoresSafeArea()
        )
    }

    override func makeButton(style: ThemeButtonStyle, title: String, icon: String?, action: @escaping () -> Void) -> AnyView {
        AnyView(
            Button(action: action) {
                HStack(spacing: 4) {
                    if let icon {
                        Image(systemName: icon)
                            .font(.system(size: 10))
                    }
                    Text(title.uppercased())
                        .font(.custom("PressStart2P-Regular", size: 8))
                }
                .foregroundStyle(primaryColor)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(
                    PixelRectangle(pixelSize: pixelSize)
                        .stroke(primaryColor.opacity(0.5), lineWidth: pixelSize)
                )
                .shadow(color: primaryColor.opacity(0.5), radius: 4, x: 0, y: 0)
            }
        )
    }

    override func makeGameOverCard(stats: GameOverStats) -> AnyView {
        AnyView(
            VStack(spacing: 16) {
                PhosphorText(
                    text: "GAME OVER",
                    color: primaryColor,
                    glowIntensity: 0.8
                )
                .font(.custom("PressStart2P-Regular", size: 12))

                PhosphorText(
                    text: "\(stats.score)",
                    color: primaryColor,
                    glowIntensity: 1.0
                )
                .font(.custom("PressStart2P-Regular", size: 24))

                HStack(spacing: 16) {
                    StatItem(title: "ACC", value: "\(Int(stats.accuracy * 100))%")
                    StatItem(title: "STR", value: "\(stats.bestStreak)")
                }
            }
            .padding()
            .background(
                PixelRectangle(pixelSize: pixelSize)
                    .stroke(primaryColor.opacity(0.3), lineWidth: pixelSize)
            )
        )
    }
}

private struct StatItem: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            PhosphorText(
                text: value,
                color: .green,
                glowIntensity: 0.8
            )
            .font(.custom("PressStart2P-Regular", size: 10))

            PhosphorText(
                text: title,
                color: .green.opacity(0.7),
                glowIntensity: 0.5
            )
            .font(.custom("PressStart2P-Regular", size: 8))
        }
    }
}
