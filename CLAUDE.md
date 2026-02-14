# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

```bash
# Build for iOS Simulator (iPhone 16, iOS 18.4)
xcodebuild -project mathgame.xcodeproj -scheme mathgame -destination 'platform=iOS Simulator,OS=18.4,name=iPhone 16' build

# Open in Xcode
open mathgame.xcodeproj
```

## Project Overview

**21 Reflex** is an iOS blackjack card counting trainer built with SwiftUI and SwiftData, targeting iOS 17+. The app is on the `blackjack-only` branch - it only includes the blackjack card counting mode (no math quiz modes).

## Architecture

### State Management

**GameState** (`Services/GameState.swift`) is the central `@Observable @MainActor` singleton that coordinates all game state:
- Navigation via `navigationPath: [Screen]` with `Screen` enum for all destinations
- Game flow: `startGame()`, `startPracticeMode()`, `endGame()`, `returnToMenu()`
- References `Player` (in-memory run stats), `BlackjackSession` (current game), and `persistentPlayer` (SwiftData)
- Theme coordination through `currentTheme` and `availableThemes`

**Player** (`Models/Player.swift`) holds per-run state (health, streak, coins, correct/wrong counts) and lifetime stats. Reset via `resetForRun()`.

**PersistentPlayer** (`Models/PersistentPlayer.swift`) is the SwiftData `@Model` for persistence:
- Coin tracking: `totalCoinsEarned`, `totalCoinsSpent`, `availableCoins` (computed)
- Stats: `bestStreak`, `totalCorrect`, `totalWrong`, `runsCompleted`
- Settings: `musicVolume`, `sfxVolume`, `hapticsEnabled`, `equippedThemeID`

### Game Session Flow

1. **BlackjackSession** (`Models/BlackjackSession.swift`) manages a single game:
   - `CardShoe` for 6-deck simulation
   - Timer with async/await (`Task.sleep`) - 10 seconds per question
   - `handValue: HandValue` with proper soft/hard calculation
   - Answer options include numeric values + BUST/BLACKJACK buttons
   - Points awarded based on speed (max 10, min 1) + 2 bonus for recognizing special hands

2. **Gameplay loop**:
   - Deal 2 cards → player selects answer → correct answer deals another card or starts new hand at 21+/bust
   - Wrong answer or timer expiration costs health (3 lives)
   - Game over when health reaches 0

3. **Coin earning**: 1 coin per correct answer (`Player.handleCorrectAnswer()`)
   - Coins sync to `PersistentPlayer.totalCoinsEarned` in `GameState.endGame()`
   - Explicit `modelContext.save()` required after coin transactions

### Theme System

**Theme** (`Models/Theme.swift`) is a SwiftData `@Model` with:
- Colors stored as hex strings (`bgColorHex`, `textColorHex`, etc.)
- Optional dark mode variants (`bgColorDarkHex`, etc.)
- `effective*Color(colorScheme)` methods return appropriate color for current mode
- `allThemes` array includes 14 themes: Classic (free), Candy (100), Ocean (200), Retro (300), Neon (500), Forest (150), Sunset (200), Midnight (250), Halloween (500), Christmas (600), Galaxy (800), Gold (2000), Diamond (3000), Cyberpunk (5000)

Themes are unlocked by spending coins in `ThemeStoreView`. Equipped theme persists via `equippedThemeID`.

### Key Patterns

- **Navigation**: `NavigationStack` with `navigationPath` binding in `MenuView`. Navigate via `GameState.navigate(to:)`.
- **Color Scheme**: All views use `@Environment(\.colorScheme)` and theme's `effective*Color()` methods.
- **Persistence**: SwiftData with iCloud sync via CloudKit (configured in `mathgame.entitlements`).
- **Audio**: `AudioManager` singleton with `.menu`, `.playing`, `.gameOver` music tracks.
- **Music**: `MIDIMusicEngine` generates jazzy MIDI loops programmatically using `AVMIDIPlayer`.
- **Timer**: Async/await based, auto-pauses on app background via `handleScenePhaseChange()`.
- **Ads**: `AdManager` singleton with `BannerAdView` component for AdMob banner ads.

### Advertising System

**AdManager** (`Services/AdManager.swift`) manages Google AdMob integration:
- Banner ads on MenuView, GameView, StatsView, and GameOverView
- `isPremiumUser` flag to disable ads for future premium feature
- Test ad unit IDs in debug builds, production IDs in release builds
- Banner ad caching and refresh on orientation changes

**Important**: BannerView requires an explicit frame set immediately after creation:
```swift
let bannerView = BannerView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: bannerHeight))
```
Without this, AdMob returns "Invalid ad width or height" error.

**BannerAdView** (`Components/BannerAdView.swift`) is the SwiftUI wrapper:
- Uses `BannerView` from Google Mobile Ads SDK via `UIViewRepresentable`
- Fixed height of 60pt, adapts to screen width
- `.bannerAd(placement:)` view modifier for easy integration

**Configuration**:
- `GADApplicationIdentifier` in Info.plist (test ID: ca-app-pub-3940256099942544~1458002511)
- SKAdNetwork identifiers configured for iOS 14+ attribution
- Initialized in `mathgameApp.swift` on app launch

### MIDI Music System

**MIDIMusicEngine** (`Services/MIDIMusicEngine.swift`) generates and plays jazzy MIDI music:
- Generates MIDI data programmatically using `SimpleMIDIComposer`
- Uses `AVMIDIPlayer` for playback (no external dependencies)
- Three music tracks: menu (relaxed jazz), playing (upbeat swing), gameOver (mellow ballad)
- 20-30 second seamless loops with automatic looping

**Music Generation** (`SimpleMIDIComposer` within `MIDIMusicEngine.swift`):
- Creates raw MIDI file data programmatically
- Jazz chord progressions (ii-V-I turnarounds)
- Multiple channels: chords (ch 0), bass (ch 1), drums (ch 9)
- Program changes for instrument selection

**AudioManager Integration**:
- `AudioManager` delegates music playback to `MIDIMusicEngine`
- Sound effects remain synthesized via `AVAudioPlayer`
- Volume/mute controls apply to both systems

**Future Theme Support**:
Each theme can optionally provide custom MIDI by implementing music generation. Currently uses default jazzy compositions for all themes.

### View Structure

- **MenuView**: Main menu with animated cards, coin balance, theme store access, banner ad at bottom
- **GameView**: Gameplay with cards, timer, answer buttons (6 buttons: 4 numeric + BUST + BLACKJACK)
  - Pause button: small (24x24), positioned next to "Blackjack" text in header
  - Mute button: located in pause menu
  - Banner ad at bottom
- **GameOverView**: Run stats, coins earned, accuracy, best streak, banner ad at bottom
- **ThemeStoreView**: Grid of themes with purchase/equip functionality
- **StatsView**: Lifetime stats with Game Center leaderboards/achievements buttons, banner ad at bottom
- **SettingsView**: Audio/haptic toggles

### Game Center Integration

**GameCenterManager** (`Services/GameCenterManager.swift`) handles:
- Leaderboards: highScore, bestStreak, mostCorrect, weeklyHighScore
- Achievements: firstSteps, streakMaster, millionaire, blackjackPro, themeCollector
- Authentication on app launch via `authenticateHandler`

### Important Implementation Details

**Blackjack Hand Calculation** (`Models/HandValue.swift`):
- Base value counts all Aces as 1
- Upgrades Aces to 11 (+10) without busting
- Soft hand = at least one Ace counted as 11
- Example: A,8 = Soft 19; A,A,9 = Soft 21; A,10,9 = Hard 20

**Timer System**:
- `timerTask: Task<Void, Never>?` with `Task.sleep(for: .milliseconds(100))`
- `onTimerExpire` callback triggers `handleBlackjackTimeExpired()` → wrong answer
- Pauses/resumes with app lifecycle via `ScenePhase` handling

**Coin Synchronization**:
- `GameState.modelContext` must be set from `MenuView.setupPersistentPlayer()`
- After earning coins in `endGame()`, explicitly call `context.save()`
- Views use `@Query var persistentPlayers: [PersistentPlayer]` for auto-updates

**Practice Mode**:
- No timer, no points, no coins earned
- Set via `isPracticeMode` flag in `GameState` and `BlackjackSession`

### File Organization

```
mathgame/
├── mathgameApp.swift          # App entry, Game Center auth
├── Models/
│   ├── Player.swift            # In-memory run stats
│   ├── PersistentPlayer.swift  # SwiftData persistence
│   ├── BlackjackSession.swift  # Game session logic
│   ├── Card.swift              # Playing card model
│   ├── CardShoe.swift          # 6-deck shoe
│   ├── HandValue.swift         # Blackjack hand calculation
│   ├── Theme.swift             # Visual themes
│   └── Achievement.swift       # Achievement definitions
├── Views/
│   ├── MenuView.swift          # Main menu
│   ├── GameView.swift          # Gameplay
│   ├── GameOverView.swift      # Run stats
│   ├── ThemeStoreView.swift    # Theme shop
│   ├── StatsView.swift         # Statistics
│   ├── SettingsView.swift      # Settings
│   ├── LeaderboardsView.swift  # Game Center leaderboards
│   └── AchievementsView.swift  # Game Center achievements
├── Components/
│   ├── PlayingCardView.swift   # Card visualization
│   ├── ThickBorderButton.swift # Custom button style
│   ├── TimerBar.swift          # Timer progress
│   ├── StreakBadge.swift       # Streak counter
│   ├── BannerAdView.swift      # AdMob banner wrapper
│   └── HealthIndicator.swift   # Health hearts display
└── Services/
    ├── GameState.swift         # Central state management
    ├── GameCenterManager.swift # Game Center integration
    ├── SyncManager.swift       # iCloud sync status
    ├── AudioManager.swift      # Audio playback
    ├── HapticManager.swift     # Haptic feedback
    ├── AdManager.swift         # AdMob integration
    └── MIDIMusicEngine.swift   # MIDI music generation
```

### Testing Notes

- XCTest causes Xcode crashes on this machine - do not add unit tests
- Manual testing checklist in README.md
- Use debug logging in `GameState.endGame()` for coin tracking
