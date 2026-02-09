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

                    // Card values
                    cardValuesSection

                    // Soft vs Hard
                    softHardSection
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
                helpRow(icon: "number", text: "Calculate the total value of the dealt cards")
                helpRow(icon: "checkmark.circle", text: "Tap the correct hand value before time runs out")
                helpRow(icon: "flame", text: "Build streaks by answering correctly in a row")
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

    private var cardValuesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("CARD VALUES")
                .font(.headline.bold())
                .foregroundStyle(gameState.currentTheme.textColor)

            VStack(spacing: 8) {
                cardValueRow(rank: "2-10", value: "Face value (2=2, 10=10)")
                cardValueRow(rank: "J, Q, K", value: "10")
                cardValueRow(rank: "A", value: "1 or 11 (your choice!)")
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

    private var softHardSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("SOFT VS HARD HANDS")
                .font(.headline.bold())
                .foregroundStyle(gameState.currentTheme.textColor)

            VStack(alignment: .leading, spacing: 8) {
                Text("Soft Hand")
                    .font(.subheadline.bold())
                    .foregroundStyle(gameState.currentTheme.textColor)
                Text("Contains an Ace counted as 11. Example: A-6 is 'Soft 17'")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text("Hard Hand")
                    .font(.subheadline.bold())
                    .foregroundStyle(gameState.currentTheme.textColor)
                Text("No Ace, or Ace counted as 1. Example: 10-7 is 'Hard 17'")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text("Bust")
                    .font(.subheadline.bold())
                    .foregroundStyle(.red)
                Text("Total over 21. You lose!")
                    .font(.caption)
                    .foregroundStyle(.secondary)
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

    private func cardValueRow(rank: String, value: String) -> some View {
        HStack {
            Text(rank)
                .font(.subheadline.bold())
                .foregroundStyle(gameState.currentTheme.textColor)
                .frame(width: 70, alignment: .leading)

            Text(value)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()
        }
    }
}

#Preview {
    HelpView()
}
