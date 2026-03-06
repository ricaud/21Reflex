//
//  MetricCard.swift
//  21Reflex
//
//  Animated metric display card with trend indicators
//

import SwiftUI

enum TrendDirection {
    case up
    case down
    case neutral
}

struct MetricCard: View {
    var title: String
    var value: Int
    var valueFormatter: (Int) -> String = { String($0) }
    var trend: TrendDirection? = nil
    var trendValue: String? = nil
    var icon: String
    var color: Color
    var animateOnAppear: Bool = true

    @Environment(\.colorScheme) private var colorScheme
    @State private var displayedValue: Int = 0
    @State private var hasAppeared = false

    var body: some View {
        VStack(spacing: 12) {
            // Icon and trend
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(color)
                    .frame(width: 36, height: 36)
                    .background(color.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                Spacer()

                if let trend = trend {
                    TrendIndicator(direction: trend, value: trendValue)
                }
            }

            // Value
            Text(valueFormatter(displayedValue))
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(colorScheme == .dark ? .white : .primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .minimumScaleFactor(0.5)

            // Title
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(color.opacity(0.2), lineWidth: 0.5)
        )
        .onAppear {
            guard animateOnAppear else {
                displayedValue = value
                return
            }
            // Animate value counting up
            withAnimation(.easeOut(duration: 0.8)) {
                displayedValue = value
            }
        }
        .onChange(of: value) { oldValue, newValue in
            withAnimation(.easeOut(duration: 0.5)) {
                displayedValue = newValue
            }
        }
    }
}

struct TrendIndicator: View {
    var direction: TrendDirection
    var value: String?

    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: iconName)
                .font(.caption2.weight(.bold))
            if let value = value {
                Text(value)
                    .font(.caption2.weight(.medium))
            }
        }
        .foregroundStyle(color)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(color.opacity(0.15))
        .clipShape(Capsule())
    }

    private var iconName: String {
        switch direction {
        case .up: return "arrow.up"
        case .down: return "arrow.down"
        case .neutral: return "minus"
        }
    }

    private var color: Color {
        switch direction {
        case .up: return .green
        case .down: return .red
        case .neutral: return .gray
        }
    }
}

// Compact metric for summary rows
struct CompactMetric: View {
    var icon: String
    var value: String
    var label: String
    var color: Color

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(color)
                .frame(width: 28, height: 28)
                .background(color.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                MetricCard(
                    title: "Best Score",
                    value: 1250,
                    trend: .up,
                    trendValue: "12%",
                    icon: "trophy.fill",
                    color: .yellow
                )

                MetricCard(
                    title: "Accuracy",
                    value: 85,
                    valueFormatter: { "\($0)%" },
                    trend: .down,
                    trendValue: "3%",
                    icon: "checkmark.circle.fill",
                    color: .green
                )

                MetricCard(
                    title: "Games Played",
                    value: 42,
                    icon: "dice.fill",
                    color: .blue
                )

                MetricCard(
                    title: "Coins",
                    value: 12500,
                    trend: .up,
                    trendValue: "+250",
                    icon: "dollarsign.circle.fill",
                    color: .orange
                )
            }
            .padding(.horizontal)

            VStack(spacing: 12) {
                CompactMetric(icon: "flame.fill", value: "15", label: "Best Streak", color: .orange)
                CompactMetric(icon: "clock.fill", value: "2.5h", label: "Play Time", color: .purple)
            }
            .padding()
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal)
        }
        .padding(.vertical)
    }
}
