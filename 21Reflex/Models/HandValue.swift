//
//  HandValue.swift
//  21Reflex
//
//  Blackjack hand value calculation with soft/hard logic
//

import Foundation

/// Represents the calculated value of a blackjack hand
struct HandValue: Equatable {
    /// The best valid value (highest value ≤ 21, or minimum value if all bust)
    let bestValue: Int

    /// Whether the hand is "soft" (contains an Ace counted as 11)
    let isSoft: Bool

    /// Whether the hand is a bust (> 21)
    let isBust: Bool

    /// Number of Aces in the hand
    let aceCount: Int

    /// Base value (all Aces counted as 1)
    let hardValue: Int

    /// Creates a HandValue from an array of Cards
    static func calculate(from cards: [Card]) -> HandValue {
        // Count Aces and sum non-Ace cards
        let aceCount = cards.filter { $0.isAce }.count
        let nonAceSum = cards.filter { !$0.isAce }.reduce(0) { $0 + $1.baseValue }

        // Base value: all Aces as 1
        let hardValue = nonAceSum + aceCount

        // Try to upgrade Aces from 1 to 11 (adds 10 each)
        // Start with hard value, then add 10 for each Ace we can upgrade
        var bestValue = hardValue
        var upgradesUsed = 0

        for _ in 0..<aceCount {
            let potentialValue = bestValue + 10
            if potentialValue <= 21 {
                bestValue = potentialValue
                upgradesUsed += 1
            } else {
                break  // Can't upgrade this Ace without busting
            }
        }

        let isSoft = upgradesUsed > 0
        let isBust = bestValue > 21

        return HandValue(
            bestValue: bestValue,
            isSoft: isSoft,
            isBust: isBust,
            aceCount: aceCount,
            hardValue: hardValue
        )
    }

    /// Display text showing the value, e.g., "19", "Soft 19", "Bust (22)"
    var displayText: String {
        if isBust {
            return "Bust (\(bestValue))"
        } else if isSoft {
            return "Soft \(bestValue)"
        } else {
            return "\(bestValue)"
        }
    }

    /// Short display for UI, e.g., "19" or "S19"
    var shortDisplay: String {
        if isSoft {
            return "S\(bestValue)"
        } else {
            return "\(bestValue)"
        }
    }
}
