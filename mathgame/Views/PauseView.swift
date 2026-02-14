//
//  PauseView.swift
//  mathgame
//
//  Pause overlay with game controls and stats
//

import SwiftUI

struct PauseView: View {
    @State private var gameState = GameState.shared
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            // Dark background
            Color.black.opacity(0.85)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer()

                // Paused title
                Text("PAUSED!")
                    .font(.system(size: 44, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(radius: 4)

                // Stats panel
                statsPanel

                Spacer()

                // Mute button
                Button(action: {
                    let newMutedValue = !gameState.audioManager.isMuted
                    gameState.audioManager.setMuted(newMutedValue)
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: gameState.audioManager.isMuted ? "speaker.slash.fill" : "speaker.fill")
                        Text(gameState.audioManager.isMuted ? "Sound Off" : "Sound On")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.1))
                    )
                }
                .padding(.bottom, 8)

                // Menu buttons
                VStack(spacing: 12) {
                    // Resume
                    ThickBorderButton(
                        title: "RESUME",
                        action: { gameState.resumeGame() },
                        bgColor: gameState.currentTheme.effectiveCorrectColor(colorScheme),
                        textColor: .white,
                        borderColor: .white,
                        borderWidth: 3,
                        shadowOffset: 4,
                        cornerRadius: 12
                    )
                    .frame(height: 55)

                    // Restart
                    ThickBorderButton(
                        title: "RESTART",
                        action: { gameState.restartGame() },
                        bgColor: gameState.currentTheme.effectiveButtonColor(colorScheme),
                        textColor: gameState.currentTheme.effectiveTextColor(colorScheme),
                        borderColor: .white,
                        borderWidth: 3,
                        shadowOffset: 4,
                        cornerRadius: 12
                    )
                    .frame(height: 50)

                    // Quit
                    ThickBorderButton(
                        title: "EXIT GAME",
                        action: { gameState.returnToMenu() },
                        bgColor: Color(red: 0.8, green: 0.3, blue: 0.3),
                        textColor: .white,
                        borderColor: .white,
                        borderWidth: 3,
                        shadowOffset: 4,
                        cornerRadius: 12
                    )
                    .frame(height: 50)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 20)
                
                Spacer()
            }
            .padding(.top, 40)
        }
    }

    private var statsPanel: some View {
        VStack(spacing: 16) {
            Text("RUN STATS")
                .font(.headline.bold())
                .foregroundStyle(.white)

            HStack(spacing: 20) {
                // Questions answered
                let totalAnswered = gameState.player.correctCount + gameState.player.wrongCount
                statBox(
                    value: "\(totalAnswered)",
                    label: "Answered",
                    color: .blue
                )

                // Correct
                statBox(
                    value: "\(gameState.player.correctCount)",
                    label: "Correct",
                    color: gameState.currentTheme.effectiveCorrectColor(colorScheme)
                )

                // Wrong
                statBox(
                    value: "\(gameState.player.wrongCount)",
                    label: "Wrong",
                    color: gameState.currentTheme.effectiveWrongColor(colorScheme)
                )
            }

            // Accuracy bar
            let total = gameState.player.correctCount + gameState.player.wrongCount
            let accuracy = total > 0 ? Double(gameState.player.correctCount) / Double(total) : 0

            VStack(spacing: 4) {
                HStack {
                    Text("Accuracy")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                    Spacer()
                    Text("\(Int(accuracy * 100))%")
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.2))
                            .frame(height: 8)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(accuracy >= 0.7 ? Color.green : (accuracy >= 0.4 ? Color.yellow : Color.red))
                            .frame(width: geo.size.width * CGFloat(accuracy), height: 8)
                    }
                }
                .frame(height: 8)
            }
            .padding(.top, 8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.3), lineWidth: 2)
        )
        .padding(.horizontal, 20)
    }

    private func statBox(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.bold())
                .foregroundStyle(color)
            Text(label)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

}

#Preview {
    PauseView()
}
