//
//  DailyStats.swift
//  21Reflex
//
//  Daily aggregated statistics for analytics charts
//

import Foundation
import SwiftData

@Model
class DailyStats {
    var date: Date
    var accuracy: Double
    var gamesPlayed: Int
    var handsPlayed: Int
    var coinsEarned: Int
    var bestStreak: Int
    var averageScore: Int
    var totalCorrect: Int
    var totalWrong: Int
    var sessionDuration: TimeInterval
    var createdAt: Date
    var lastModified: Date

    init(
        date: Date,
        accuracy: Double = 0.0,
        gamesPlayed: Int = 0,
        handsPlayed: Int = 0,
        coinsEarned: Int = 0,
        bestStreak: Int = 0,
        averageScore: Int = 0,
        totalCorrect: Int = 0,
        totalWrong: Int = 0,
        sessionDuration: TimeInterval = 0
    ) {
        self.date = date
        self.accuracy = accuracy
        self.gamesPlayed = gamesPlayed
        self.handsPlayed = handsPlayed
        self.coinsEarned = coinsEarned
        self.bestStreak = bestStreak
        self.averageScore = averageScore
        self.totalCorrect = totalCorrect
        self.totalWrong = totalWrong
        self.sessionDuration = sessionDuration
        self.createdAt = Date()
        self.lastModified = Date()
    }

    /// Returns the start of day for grouping
    static func startOfDay(_ date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
    }

    /// Update stats with a new session
    func addSession(_ session: SessionHistory) {
        gamesPlayed += 1
        handsPlayed += session.handsPlayed
        coinsEarned += session.coinsEarned
        totalCorrect += session.correctCount
        totalWrong += session.wrongCount
        sessionDuration += session.sessionDuration

        // Update best streak
        if session.bestStreak > bestStreak {
            bestStreak = session.bestStreak
        }

        // Recalculate accuracy
        let total = totalCorrect + totalWrong
        accuracy = total > 0 ? Double(totalCorrect) / Double(total) : 0.0

        // Update average score
        let totalScore = (averageScore * (gamesPlayed - 1)) + session.finalScore
        averageScore = totalScore / gamesPlayed

        lastModified = Date()
    }
}
