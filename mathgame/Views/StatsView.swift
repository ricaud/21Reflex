//
//  StatsView.swift
//  mathgame
//
//  Statistics display
//

import SwiftUI

struct StatsView: View {
    @State private var gameState = GameState.shared

    var body: some View {
        ZStack {
            // Background
            gameState.currentTheme.bgColor
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection

                    // Statistics grid
                    statisticsSection
                }
                .padding()
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            // Decorative line
            Rectangle()
                .fill(gameState.currentTheme.accentColor)
                .frame(height: 8)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(gameState.currentTheme.borderColor, lineWidth: 3)
                )

            Text("STATISTICS")
                .font(.system(size: 36, weight: .black, design: .rounded))
                .foregroundStyle(gameState.currentTheme.textColor)
                .shadow(color: gameState.currentTheme.borderColor, radius: 0, x: 3, y: 3)
        }
    }

    private var statisticsSection: some View {
        VStack(spacing: 16) {
            Text("LIFETIME STATS")
                .font(.headline.bold())
                .foregroundStyle(gameState.currentTheme.textColor)

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
                    iconColor: gameState.currentTheme.correctColor,
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
                .fill(gameState.currentTheme.buttonColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(gameState.currentTheme.borderColor, lineWidth: 4)
        )
    }

    private func statCard(icon: String, iconColor: Color, value: String, label: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(iconColor)

            Text(value)
                .font(.title3.bold())
                .foregroundStyle(gameState.currentTheme.textColor)

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(gameState.currentTheme.bgColor.opacity(0.5))
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
