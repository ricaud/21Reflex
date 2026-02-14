//
//  GameState.swift
//  21Reflex
//
//  Central game state management and navigation
//

import SwiftUI
import SwiftData

@Observable
@MainActor
class GameState {
    static let shared = GameState()

    // MARK: - Navigation
    enum Screen: Hashable {
        case menu
        case game
        case gameOver
        case stats
        case settings
        case help
        case themes
        case leaderboards
        case achievements
    }

    var navigationPath: [Screen] = []
    var currentScreen: Screen = .menu

    // MARK: - Game Objects
    var player = Player()
    var session: BlackjackSession?
    var audioManager = AudioManager()
    var hapticManager = HapticManager()

    // MARK: - Theme
    var currentTheme: Theme = .classic
    var availableThemes: [Theme] = Theme.allThemes

    // MARK: - UI State
    var isPaused: Bool = false
    var showPauseOverlay: Bool = false

    // MARK: - Settings Navigation
    var showSettingsInPause: Bool = false

    // MARK: - Game Mode
    var isPracticeMode: Bool = false

    // MARK: - Persistent Player (set from outside)
    weak var persistentPlayer: PersistentPlayer?

    // MARK: - Model Context for SwiftData saves
    weak var modelContext: ModelContext?

    private init() {}

    // MARK: - Theme Management

    func loadThemeFromPersistentStorage() {
        guard let persistentPlayer = persistentPlayer else { return }

        // Find the equipped theme
        if let theme = availableThemes.first(where: { $0.id == persistentPlayer.equippedThemeID }) {
            // Unequip all themes first
            availableThemes.forEach { $0.isEquipped = false }

            // Equip the saved theme
            theme.isEquipped = true
            theme.isUnlocked = true
            currentTheme = theme
        }
    }

    func saveThemeToPersistentStorage() {
        persistentPlayer?.equippedThemeID = currentTheme.id
    }

    // MARK: - Complete State Loading

    /// Load all persisted state from SwiftData
    func loadCompleteState(context: ModelContext) {
        // Load PersistentPlayer
        let playerDescriptor = FetchDescriptor<PersistentPlayer>()
        if let pp = try? context.fetch(playerDescriptor).first {
            persistentPlayer = pp

            // Sync to in-memory Player
            syncPersistentPlayerToPlayer(pp)

            print("[GameState] Loaded complete state from PersistentPlayer")
        }

        // Load ThemeState and sync to availableThemes
        loadThemeStates(context: context)
    }

    /// Sync PersistentPlayer data to in-memory Player
    private func syncPersistentPlayerToPlayer(_ pp: PersistentPlayer) {
        // Sync high scores
        player.highScore.topScores = pp.topScores
        player.highScore.bestStreak = pp.bestStreak
        player.highScore.mostCoinsInRun = pp.mostCoinsInRun
        player.highScore.highestCorrectCount = pp.highestCorrectCount

        // Sync lifetime stats
        player.lifetimeStats.totalQuestionsAnswered = pp.totalQuestionsAnswered
        player.lifetimeStats.totalCorrect = pp.totalCorrect
        player.lifetimeStats.totalWrong = pp.totalWrong
        player.lifetimeStats.runsCompleted = pp.runsCompleted

        // Sync audio settings
        audioManager.sfxVolume = pp.sfxVolume
        audioManager.hapticsEnabled = pp.hapticsEnabled
        hapticManager.isEnabled = pp.hapticsEnabled
        audioManager.isMuted = pp.isMuted

        print("[GameState] Loaded audio settings - SFX: \(pp.sfxVolume), Haptics: \(pp.hapticsEnabled), Muted: \(pp.isMuted)")
    }

    /// Load ThemeState and apply to availableThemes
    func loadThemeStates(context: ModelContext) {
        let themeStateDescriptor = FetchDescriptor<ThemeState>()
        guard let themeStates = try? context.fetch(themeStateDescriptor) else { return }

        for themeState in themeStates {
            if let theme = availableThemes.first(where: { $0.id == themeState.themeID }) {
                theme.isUnlocked = themeState.isUnlocked
                theme.isEquipped = themeState.isEquipped
            }
        }

        // Ensure current equipped theme is set
        if let equippedTheme = availableThemes.first(where: { $0.isEquipped }) {
            currentTheme = equippedTheme
        }
    }

    /// Save current theme states to ThemeState model
    func saveThemeStates(context: ModelContext) {
        for theme in availableThemes {
            // Use a simple fetch and filter instead of predicate to avoid capture issues
            let descriptor = FetchDescriptor<ThemeState>()
            let allStates = (try? context.fetch(descriptor)) ?? []
            let existing = allStates.first { $0.themeID == theme.id }

            let themeState: ThemeState
            if let existing = existing {
                themeState = existing
            } else {
                themeState = ThemeState(themeID: theme.id)
                context.insert(themeState)
            }

            themeState.isUnlocked = theme.isUnlocked
            themeState.isEquipped = theme.isEquipped
            themeState.lastModified = Date()

            if theme.isUnlocked && themeState.unlockDate == nil {
                themeState.unlockDate = Date()
            }

            // Update modification timestamp for sync tracking
            themeState.lastModified = Date()
        }

        do {
            try context.save()
            print("[GameState] Saved theme states")
        } catch {
            print("[GameState] Failed to save theme states: \(error)")
        }
    }

    // MARK: - Navigation
    func navigate(to screen: Screen) {
        currentScreen = screen
        if screen != .menu {
            navigationPath.append(screen)
        }
    }

    func navigateBack() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
            currentScreen = navigationPath.last ?? .menu
        }
    }

    func resetNavigation() {
        navigationPath.removeAll()
        currentScreen = .menu
    }

    // MARK: - Game Flow
    func startGame() {
        isPracticeMode = false
        player.resetForRun()

        session = BlackjackSession(isPracticeMode: false)
        session?.onTimerExpire = { [weak self] in
            Task { @MainActor in
                self?.handleBlackjackTimeExpired()
            }
        }
        session?.start()

        navigate(to: .game)
    }

    func startPracticeMode() {
        isPracticeMode = true
        player.resetForRun()

        session = BlackjackSession(isPracticeMode: true)
        session?.start()

        navigate(to: .game)
    }

    func handleBlackjackTimeExpired() {
        // No timer expiration in practice mode
        guard !isPracticeMode else { return }

        let result = player.handleWrongAnswer()

        switch result {
        case .gameOver:
            endGame()
        case .shieldUsed, .luckySave, .secondChanceUsed:
            audioManager.playSound(.wrong)
            hapticManager.playWrongFeedback()
            session?.handleWrongAnswer()
        case .normal:
            audioManager.playSound(.wrong)
            hapticManager.playWrongFeedback()
            session?.handleWrongAnswer()
        }
    }


    func endGame() {
        session?.endGame()

        // Only update stats and scores in normal mode
        if !isPracticeMode {
            // Update lifetime stats
            player.lifetimeStats.runsCompleted += 1

            // Update top scores
            let sessionPoints = session?.totalSessionPoints ?? 0
            player.updateTopScores(sessionPoints)

            // Sync coins and stats to persistent storage
            // Fetch fresh reference to ensure we're updating the right object
            if let context = modelContext {
                let descriptor = FetchDescriptor<PersistentPlayer>()
                if let pp = try? context.fetch(descriptor).first {
                    pp.totalCoinsEarned += player.coins
                    pp.totalCorrect += player.correctCount
                    pp.totalWrong += player.wrongCount
                    pp.totalQuestionsAnswered += player.correctCount + player.wrongCount
                    pp.runsCompleted += 1

                    // Save top scores
                    pp.topScores = player.highScore.topScores
                    pp.mostCoinsInRun = max(pp.mostCoinsInRun, player.coins)

                    // Update achievement progress
                    pp.firstStepsCompleted = pp.firstStepsCompleted || (player.correctCount >= 1)
                    pp.streakMasterProgress = max(pp.streakMasterProgress, player.streak)
                    pp.millionaireProgress = pp.totalCoinsEarned
                    pp.blackjackProProgress = pp.totalCorrect
                    pp.themeCollectorProgress = availableThemes.filter { $0.isUnlocked }.count

                    // Update sync timestamp before saving
                    pp.markModified()

                    print("[GameState] Earned \(player.coins) coins. Total earned: \(pp.totalCoinsEarned), Available: \(pp.availableCoins)")

                    do {
                        try context.save()
                        print("[GameState] SwiftData context saved successfully")
                    } catch {
                        print("[GameState] Failed to save context: \(error)")
                    }
                } else {
                    print("[GameState] Warning: Could not fetch PersistentPlayer to save coins")
                }
            } else {
                print("[GameState] Warning: modelContext is nil, cannot save coins")
            }

            // Submit scores to Game Center
            Task {
                await GameCenterManager.shared.submitScores(
                    highScore: sessionPoints,
                    bestStreak: player.streak,
                    mostCorrect: player.correctCount
                )

                // Check for achievements
                await checkAchievements()
            }
        }

        navigate(to: .gameOver)
    }

    private func checkAchievements() async {
        // Fetch fresh persistent player data for achievements
        var totalCoins = 0
        var totalCorrect = 0
        if let context = modelContext {
            let descriptor = FetchDescriptor<PersistentPlayer>()
            if let pp = try? context.fetch(descriptor).first {
                totalCoins = pp.totalCoinsEarned
                totalCorrect = pp.totalCorrect
            }
        }

        // First Steps - Answer first question (submit 100% on first correct)
        if player.correctCount >= 1 {
            await GameCenterManager.shared.submitAchievement(.firstSteps, percentComplete: 100)
        }

        // Streak Master - Reach 20 streak
        if player.streak >= 20 {
            await GameCenterManager.shared.submitAchievement(.streakMaster, percentComplete: 100)
        }

        // Millionaire - Earn 1,000,000 coins total
        if totalCoins >= 1_000_000 {
            await GameCenterManager.shared.submitAchievement(.millionaire, percentComplete: 100)
        } else {
            let progress = Double(totalCoins) / 1_000_000.0 * 100
            await GameCenterManager.shared.submitAchievement(.millionaire, percentComplete: progress)
        }

        // Blackjack Pro - Answer 100 blackjack hands correctly
        if totalCorrect >= 100 {
            await GameCenterManager.shared.submitAchievement(.blackjackPro, percentComplete: 100)
        } else {
            let progress = Double(totalCorrect) / 100.0 * 100
            await GameCenterManager.shared.submitAchievement(.blackjackPro, percentComplete: progress)
        }

        // Theme Collector - Unlock 5 themes
        let unlockedCount = availableThemes.filter { $0.isUnlocked }.count
        if unlockedCount >= 5 {
            await GameCenterManager.shared.submitAchievement(.themeCollector, percentComplete: 100)
        } else {
            let progress = Double(unlockedCount) / 5.0 * 100
            await GameCenterManager.shared.submitAchievement(.themeCollector, percentComplete: progress)
        }
    }

    func restartGame() {
        setPauseState(false)
        resetNavigation()
        startGame()
    }

    func returnToMenu() {
        // First dismiss pause overlay and reset pause state
        setPauseState(false)

        // Then clean up session
        session?.reset()
        session = nil

        // Finally reset navigation
        resetNavigation()
    }

    // MARK: - Pause
    private func setPauseState(_ paused: Bool) {
        isPaused = paused
        showPauseOverlay = paused

        if paused {
            session?.pauseTimer()
        } else {
            session?.resumeTimer()
        }
    }

    func togglePause() {
        setPauseState(!isPaused)
    }

    func resumeGame() {
        setPauseState(false)
    }

    // MARK: - Scene Phase Handling
    func handleScenePhaseChange(_ phase: ScenePhase) {
        switch phase {
        case .background:
            // Pause game if playing
            if currentScreen == .game && !isPaused {
                setPauseState(true)
            }
            // Save player data when backgrounding
            savePlayerData()
        case .inactive:
            // App is transitioning - no action needed
            break
        case .active:
            // App is foregrounded
            break
        @unknown default:
            break
        }
    }

    func savePlayerData() {
        // Trigger SwiftData save
        // SwiftData auto-saves, but we can force it if needed
        // This is a hook for any additional save logic
    }

    // MARK: - Audio Settings Persistence

    /// Save current audio settings to PersistentPlayer
    func saveAudioSettings() {
        guard let pp = persistentPlayer, let context = modelContext else {
            print("[GameState] Cannot save audio settings - missing persistentPlayer or context")
            return
        }

        pp.sfxVolume = audioManager.sfxVolume
        pp.hapticsEnabled = audioManager.hapticsEnabled
        pp.isMuted = audioManager.isMuted
        pp.markModified()

        do {
            try context.save()
            print("[GameState] Saved audio settings - SFX: \(pp.sfxVolume), Haptics: \(pp.hapticsEnabled), Muted: \(pp.isMuted)")
        } catch {
            print("[GameState] Failed to save audio settings: \(error)")
        }
    }

    // MARK: - Settings from Pause
    func showSettingsFromPause() {
        showSettingsInPause = true
    }

    func closeSettingsFromPause() {
        showSettingsInPause = false
    }
}
