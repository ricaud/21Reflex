//
//  StatsView.swift
//  mathgame
//
//  Statistics and achievements display
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

                    // Achievements section
                    achievementsSection
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
                    label: "Questions"
                )

                statCard(
                    icon: "checkmark.circle.fill",
                    iconColor: gameState.currentTheme.correctColor,
                    value: "\(accuracyPercentage)%",
                    label: "Accuracy"
                )

                statCard(
                    icon: "diamond.fill",
                    iconColor: Color(red: 0.9, green: 0.75, blue: 0.2),
                    value: "\(gameState.player.totalCoins)",
                    label: "Total Coins"
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
                    label: "Runs"
                )

                statCard(
                    icon: "bolt.fill",
                    iconColor: .yellow,
                    value: "\(gameState.player.lifetimeStats.buffsCollected)",
                    label: "Buffs"
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

    private var achievementsSection: some View {
        VStack(spacing: 16) {
            Text("ACHIEVEMENTS")
                .font(.headline.bold())
                .foregroundStyle(gameState.currentTheme.textColor)

            VStack(spacing: 12) {
                ForEach(Achievement.allAchievements) { achievement in
                    achievementRow(achievement)
                }
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

    private func achievementRow(_ achievement: Achievement) -> some View {
        let isUnlocked = gameState.player.unlockedAchievements.contains(achievement.id)
        let progress = achievementProgress(for: achievement)

        return HStack(spacing: 12) {
            // Icon
            Image(systemName: achievement.icon)
                .font(.title2)
                .foregroundStyle(isUnlocked ? achievementColor(for: achievement) : .gray)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(isUnlocked ? achievementColor(for: achievement).opacity(0.2) : Color.gray.opacity(0.1))
                )

            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(achievement.name)
                        .font(.subheadline.bold())
                        .foregroundStyle(isUnlocked ? .primary : .secondary)

                    if isUnlocked {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .font(.caption)
                    }
                }

                Text(achievement.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                // Progress bar
                if !isUnlocked && achievement.target > 1 {
                    ProgressView(value: Double(min(progress, achievement.target)), total: Double(achievement.target))
                        .tint(achievementColor(for: achievement))
                }
            }

            Spacer()
        }
        .opacity(isUnlocked ? 1.0 : 0.6)
    }

    private func achievementProgress(for achievement: Achievement) -> Int {
        let player = gameState.player
        switch achievement.id {
        case "first_steps":
            return player.lifetimeStats.totalCorrect
        case "multiplying":
            return player.lifetimeStats.totalCorrect
        case "master":
            return player.lifetimeStats.totalCorrect
        case "speed_demon":
            return 0 // fastAnswers not implemented
        case "collector":
            return player.lifetimeStats.buffsCollected
        case "hoarder":
            return player.totalCoins
        case "survivor":
            return player.highScore.highestCorrectCount
        case "perfection":
            return 0 // perfectRuns not implemented
        case "dedicated":
            return player.lifetimeStats.runsCompleted
        case "streak_master":
            return player.highScore.bestStreak
        case "shopaholic":
            return player.unlockedThemeIds.count - 1 // Exclude default theme
        case "untouchable":
            return 0 // noDamageRuns not implemented
        default:
            return 0
        }
    }

    private func achievementColor(for achievement: Achievement) -> Color {
        switch achievement.id {
        case "first_steps", "multiplying", "master":
            return .blue
        case "speed_demon":
            return .orange
        case "collector", "hoarder":
            return Color(red: 0.9, green: 0.75, blue: 0.2)
        case "survivor", "perfection":
            return .green
        case "dedicated":
            return .purple
        case "streak_master":
            return .red
        case "shopaholic":
            return .pink
        case "untouchable":
            return .cyan
        default:
            return .gray
        }
    }
}

#Preview {
    StatsView()
}
