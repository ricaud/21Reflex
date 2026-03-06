//
//  StatsChartView.swift
//  21Reflex
//
//  Reusable chart components using native Apple Charts
//

import SwiftUI
import Charts

// MARK: - Data Models

struct ScoreDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let score: Int
}

struct AccuracyDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let accuracy: Double // 0.0 to 1.0
}

struct DailyMetricPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Int
    let label: String
}

// MARK: - Score History Chart

struct ScoreHistoryChart: View {
    var data: [ScoreDataPoint]
    var accentColor: Color = .blue
    var showAverage: Bool = true

    @Environment(\.colorScheme) private var colorScheme

    private var averageScore: Double {
        guard !data.isEmpty else { return 0 }
        return Double(data.map(\.score).reduce(0, +)) / Double(data.count)
    }

    var body: some View {
        Chart(data) { point in
            LineMark(
                x: .value("Date", point.date),
                y: .value("Score", point.score)
            )
            .foregroundStyle(accentColor.gradient)
            .lineStyle(StrokeStyle(lineWidth: 2.5))

            AreaMark(
                x: .value("Date", point.date),
                y: .value("Score", point.score)
            )
            .foregroundStyle(accentColor.opacity(0.1).gradient)

            if data.count <= 7 {
                PointMark(
                    x: .value("Date", point.date),
                    y: .value("Score", point.score)
                )
                .foregroundStyle(accentColor)
                .symbolSize(50)
            }

            if showAverage {
                RuleMark(y: .value("Average", averageScore))
                    .foregroundStyle(.secondary)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                    .annotation(position: .trailing) {
                        Text("Avg: \(Int(averageScore))")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 5)) { value in
                AxisGridLine()
                    .foregroundStyle(colorScheme == .dark ? .white.opacity(0.1) : .black.opacity(0.05))
                AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                    .font(.caption)
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisGridLine()
                    .foregroundStyle(colorScheme == .dark ? .white.opacity(0.1) : .black.opacity(0.05))
                AxisValueLabel {
                    if let intValue = value.as(Int.self) {
                        Text("\(intValue)")
                            .font(.caption)
                    }
                }
            }
        }
        .frame(height: 180)
    }
}

// MARK: - Accuracy Trend Chart

struct AccuracyTrendChart: View {
    var data: [AccuracyDataPoint]
    var accentColor: Color = .green

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Chart(data) { point in
            LineMark(
                x: .value("Date", point.date),
                y: .value("Accuracy", point.accuracy * 100)
            )
            .foregroundStyle(accentColor.gradient)
            .lineStyle(StrokeStyle(lineWidth: 2.5))
            .interpolationMethod(.catmullRom)

            AreaMark(
                x: .value("Date", point.date),
                y: .value("Accuracy", point.accuracy * 100)
            )
            .foregroundStyle(accentColor.opacity(0.15).gradient)
            .interpolationMethod(.catmullRom)
        }
        .chartYScale(domain: 0...100)
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 4)) { value in
                AxisGridLine()
                    .foregroundStyle(colorScheme == .dark ? .white.opacity(0.1) : .black.opacity(0.05))
                AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                    .font(.caption)
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisGridLine()
                    .foregroundStyle(colorScheme == .dark ? .white.opacity(0.1) : .black.opacity(0.05))
                AxisValueLabel {
                    if let intValue = value.as(Int.self) {
                        Text("\(intValue)%")
                            .font(.caption)
                    }
                }
            }
        }
        .frame(height: 150)
    }
}

// MARK: - Daily Activity Bar Chart

struct DailyActivityChart: View {
    var data: [DailyMetricPoint]
    var accentColor: Color = .blue

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Chart(data) { point in
            BarMark(
                x: .value("Date", point.date),
                y: .value("Value", point.value)
            )
            .foregroundStyle(accentColor.gradient)
            .cornerRadius(4)
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 5)) { value in
                AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                    .font(.caption)
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisGridLine()
                    .foregroundStyle(colorScheme == .dark ? .white.opacity(0.1) : .black.opacity(0.05))
                AxisValueLabel {
                    if let intValue = value.as(Int.self) {
                        Text("\(intValue)")
                            .font(.caption)
                    }
                }
            }
        }
        .frame(height: 120)
    }
}

// MARK: - Coins Accumulation Chart

struct CoinsAccumulationChart: View {
    var data: [DailyMetricPoint]

    @Environment(\.colorScheme) private var colorScheme

    private var cumulativeData: [DailyMetricPoint] {
        var cumulative: [DailyMetricPoint] = []
        var total = 0
        for point in data {
            total += point.value
            cumulative.append(DailyMetricPoint(date: point.date, value: total, label: point.label))
        }
        return cumulative
    }

    var body: some View {
        Chart(cumulativeData) { point in
            AreaMark(
                x: .value("Date", point.date),
                y: .value("Coins", point.value)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [.orange.opacity(0.4), .orange.opacity(0.1)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .interpolationMethod(.catmullRom)

            LineMark(
                x: .value("Date", point.date),
                y: .value("Coins", point.value)
            )
            .foregroundStyle(.orange)
            .lineStyle(StrokeStyle(lineWidth: 2))
            .interpolationMethod(.catmullRom)
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 4)) { value in
                AxisGridLine()
                    .foregroundStyle(colorScheme == .dark ? .white.opacity(0.1) : .black.opacity(0.05))
                AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                    .font(.caption)
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisGridLine()
                    .foregroundStyle(colorScheme == .dark ? .white.opacity(0.1) : .black.opacity(0.05))
                AxisValueLabel {
                    if let intValue = value.as(Int.self) {
                        Text("\(intValue)")
                            .font(.caption)
                    }
                }
            }
        }
        .frame(height: 140)
    }
}

// MARK: - Compact Mini Chart

struct MiniScoreChart: View {
    var scores: [Int]
    var color: Color = .blue

    var body: some View {
        if scores.count >= 2 {
            Chart(Array(scores.enumerated()), id: \.offset) { index, score in
                LineMark(
                    x: .value("Index", index),
                    y: .value("Score", score)
                )
                .foregroundStyle(color)
                .lineStyle(StrokeStyle(lineWidth: 2))
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .frame(height: 40)
        } else {
            // Placeholder when not enough data
            RoundedRectangle(cornerRadius: 4)
                .fill(color.opacity(0.1))
                .frame(height: 40)
                .overlay(
                    Text("Play more games to see trends")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                )
        }
    }
}

// MARK: - Chart Container

struct ChartContainer<Content: View>: View {
    var title: String
    var subtitle: String? = nil
    var icon: String? = nil
    @ViewBuilder var content: Content

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.primary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()
            }

            // Chart content
            content
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.05), lineWidth: 0.5)
        )
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            // Sample data
            let scoreData = [
                ScoreDataPoint(date: Date().addingTimeInterval(-86400 * 6), score: 450),
                ScoreDataPoint(date: Date().addingTimeInterval(-86400 * 5), score: 520),
                ScoreDataPoint(date: Date().addingTimeInterval(-86400 * 4), score: 480),
                ScoreDataPoint(date: Date().addingTimeInterval(-86400 * 3), score: 650),
                ScoreDataPoint(date: Date().addingTimeInterval(-86400 * 2), score: 720),
                ScoreDataPoint(date: Date().addingTimeInterval(-86400), score: 680),
                ScoreDataPoint(date: Date(), score: 850)
            ]

            let accuracyData = [
                AccuracyDataPoint(date: Date().addingTimeInterval(-86400 * 6), accuracy: 0.72),
                AccuracyDataPoint(date: Date().addingTimeInterval(-86400 * 5), accuracy: 0.75),
                AccuracyDataPoint(date: Date().addingTimeInterval(-86400 * 4), accuracy: 0.71),
                AccuracyDataPoint(date: Date().addingTimeInterval(-86400 * 3), accuracy: 0.82),
                AccuracyDataPoint(date: Date().addingTimeInterval(-86400 * 2), accuracy: 0.85),
                AccuracyDataPoint(date: Date().addingTimeInterval(-86400), accuracy: 0.88),
                AccuracyDataPoint(date: Date(), accuracy: 0.92)
            ]

            let activityData = [
                DailyMetricPoint(date: Date().addingTimeInterval(-86400 * 6), value: 3, label: "games"),
                DailyMetricPoint(date: Date().addingTimeInterval(-86400 * 5), value: 5, label: "games"),
                DailyMetricPoint(date: Date().addingTimeInterval(-86400 * 4), value: 2, label: "games"),
                DailyMetricPoint(date: Date().addingTimeInterval(-86400 * 3), value: 7, label: "games"),
                DailyMetricPoint(date: Date().addingTimeInterval(-86400 * 2), value: 4, label: "games"),
                DailyMetricPoint(date: Date().addingTimeInterval(-86400), value: 6, label: "games"),
                DailyMetricPoint(date: Date(), value: 8, label: "games")
            ]

            let coinsData = [
                DailyMetricPoint(date: Date().addingTimeInterval(-86400 * 6), value: 45, label: "coins"),
                DailyMetricPoint(date: Date().addingTimeInterval(-86400 * 5), value: 72, label: "coins"),
                DailyMetricPoint(date: Date().addingTimeInterval(-86400 * 4), value: 38, label: "coins"),
                DailyMetricPoint(date: Date().addingTimeInterval(-86400 * 3), value: 95, label: "coins"),
                DailyMetricPoint(date: Date().addingTimeInterval(-86400 * 2), value: 68, label: "coins"),
                DailyMetricPoint(date: Date().addingTimeInterval(-86400), value: 84, label: "coins"),
                DailyMetricPoint(date: Date(), value: 120, label: "coins")
            ]

            ChartContainer(title: "Score History", subtitle: "Last 7 days", icon: "chart.line.uptrend.xyaxis") {
                ScoreHistoryChart(data: scoreData, accentColor: .blue)
            }
            .padding(.horizontal)

            ChartContainer(title: "Accuracy Trend", subtitle: "Daily accuracy percentage", icon: "checkmark.circle") {
                AccuracyTrendChart(data: accuracyData, accentColor: .green)
            }
            .padding(.horizontal)

            HStack(spacing: 12) {
                ChartContainer(title: "Games Played", icon: "dice") {
                    DailyActivityChart(data: activityData, accentColor: .purple)
                }

                ChartContainer(title: "Coins Earned", icon: "dollarsign.circle") {
                    CoinsAccumulationChart(data: coinsData)
                }
            }
            .padding(.horizontal)

            // Mini chart
            VStack(alignment: .leading, spacing: 8) {
                Text("Recent Trend")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                MiniScoreChart(scores: [450, 520, 480, 650, 720, 680, 850], color: .blue)
            }
            .padding()
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
        }
        .padding(.vertical)
    }
}
