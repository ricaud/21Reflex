//
//  StatsView.swift
//  mathgame
//
//  Statistics display
//

import SwiftUI

struct StatsView: View {
    @State private var gameState = GameState.shared
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            // Background
            gameState.currentTheme.effectiveBgColor(colorScheme)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection

                    // Game Center section
                    gameCenterSection

                    // Statistics grid
                    statisticsSection

                    // Top scores section
                    topScoresSection
                }
                .padding()
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            // Decorative line
            Rectangle()
                .fill(gameState.currentTheme.effectiveAccentColor(colorScheme))
                .frame(height: 8)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(gameState.currentTheme.effectiveBorderColor(colorScheme), lineWidth: 3)
                )

            Text("STATISTICS")
                .font(.system(size: 36, weight: .black, design: .rounded))
                .foregroundStyle(gameState.currentTheme.effectiveTextColor(colorScheme))
                .shadow(color: gameState.currentTheme.effectiveBorderColor(colorScheme), radius: 0, x: 3, y: 3)
        }
    }

    private var gameCenterSection: some View {
        VStack(spacing: 16) {
            Text("GAME CENTER")
                .font(.headline.bold())
                .foregroundStyle(gameState.currentTheme.effectiveTextColor(colorScheme))

            HStack(spacing: 12) {
                // Authentication status
                HStack(spacing: 6) {
                    Image(systemName: GameCenterManager.shared.isAuthenticated ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(GameCenterManager.shared.isAuthenticated ? .green : .red)

                    Text(GameCenterManager.shared.isAuthenticated ? "Connected" : "Not Connected")
                        .font(.subheadline.bold())
                        .foregroundStyle(gameState.currentTheme.effectiveTextColor(colorScheme))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(gameState.currentTheme.effectiveButtonColor(colorScheme))
                )

                Spacer()

                // View Leaderboards button
                Button(action: {
                    gameState.navigate(to: .leaderboards)
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "trophy.fill")
                        Text("Leaderboards")
                            .font(.subheadline.bold())
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.blue)
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(gameState.currentTheme.effectiveButtonColor(colorScheme))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(gameState.currentTheme.effectiveBorderColor(colorScheme), lineWidth: 4)
        )
    }

    private var statisticsSection: some View {
        VStack(spacing: 16) {
            Text("LIFETIME STATS")
                .font(.headline.bold())
                .foregroundStyle(gameState.currentTheme.effectiveTextColor(colorScheme))

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                statCard(
                    icon: "questionmark.circle.fill",
                    iconColor: .blue,
                    value: "\(gameState.player.lifetimeStats.totalQuestionsAnswered)",
                    label: "Hands Played"
                )

                statCard(
                    icon: "checkmark.circle.fill",
                    iconColor: gameState.currentTheme.effectiveCorrectColor(colorScheme),
                    value: "\(accuracyPercentage)%",
                    label: "Accuracy"
                )

                statCard(
                    icon: "flame.fill",
                    iconColor: .orange,
                    value: "\(gameState.player.highScore.bestStreak)",
                    label: "Best Streak"
                )

                statCard(
                    icon: "play.circle.fill",
                    iconColor: .purple,
                    value: "\(gameState.player.lifetimeStats.runsCompleted)",
                    label: "Games Played"
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(gameState.currentTheme.effectiveButtonColor(colorScheme))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(gameState.currentTheme.effectiveBorderColor(colorScheme), lineWidth: 4)
        )
    }

    private var topScoresSection: some View {
        VStack(spacing: 16) {
            Text("TOP SCORES")
                .font(.headline.bold())
                .foregroundStyle(gameState.currentTheme.effectiveTextColor(colorScheme))

            VStack(spacing: 12) {
                ForEach(0..<3, id: \.self) { index in
                    topScoreRow(index: index)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(gameState.currentTheme.effectiveButtonColor(colorScheme))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(gameState.currentTheme.effectiveBorderColor(colorScheme), lineWidth: 4)
        )
    }

    private func topScoreRow(index: Int) -> some View {
        let topScores = gameState.player.highScore.topScores
        let hasScore = index < topScores.count

        return HStack {
            // Medal icon
            Image(systemName: medalIcon(for: index))
                .font(.title3)
                .foregroundStyle(medalColor(for: index))
                .frame(width: 30)

            Text("\(index + 1)\(ordinalSuffix(index))")
                .font(.subheadline.bold())
                .foregroundStyle(gameState.currentTheme.effectiveTextColor(colorScheme))

            Spacer()

            if hasScore {
                Text("\(topScores[index]) pts")
                    .font(.title3.bold())
                    .foregroundStyle(gameState.currentTheme.effectiveTextColor(colorScheme))
            } else {
                Text("-")
                    .font(.title3.bold())
                    .foregroundStyle(gameState.currentTheme.effectiveTextColor(colorScheme).opacity(0.3))
            }
        }
        .padding(.horizontal, 8)
    }

    private func medalIcon(for index: Int) -> String {
        switch index {
        case 0: return "medal.fill"
        case 1: return "medal.fill"
        case 2: return "medal.fill"
        default: return "circle"
        }
    }

    private func medalColor(for index: Int) -> Color {
        switch index {
        case 0: return .yellow  // Gold
        case 1: return .gray    // Silver
        case 2: return .orange  // Bronze
        default: return .clear
        }
    }

    private func ordinalSuffix(_ index: Int) -> String {
        switch index {
        case 0: return "st"
        case 1: return "nd"
        case 2: return "rd"
        default: return "th"
        }
    }

    private func statCard(icon: String, iconColor: Color, value: String, label: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(iconColor)

            Text(value)
                .font(.title3.bold())
                .foregroundStyle(gameState.currentTheme.effectiveTextColor(colorScheme))

            Text(label)
                .font(.caption)
                .foregroundStyle(gameState.currentTheme.effectiveTextColor(colorScheme).opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(gameState.currentTheme.effectiveBgColor(colorScheme).opacity(0.5))
        )
    }

    private var accuracyPercentage: Int {
        let total = gameState.player.lifetimeStats.totalQuestionsAnswered
        let correct = gameState.player.lifetimeStats.totalCorrect
        guard total > 0 else { return 0 }
        return Int((Double(correct) / Double(total)) * 100)
    }
}

#Preview {
    StatsView()
}
