# 21 Reflex

A fast-paced blackjack card counting trainer for iOS. Practice your card counting skills with realistic 6-deck shoe simulation. Built with SwiftUI and SwiftData.

## Features

### Game Modes

1. **Classic Mode** - Standard gameplay with 7-second timer per question
   - Progress through increasing difficulty
   - Earn buffs every 10 correct answers
   - Boss battles every 50 questions

2. **Practice Mode** - No timer, no pressure
   - Perfect for learning multiplication tables
   - No health penalties

3. **Hard Mode** - For expert players
   - 4-second timer (almost half the time)
   - No buffs allowed
   - Double coin rewards
   - Starts at difficulty 3

4. **Blackjack Mode** - Card counting practice
   - Practice counting card values like in casino blackjack
   - Proper soft/hard hand logic (Aces count as 1 or 11)
   - 6-deck shoe simulation for realistic practice
   - Cards animate in when dealt

### Progression System

- **Coins**: Earn coins for correct answers to spend in the shop
- **Themes**: Unlock visual themes to customize the game
- **Buffs**: Earn powerful buffs during gameplay
  - Extra Health: Additional hit points
  - Lucky Guess: Chance to survive wrong answers
  - Shield: Block one wrong answer
  - Second Chance: Continue after game over once
  - Slow Timer: Reduces timer speed
  - Double Coins: Earn twice the coins

### Stats & Achievements

Track your progress with detailed statistics:
- Games played and completed
- Correct/incorrect answer ratios
- Best streaks
- Coins earned
- Achievements unlocked

## Requirements

- iOS 17.0+
- Xcode 16.0+
- Swift 5.9+

## How to Run

### Clone and Build

```bash
cd /Users/davidricaud/git/xcode/mathgame/mathgame
xcodebuild -project mathgame.xcodeproj -scheme mathgame -destination 'platform=iOS Simulator,name=iPhone 17' build
```

### Run in Simulator

```bash
# Open in Xcode
open mathgame.xcodeproj

# Or run from command line
xcodebuild -project mathgame.xcodeproj -scheme mathgame -destination 'platform=iOS Simulator,name=iPhone 17' test
```

## Project Structure

```
mathgame/
├── mathgame/
│   ├── mathgameApp.swift          # App entry point
│   ├── Info.plist                 # App configuration
│   │
│   ├── Models/                    # Data models
│   │   ├── Achievement.swift      # Achievement definitions
│   │   ├── BlackjackSession.swift # Blackjack game logic
│   │   ├── Buff.swift             # Buff definitions
│   │   ├── Card.swift             # Playing card model
│   │   ├── CardShoe.swift         # Card shoe for blackjack
│   │   ├── GameCard.swift         # Game card component
│   │   ├── GameSession.swift      # Main game session logic
│   │   ├── HandValue.swift        # Blackjack hand calculation
│   │   ├── Player.swift           # Player stats and progress
│   │   ├── PersistentPlayer.swift # SwiftData persistence
│   │   └── Theme.swift            # Visual themes
│   │
│   ├── Views/                     # UI Views
│   │   ├── BlackjackView.swift    # Blackjack gameplay
│   │   ├── BuffSelectView.swift   # Buff selection screen
│   │   ├── GameOverView.swift     # Game over screen
│   │   ├── GameView.swift         # Main gameplay view
│   │   ├── HelpView.swift         # Help/instructions
│   │   ├── LaunchScreen.storyboard # Launch screen
│   │   ├── MenuView.swift         # Main menu
│   │   ├── PauseView.swift        # Pause overlay
│   │   ├── SettingsView.swift     # Settings screen
│   │   ├── ShopView.swift         # Theme shop
│   │   └── StatsView.swift        # Statistics view
│   │
│   ├── Components/                # Reusable UI components
│   │   ├── Diamond.swift          # Diamond shape for coins
│   │   ├── HealthIndicator.swift  # Health hearts display
│   │   ├── PlayingCardView.swift  # Card visualization
│   │   ├── StreakBadge.swift      # Streak counter UI
│   │   ├── ThickBorderButton.swift # Custom button style
│   │   └── TimerBar.swift         # Timer progress bar
│   │
│   ├── Services/                  # Business logic
│   │   ├── AnalyticsManager.swift # Analytics (stub)
│   │   ├── AudioManager.swift     # Sound and music
│   │   ├── GameState.swift        # Central state management
│   │   └── HapticManager.swift    # Haptic feedback
│   │
│   └── Assets.xcassets/           # Images, icons, colors
│
└── mathgame.xcodeproj/            # Xcode project
```

## Key Technical Details

### State Management

- Uses `@Observable` (iOS 17+) for reactive state
- `GameState` is a singleton `@MainActor` class that coordinates all game state
- SwiftData (`PersistentPlayer`) for persistent storage

### Blackjack Hand Calculation

The blackjack mode implements proper soft/hard hand logic:

```swift
// HandValue.swift
// - Base value: All Aces as 1
// - Upgrade: Try to count each Ace as 11 (+10) without busting
// - Soft hand: At least one Ace counted as 11 without busting
// - Hard hand: All Aces as 1, or no Aces
```

Example hands:
- A, 8 → Soft 19 (11 + 8)
- A, A, 9 → Soft 21 (11 + 1 + 9)
- A, 10, 9 → Hard 20 (1 + 10 + 9)
- 10, 5, 7 → Bust 22

### Timer System

- Async/await based timer using `Task.sleep`
- Automatically pauses when app goes to background
- Resumes when app returns to foreground

### Accessibility

- VoiceOver labels on all interactive elements
- Accessibility hints for context
- Dynamic Type support for text scaling

## Development Notes

### Adding a New Game Mode

1. Add case to `GameSession.GameMode` enum
2. Configure mode properties (timeLimit, difficulty, etc.)
3. Add button in `MenuView.swift`
4. Handle mode-specific logic in `GameState.startGame()`

### Adding a New Buff

1. Create buff instance in `Models/Buff.swift`
2. Add handling logic in `Player.swift`
3. Add UI representation if needed

### Adding a New Theme

1. Create theme in `Models/Theme.swift`
2. Add to `Theme.allThemes` array
3. Set cost > 0 if it should be unlockable

## Testing

### Unit Tests

Run unit tests:
```bash
xcodebuild -project mathgame.xcodeproj -scheme mathgame -destination 'platform=iOS Simulator,name=iPhone 17' test
```

### Manual Testing Checklist

- [ ] All game modes start correctly
- [ ] Timer pauses in background
- [ ] Audio mutes/unmutes properly
- [ ] Themes unlock and apply
- [ ] Buffs work as expected
- [ ] Blackjack soft/hard hands calculate correctly
- [ ] Accessibility labels read correctly
- [ ] Data persists across app restarts

## Production Readiness

### Implemented

✅ Soft/hard hand logic for blackjack
✅ App icons and launch screen
✅ Accessibility support
✅ Scene phase handling (background/foreground)
✅ Error handling (no fatalError on data load)
✅ iOS 17+ deployment target

### Future Improvements

- [ ] iPad layout optimization
- [ ] Dark mode themes
- [ ] Unit test coverage
- [ ] Analytics integration
- [ ] iCloud sync for progress
- [ ] Game Center leaderboards

## License

This project is proprietary. Created for educational and entertainment purposes.

## Credits

Built with:
- SwiftUI for UI
- SwiftData for persistence
- AVFoundation for audio
