//
//  CardShoe.swift
//  mathgame
//
//  Casino shoe with multiple decks for blackjack
//

import SwiftUI

@Observable
@MainActor
class CardShoe {
    private var cards: [Card] = []
    private let numberOfDecks: Int = 6  // Standard casino uses 6 decks
    private let shuffleThreshold: Double = 0.20  // Reshuffle when 20% remaining

    var cardsRemaining: Int { cards.count }
    var totalCards: Int { numberOfDecks * 52 }
    var penetration: Double {
        Double(cardsRemaining) / Double(totalCards)
    }

    func shuffle() {
        cards = []

        // Create 6 standard decks
        for _ in 0..<numberOfDecks {
            for suit in Suit.allCases {
                for rank in Rank.allCases {
                    cards.append(Card(suit: suit, rank: rank))
                }
            }
        }

        // Fisher-Yates shuffle
        var rng = SystemRandomNumberGenerator()
        cards.shuffle(using: &rng)
    }

    func deal() -> Card {
        // Reshuffle if running low
        if cards.isEmpty || penetration < shuffleThreshold {
            shuffle()
        }

        return cards.removeLast()
    }

    func reset() {
        cards.removeAll()
    }
}
