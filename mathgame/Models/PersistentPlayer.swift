//
//  PersistentPlayer.swift
//  mathgame
//
//  SwiftData model for persistent player data
//

import SwiftData

@Model
class PersistentPlayer {
    // High scores
    var bestStreak: Int
    var highestCorrectCount: Int

    // Lifetime stats
    var totalQuestionsAnswered: Int
    var totalCorrect: Int
    var totalWrong: Int
    var runsCompleted: Int

    // Audio settings
    var musicVolume: Float
    var sfxVolume: Float
    var hapticsEnabled: Bool

    init(
        bestStreak: Int = 0,
        highestCorrectCount: Int = 0,
        totalQuestionsAnswered: Int = 0,
        totalCorrect: Int = 0,
        totalWrong: Int = 0,
        runsCompleted: Int = 0,
        musicVolume: Float = 0.7,
        sfxVolume: Float = 0.8,
        hapticsEnabled: Bool = true
    ) {
        self.bestStreak = bestStreak
        self.highestCorrectCount = highestCorrectCount
        self.totalQuestionsAnswered = totalQuestionsAnswered
        self.totalCorrect = totalCorrect
        self.totalWrong = totalWrong
        self.runsCompleted = runsCompleted
        self.musicVolume = musicVolume
        self.sfxVolume = sfxVolume
        self.hapticsEnabled = hapticsEnabled
    }
}
