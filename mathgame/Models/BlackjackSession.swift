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

    // Game mode
    let isPracticeMode: Bool

    // Timer state
    var timeRemaining: Double = 10.0
    var timeLimit: Double = 10.0
    var isPaused: Bool = false
    var isGameOver: Bool = false

    // Streak tracking
    var correctCount: Int = 0
    var wrongCount: Int = 0

    // Points tracking
    var currentRoundPoints: Int = 0
    var totalSessionPoints: Int = 0
    var answerStartTime: Date = Date()

    init(isPracticeMode: Bool = false) {
        self.isPracticeMode = isPracticeMode
    }

    /// Current hand value with proper soft/hard calculation
    var handValue: HandValue {
        HandValue.calculate(from: currentCards)
    }

    private var timerTask: Task<Void, Never>?
    var onTimerExpire: (() -> Void)?

    enum AnswerType: Equatable {
        case value(Int)
        case bust
        case blackjack

        var displayText: String {
            switch self {
            case .value(let v): return "\(v)"
            case .bust: return "BUST"
            case .blackjack: return "BLACKJACK"
            }
        }
    }

    struct AnswerOption: Identifiable {
        let id = UUID()
        let type: AnswerType
        let isCorrect: Bool

        var displayText: String {
            type.displayText
        }
    }

    // MARK: - Initialization
    func start() {
        correctCount = 0
        wrongCount = 0
        currentRoundPoints = 0
        totalSessionPoints = 0
        isPaused = false
        isGameOver = false
        timeLimit = 10.0
        timeRemaining = timeLimit

        shoe.shuffle()
        dealInitialCards()

        // Only start timer in normal mode
        if !isPracticeMode {
            startTimer()
        }
    }

    // MARK: - Card Dealing
    func dealInitialCards() {
        currentCards = [shoe.deal(), shoe.deal()]
        answerStartTime = Date()
        generateAnswerOptions()
    }

    func dealNextCard() {
        currentCards.append(shoe.deal())
        answerStartTime = Date()
        generateAnswerOptions()
        resetTimer()
    }

    // MARK: - Answer Options
    func generateAnswerOptions() {
        let handValue = self.handValue
        let correctValue = handValue.bestValue

        var numericOptions: [AnswerOption] = []

        // Add correct numeric value (always included)
        numericOptions.append(AnswerOption(type: .value(correctValue), isCorrect: true))

        // Generate wrong numeric answers (only 3 now to make room for special buttons)
        var attempts = 0
        while numericOptions.count < 4 && attempts < 50 {
            let offset = Int.random(in: -6...6)
            let wrong = correctValue + offset

            if wrong > 0 && wrong != correctValue && !numericOptions.contains(where: { self.valueFromType($0.type) == wrong }) {
                numericOptions.append(AnswerOption(type: .value(wrong), isCorrect: false))
            }
            attempts += 1
        }

        // Fill remaining numeric slots if needed
        while numericOptions.count < 4 {
            let random = Int.random(in: max(1, correctValue - 10)...max(correctValue + 10, 12))
            if random != correctValue && !numericOptions.contains(where: { self.valueFromType($0.type) == random }) {
                numericOptions.append(AnswerOption(type: .value(random), isCorrect: false))
            }
        }

        // Always add special buttons (Bust and Blackjack)
        // These are evaluated at answer time, not generation time
        // For the UI, we show them with isCorrect based on current hand state
        let bustOption = AnswerOption(type: .bust, isCorrect: handValue.isBust)
        let blackjackOption = AnswerOption(type: .blackjack, isCorrect: correctValue == 21 && !handValue.isBust)

        // Combine: numeric options first, then special buttons
        answerOptions = numericOptions.shuffled() + [bustOption, blackjackOption]
    }

    /// Helper to extract Int value from AnswerType for comparison
    private func valueFromType(_ type: AnswerType) -> Int? {
        if case .value(let v) = type {
            return v
        }
        return nil
    }

    // MARK: - Game Logic
    func checkAnswer(_ option: AnswerOption) -> Bool {
        option.isCorrect
    }

    func calculatePoints(for option: AnswerOption) -> Int {
        // No points in practice mode
        if isPracticeMode {
            return 0
        }

        let handValue = self.handValue
        let elapsedSeconds = Int(Date().timeIntervalSince(answerStartTime))
        var points = max(1, 10 - elapsedSeconds) // Minimum 1 point

        // Bonus: +2 if hand is Blackjack/Bust and user selected numeric value
        let isBlackjack = handValue.bestValue == 21 && !handValue.isBust
        let isBust = handValue.isBust

        if (isBlackjack || isBust) && option.isCorrect {
            if case .value = option.type {
                points += 2
            }
        }

        return points
    }

    func awardPoints(_ points: Int) {
        currentRoundPoints += points
        totalSessionPoints += points
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
