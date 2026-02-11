//
//  MenuView.swift
//  mathgame
//
//  Main menu with game mode selection
//

import SwiftUI

struct MenuView: View {
    @State private var gameState = GameState.shared

    // Card animation states
    @State private var kingDealt = false
    @State private var aceDealt = false
    @State private var floatingOffset: CGFloat = 0

    // Card models
    let kingOfHearts = Card(suit: .hearts, rank: .king)
    let aceOfSpades = Card(suit: .spades, rank: .ace)

    var body: some View {
        NavigationStack(path: $gameState.navigationPath) {
            ZStack {
                // Background
                gameState.currentTheme.bgColor
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    // Title - always visible
                    titleSection

                    Spacer()

                    // Floating cards - animate in with deal effect
                    floatingCardsSection

                    Spacer()
                    
                    // Play button - always visible
                    playButtonSection

                    // Practice button - always visible
                    practiceButtonSection

                    Spacer()

                    // Bottom toolbar - always visible
                    bottomToolbar.padding(.bottom)
                    
                    //ads here 👹

                }
                .padding()
            }
            .navigationDestination(for: GameState.Screen.self) { screen in
                switch screen {
                    case .game:
                        GameView()
                    case .gameOver:
                        EmptyView()
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

            // Deal King of Hearts first
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeOut(duration: 0.5)) {
                    kingDealt = true
                }
            }

            // Deal Ace of Spades second (0.2s delay after King)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                withAnimation(.easeOut(duration: 0.5)) {
                    aceDealt = true
                }
            }

            // Start floating animation after both cards dealt
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    floatingOffset = -10
                }
            }
        }
    }

    private var floatingCardsSection: some View {
        HStack(spacing: -30) {
            // King of Hearts - slides in from left
            PlayingCardView(card: kingOfHearts)
                .frame(width: 140, height: 191)
                .rotationEffect(.degrees(-5))
                .offset(x: kingDealt ? 0 : -500)
                .animation(.easeOut(duration: 0.5), value: kingDealt)

            // Ace of Spades - slides in from left (dealt second)
            PlayingCardView(card: aceOfSpades)
                .frame(width: 140, height: 191)
                .rotationEffect(.degrees(5))
                .offset(x: aceDealt ? 0 : -500)
                .animation(.easeOut(duration: 0.5), value: aceDealt)
        }
        .offset(y: floatingOffset)
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

    private var practiceButtonSection: some View {
        ThickBorderButton(
            title: "PRACTICE",
            action: { gameState.startPracticeMode() },
            bgColor: gameState.currentTheme.buttonColor,
            textColor: gameState.currentTheme.textColor,
            borderColor: gameState.currentTheme.borderColor,
            borderWidth: 3,
            shadowOffset: 2,
            cornerRadius: 10
        )
        .frame(width: 275, height: 45)
        .accessibilityLabel("Practice Mode")
        .accessibilityHint("Practice without timers or penalties")
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
                    .frame(width: 45, height: 45)
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
