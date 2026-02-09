//
//  GameSession.swift
//  mathgame
//
//  Active game session state
//

import SwiftUI

@Observable
@MainActor
class GameSession {
    // MARK: - Game Mode
    enum GameMode: String, CaseIterable {
        case classic = "Classic"
        case practice = "Practice"
        case hard = "Hard Mode"
        case blackjack = "Blackjack"

        var timeLimit: Double {
            switch self {
            case .classic: return 7.0
            case .practice: return 9999.0
            case .hard: return 4.0
            case .blackjack: return 10.0
            }
        }

        var startingDifficulty: Double {
            switch self {
            case .classic, .practice, .blackjack: return 1.0
            case .hard: return 3.0
            }
        }

        var coinMultiplier: Int {
            switch self {
            case .hard: return 2
            default: return 1
            }
        }

        var buffsEnabled: Bool {
            switch self {
            case .hard, .blackjack: return false
            default: return true
            }
        }

        var hasTimer: Bool {
            self != .practice
        }

        var hasHealth: Bool {
            self != .practice
        }
    }

    // MARK: - Current State
    var mode: GameMode = .classic
    var difficulty: Double = 1.0
    var timeRemaining: Double = 7.0
    var timeLimit: Double = 7.0
    var isPaused: Bool = false
    var isGameOver: Bool = false

    // MARK: - Question State
    struct Question {
        let a: Int
        let b: Int
        let answer: Int
        var text: String { "\(a) × \(b)" }
    }

    var currentQuestion: Question?
    var answerOptions: [AnswerOption] = []

    struct AnswerOption: Identifiable {
        let id = UUID()
        let value: Int
        let isCorrect: Bool
        var text: String { "\(value)" }
    }

    // MARK: - Boss Battle
    var isBossBattle: Bool = false
    var bossQuestionCount: Int = 0
    var bossQuestionsTotal: Int = 3

    // MARK: - Timer Management
    private var timerTask: Task<Void, Never>?
    var onTimerExpire: (() -> Void)?

    // MARK: - Initialization
    func start(mode: GameMode) {
        self.mode = mode
        self.difficulty = mode.startingDifficulty
        self.timeLimit = mode.timeLimit
        self.timeRemaining = mode.timeLimit
        self.isPaused = false
        self.isGameOver = false
        self.isBossBattle = false
        self.bossQuestionCount = 0


        generateQuestion()
        startTimer()
    }

    // MARK: - Timer
    func startTimer() {
        guard mode.hasTimer, !isPaused else { return }

        timerTask?.cancel()
        timerTask = Task { [weak self] in
            while let self = self, !self.isPaused, !self.isGameOver {
                try? await Task.sleep(for: .milliseconds(100))

                await MainActor.run {
                    guard !self.isPaused, !self.isGameOver else { return }

                    // Apply slow timer buff
                    let timeScale = 1.0
                    // Note: Buff check would need to be passed in or accessed differently
                    // For now, we'll handle this in the GameState

                    self.timeRemaining -= 0.1 * timeScale

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
        timeRemaining = isBossBattle ? 10.0 : timeLimit
        isGameOver = false

        // Restart timer if it had expired (timer task was cancelled)
        if wasGameOver {
            startTimer()
        }
    }

    // MARK: - Question Generation
    func generateQuestion() {
        // Check for boss battle trigger
        if !isBossBattle {
            let nextCount = (currentQuestion == nil ? 0 : 1)
            let totalCorrect = nextCount // This would need to come from Player
            if totalCorrect > 0 && totalCorrect % 50 == 0 {
                isBossBattle = true
                bossQuestionCount = 0
            }
        }

        let (a, b) = generateNumbers()
        currentQuestion = Question(a: a, b: b, answer: a * b)
        generateAnswerOptions()
        resetTimer()
    }

    private func generateNumbers() -> (Int, Int) {
        var rng = SystemRandomNumberGenerator()

        let maxNumber: Int
        switch difficulty {
        case 1...2:
            maxNumber = 5
        case 3...5:
            maxNumber = 10
        case 6...9:
            maxNumber = 12
        default:
            maxNumber = 20
        }

        var a = Int.random(in: 1...maxNumber, using: &rng)
        var b = Int.random(in: 1...maxNumber, using: &rng)

        // Boss battle: harder questions
        if isBossBattle {
            a = Int.random(in: 10...20, using: &rng)
            b = Int.random(in: 10...20, using: &rng)
        }

        return (a, b)
    }

    private func generateAnswerOptions() {
        guard let question = currentQuestion else { return }

        let correctAnswer = question.answer
        var options = [correctAnswer]

        // Generate wrong answers
        while options.count < 4 {
            let variation = Int.random(in: -3...3)
            let wrongAnswer = correctAnswer + variation

            // Also try common mistakes
            let mistakeType = Int.random(in: 0...2)
            let wrongAnswer2: Int
            switch mistakeType {
            case 0:
                wrongAnswer2 = question.a + question.b // Addition mistake
            case 1:
                wrongAnswer2 = correctAnswer + (Int.random(in: 1...5) * (Bool.random() ? 1 : -1))
            default:
                wrongAnswer2 = question.a * (question.b + (Int.random(in: 1...3) * (Bool.random() ? 1 : -1)))
            }

            guard let candidate = [wrongAnswer, wrongAnswer2].randomElement() else { continue }
            if candidate > 0 && !options.contains(candidate) {
                options.append(candidate)
            }
        }

        options.shuffle()
        answerOptions = options.map { AnswerOption(value: $0, isCorrect: $0 == correctAnswer) }
    }

    // MARK: - Game Logic
    func checkAnswer(_ option: AnswerOption) -> Bool {
        option.isCorrect
    }

    func increaseDifficulty() {
        difficulty += 0.5

        // Time pressure increases
        if difficulty > 5 && mode != .practice {
            timeLimit = max(4.0, timeLimit - 0.1)
        }
    }

    func handleBossBattleProgress() {
        if isBossBattle {
            bossQuestionCount += 1
            if bossQuestionCount >= bossQuestionsTotal {
                isBossBattle = false
            }
        }
    }

    // Placeholder - would need to coordinate with Player
    private func correctCount() -> Int {
        0
    }

    // MARK: - Reset
    func endGame() {
        isGameOver = true
        timerTask?.cancel()
    }

    func reset() {
        timerTask?.cancel()
        currentQuestion = nil
        answerOptions = []
        isBossBattle = false
        bossQuestionCount = 0
    }
}

// MARK: - Seeded Random Number Generator
struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = 6364136223846793005 &* state &+ 1
        return state
    }
}
