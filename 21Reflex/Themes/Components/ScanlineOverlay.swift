//
//  ScanlineOverlay.swift
//  21Reflex
//
//  CRT monitor scanline effect for retro themes
//

import SwiftUI

/// Simulates CRT monitor scanlines and phosphor glow
struct ScanlineOverlay: View {
    var lineSpacing: CGFloat = 4
    var lineOpacity: Double = 0.3
    var glowIntensity: Double = 0.1
    var curvature: CGFloat = 0  // 0 = flat, higher = more curved

    @State private var flickerOpacity: Double = 0.02

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Horizontal scanlines
                VStack(spacing: 0) {
                    ForEach(0..<Int(geometry.size.height / lineSpacing), id: \.self) { _ in
                        Rectangle()
                            .fill(Color.black.opacity(lineOpacity))
                            .frame(height: lineSpacing / 2)

                        Spacer()
                            .frame(height: lineSpacing / 2)
                    }
                }

                // Vertical phosphor lines (subtle)
                HStack(spacing: 0) {
                    ForEach(0..<Int(geometry.size.width / 3), id: \.self) { i in
                        Group {
                            if i % 3 == 0 {
                                Color.red.opacity(glowIntensity)
                            } else if i % 3 == 1 {
                                Color.green.opacity(glowIntensity)
                            } else {
                                Color.blue.opacity(glowIntensity)
                            }
                        }
                        .frame(width: 1)

                        Spacer()
                            .frame(width: 2)
                    }
                }
                .blendMode(.screen)

                // Subtle flicker overlay
                Color.white.opacity(flickerOpacity)
                    .blendMode(.overlay)

                // Vignette / screen curvature
                RadialGradient(
                    colors: [
                        .clear,
                        .black.opacity(0.2),
                        .black.opacity(0.5)
                    ],
                    center: .center,
                    startRadius: geometry.size.width * 0.3,
                    endRadius: geometry.size.width * 0.7
                )
                .blendMode(.multiply)

                // Screen edge glow
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                .clear,
                                .cyan.opacity(0.05),
                                .clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            .onAppear {
                // Subtle random flicker
                Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
                    withAnimation(.linear(duration: 0.05)) {
                        flickerOpacity = Double.random(in: 0.01...0.03)
                    }
                }
            }
        }
    }
}

/// A view modifier that applies CRT effects to content
struct CRTModifier: ViewModifier {
    var scanlineOpacity: Double = 0.3
    var glowAmount: Double = 0.1
    var chromaticAberration: CGFloat = 1.0

    func body(content: Content) -> some View {
        content
            .overlay(
                ScanlineOverlay(
                    lineOpacity: scanlineOpacity,
                    glowIntensity: glowAmount
                )
            )
            .colorMultiply(Color.white.opacity(0.9)) // Slight desaturation
    }
}

extension View {
    func crtEffect(scanlineOpacity: Double = 0.3, glowAmount: Double = 0.1) -> some View {
        modifier(CRTModifier(scanlineOpacity: scanlineOpacity, glowAmount: glowAmount))
    }
}

/// Retro phosphor text glow effect
struct PhosphorText: View {
    let text: String
    let color: Color
    var glowIntensity: Double = 0.8
    var flicker: Bool = true

    @State private var glowOpacity: Double = 1.0

    var body: some View {
        Text(text)
            .foregroundColor(color)
            .shadow(color: color.opacity(glowIntensity), radius: 4, x: 0, y: 0)
            .shadow(color: color.opacity(glowIntensity * 0.5), radius: 8, x: 0, y: 0)
            .opacity(glowOpacity)
            .onAppear {
                if flicker {
                    Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                        withAnimation(.linear(duration: 0.05)) {
                            glowOpacity = Double.random(in: 0.95...1.0)
                        }
                    }
                }
            }
    }
}

/// A retro terminal-style cursor
struct CRTCursor: View {
    var blinkRate: Double = 0.5
    var color: Color = .green

    @State private var isVisible = true

    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: 12, height: 20)
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: blinkRate, repeats: true) { _ in
                    withAnimation(.linear(duration: 0.1)) {
                        isVisible.toggle()
                    }
                }
            }
    }
}

// MARK: - Preview

#Preview("CRT Effects") {
    ZStack {
        // Background content
        Color.black

        Text("RETRO THEME")
            .font(.system(size: 40, weight: .bold, design: .monospaced))
            .foregroundColor(.green)
            .modifier(CRTModifier())

        // Just scanlines overlay
        ScanlineOverlay(lineSpacing: 4, lineOpacity: 0.4)
    }
    .frame(width: 300, height: 200)
}
