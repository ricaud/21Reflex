//
//  GameOverView.swift
//  mathgame
//
//  Game over screen with run statistics
//

import SwiftUI

struct GameOverView: View {
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

                    // Stats panel
                    statsPanel

                    // Buttons
                    buttonsSection
                }
                .padding()
                .padding(.top, 40)
            }
        }
        .onAppear {
            gameState.audioManager.playMusic(.gameOver)
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("GAME OVER")
                .font(.system(size: 48, weight: .black, design: .rounded))
                .foregroundStyle(gameState.currentTheme.effectiveWrongColor(colorScheme))
                .shadow(color: gameState.currentTheme.effectiveBorderColor(colorScheme), radius: 0, x: 3, y: 3)

            if let session = gameState.session {
                Text("Final Score: \(session.totalSessionPoints) pts")
                    .font(.title2.bold())
                    .foregroundStyle(gameState.currentTheme.effectiveTextColor(colorScheme))
            }
        }
    }

    private var statsPanel: some View {
        VStack(spacing: 20) {
            Text("RUN STATS")
                .font(.headline.bold())
                .foregroundStyle(gameState.currentTheme.effectiveTextColor(colorScheme))

            // Stats grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                statBox(
                    value: "\(gameState.player.correctCount + gameState.player.wrongCount)",
                    label: "Questions",
                    color: .blue
                )

                statBox(
                    value: "\(gameState.player.correctCount)",
                    label: "Correct",
                    color: gameState.currentTheme.effectiveCorrectColor(colorScheme)
                )

                statBox(
                    value: "\(gameState.player.wrongCount)",
                    label: "Wrong",
                    color: gameState.currentTheme.effectiveWrongColor(colorScheme)
                )

                statBox(
                    value: "\(runAccuracy)%",
                    label: "Accuracy",
                    color: .orange
                )

                statBox(
                    value: "\(gameState.player.streak)",
                    label: "Best Streak",
                    color: .purple
                )

                statBox(
                    value: "\(gameState.player.coins)",
                    label: "Coins Earned",
                    color: .yellow
                )
            }

            // Session points
            if let session = gameState.session {
                VStack(spacing: 8) {
                    Text("SESSION POINTS")
                        .font(.caption.bold())
                        .foregroundStyle(gameState.currentTheme.effectiveTextColor(colorScheme).opacity(0.7))

                    Text("\(session.totalSessionPoints)")
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .foregroundStyle(gameState.currentTheme.effectiveAccentColor(colorScheme))
                }
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(gameState.currentTheme.effectiveButtonColor(colorScheme).opacity(0.5))
                )
            }

            // Top score comparison
            if let topScore = gameState.player.highScore.topScores.first {
                VStack(spacing: 4) {
                    Text("YOUR TOP SCORE")
                        .font(.caption.bold())
                        .foregroundStyle(gameState.currentTheme.effectiveTextColor(colorScheme).opacity(0.7))

                    Text("\(topScore) pts")
                        .font(.title.bold())
                        .foregroundStyle(gameState.currentTheme.effectiveTextColor(colorScheme))
                }
                .padding(.vertical, 8)
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

    private var buttonsSection: some View {
        VStack(spacing: 16) {
            // Replay button
            ThickBorderButton(
                title: "PLAY AGAIN",
                action: { gameState.restartGame() },
                bgColor: gameState.currentTheme.effectiveCorrectColor(colorScheme),
                textColor: .white,
                borderColor: gameState.currentTheme.effectiveBorderColor(colorScheme),
                borderWidth: 4,
                shadowOffset: 4,
                cornerRadius: 12
            )
            .frame(height: 60)

            // Return to menu button
            ThickBorderButton(
                title: "RETURN TO MENU",
                action: { gameState.returnToMenu() },
                bgColor: gameState.currentTheme.effectiveButtonColor(colorScheme),
                textColor: gameState.currentTheme.effectiveTextColor(colorScheme),
                borderColor: gameState.currentTheme.effectiveBorderColor(colorScheme),
                borderWidth: 3,
                shadowOffset: 3,
                cornerRadius: 12
            )
            .frame(height: 50)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    private func statBox(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.title2.bold())
                .foregroundStyle(color)

            Text(label)
                .font(.caption)
                .foregroundStyle(gameState.currentTheme.effectiveTextColor(colorScheme).opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(gameState.currentTheme.effectiveBgColor(colorScheme).opacity(0.5))
        )
    }

    private var runAccuracy: Int {
        let total = gameState.player.correctCount + gameState.player.wrongCount
        guard total > 0 else { return 0 }
        return Int((Double(gameState.player.correctCount) / Double(total)) * 100)
    }
}

#Preview {
    GameOverView()
}
