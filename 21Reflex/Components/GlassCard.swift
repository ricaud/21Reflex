//
//  GlassCard.swift
//  21Reflex
//
//  Glass-morphism container card with refined styling
//

import SwiftUI

struct GlassCard<Content: View>: View {
    var cornerRadius: CGFloat = 20
    var material: Material = .thinMaterial
    var strokeColor: Color? = nil
    var strokeWidth: CGFloat = 0.5
    var shadowRadius: CGFloat = 10
    var shadowOpacity: Double = 0.1
    @ViewBuilder var content: Content

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        content
            .padding()
            .background(material)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        strokeColor ?? (colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.05)),
                        lineWidth: strokeWidth
                    )
            )
            .shadow(
                color: Color.black.opacity(colorScheme == .dark ? 0.2 : shadowOpacity),
                radius: shadowRadius,
                x: 0,
                y: 4
            )
    }
}

// Compact variant for smaller UI elements
struct GlassBadge: View {
    var icon: String? = nil
    var text: String
    var color: Color? = nil
    var material: Material = .ultraThinMaterial

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 4) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.caption2)
            }
            Text(text)
                .font(.caption.weight(.medium))
        }
        .foregroundStyle(color ?? (colorScheme == .dark ? .white : .primary))
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(material)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(color?.opacity(0.3) ?? Color.primary.opacity(0.1), lineWidth: 0.5)
        )
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            GlassCard {
                VStack(spacing: 12) {
                    Text("Glass Card")
                        .font(.headline)
                    Text("This is a glass-morphism card with a refined look.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal)

            HStack(spacing: 12) {
                GlassBadge(icon: "flame.fill", text: "12", color: .orange)
                GlassBadge(icon: "dollarsign.circle.fill", text: "150", color: .green)
                GlassBadge(icon: "checkmark.circle.fill", text: "85%", color: .blue)
            }

            GlassCard(material: .ultraThinMaterial, strokeColor: .blue.opacity(0.3)) {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                    Text("Special Card")
                    Spacer()
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
    }
    .background(
        LinearGradient(colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                      startPoint: .topLeading,
                      endPoint: .bottomTrailing)
    )
}
