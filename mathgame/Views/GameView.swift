//
//  GameView.swift
//  mathgame
//
//  Main gameplay view
//

import SwiftUI

struct GameView: View {
    @State private var gameState = GameState.shared
    @State private var selectedAnswer: GameSession.AnswerOption?
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
                if let session = gameState.session, session.mode.hasTimer {
                    TimerBar(progress: timerProgress)
                        .padding(.horizontal)
                        .accessibilityLabel("Time remaining")
                        .accessibilityValue("\(Int(session.timeRemaining)) seconds")
                }

                // Question
                questionSection

                // Feedback (always takes space to prevent layout shift)
                Text(feedbackText)
                    .font(.title.bold())
                    .foregroundStyle(feedbackColor)
                    .opacity(showFeedback ? 1 : 0)

                // Answer buttons
                answerButtonsSection
                    .padding(.top, 20)

                // Pause and Mute controls
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
            Text(gameState.session?.mode.rawValue ?? "")
                .font(.caption.bold())
                .foregroundStyle(modeColor)

            Spacer()

            // Health (if applicable)
            if gameState.session?.mode.hasHealth == true {
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

    private var modeColor: Color {
        switch gameState.session?.mode {
        case .practice:
            return .green
        case .hard:
            return .red
        case .blackjack:
            return Color(red: 0.2, green: 0.6, blue: 0.3)
        default:
            return .primary
        }
    }

    private var timerProgress: Double {
        guard let session = gameState.session else { return 1.0 }
        return max(0, min(1, session.timeRemaining / session.timeLimit))
    }

    private var questionSection: some View {
        VStack(spacing: 20) {
            // Boss battle indicator
            if gameState.session?.isBossBattle == true {
                Text("⚔️ BOSS BATTLE ⚔️")
                    .font(.headline.bold())
                    .foregroundStyle(.purple)
            }

            // Question text
            if let question = gameState.session?.currentQuestion {
                Text(question.text)
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .foregroundStyle(gameState.currentTheme.textColor)
                    .minimumScaleFactor(0.5)
            }
        }
        .frame(maxWidth: .infinity)
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

        let isTimerExpired = gameState.session?.mode.hasTimer == true &&
                            gameState.session?.timeRemaining ?? 1 <= 0

        return LazyVGrid(columns: columns, spacing: 16) {
            ForEach(gameState.session?.answerOptions ?? []) { option in
                ThickBorderButton(
                    title: option.text,
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
                .accessibilityHint("Select this as your answer")
            }
        }
    }

    private func buttonColor(for option: GameSession.AnswerOption) -> Color {
        if selectedAnswer?.id == option.id {
            return option.isCorrect ? gameState.currentTheme.correctColor : gameState.currentTheme.wrongColor
        }
        return gameState.currentTheme.buttonColor
    }

    private func handleAnswer(_ option: GameSession.AnswerOption) {
        selectedAnswer = option

        if option.isCorrect {
            // Correct answer
            feedbackText = "NICE!"
            feedbackColor = gameState.currentTheme.correctColor
            showFeedback = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                gameState.handleAnswer(option)
                resetFeedback()
            }
        } else {
            // Wrong answer
            feedbackText = "OOPS!"
            feedbackColor = gameState.currentTheme.wrongColor
            showFeedback = true

            // Shake animation
            withAnimation(.easeInOut(duration: 0.05).repeatCount(4, autoreverses: true)) {
                shakeOffset = 10
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                shakeOffset = 0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                gameState.handleAnswer(option)
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
    GameView()
}
