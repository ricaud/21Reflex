//
//  SessionHistory.swift
//  21Reflex
//
//  Individual game session records for detailed analytics
//

import Foundation
import SwiftData

@Model
class SessionHistory {
    @Attribute(.unique) var id: UUID
    var date: Date
    var finalScore: Int
    var accuracy: Double
    var handsPlayed: Int
    var correctCount: Int
    var wrongCount: Int
    var bestStreak: Int
    var coinsEarned: Int
    var sessionDuration: TimeInterval
    var themeID: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        finalScore: Int = 0,
        accuracy: Double = 0.0,
        handsPlayed: Int = 0,
        correctCount: Int = 0,
        wrongCount: Int = 0,
        bestStreak: Int = 0,
        coinsEarned: Int = 0,
        sessionDuration: TimeInterval = 0,
        themeID: String = "classic"
    ) {
        self.id = id
        self.date = date
        self.finalScore = finalScore
        self.accuracy = accuracy
        self.handsPlayed = handsPlayed
        self.correctCount = correctCount
        self.wrongCount = wrongCount
        self.bestStreak = bestStreak
        self.coinsEarned = coinsEarned
        self.sessionDuration = sessionDuration
        self.themeID = themeID
        self.createdAt = Date()
    }

}
