//
//  GameView.swift
//  21Reflex
//
//  Blackjack card counting gameplay view
//

import SwiftUI

struct GameView: View {
    @State private var gameState = GameState.shared
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedAnswer: BlackjackSession.AnswerOption?
    @State private var showFeedback = false
    @State private var feedbackText = ""
    @State private var feedbackColor: Color = .green
    @State private var shakeOffset: CGFloat = 0
    @State private var pointsEarned = 0
    @State private var showBonusAnimation = false

    var body: some View {
        ZStack {
            // Background
            gameState.currentTheme.effectiveBgColor(colorScheme)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                // Header
                headerSection

                // Timer bar (hidden in practice mode)
                if !gameState.isPracticeMode {
                    TimerBar(progress: timerProgress)
                        .padding(.horizontal)
                        .accessibilityElement()
                        .accessibilityLabel("Time remaining")
                        .accessibilityValue("\(Int(gameState.session?.timeRemaining ?? 0)) seconds")
                }

                // Cards display
                cardsSection

                // Prompt
                Text("What's the total?")
                    .font(.headline)
                    .foregroundStyle(gameState.currentTheme.effectiveTextColor(colorScheme))

                // Feedback display
                if gameState.isPracticeMode {
                    // Practice mode: simple single-line feedback
                    VStack(spacing: 8) {
                        Text(feedbackText)
                            .font(.title.bold())
                            .foregroundStyle(feedbackColor)

                        // Simple BONUS text (no gold, no +2)
                        Text("BONUS")
                            .font(.headline.bold())
                            .foregroundStyle(feedbackColor)
                            .opacity(showBonusAnimation ? 1 : 0)
                            .animation(.easeOut(duration: 0.2), value: showBonusAnimation)
                    }
                    .opacity(showFeedback ? 1 : 0)
                    .scaleEffect(showFeedback ? 1.0 : 0.9)
                    .animation(.easeOut(duration: 0.2), value: showFeedback)
                    .frame(height: 80)
                } else {
                    // Normal mode: two-line feedback with points
                    VStack(spacing: 4) {
                        Text(feedbackText)
                            .font(.title.bold())
                        Text("+\(pointsEarned) points")
                            .font(.title2.bold())
                    }
                    .foregroundStyle(feedbackColor)
                    .opacity(showFeedback ? 1 : 0)
                    .scaleEffect(showFeedback ? 1.0 : 0.9)
                    .animation(.easeOut(duration: 0.2), value: showFeedback)
                    .frame(height: 60)

                    // Gold bonus animation
                    Text("+2 BONUS!")
                        .font(.headline.bold().italic())
                        .foregroundStyle(Color(red: 1.0, green: 0.84, blue: 0.0))
                        .shadow(color: .black, radius: 0.5, x: 0, y: 0)
                        .shadow(color: .black, radius: 0.5, x: 0.5, y: 0)
                        .shadow(color: .black, radius: 0.5, x: -0.5, y: 0)
                        .shadow(color: .black, radius: 0.5, x: 0, y: 0.5)
                        .shadow(color: .black, radius: 0.5, x: 0, y: -0.5)
                        .opacity(showBonusAnimation ? 1 : 0)
                        .offset(y: showBonusAnimation ? -5 : 0)
                        .animation(.easeOut(duration: 0.2), value: showBonusAnimation)
                        .frame(height: 30)
                }

                // Answer buttons
                answerButtonsSection
                    .padding(.top, 8)


                // Banner ad at bottom
                BannerAdView(placement: .game)
                    .frame(height: BannerAdView.bannerHeight)
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)
            .padding(.top)

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

    private var headerSection: some View {
        VStack(spacing: 12) {

            HStack(spacing: 12) {
                // Mode indicator with pause button
                Text("Blackjack")
                    .font(.caption.bold())
                    .foregroundStyle(Color(red: 0.2, green: 0.6, blue: 0.3))

                // Pause button - small, to the right of "Blackjack"
                Button(action: { gameState.togglePause() }) {
                    Image(systemName: "pause.fill")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(gameState.currentTheme.effectiveTextColor(colorScheme).opacity(0.6))
                        .frame(width: 24, height: 24)
                        .background(
                            Circle()
                                .fill(gameState.currentTheme.effectiveButtonColor(colorScheme).opacity(0.3))
                        )
                }
                .accessibilityLabel("Pause game")
                .accessibilityHint("Opens pause menu")

                Spacer()

                // Points (hidden in practice mode)
                if !gameState.isPracticeMode, let session = gameState.session {
                    HStack(spacing: 4) {
                        Text("\(session.currentRoundPoints)")
                            .font(.headline.bold())
                            .foregroundStyle(gameState.currentTheme.effectiveTextColor(colorScheme))
                        Text("pts")
                            .font(.caption)
                            .foregroundStyle(gameState.currentTheme.effectiveTextColor(colorScheme).opacity(0.7))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(gameState.currentTheme.effectiveButtonColor(colorScheme))
                    )
                }
            }
            .padding(.horizontal)

            // Second row: Lives (left) and Streak (right) - both away from Dynamic Island
            HStack {
                // Health with LIVES: label
                if gameState.player.health > 0 {
                    HStack(spacing: 4) {
                        Text("LIVES:")
                            .font(.caption.bold())
                            .foregroundStyle(.red)
                        HealthIndicator(
                            current: gameState.player.health,
                            max: 3
                        )
                    }
                }

                Spacer()

                // Streak - moved to right side away from Dynamic Island
                StreakBadge(streak: gameState.player.streak)
            }
            .padding(.horizontal)
        }
    }

    private var timerProgress: Double {
        guard let session = gameState.session else { return 1.0 }
        return max(0, min(1, session.timeRemaining / session.timeLimit))
    }

    private var cardsSection: some View {
        HStack(spacing: -25) {
            if let session = gameState.session {
                ForEach(session.currentCards) { card in
                    PlayingCardView(card: card, animateOnAppear: true)
                        .frame(width: 70, height: 100)
                        .transition(.asymmetric(
                            insertion: .offset(x: 50).combined(with: .opacity),
                            removal: .opacity
                        ))
                }
            }
        }
        .frame(height: 110)
        .padding(.horizontal, 30)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(gameState.currentTheme.effectiveButtonColor(colorScheme))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(gameState.currentTheme.effectiveBorderColor(colorScheme), lineWidth: 4)
        )
    }

    private var answerButtonsSection: some View {
        let isTimerExpired = gameState.session?.timeRemaining ?? 1 <= 0
        let options = gameState.session?.answerOptions ?? []
        let numericOptions = options.filter { option in
            if case .value = option.type { return true }
            return false
        }
        let specialOptions = options.filter { option in
            if case .bust = option.type { return true }
            if case .blackjack = option.type { return true }
            return false
        }

        return VStack(spacing: 16) {
            // Special buttons (Bust and Blackjack) - full width horizontal
            specialButtonsRow(options: specialOptions, isTimerExpired: isTimerExpired)
            
            // Numeric options in 2x2 grid
            numericButtonsGrid(options: numericOptions, isTimerExpired: isTimerExpired)
        }
    }

    private func numericButtonsGrid(options: [BlackjackSession.AnswerOption], isTimerExpired: Bool) -> some View {
        let columns = [
            GridItem(.flexible()),
            GridItem(.flexible())
        ]

        return LazyVGrid(columns: columns, spacing: 16) {
            ForEach(options) { option in
                ThickBorderButton(
                    title: option.displayText,
                    action: { handleAnswer(option) },
                    bgColor: buttonColor(for: option),
                    textColor: gameState.currentTheme.effectiveTextColor(colorScheme),
                    borderColor: gameState.currentTheme.effectiveBorderColor(colorScheme),
                    borderWidth: 4,
                    shadowOffset: 5,
                    cornerRadius: 12,
                    font: .system(size: 36, weight: .bold)
                )
                .frame(height: 90)
                .disabled(isTimerExpired)
                .opacity(isTimerExpired ? 0.5 : 1)
                .accessibilityLabel("Answer option \(option.displayText)")
                .accessibilityHint("Select this as the total card value")
            }
        }
    }

    private func specialButtonsRow(options: [BlackjackSession.AnswerOption], isTimerExpired: Bool) -> some View {
        HStack(spacing: 16) {
            ForEach(options) { option in
                ThickBorderButton(
                    title: option.displayText,
                    action: { handleAnswer(option) },
                    bgColor: buttonColor(for: option),
                    textColor: gameState.currentTheme.effectiveTextColor(colorScheme),
                    borderColor: gameState.currentTheme.effectiveBorderColor(colorScheme),
                    borderWidth: 4,
                    shadowOffset: 5,
                    cornerRadius: 12,
                    font: .system(size: 20, weight: .bold)
                )
                .frame(height: 60)
                .disabled(isTimerExpired)
                .opacity(isTimerExpired ? 0.5 : 1)
                .accessibilityLabel("Answer option \(option.displayText)")
                .accessibilityHint(option.type == .bust ? "Select if hand is bust" : "Select if hand is blackjack")
            }
        }
    }

    private func buttonColor(for option: BlackjackSession.AnswerOption) -> Color {
        if selectedAnswer?.id == option.id {
            return option.isCorrect ? gameState.currentTheme.effectiveCorrectColor(colorScheme) : gameState.currentTheme.effectiveWrongColor(colorScheme)
        }
        return gameState.currentTheme.effectiveButtonColor(colorScheme)
    }

    private func handleAnswer(_ option: BlackjackSession.AnswerOption) {
        selectedAnswer = option

        if option.isCorrect {
            // Calculate and award points
            if let session = gameState.session {
                let points = session.calculatePoints(for: option)
                let basePoints = max(1, 10 - Int(Date().timeIntervalSince(session.answerStartTime)))
                let hasBonus = points > basePoints

                session.awardPoints(points)
                pointsEarned = points

                // Show combined feedback
                feedbackText = gameState.isPracticeMode ? "CORRECT" : "CORRECT!"
                feedbackColor = gameState.currentTheme.effectiveCorrectColor(colorScheme)
                showFeedback = true
                showBonusAnimation = hasBonus

                // Hide animations after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(.easeIn(duration: 0.3)) {
                        showFeedback = false
                        showBonusAnimation = false
                    }
                }
            } else {
                feedbackText = "CORRECT!"
                feedbackColor = gameState.currentTheme.effectiveCorrectColor(colorScheme)
                showFeedback = true
            }

            gameState.player.handleCorrectAnswer()
            gameState.audioManager.playSound(.correct)
            gameState.hapticManager.playCorrectFeedback()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation {
                    gameState.session?.handleCorrectAnswer()
                }
                resetFeedback()
            }
        } else {
            // Wrong answer - show INCORRECT in red
            pointsEarned = 0
            feedbackText = "INCORRECT"
            feedbackColor = gameState.currentTheme.effectiveWrongColor(colorScheme)
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

            // Hide feedback after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeIn(duration: 0.3)) {
                    showFeedback = false
                }
            }

            // In practice mode: no health penalty, just continue
            // In normal mode: handle wrong answer with health penalty
            if gameState.isPracticeMode {
                // Just reset streak and continue
                gameState.player.streak = 0
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    gameState.session?.handleWrongAnswer()
                    resetFeedback()
                }
            } else {
                let result = gameState.player.handleWrongAnswer()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    switch result {
                    case .gameOver:
                        gameState.endGame()
                    case .shieldUsed, .luckySave, .secondChanceUsed:
                        gameState.session?.handleWrongAnswer()
                    case .normal:
                        gameState.session?.handleWrongAnswer()
                    }
                    resetFeedback()
                }
            }
        }
    }

    private func resetFeedback() {
        showFeedback = false
        selectedAnswer = nil
        showBonusAnimation = false
    }
}

#Preview {
    GameView()
}
