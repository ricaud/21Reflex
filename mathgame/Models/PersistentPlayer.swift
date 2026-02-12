//
//  PersistentPlayer.swift
//  mathgame
//
//  SwiftData model for persistent player data
//

import Foundation
import SwiftData

@Model
class PersistentPlayer {
    // High scores
    var bestStreak: Int = 0
    var highestCorrectCount: Int = 0

    // Lifetime stats
    var totalQuestionsAnswered: Int = 0
    var totalCorrect: Int = 0
    var totalWrong: Int = 0
    var runsCompleted: Int = 0

    // Coin tracking
    var totalCoinsEarned: Int = 0
    var totalCoinsSpent: Int = 0

    // Audio settings
    var musicVolume: Float = 0.7
    var sfxVolume: Float = 0.8
    var hapticsEnabled: Bool = true

    // Theme settings
    var equippedThemeID: String = "classic"

    // Additional high scores (from HighScores struct)
    var mostCoinsInRun: Int = 0

    // Top 3 scores (from HighScores.topScores)
    @Attribute(.externalStorage)
    var topScores: [Int] = []

    // Audio settings - additional
    var isMuted: Bool = false

    // Achievement progress tracking (local progress before Game Center)
    var firstStepsCompleted: Bool = false
    var streakMasterProgress: Int = 0  // Current streak toward 20
    var millionaireProgress: Int = 0   // Total coins earned toward 1M
    var blackjackProProgress: Int = 0  // Total correct answers toward 100
    var themeCollectorProgress: Int = 0 // Unlocked themes count toward 5

    // CloudKit sync tracking
    var lastCloudKitSync: Date? = nil

    /// Available coins for spending
    var availableCoins: Int {
        totalCoinsEarned - totalCoinsSpent
    }

    init(
        bestStreak: Int = 0,
        highestCorrectCount: Int = 0,
        totalQuestionsAnswered: Int = 0,
        totalCorrect: Int = 0,
        totalWrong: Int = 0,
        runsCompleted: Int = 0,
        totalCoinsEarned: Int = 0,
        totalCoinsSpent: Int = 0,
        musicVolume: Float = 0.7,
        sfxVolume: Float = 0.8,
        hapticsEnabled: Bool = true,
        equippedThemeID: String = "classic",
        mostCoinsInRun: Int = 0,
        topScores: [Int] = [],
        isMuted: Bool = false,
        firstStepsCompleted: Bool = false,
        streakMasterProgress: Int = 0,
        millionaireProgress: Int = 0,
        blackjackProProgress: Int = 0,
        themeCollectorProgress: Int = 0,
        lastCloudKitSync: Date? = nil
    ) {
        self.bestStreak = bestStreak
        self.highestCorrectCount = highestCorrectCount
        self.totalQuestionsAnswered = totalQuestionsAnswered
        self.totalCorrect = totalCorrect
        self.totalWrong = totalWrong
        self.runsCompleted = runsCompleted
        self.totalCoinsEarned = totalCoinsEarned
        self.totalCoinsSpent = totalCoinsSpent
        self.musicVolume = musicVolume
        self.sfxVolume = sfxVolume
        self.hapticsEnabled = hapticsEnabled
        self.equippedThemeID = equippedThemeID
        self.mostCoinsInRun = mostCoinsInRun
        self.topScores = topScores
        self.isMuted = isMuted
        self.firstStepsCompleted = firstStepsCompleted
        self.streakMasterProgress = streakMasterProgress
        self.millionaireProgress = millionaireProgress
        self.blackjackProProgress = blackjackProProgress
        self.themeCollectorProgress = themeCollectorProgress
        self.lastCloudKitSync = lastCloudKitSync
    }
}
