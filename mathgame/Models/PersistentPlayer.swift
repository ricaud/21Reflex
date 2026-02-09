//
//  PersistentPlayer.swift
//  mathgame
//
//  SwiftData model for persistent player data
//

import SwiftData

@Model
class PersistentPlayer {
    var totalCoins: Int
    var unlockedThemeIds: [String]
    var equippedThemeId: String

    // High scores
    var bestStreak: Int
    var mostCoinsInRun: Int
    var highestCorrectCount: Int

    // Lifetime stats
    var totalQuestionsAnswered: Int
    var totalCorrect: Int
    var totalWrong: Int
    var totalCoinsEarned: Int
    var runsCompleted: Int
    var buffsCollected: Int

    // Achievements
    var unlockedAchievements: [String]

    // Audio settings
    var musicVolume: Float
    var sfxVolume: Float
    var hapticsEnabled: Bool

    init(
        totalCoins: Int = 0,
        unlockedThemeIds: [String] = ["classic"],
        equippedThemeId: String = "classic",
        bestStreak: Int = 0,
        mostCoinsInRun: Int = 0,
        highestCorrectCount: Int = 0,
        totalQuestionsAnswered: Int = 0,
        totalCorrect: Int = 0,
        totalWrong: Int = 0,
        totalCoinsEarned: Int = 0,
        runsCompleted: Int = 0,
        buffsCollected: Int = 0,
        unlockedAchievements: [String] = [],
        musicVolume: Float = 0.7,
        sfxVolume: Float = 0.8,
        hapticsEnabled: Bool = true
    ) {
        self.totalCoins = totalCoins
        self.unlockedThemeIds = unlockedThemeIds
        self.equippedThemeId = equippedThemeId
        self.bestStreak = bestStreak
        self.mostCoinsInRun = mostCoinsInRun
        self.highestCorrectCount = highestCorrectCount
        self.totalQuestionsAnswered = totalQuestionsAnswered
        self.totalCorrect = totalCorrect
        self.totalWrong = totalWrong
        self.totalCoinsEarned = totalCoinsEarned
        self.runsCompleted = runsCompleted
        self.buffsCollected = buffsCollected
        self.unlockedAchievements = unlockedAchievements
        self.musicVolume = musicVolume
        self.sfxVolume = sfxVolume
        self.hapticsEnabled = hapticsEnabled
    }
}
