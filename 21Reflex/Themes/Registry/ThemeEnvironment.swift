//
//  ThemeEnvironment.swift
//  21Reflex
//
//  Environment key and wrapper for theme access
//

import SwiftUI

// MARK: - Environment Key

private struct ThemeKey: EnvironmentKey {
    static let defaultValue: any AppTheme = SlateTheme()
}

extension EnvironmentValues {
    var theme: any AppTheme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}

// MARK: - CurrentThemeView Wrapper

/// A view that provides access to the current theme via environment
struct CurrentThemeView<Content: View>: View {
    @State private var gameState = GameState.shared
    let content: (any AppTheme) -> Content

    var body: some View {
        content(gameState.currentTheme as! (any AppTheme))
            .environment(\.theme, gameState.currentTheme as! (any AppTheme))
    }
}

// MARK: - Theme View Modifier

extension View {
    /// Applies the current theme from GameState to the environment
    func withCurrentTheme() -> some View {
        self.environment(\.theme, GameState.shared.currentTheme as! (any AppTheme))
    }
}

// MARK: - Theme Provider View

/// Root view that sets up the theme environment
struct ThemeProvider<Content: View>: View {
    @State private var gameState = GameState.shared
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .environment(\.theme, gameState.currentTheme as! (any AppTheme))
    }
}
