//
//  AchievementsView.swift
//  mathgame
//
//  Game Center achievements view
//

import SwiftUI
import GameKit

struct AchievementsView: View {
    @State private var gameState = GameState.shared
    @Environment(\.colorScheme) private var colorScheme

    // Achievement progress tracking
    @State private var achievementProgress: [GameCenterManager.AchievementID: Double] = [:]

    var body: some View {
        ZStack {
            // Background
            gameState.currentTheme.effectiveBgColor(colorScheme)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // Header
                headerSection

                // Game Center status
                gameCenterStatusSection

                // Achievements list
                achievementsList

                Spacer()
            }
            .padding()
        }
        .onAppear {
            loadAchievementProgress()
        }
    }

    // MARK: - Header Section

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

            Text("ACHIEVEMENTS")
                .font(.system(size: 36, weight: .black, design: .rounded))
                .foregroundStyle(gameState.currentTheme.effectiveTextColor(colorScheme))
                .shadow(color: gameState.currentTheme.effectiveBorderColor(colorScheme), radius: 0, x: 3, y: 3)
        }
    }

    // MARK: - Game Center Status

    @ViewBuilder
    private var gameCenterStatusSection: some View {
        if GameCenterManager.shared.isAuthenticated {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)

                Text("Signed in to Game Center")
                    .font(.subheadline)
                    .foregroundStyle(gameState.currentTheme.effectiveTextColor(colorScheme))

                if let player = GameCenterManager.shared.localPlayer {
                    Text("(\(player.displayName))")
                        .font(.subheadline)
                        .foregroundStyle(gameState.currentTheme.effectiveTextColor(colorScheme).opacity(0.7))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(gameState.currentTheme.effectiveButtonColor(colorScheme))
            )
            .overlay(
                Capsule()
                    .stroke(gameState.currentTheme.effectiveBorderColor(colorScheme), lineWidth: 2)
            )
        } else {
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.red)

                    Text("Not signed in to Game Center")
                        .font(.subheadline)
                        .foregroundStyle(gameState.currentTheme.effectiveTextColor(colorScheme))
                }

                Button("Sign In") {
                    // Open Game Center settings
                    if let url = URL(string: "gamecenter:") {
                        UIApplication.shared.open(url)
                    }
                }
                .font(.caption.bold())
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.blue)
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(gameState.currentTheme.effectiveButtonColor(colorScheme))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(gameState.currentTheme.effectiveBorderColor(colorScheme), lineWidth: 2)
            )
        }
    }

    // MARK: - Achievements List

    private var achievementsList: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach([
                    GameCenterManager.AchievementID.firstSteps,
                    .speedDemon,
                    .streakMaster,
                    .themeCollector,
                    .millionaire,
                    .blackjackPro
                ], id: \.self) { achievement in
                    AchievementRow(
                        achievement: achievement,
                        progress: achievementProgress[achievement] ?? 0,
                        isAuthenticated: GameCenterManager.shared.isAuthenticated,
                        colorScheme: colorScheme
                    )
                }
            }
            .padding(.horizontal)
        }
    }

    private func loadAchievementProgress() {
        // Load current progress from GameState
        achievementProgress[.firstSteps] = gameState.player.lifetimeStats.totalCorrect >= 1 ? 100 : 0
        achievementProgress[.streakMaster] = min(Double(gameState.player.highScore.bestStreak) / 20.0 * 100, 100)
        achievementProgress[.themeCollector] = min(Double(gameState.availableThemes.filter { $0.isUnlocked }.count) / 5.0 * 100, 100)

        let totalCoins = gameState.persistentPlayer?.totalCoinsEarned ?? 0
        achievementProgress[.millionaire] = min(Double(totalCoins) / 1_000_000.0 * 100, 100)

        let totalCorrect = gameState.persistentPlayer?.totalCorrect ?? 0
        achievementProgress[.blackjackPro] = min(Double(totalCorrect) / 100.0 * 100, 100)

        // Speed Demon requires tracking fastest answer time (not yet implemented)
        achievementProgress[.speedDemon] = 0
    }
}

// MARK: - Achievement Row

struct AchievementRow: View {
    let achievement: GameCenterManager.AchievementID
    let progress: Double
    let isAuthenticated: Bool
    let colorScheme: ColorScheme

    @State private var gameState = GameState.shared

    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: iconName)
                .font(.title2)
                .foregroundStyle(isCompleted ? .yellow : gameState.currentTheme.effectiveAccentColor(colorScheme))
                .frame(width: 40)

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.displayName)
                    .font(.headline.bold())
                    .foregroundStyle(gameState.currentTheme.effectiveTextColor(colorScheme))

                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(gameState.currentTheme.effectiveTextColor(colorScheme).opacity(0.7))

                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: 4)
                            .fill(gameState.currentTheme.effectiveBgColor(colorScheme).opacity(0.5))
                            .frame(height: 8)

                        // Progress
                        RoundedRectangle(cornerRadius: 4)
                            .fill(isCompleted ? Color.green : gameState.currentTheme.effectiveAccentColor(colorScheme))
                            .frame(width: geometry.size.width * CGFloat(progress / 100), height: 8)
                    }
                }
                .frame(height: 8)

                Text("\(Int(progress))%")
                    .font(.caption.bold())
                    .foregroundStyle(isCompleted ? .green : gameState.currentTheme.effectiveTextColor(colorScheme).opacity(0.7))
            }

            Spacer()

            // Completion indicator
            if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.green)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(gameState.currentTheme.effectiveButtonColor(colorScheme))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(gameState.currentTheme.effectiveBorderColor(colorScheme), lineWidth: 2)
        )
        .opacity(isAuthenticated ? 1.0 : 0.6)
    }

    private var isCompleted: Bool {
        progress >= 100
    }

    private var iconName: String {
        switch achievement {
        case .firstSteps:
            return "figure.walk"
        case .speedDemon:
            return "bolt.fill"
        case .streakMaster:
            return "flame.fill"
        case .themeCollector:
            return "paintpalette.fill"
        case .millionaire:
            return "dollarsign.circle.fill"
        case .blackjackPro:
            return "suit.spade.fill"
        }
    }

    private var description: String {
        switch achievement {
        case .firstSteps:
            return "Answer your first question correctly"
        case .speedDemon:
            return "Answer correctly in under 2 seconds"
        case .streakMaster:
            return "Reach a streak of 20 correct answers"
        case .themeCollector:
            return "Unlock 5 different themes"
        case .millionaire:
            return "Earn 1,000,000 coins total"
        case .blackjackPro:
            return "Answer 100 questions correctly"
        }
    }
}

// MARK: - Preview

#Preview {
    AchievementsView()
}
