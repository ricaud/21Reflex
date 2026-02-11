//
//  Player.swift
//  mathgame
//
//  Player state and statistics
//

import SwiftUI
import SwiftData

@Observable
@MainActor
class Player {
    // MARK: - Per-Run Stats
    var health: Int = 3
    var streak: Int = 0
    var correctCount: Int = 0
    var wrongCount: Int = 0
    var coins: Int = 0

    // MARK: - High Scores
    var highScore = HighScores()

    // MARK: - Lifetime Stats
    var lifetimeStats = LifetimeStats()

    // MARK: - Reset for New Run
    func resetForRun() {
        health = 3
        streak = 0
        correctCount = 0
        wrongCount = 0
        coins = 0
    }

    // MARK: - High Score Updates
    func updateHighScores() -> Bool {
        var newRecord = false

        if streak > highScore.bestStreak {
            highScore.bestStreak = streak
            newRecord = true
        }

        if coins > highScore.mostCoinsInRun {
            highScore.mostCoinsInRun = coins
            newRecord = true
        }

        if correctCount > highScore.highestCorrectCount {
            highScore.highestCorrectCount = correctCount
            newRecord = true
        }

        return newRecord
    }

    func updateTopScores(_ sessionTotal: Int) {
        highScore.topScores.append(sessionTotal)
        highScore.topScores.sort(by: >)
        if highScore.topScores.count > 3 {
            highScore.topScores = Array(highScore.topScores.prefix(3))
        }
    }

    // MARK: - Wrong Answer Handling
    enum WrongAnswerResult {
        case gameOver
        case shieldUsed
        case luckySave
        case secondChanceUsed
        case normal
    }

    func handleWrongAnswer() -> WrongAnswerResult {
        wrongCount += 1

        // Normal wrong answer
        health -= 1
        streak = 0
        lifetimeStats.totalWrong += 1
        lifetimeStats.totalQuestionsAnswered += 1

        if health <= 0 {
            return .gameOver
        }

        return .normal
    }

    func handleCorrectAnswer() {
        streak += 1
        correctCount += 1
        coins += 1  // Earn 1 coin for each correct answer
        lifetimeStats.totalCorrect += 1
        lifetimeStats.totalQuestionsAnswered += 1
    }

    // MARK: - Computed Properties
    var accuracy: Int {
        let total = lifetimeStats.totalCorrect + lifetimeStats.totalWrong
        guard total > 0 else { return 0 }
        return Int((Double(lifetimeStats.totalCorrect) / Double(total)) * 100)
    }
}

// MARK: - Supporting Types
struct HighScores {
    var bestStreak: Int = 0
    var mostCoinsInRun: Int = 0
    var highestCorrectCount: Int = 0
    var topScores: [Int] = []  // Top 3 scores, sorted descending
}

struct LifetimeStats {
    var totalQuestionsAnswered: Int = 0
    var totalCorrect: Int = 0
    var totalWrong: Int = 0
    var runsCompleted: Int = 0
}
