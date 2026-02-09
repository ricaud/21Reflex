//
//  Achievement.swift
//  mathgame
//
//  Achievement definitions and tracking
//

import Foundation

struct Achievement: Identifiable, Hashable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let target: Int

    static let allAchievements: [Achievement] = [
        Achievement(id: "first_run", name: "First Steps", description: "Complete your first run", icon: "star.fill", target: 1),
        Achievement(id: "streak_10", name: "On Fire!", description: "Reach a 10 streak", icon: "flame.fill", target: 10),
        Achievement(id: "streak_25", name: "Unstoppable", description: "Reach a 25 streak", icon: "crown.fill", target: 25),
        Achievement(id: "questions_50", name: "Getting Started", description: "Answer 50 questions", icon: "book.fill", target: 50),
        Achievement(id: "questions_500", name: "Math Whiz", description: "Answer 500 questions", icon: "brain.fill", target: 500),
        Achievement(id: "questions_1000", name: "Grandmaster", description: "Answer 1000 questions", icon: "trophy.fill", target: 1000),
        Achievement(id: "coin_collector", name: "Coin Collector", description: "Earn 1000 coins total", icon: "dollarsign.circle.fill", target: 1000),
        Achievement(id: "theme_collector", name: "Fashionista", description: "Buy all themes", icon: "paintpalette.fill", target: 5),
        Achievement(id: "buff_master", name: "Buff Master", description: "Collect 50 buffs", icon: "bolt.fill", target: 50),
        Achievement(id: "perfect_10", name: "Perfect 10", description: "Get 10 correct in a row", icon: "checkmark.circle.fill", target: 10),
        Achievement(id: "speed_demon", name: "Speed Demon", description: "Answer 20 questions before 50% time", icon: "bolt.shield.fill", target: 20),
        Achievement(id: "survivor", name: "Survivor", description: "Reach 50 correct in one run", icon: "shield.checkerboard", target: 50)
    ]

    static func getById(_ id: String) -> Achievement? {
        allAchievements.first { $0.id == id }
    }

    func progress(for player: PlayerStats) -> Int {
        switch id {
        case "first_run":
            return min(player.runsCompleted, target)
        case "streak_10", "streak_25":
            return min(player.bestStreak, target)
        case "questions_50", "questions_500", "questions_1000":
            return min(player.totalQuestionsAnswered, target)
        case "coin_collector":
            return min(player.totalCoinsEarned, target)
        case "theme_collector":
            return min(player.themesUnlocked, target)
        case "buff_master":
            return min(player.buffsCollected, target)
        case "perfect_10":
            return min(player.currentStreak, target)
        case "survivor":
            return min(player.highestCorrectCount, target)
        default:
            return 0
        }
    }

    func isUnlocked(by player: PlayerStats) -> Bool {
        progress(for: player) >= target
    }
}

// Stats needed for achievement checking
struct PlayerStats {
    var runsCompleted: Int = 0
    var bestStreak: Int = 0
    var totalQuestionsAnswered: Int = 0
    var totalCoinsEarned: Int = 0
    var themesUnlocked: Int = 1
    var buffsCollected: Int = 0
    var currentStreak: Int = 0
    var highestCorrectCount: Int = 0
}
