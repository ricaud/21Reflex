//
//  HelpView.swift
//  mathgame
//
//  Help and instructions screen
//

import SwiftUI

struct HelpView: View {
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

                    // How to play
                    howToPlaySection

                    // Game modes
                    gameModesSection

                    // Scoring
                    scoringSection

                    // Buffs
                    buffsSection
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

            Text("HOW TO PLAY")
                .font(.system(size: 36, weight: .black, design: .rounded))
                .foregroundStyle(gameState.currentTheme.textColor)
                .shadow(color: gameState.currentTheme.borderColor, radius: 0, x: 3, y: 3)
        }
    }

    private var howToPlaySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("BASICS")
                .font(.headline.bold())
                .foregroundStyle(gameState.currentTheme.textColor)

            VStack(alignment: .leading, spacing: 8) {
                helpRow(icon: "multiply", text: "Solve multiplication problems quickly")
                helpRow(icon: "checkmark.circle", text: "Tap the correct answer before time runs out")
                helpRow(icon: "flame", text: "Build streaks for bonus coins")
                helpRow(icon: "heart", text: "Wrong answers cost health - 3 strikes and you're out!")
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

    private var gameModesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("GAME MODES")
                .font(.headline.bold())
                .foregroundStyle(gameState.currentTheme.textColor)

            VStack(spacing: 12) {
                modeRow(
                    name: "CLASSIC",
                    color: gameState.currentTheme.accentColor,
                    description: "Standard mode with timer and health"
                )

                modeRow(
                    name: "PRACTICE",
                    color: .green,
                    description: "No timer, no health - just practice"
                )

                modeRow(
                    name: "HARD MODE",
                    color: .red,
                    description: "Faster timer, harder questions"
                )

                modeRow(
                    name: "DAILY",
                    color: .blue,
                    description: "Same questions as everyone else today"
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

    private var scoringSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("SCORING")
                .font(.headline.bold())
                .foregroundStyle(gameState.currentTheme.textColor)

            VStack(alignment: .leading, spacing: 8) {
                scoringRow(label: "Base correct answer", value: "+1 coin")
                scoringRow(label: "Streak bonus (every 5)", value: "+1 coin")
                scoringRow(label: "Double Coins buff", value: "2x multiplier")
                scoringRow(label: "Streak Bonus buff", value: "Bonus every 3")
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

    private var buffsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("BUFFS")
                .font(.headline.bold())
                .foregroundStyle(gameState.currentTheme.textColor)

            Text("Choose a buff every 10 correct answers. Buffs stack and last the entire run!")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            VStack(spacing: 8) {
                ForEach(Buff.randomBuffs(count: 5, excluding: [])) { buff in
                    buffRow(buff)
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

    private func helpRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(gameState.currentTheme.accentColor)
                .frame(width: 24)

            Text(text)
                .font(.subheadline)
                .foregroundStyle(gameState.currentTheme.textColor)

            Spacer()
        }
    }

    private func modeRow(name: String, color: Color, description: String) -> some View {
        HStack(spacing: 12) {
            Text(name)
                .font(.caption.bold())
                .foregroundStyle(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(color)
                .clipShape(RoundedRectangle(cornerRadius: 6))

            Text(description)
                .font(.subheadline)
                .foregroundStyle(gameState.currentTheme.textColor)

            Spacer()
        }
    }

    private func scoringRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(gameState.currentTheme.textColor)

            Spacer()

            Text(value)
                .font(.subheadline.bold())
                .foregroundStyle(Color(red: 0.9, green: 0.75, blue: 0.2))
        }
    }

    private func buffRow(_ buff: Buff) -> some View {
        HStack(spacing: 12) {
            Image(systemName: buff.icon)
                .foregroundStyle(gameState.currentTheme.accentColor)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(buff.name)
                    .font(.caption.bold())
                    .foregroundStyle(gameState.currentTheme.textColor)

                Text(buff.description)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }
}

#Preview {
    HelpView()
}
