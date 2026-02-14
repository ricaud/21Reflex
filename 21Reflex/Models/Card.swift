//
//  Card.swift
//  21Reflex
//
//  Playing card model for blackjack mode
//

import SwiftUI

enum Suit: String, CaseIterable {
    case hearts = "♥️"
    case diamonds = "♦️"
    case clubs = "♣️"
    case spades = "♠️"

    var color: Color {
        switch self {
        case .hearts, .diamonds:
            return .red
        case .clubs, .spades:
            return .black
        }
    }
}

enum Rank: String, CaseIterable {
    case two = "2"
    case three = "3"
    case four = "4"
    case five = "5"
    case six = "6"
    case seven = "7"
    case eight = "8"
    case nine = "9"
    case ten = "10"
    case jack = "J"
    case queen = "Q"
    case king = "K"
    case ace = "A"

    /// Base value for calculation (Ace = 1, Face = 10)
    var baseValue: Int {
        switch self {
        case .two: return 2
        case .three: return 3
        case .four: return 4
        case .five: return 5
        case .six: return 6
        case .seven: return 7
        case .eight: return 8
        case .nine: return 9
        case .ten, .jack, .queen, .king: return 10
        case .ace: return 1  // Ace base value is always 1
        }
    }

    /// Whether this rank is an Ace
    var isAce: Bool {
        self == .ace
    }

    var displayValue: String {
        rawValue
    }
}

struct Card: Identifiable, Hashable {
    let id = UUID()
    let suit: Suit
    let rank: Rank

    /// Base value (Ace = 1)
    var baseValue: Int { rank.baseValue }

    /// Whether this card is an Ace
    var isAce: Bool { rank.isAce }

    var displayText: String { rank.rawValue }
}
