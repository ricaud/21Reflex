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
    var coins: Int = 0
    var streak: Int = 0
    var correctCount: Int = 0
    var wrongCount: Int = 0
    var activeBuffs: [ActiveBuff] = []

    // MARK: - Persistent Stats
    var totalCoins: Int = 0
    var unlockedThemeIds: Set<String> = ["classic"]
    var equippedThemeId: String = "classic"

    // MARK: - High Scores
    var highScore = HighScores()

    // MARK: - Lifetime Stats
    var lifetimeStats = LifetimeStats()

    // MARK: - Achievements
    var unlockedAchievements: Set<String> = []

    // MARK: - Reset for New Run
    func resetForRun() {
        health = 3
        coins = 0
        streak = 0
        correctCount = 0
        wrongCount = 0
        activeBuffs = []

        // Apply extra health buffs from persistent unlocks
        let extraHealthCount = activeBuffs.filter { $0.buff.id == "extra_health" }.count
        health += extraHealthCount
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

    // MARK: - Achievement Checking
    func checkAchievements() -> [Achievement] {
        let stats = PlayerStats(
            runsCompleted: lifetimeStats.runsCompleted,
            bestStreak: highScore.bestStreak,
            totalQuestionsAnswered: lifetimeStats.totalQuestionsAnswered,
            totalCoinsEarned: lifetimeStats.totalCoinsEarned,
            themesUnlocked: unlockedThemeIds.count,
            buffsCollected: lifetimeStats.buffsCollected,
            currentStreak: streak,
            highestCorrectCount: highScore.highestCorrectCount
        )

        var newlyUnlocked: [Achievement] = []
        for achievement in Achievement.allAchievements {
            if !unlockedAchievements.contains(achievement.id) && achievement.isUnlocked(by: stats) {
                unlockedAchievements.insert(achievement.id)
                newlyUnlocked.append(achievement)
            }
        }

        return newlyUnlocked
    }

    // MARK: - Buff Management
    func hasBuff(_ id: String) -> Bool {
        activeBuffs.contains { $0.buff.id == id }
    }

    func addBuff(_ buff: Buff) {
        if buff.isStackable {
            if let index = activeBuffs.firstIndex(where: { $0.buff.id == buff.id }) {
                activeBuffs[index].remainingUses += 1
            } else {
                activeBuffs.append(ActiveBuff(buff: buff))
            }
        } else {
            activeBuffs.append(ActiveBuff(buff: buff))
        }
        lifetimeStats.buffsCollected += 1
    }

    func consumeBuff(_ id: String) {
        if let index = activeBuffs.firstIndex(where: { $0.buff.id == id }) {
            activeBuffs[index].remainingUses -= 1
            if activeBuffs[index].remainingUses <= 0 {
                activeBuffs.remove(at: index)
            }
        }
    }

    func removeBuff(_ id: String) {
        activeBuffs.removeAll { $0.buff.id == id }
    }

    // MARK: - Theme Management
    func hasTheme(_ id: String) -> Bool {
        unlockedThemeIds.contains(id)
    }

    func unlockTheme(_ id: String, cost: Int) -> Bool {
        guard totalCoins >= cost, !hasTheme(id) else { return false }
        totalCoins -= cost
        unlockedThemeIds.insert(id)
        return true
    }

    func equipTheme(_ id: String) {
        guard hasTheme(id) else { return }
        equippedThemeId = id
    }

    // MARK: - Scoring
    func calculateCoinGain() -> Int {
        let baseCoins = 1
        let streakThreshold = hasBuff("streak_bonus") ? 3 : 5
        var streakBonus = streak / streakThreshold

        var multiplier = 1
        if hasBuff("double_coins") {
            multiplier *= 2
        }
        if hasBuff("multiplier_stack") {
            streakBonus *= 2
        }

        return (baseCoins + streakBonus) * multiplier
    }

    func addCoins(_ amount: Int) {
        coins += amount
        totalCoins += amount
        lifetimeStats.totalCoinsEarned += amount
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

        // Check shield buff
        if hasBuff("shield") {
            consumeBuff("shield")
            lifetimeStats.totalWrong += 1
            lifetimeStats.totalQuestionsAnswered += 1
            return .shieldUsed
        }

        // Check lucky buff (50% chance)
        if hasBuff("lucky") && Bool.random() {
            lifetimeStats.totalWrong += 1
            lifetimeStats.totalQuestionsAnswered += 1
            return .luckySave
        }

        // Check second chance buff
        if hasBuff("second_chance") {
            consumeBuff("second_chance")
            streak = 0
            lifetimeStats.totalWrong += 1
            lifetimeStats.totalQuestionsAnswered += 1
            return .secondChanceUsed
        }

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
        lifetimeStats.totalCorrect += 1
        lifetimeStats.totalQuestionsAnswered += 1

        let earned = calculateCoinGain()
        addCoins(earned)

        // Apply coin shower buff immediately
        if hasBuff("coin_shower") {
            addCoins(5)
        }
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
}

struct LifetimeStats {
    var totalQuestionsAnswered: Int = 0
    var totalCorrect: Int = 0
    var totalWrong: Int = 0
    var totalCoinsEarned: Int = 0
    var runsCompleted: Int = 0
    var buffsCollected: Int = 0
}
