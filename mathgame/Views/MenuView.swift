//
//  MenuView.swift
//  mathgame
//
//  Main menu with game mode selection
//

import SwiftUI

struct MenuView: View {
    @State private var gameState = GameState.shared

    var body: some View {
        NavigationStack(path: $gameState.navigationPath) {
            ZStack {
                // Background
                gameState.currentTheme.bgColor
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    // Title
                    titleSection

                    // Mode selection
                    modeButtonsSection

                    Spacer()

                    // Bottom toolbar
                    bottomToolbar
                }
                .padding()
            }
            .navigationDestination(for: GameState.Screen.self) { screen in
                switch screen {
                case .game:
                    if gameState.selectedGameMode == .blackjack {
                        BlackjackView()
                    } else {
                        GameView()
                    }
                case .buffSelect:
                    BuffSelectView()
                case .gameOver:
                    GameOverView()
                case .shop:
                    ShopView()
                case .stats:
                    StatsView()
                case .settings:
                    SettingsView()
                case .help:
                    HelpView()
                case .menu:
                    EmptyView()
                }
            }
        }
        .onAppear {
            gameState.audioManager.playMusic(.menu)
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

            // Title
            Text("MATH RUSH")
                .font(.system(size: 48, weight: .black, design: .rounded))
                .foregroundStyle(gameState.currentTheme.textColor)
                .shadow(color: gameState.currentTheme.borderColor, radius: 0, x: 3, y: 3)

            // Subtitle
            Text("MULTIPLY  |  SURVIVE  |  UPGRADE")
                .font(.caption.bold())
                .foregroundStyle(gameState.currentTheme.textColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(gameState.currentTheme.buttonColor)
                )
                .overlay(
                    Capsule()
                        .stroke(gameState.currentTheme.borderColor, lineWidth: 3)
                )

            // Total coins
            HStack(spacing: 8) {
                Diamond()
                    .fill(Color(red: 0.9, green: 0.75, blue: 0.2))
                    .frame(width: 20, height: 20)
                Text("\(gameState.player.totalCoins)")
                    .font(.title2.bold())
                    .foregroundStyle(Color(red: 0.9, green: 0.75, blue: 0.2))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(gameState.currentTheme.buttonColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(gameState.currentTheme.borderColor, lineWidth: 3)
            )
        }
    }

    private var modeButtonsSection: some View {
        VStack(spacing: 12) {
            // Classic
            ThickBorderButton(
                title: "CLASSIC",
                action: { gameState.startGame(mode: .classic) },
                bgColor: gameState.currentTheme.accentColor,
                textColor: .white,
                borderColor: gameState.currentTheme.borderColor,
                borderWidth: 4,
                shadowOffset: 4,
                cornerRadius: 10
            )
            .frame(height: 55)
            .accessibilityLabel("Classic mode")
            .accessibilityHint("Starts a classic game with standard rules")

            // Practice
            ThickBorderButton(
                title: "PRACTICE",
                action: { gameState.startGame(mode: .practice) },
                bgColor: gameState.currentTheme.buttonColor,
                textColor: gameState.currentTheme.textColor,
                borderColor: gameState.currentTheme.borderColor,
                borderWidth: 4,
                shadowOffset: 4,
                cornerRadius: 10
            )
            .frame(height: 50)
            .accessibilityLabel("Practice mode")
            .accessibilityHint("Practice without time limits or penalties")

            // Hard Mode
            ThickBorderButton(
                title: "HARD MODE",
                action: { gameState.startGame(mode: .hard) },
                bgColor: Color(red: 0.8, green: 0.3, blue: 0.3),
                textColor: .white,
                borderColor: gameState.currentTheme.borderColor,
                borderWidth: 4,
                shadowOffset: 4,
                cornerRadius: 10
            )
            .frame(height: 50)
            .accessibilityLabel("Hard mode")
            .accessibilityHint("Shorter timer, no buffs, double coins")

            // Blackjack
            ThickBorderButton(
                title: "BLACKJACK",
                action: { gameState.startGame(mode: .blackjack) },
                bgColor: Color(red: 0.2, green: 0.6, blue: 0.3),
                textColor: .white,
                borderColor: gameState.currentTheme.borderColor,
                borderWidth: 4,
                shadowOffset: 4,
                cornerRadius: 10
            )
            .frame(height: 50)
            .accessibilityLabel("Blackjack mode")
            .accessibilityHint("Practice card counting with casino rules")
        }
    }

    private var bottomToolbar: some View {
        HStack(spacing: 12) {
            toolbarButton(title: "SHOP", icon: "bag.fill", action: {
                gameState.navigate(to: .shop)
            })

            toolbarButton(title: "STATS", icon: "chart.bar.fill", action: {
                gameState.navigate(to: .stats)
            })

            toolbarButton(title: "SETTINGS", icon: "gear", action: {
                gameState.navigate(to: .settings)
            })

            // Help button (smaller)
            Button(action: {
                gameState.navigate(to: .help)
            }) {
                Text("?")
                    .font(.title2.bold())
                    .foregroundStyle(gameState.currentTheme.textColor)
                    .frame(width: 44, height: 44)
                    .background(gameState.currentTheme.buttonColor)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(gameState.currentTheme.borderColor, lineWidth: 3)
                    )
            }
        }
    }

    private func toolbarButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title3)
                Text(title)
                    .font(.caption.bold())
            }
            .foregroundStyle(gameState.currentTheme.textColor)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(gameState.currentTheme.buttonColor)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(gameState.currentTheme.borderColor, lineWidth: 3)
            )
        }
        .accessibilityLabel(title)
    }
}

#Preview {
    MenuView()
}
