//
//  LeaderboardsView.swift
//  mathgame
//
//  Game Center leaderboards view
//

import SwiftUI
import GameKit

struct LeaderboardsView: View {
    @State private var gameState = GameState.shared
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    @State private var localPlayerScores: [GameCenterManager.LeaderboardID: Int] = [:]
    @State private var isLoading = true

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

                // Leaderboards list
                leaderboardsList

                Spacer()
            }
            .padding()
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

            Text("LEADERBOARDS")
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

    // MARK: - Leaderboards List

    private var leaderboardsList: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach([GameCenterManager.LeaderboardID.highScore,
                         .bestStreak,
                         .mostCorrect,
                         .weeklyHighScore], id: \.self) { leaderboard in
                    LeaderboardRow(
                        leaderboard: leaderboard,
                        score: localPlayerScores[leaderboard] ?? 0,
                        isAuthenticated: GameCenterManager.shared.isAuthenticated,
                        colorScheme: colorScheme
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Leaderboard Row

struct LeaderboardRow: View {
    let leaderboard: GameCenterManager.LeaderboardID
    let score: Int
    let isAuthenticated: Bool
    let colorScheme: ColorScheme

    @State private var gameState = GameState.shared

    var body: some View {
        Button(action: {
            // Show Game Center leaderboard
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                GameCenterManager.shared.showLeaderboard(leaderboard, from: rootVC)
            }
        }) {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: iconName)
                    .font(.title2)
                    .foregroundStyle(gameState.currentTheme.effectiveAccentColor(colorScheme))
                    .frame(width: 40)

                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(leaderboard.displayName)
                        .font(.headline.bold())
                        .foregroundStyle(gameState.currentTheme.effectiveTextColor(colorScheme))

                    if isAuthenticated {
                        Text("Your Score: \(score)")
                            .font(.subheadline)
                            .foregroundStyle(gameState.currentTheme.effectiveTextColor(colorScheme).opacity(0.7))
                    } else {
                        Text("Sign in to view")
                            .font(.subheadline)
                            .foregroundStyle(gameState.currentTheme.effectiveTextColor(colorScheme).opacity(0.5))
                    }
                }

                Spacer()

                // Arrow
                Image(systemName: "chevron.right")
                    .foregroundStyle(gameState.currentTheme.effectiveAccentColor(colorScheme))
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
        }
        .disabled(!isAuthenticated)
        .opacity(isAuthenticated ? 1.0 : 0.6)
    }

    private var iconName: String {
        switch leaderboard {
        case .highScore, .weeklyHighScore:
            return "trophy.fill"
        case .bestStreak:
            return "flame.fill"
        case .mostCorrect:
            return "checkmark.circle.fill"
        }
    }
}

// MARK: - Preview

#Preview {
    LeaderboardsView()
}
