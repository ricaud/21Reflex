# Claude Code Session Context

## Session Date: 2026-02-10

## Overview
This session focused on splitting the Math Rush game into two separate git branches:
1. **math-only**: Multiplication game only
2. **blackjack-only**: Blackjack card counting game only

## Branches Created

### 1. math-only (completed)
**Location**: `git checkout math-only`

**State**: Fully functional multiplication game
- **Game Modes**: Classic, Practice, Hard Mode
- **Features**: Buffs, Achievements, Shop, Themes, High Scores
- **Removed**: All blackjack functionality

**Files Removed**:
- Views/BlackjackView.swift
- Models/BlackjackSession.swift
- Models/Card.swift
- Models/CardShoe.swift
- Models/HandValue.swift
- Components/PlayingCardView.swift

### 2. blackjack-only (completed)
**Location**: `git checkout blackjack-only`

**State**: Fully functional blackjack card counting game
- **Game Mode**: Single blackjack mode with hand value calculation
- **Features**: Soft/hard hand logic, timer, health system, streaks
- **Removed**: Buffs, Achievements, Shop, Themes, Coins, multiple game modes

**Files Removed**:
- Views/GameView.swift (original math version)
- Models/GameSession.swift
- Components/GameCard.swift
- Components/CoinDisplay.swift
- Views/BuffSelectView.swift
- Views/GameOverView.swift
- Views/ShopView.swift
- Models/Buff.swift
- Models/Achievement.swift

**Key Simplifications**:
- `GameState.swift`: Removed math session handling, renamed `blackjackSession` to `session`
- `Player.swift`: Removed coins, buffs, themes, achievements; kept basic stats
- `MenuView.swift`: Single "PLAY" button instead of mode selection
- `HelpView.swift`: Updated with blackjack instructions and soft/hard hand explanations
- `StatsView.swift`: Simplified to show only hands played, accuracy, best streak, games played
- `PersistentPlayer.swift`: Removed coin/theme/achievement persistence

### 3. main (original)
**Location**: `git checkout main`

**State**: Contains both math and blackjack functionality (the original combined app)

## Key Technical Details

### Soft/Hard Hand Logic (implemented in HandValue.swift)
- Aces are calculated as 11 when possible without busting
- "Soft" hand = contains an Ace counted as 11
- "Hard" hand = no Ace, or Ace counted as 1
- "Bust" = total > 21

### Architecture
- SwiftUI with `@Observable` pattern (iOS 17+)
- SwiftData for persistence
- `@MainActor` for all observable classes
- Singleton pattern for GameState

### Project Structure
```
mathgame/
├── mathgame/
│   ├── Components/     # Reusable UI components
│   ├── Models/         # Data models
│   ├── Services/       # Game logic, audio, haptics
│   └── Views/          # SwiftUI views
└── mathgame.xcodeproj/
```

## Next Steps / Potential Tasks

### For math-only branch:
- [ ] Consider adding Daily Challenge mode
- [ ] Potentially add more buff types
- [ ] Balance coin rewards and shop prices
- [ ] Add leaderboard for high scores

### For blackjack-only branch:
- [ ] Add different difficulty levels (easy/medium/hard)
- [ ] Consider adding card counting trainer features
- [ ] Add "Dealer shows" indicator for more realistic practice
- [ ] Track statistics like "soft hands answered correctly"

### For both branches:
- [ ] Add proper app icons
- [ ] Create launch screen
- [ ] Add comprehensive unit tests
- [ ] Implement proper error handling
- [ ] Add App Store compliance features (privacy policy, rating prompts)

## Important Notes

1. **HandValue calculation** is in `Models/HandValue.swift` - this is the core blackjack logic
2. **Card values**: 2-10 = face value, J/Q/K = 10, Ace = 1 or 11
3. **Timer system**: TimerBar component shows remaining time
4. **Theme system**: Only in math-only branch; blackjack-only uses hardcoded classic theme

## Build Instructions
1. Open `mathgame.xcodeproj` in Xcode
2. Select target device (iOS 17.0+)
3. Build and run (Cmd+R)

## Git Workflow
```bash
# Switch to math-only branch
git checkout math-only

# Switch to blackjack-only branch
git checkout blackjack-only

# Switch to main (combined version)
git checkout main
```

## Contact/Context
This project was developed with Claude Code (Claude Opus 4.5).
For questions about implementation details, refer to the code comments or previous conversation transcripts.
