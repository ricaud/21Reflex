//
//  BlackjackSession.swift
//  mathgame
//
//  Game session for blackjack card counting mode
//

import SwiftUI

@Observable
@MainActor
class BlackjackSession {
    let shoe = CardShoe()
    var currentCards: [Card] = []
    var answerOptions: [AnswerOption] = []

    // Timer state
    var timeRemaining: Double = 10.0
    var timeLimit: Double = 10.0
    var isPaused: Bool = false
    var isGameOver: Bool = false

    // Streak tracking
    var correctCount: Int = 0
    var wrongCount: Int = 0

    /// Current hand value with proper soft/hard calculation
    var handValue: HandValue {
        HandValue.calculate(from: currentCards)
    }

    private var timerTask: Task<Void, Never>?
    var onTimerExpire: (() -> Void)?

    struct AnswerOption: Identifiable {
        let id = UUID()
        let value: Int
        let isCorrect: Bool
    }

    // MARK: - Initialization
    func start() {
        correctCount = 0
        wrongCount = 0
        isPaused = false
        isGameOver = false
        timeLimit = 10.0
        timeRemaining = 10.0

        shoe.shuffle()
        dealInitialCards()
        startTimer()
    }

    // MARK: - Card Dealing
    func dealInitialCards() {
        currentCards = [shoe.deal(), shoe.deal()]
        generateAnswerOptions()
    }

    func dealNextCard() {
        currentCards.append(shoe.deal())
        generateAnswerOptions()
        resetTimer()
    }

    // MARK: - Answer Options
    func generateAnswerOptions() {
        let handValue = self.handValue
        let correct = handValue.bestValue

        var options = [AnswerOption(value: correct, isCorrect: true)]

        // Generate wrong answers
        var attempts = 0
        while options.count < 4 && attempts < 50 {
            let offset = Int.random(in: -6...6)
            let wrong = correct + offset

            if wrong > 0 && wrong != correct && !options.contains(where: { $0.value == wrong }) {
                options.append(AnswerOption(value: wrong, isCorrect: false))
            }
            attempts += 1
        }

        // Fill remaining slots if needed
        while options.count < 4 {
            let random = Int.random(in: max(1, correct - 10)...max(correct + 10, 12))
            if random != correct && !options.contains(where: { $0.value == random }) {
                options.append(AnswerOption(value: random, isCorrect: false))
            }
        }

        answerOptions = options.shuffled()
    }

    // MARK: - Game Logic
    func checkAnswer(_ option: AnswerOption) -> Bool {
        option.isCorrect
    }

    func handleCorrectAnswer() {
        correctCount += 1

        let handValue = self.handValue

        // Round complete if >= 21 or is bust
        if handValue.bestValue >= 21 || handValue.isBust {
            // Round complete, start new hand after a brief delay
            Task {
                try? await Task.sleep(for: .milliseconds(500))
                await MainActor.run {
                    self.currentCards.removeAll()
                    self.dealInitialCards()
                }
            }
        } else {
            dealNextCard()
        }
    }

    func handleWrongAnswer() {
        wrongCount += 1
        // Keep same cards for next attempt
        generateAnswerOptions()
        resetTimer()
    }

    // MARK: - Timer
    func startTimer() {
        guard !isPaused else { return }

        timerTask?.cancel()
        timerTask = Task { [weak self] in
            while let self = self, !self.isPaused, !self.isGameOver {
                try? await Task.sleep(for: .milliseconds(100))

                await MainActor.run {
                    guard !self.isPaused, !self.isGameOver else { return }

                    self.timeRemaining -= 0.1

                    if self.timeRemaining <= 0 {
                        self.timeRemaining = 0
                        self.isGameOver = true
                        self.timerTask?.cancel()
                        self.onTimerExpire?()
                    }
                }
            }
        }
    }

    func pauseTimer() {
        isPaused = true
        timerTask?.cancel()
    }

    func resumeTimer() {
        isPaused = false
        startTimer()
    }

    func resetTimer() {
        let wasGameOver = isGameOver
        timeRemaining = timeLimit
        isGameOver = false

        if wasGameOver {
            startTimer()
        }
    }

    // MARK: - Reset
    func endGame() {
        isGameOver = true
        timerTask?.cancel()
    }

    func reset() {
        timerTask?.cancel()
        currentCards.removeAll()
        answerOptions.removeAll()
        correctCount = 0
        wrongCount = 0
    }
}
