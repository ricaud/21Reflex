//
//  ThemeState.swift
//  mathgame
//
//  Persisted theme unlock state separate from theme definitions
//

import Foundation
import SwiftData

/// Tracks unlock and equipped state for themes
/// Theme definitions remain static in code, this tracks user-specific state
@Model
class ThemeState {
    /// Theme ID linking to static Theme definition
    var themeID: String = ""

    /// Whether the user has unlocked/purchased this theme
    var isUnlocked: Bool = false

    /// Whether this theme is currently equipped
    var isEquipped: Bool = false

    /// When the theme was unlocked (for analytics/history)
    var unlockDate: Date? = nil

    /// Last modification date for sync conflict resolution
    var lastModified: Date = Date()

    init(
        themeID: String = "",
        isUnlocked: Bool = false,
        isEquipped: Bool = false,
        unlockDate: Date? = nil,
        lastModified: Date = Date()
    ) {
        self.themeID = themeID
        self.isUnlocked = isUnlocked
        self.isEquipped = isEquipped
        self.unlockDate = unlockDate
        self.lastModified = lastModified
    }
}
