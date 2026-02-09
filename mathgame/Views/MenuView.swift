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

                    // Play button
                    playButtonSection

                    Spacer()

                    // Bottom toolbar
                    bottomToolbar
                }
                .padding()
            }
            .navigationDestination(for: GameState.Screen.self) { screen in
                switch screen {
                case .game:
                    GameView()
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
            Text("CARD COUNT")
                .font(.system(size: 44, weight: .black, design: .rounded))
                .foregroundStyle(gameState.currentTheme.textColor)
                .shadow(color: gameState.currentTheme.borderColor, radius: 0, x: 3, y: 3)

            // Subtitle
            Text("PRACTICE BLACKJACK CARD COUNTING")
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

        }
    }

    private var playButtonSection: some View {
        ThickBorderButton(
            title: "PLAY",
            action: { gameState.startGame() },
            bgColor: Color(red: 0.2, green: 0.6, blue: 0.3),
            textColor: .white,
            borderColor: gameState.currentTheme.borderColor,
            borderWidth: 4,
            shadowOffset: 4,
            cornerRadius: 10
        )
        .frame(height: 60)
        .accessibilityLabel("Play Blackjack")
        .accessibilityHint("Start a new blackjack card counting game")
    }

    private var bottomToolbar: some View {
        HStack(spacing: 12) {
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
