//
//  BuffSelectView.swift
//  mathgame
//
//  Buff selection screen
//

import SwiftUI

struct BuffSelectView: View {
    @State private var gameState = GameState.shared
    @State private var buffs: [Buff] = []

    var body: some View {
        ZStack {
            // Background
            gameState.currentTheme.bgColor
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // Header
                headerSection

                // Progress
                Text("CORRECT: \(gameState.player.correctCount)")
                    .font(.headline)
                    .foregroundStyle(gameState.currentTheme.textColor)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(gameState.currentTheme.buttonColor)
                    )
                    .overlay(
                        Capsule()
                            .stroke(gameState.currentTheme.borderColor, lineWidth: 3)
                    )

                // Buff cards
                VStack(spacing: 16) {
                    ForEach(Array(buffs.enumerated()), id: \.element.id) { index, buff in
                        GameCard(
                            title: buff.name,
                            description: buff.description,
                            icon: buff.icon,
                            action: { selectBuff(buff) }
                        )
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding()
        }
        .onAppear {
            // Get 3 random buffs
            buffs = Buff.randomBuffs(count: 3, excluding: gameState.player.activeBuffs.map { $0.buff })
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

            Text("CHOOSE A BUFF!")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(gameState.currentTheme.accentColor)
        }
    }

    private func selectBuff(_ buff: Buff) {
        gameState.selectBuff(buff)
    }
}

#Preview {
    BuffSelectView()
}
