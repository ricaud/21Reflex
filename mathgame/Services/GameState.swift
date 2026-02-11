//
//  GameState.swift
//  mathgame
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

        audioManager.playMusic(.playing)
        navigate(to: .game)
    }

    func startPracticeMode() {
        isPracticeMode = true
        player.resetForRun()

        session = BlackjackSession(isPracticeMode: true)
        session?.start()

        audioManager.playMusic(.playing)
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
            player.updateTopScores(session?.totalSessionPoints ?? 0)

            // Sync coins to persistent storage
            persistentPlayer?.totalCoinsEarned += player.coins
        }

        audioManager.playMusic(.gameOver)
        returnToMenu()
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
        audioManager.playMusic(.menu)
    }

    // MARK: - Pause
    private func setPauseState(_ paused: Bool) {
        isPaused = paused
        showPauseOverlay = paused

        if paused {
            session?.pauseTimer()
            audioManager.pauseMusic()
        } else {
            session?.resumeTimer()
            audioManager.resumeMusic()
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
            // App is foregrounded - can restore if needed
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


    // MARK: - Settings from Pause
    func showSettingsFromPause() {
        showSettingsInPause = true
    }

    func closeSettingsFromPause() {
        showSettingsInPause = false
    }
}
