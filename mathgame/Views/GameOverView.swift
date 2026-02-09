//
//  GameOverView.swift
//  mathgame
//
//  Game over screen with stats and options
//

import SwiftUI

struct GameOverView: View {
    @State private var gameState = GameState.shared

    var body: some View {
        ZStack {
            // Background
            gameState.currentTheme.bgColor
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // Title
                titleSection

                // New record badge (if applicable)
                if hasNewRecord {
                    newRecordBadge
                }

                // Stats panel
                statsPanel

                Spacer()

                // Action buttons
                actionButtons
            }
            .padding()
        }
        .onAppear {
            gameState.audioManager.playMusic(.gameOver)
        }
    }

    private var titleSection: some View {
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

            Text("GAME OVER")
                .font(.system(size: 40, weight: .black, design: .rounded))
                .foregroundStyle(gameState.currentTheme.textColor)
                .shadow(color: gameState.currentTheme.borderColor, radius: 0, x: 3, y: 3)
        }
    }

    private var newRecordBadge: some View {
        Text("NEW RECORD!")
            .font(.title2.bold())
            .foregroundStyle(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.9, green: 0.75, blue: 0.2))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(gameState.currentTheme.borderColor, lineWidth: 3)
            )
    }

    private var statsPanel: some View {
        VStack(spacing: 16) {
            // Correct answers
            statRow(
                icon: "checkmark.circle.fill",
                iconColor: gameState.currentTheme.correctColor,
                label: "CORRECT",
                value: "\(gameState.player.correctCount)"
            )

            // Best streak
            statRow(
                icon: "flame.fill",
                iconColor: .orange,
                label: "BEST STREAK",
                value: "\(gameState.player.highScore.bestStreak)"
            )

            // Coins earned this run
            statRow(
                icon: "diamond.fill",
                iconColor: Color(red: 0.9, green: 0.75, blue: 0.2),
                label: "COINS EARNED",
                value: "\(gameState.player.coins)"
            )

            Divider()
                .background(gameState.currentTheme.borderColor)

            // Total coins
            HStack {
                Image(systemName: "diamond.fill")
                    .foregroundStyle(Color(red: 0.9, green: 0.75, blue: 0.2))

                Text("TOTAL COINS")
                    .font(.headline)
                    .foregroundStyle(gameState.currentTheme.textColor)

                Spacer()

                Text("\(gameState.player.totalCoins)")
                    .font(.title2.bold())
                    .foregroundStyle(Color(red: 0.9, green: 0.75, blue: 0.2))
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

    private func statRow(icon: String, iconColor: Color, label: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(iconColor)
                .font(.title2)

            Text(label)
                .font(.headline)
                .foregroundStyle(gameState.currentTheme.textColor)

            Spacer()

            Text(value)
                .font(.title2.bold())
                .foregroundStyle(gameState.currentTheme.textColor)
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            // Play Again
            ThickBorderButton(
                title: "PLAY AGAIN",
                action: { gameState.restartGame() },
                bgColor: gameState.currentTheme.correctColor,
                textColor: .white,
                borderColor: gameState.currentTheme.borderColor,
                borderWidth: 4,
                shadowOffset: 4,
                cornerRadius: 12
            )
            .frame(height: 55)

            // Main Menu
            ThickBorderButton(
                title: "MAIN MENU",
                action: { gameState.returnToMenu() },
                bgColor: gameState.currentTheme.buttonColor,
                textColor: gameState.currentTheme.textColor,
                borderColor: gameState.currentTheme.borderColor,
                borderWidth: 4,
                shadowOffset: 4,
                cornerRadius: 12
            )
            .frame(height: 50)
        }
    }

    private var hasNewRecord: Bool {
        let player = gameState.player
        return player.correctCount > player.highScore.highestCorrectCount ||
               player.streak > player.highScore.bestStreak ||
               player.coins > player.highScore.mostCoinsInRun
    }
}

#Preview {
    GameOverView()
}
