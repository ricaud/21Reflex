//
//  ThemeRegistry.swift
//  21Reflex
//
//  Central registry for all available themes
//

import SwiftUI

/// Central registry that holds all available themes
@Observable
@MainActor
final class ThemeRegistry {
    static let shared = ThemeRegistry()

    /// All available themes in the app
    private(set) var allThemes: [any AppTheme] = []

    private init() {
        registerDefaultThemes()
    }

    /// Register all default themes
    private func registerDefaultThemes() {
        allThemes = [
            // Glass Themes (Refined, elegant)
            SlateTheme(),
            OceanTheme(),
            MidnightTheme(),
            ForestTheme(),

            // Playful Themes (Thick borders, fun)
            ClassicRetroTheme(),
            CandyTheme(),
            ArcadeTheme(),
            ComicTheme(),

            // Hand Drawn Themes (Artistic, sketchy)
            SketchbookTheme(),
            CrayonTheme(),

            // Retro Themes (Pixel, CRT)
            PixelTheme(),
            CRTTheme(),
            VaporwaveTheme(),

            // Luxury Themes (Premium)
            GoldTheme(),
            DiamondTheme()
        ]
    }

    /// Get a theme by its ID
    func theme(withID id: String) -> (any AppTheme)? {
        allThemes.first { $0.id == id }
    }

    /// Get themes grouped by category
    func themesByCategory() -> [(category: String, themes: [any AppTheme])] {
        [
            ("Glass", allThemes.filter { $0 is GlassThemed }),
            ("Playful", allThemes.filter { $0 is PlayfulThemed }),
            ("Hand Drawn", allThemes.filter { $0 is HandDrawnThemed }),
            ("Retro", allThemes.filter { $0 is RetroThemed }),
            ("Luxury", allThemes.filter { $0 is LuxuryThemed })
        ].filter { !$0.themes.isEmpty }
    }

    /// Get themes sorted by cost (free first, then ascending)
    var themesByCost: [any AppTheme] {
        allThemes.sorted { $0.cost < $1.cost }
    }

    /// Get all theme IDs
    var allThemeIDs: [String] {
        allThemes.map { $0.id }
    }
}

