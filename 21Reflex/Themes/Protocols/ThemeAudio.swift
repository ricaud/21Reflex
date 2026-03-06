//
//  ThemeAudio.swift
//  21Reflex
//
//  Audio protocol for themes with custom music and sound effects
//

import Foundation

/// Protocol for themes that provide custom audio
protocol ThemeAudio {
    /// Background music for menu screen (filename without extension)
    var menuMusic: String? { get }

    /// Background music during gameplay (filename without extension)
    var gameMusic: String? { get }

    /// Background music for game over screen (filename without extension)
    var gameOverMusic: String? { get }

    /// Returns a custom sound effect filename for an event, or nil to use default
    func soundEffect(for event: SoundEvent) -> String?
}

/// Game events that can have custom sounds
enum SoundEvent {
    case correctAnswer
    case wrongAnswer
    case buttonTap
    case cardDeal
    case cardFlip
    case gameOver
    case coinEarned
    case achievementUnlock
    case themeSwitch
}

/// Game phases for music
enum GamePhase {
    case menu
    case playing
    case gameOver
}

// MARK: - Default Implementation

extension ThemeAudio {
    var menuMusic: String? { nil }
    var gameMusic: String? { nil }
    var gameOverMusic: String? { nil }

    func soundEffect(for event: SoundEvent) -> String? {
        nil // Return nil to use default sounds
    }
}
