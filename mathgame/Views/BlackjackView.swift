//
//  BlackjackView.swift
//  mathgame
//
//  Blackjack card counting mode gameplay view
//

import SwiftUI

struct BlackjackView: View {
    @State private var gameState = GameState.shared
    @State private var selectedAnswer: BlackjackSession.AnswerOption?
    @State private var showFeedback = false
    @State private var feedbackText = ""
    @State private var feedbackColor: Color = .green
    @State private var shakeOffset: CGFloat = 0
    @State private var isMuted = false

    var body: some View {
        ZStack {
            // Background
            gameState.currentTheme.bgColor
                .ignoresSafeArea()

            VStack(spacing: 16) {
                // Header
                headerSection

                // Timer bar
                TimerBar(progress: timerProgress)
                    .padding(.horizontal)
                    .accessibilityElement()
                    .accessibilityLabel("Time remaining")
                    .accessibilityValue("\(Int(gameState.blackjackSession?.timeRemaining ?? 0)) seconds")

                // Cards display
                cardsSection

                // Prompt
                Text("What's the total?")
                    .font(.headline)
                    .foregroundStyle(gameState.currentTheme.textColor)

                // Feedback
                Text(feedbackText)
                    .font(.title.bold())
                    .foregroundStyle(feedbackColor)
                    .opacity(showFeedback ? 1 : 0)
                    .frame(height: 40)

                // Answer buttons
                answerButtonsSection
                    .padding(.top, 8)

                // Controls
                controlsSection

                Spacer()
            }
            .padding()

            // Pause overlay
            if gameState.showPauseOverlay {
                PauseView()
            }
        }
        .offset(x: shakeOffset)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            gameState.hapticManager.prepare()
        }
    }

    private var controlsSection: some View {
        HStack(spacing: 20) {
            // Pause button
            Button(action: { gameState.togglePause() }) {
                Image(systemName: "pause.fill")
                    .font(.title2)
                    .foregroundStyle(gameState.currentTheme.textColor)
                    .frame(width: 50, height: 50)
                    .background(gameState.currentTheme.buttonColor)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(gameState.currentTheme.borderColor, lineWidth: 2)
                    )
            }
            .accessibilityLabel("Pause game")
            .accessibilityHint("Opens pause menu")

            // Mute button
            Button(action: { isMuted.toggle() }) {
                Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.fill")
                    .font(.title2)
                    .foregroundStyle(gameState.currentTheme.textColor)
                    .frame(width: 50, height: 50)
                    .background(gameState.currentTheme.buttonColor)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(gameState.currentTheme.borderColor, lineWidth: 2)
                    )
            }
            .accessibilityLabel(isMuted ? "Unmute sound" : "Mute sound")
            .accessibilityHint("Toggles game audio")
        }
        .padding(.top, 16)
    }

    private var headerSection: some View {
        HStack {
            // Mode indicator
            Text("Blackjack")
                .font(.caption.bold())
                .foregroundStyle(Color(red: 0.2, green: 0.6, blue: 0.3))

            Spacer()

            // Health
            if gameState.player.health > 0 {
                HealthIndicator(
                    current: gameState.player.health,
                    max: 3 + gameState.player.activeBuffs
                        .filter { $0.buff.id == "extra_health" }
                        .reduce(0) { $0 + $1.remainingUses }
                )
            }

            Spacer()

            // Streak
            StreakBadge(streak: gameState.player.streak)
        }
        .padding(.horizontal)
    }

    private var timerProgress: Double {
        guard let session = gameState.blackjackSession else { return 1.0 }
        return max(0, min(1, session.timeRemaining / session.timeLimit))
    }

    private var cardsSection: some View {
        VStack(spacing: 8) {
            // Cards display
            HStack(spacing: -25) {
                if let session = gameState.blackjackSession {
                    ForEach(session.currentCards) { card in
                        PlayingCardView(card: card)
                            .transition(.asymmetric(
                                insertion: .offset(x: 50).combined(with: .opacity),
                                removal: .opacity
                            ))
                    }
                }
            }
            .frame(height: 110)
            .padding(.horizontal, 30)
            .padding(.vertical, 10)

            // Show current hand value with soft/hard/bust indicator
            if let session = gameState.blackjackSession {
                let handValue = session.handValue
                Text(handValue.displayText)
                    .font(.caption.bold())
                    .foregroundStyle(
                        handValue.isBust ? .red :
                        (handValue.isSoft ? Color(red: 0.2, green: 0.8, blue: 0.3) : gameState.currentTheme.textColor)
                    )
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(gameState.currentTheme.bgColor.opacity(0.8))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                handValue.isBust ? Color.red.opacity(0.5) :
                                (handValue.isSoft ? Color.green.opacity(0.5) : Color.clear),
                                lineWidth: 1
                            )
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

    private var answerButtonsSection: some View {
        let columns = [
            GridItem(.flexible()),
            GridItem(.flexible())
        ]

        let isTimerExpired = gameState.blackjackSession?.timeRemaining ?? 1 <= 0

        return LazyVGrid(columns: columns, spacing: 16) {
            ForEach(gameState.blackjackSession?.answerOptions ?? []) { option in
                ThickBorderButton(
                    title: "\(option.value)",
                    action: { handleAnswer(option) },
                    bgColor: buttonColor(for: option),
                    textColor: gameState.currentTheme.textColor,
                    borderColor: gameState.currentTheme.borderColor,
                    borderWidth: 4,
                    shadowOffset: 5,
                    cornerRadius: 12,
                    font: .system(size: 36, weight: .bold)
                )
                .frame(height: 90)
                .disabled(isTimerExpired)
                .opacity(isTimerExpired ? 0.5 : 1)
                .accessibilityLabel("Answer option \(option.value)")
                .accessibilityHint("Select this as the total card value")
            }
        }
    }

    private func buttonColor(for option: BlackjackSession.AnswerOption) -> Color {
        if selectedAnswer?.id == option.id {
            return option.isCorrect ? gameState.currentTheme.correctColor : gameState.currentTheme.wrongColor
        }
        return gameState.currentTheme.buttonColor
    }

    private func handleAnswer(_ option: BlackjackSession.AnswerOption) {
        selectedAnswer = option

        if option.isCorrect {
            // Correct answer
            feedbackText = "CORRECT!"
            feedbackColor = gameState.currentTheme.correctColor
            showFeedback = true

            gameState.player.handleCorrectAnswer()
            gameState.audioManager.playSound(.correct)
            gameState.hapticManager.playCorrectFeedback()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation {
                    gameState.blackjackSession?.handleCorrectAnswer()
                }
                resetFeedback()
            }
        } else {
            // Wrong answer
            feedbackText = "WRONG!"
            feedbackColor = gameState.currentTheme.wrongColor
            showFeedback = true

            gameState.audioManager.playSound(.wrong)
            gameState.hapticManager.playWrongFeedback()

            // Shake animation
            withAnimation(.easeInOut(duration: 0.05).repeatCount(4, autoreverses: true)) {
                shakeOffset = 10
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                shakeOffset = 0
            }

            // Handle wrong answer through player
            let result = gameState.player.handleWrongAnswer()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                switch result {
                case .gameOver:
                    gameState.endGame()
                case .shieldUsed, .luckySave, .secondChanceUsed:
                    gameState.blackjackSession?.handleWrongAnswer()
                case .normal:
                    gameState.blackjackSession?.handleWrongAnswer()
                }
                resetFeedback()
            }
        }
    }

    private func resetFeedback() {
        showFeedback = false
        selectedAnswer = nil
    }
}

#Preview {
    BlackjackView()
}
