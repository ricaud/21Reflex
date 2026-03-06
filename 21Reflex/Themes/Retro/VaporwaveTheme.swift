//
//  VaporwaveTheme.swift
//  21Reflex
//
//  Aesthetic vaporwave theme with sunset colors
//

import SwiftUI

/// Vaporwave aesthetic theme with sunset gradients
final class VaporwaveTheme: RetroTheme {
    override var id: String { "vaporwave" }
    override var name: String { "Vaporwave" }
    override var cost: Int { 0 } // Was: 250
    override var description: String { "Aesthetic 80s vaporwave with sunset colors" }
    override var previewImageName: String? { "preview_vaporwave" }

    override var backgroundColor: Color { Color(hex: "#2D1B4E") }
    override var primaryColor: Color { Color(hex: "#FF006E") }  // Hot pink
    override var secondaryColor: Color { Color(hex: "#8338EC") }  // Purple
    override var accentColor: Color { Color(hex: "#3A86FF") }  // Cyan blue
    override var borderColor: Color { Color(hex: "#FF006E") }
    override var textColor: Color { Color(hex: "#FFBE0B") }  // Yellow

    override var pixelSize: CGFloat { 3 }

    override var animationStyle: AnimationStyle { .glitch }
    override var soundEffectStyle: SoundEffectStyle { .futuristic }

    override func makeBackground() -> AnyView {
        AnyView(
            ZStack {
                // Sunset gradient
                LinearGradient(
                    colors: [
                        Color(hex: "#2D1B4E"),
                        Color(hex: "#5D2E8C"),
                        Color(hex: "#B5179E"),
                        Color(hex: "#F72585"),
                        Color(hex: "#FF9F1C")
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                // Grid overlay
                GeometryReader { geo in
                    ZStack {
                        // Horizontal grid lines
                        VStack(spacing: 40) {
                            ForEach(0..<Int(geo.size.height / 40), id: \.self) { _ in
                                Rectangle()
                                    .fill(Color(hex: "#FF006E").opacity(0.3))
                                    .frame(height: 1)
                                    .frame(maxWidth: .infinity)
                            }
                        }

                        // Vertical grid lines (perspective)
                        HStack(spacing: 60) {
                            ForEach(0..<Int(geo.size.width / 60), id: \.self) { _ in
                                Rectangle()
                                    .fill(Color(hex: "#FF006E").opacity(0.3))
                                    .frame(width: 1)
                                    .frame(maxHeight: .infinity)
                            }
                        }
                    }
                }
            }
            .ignoresSafeArea()
        )
    }
}
