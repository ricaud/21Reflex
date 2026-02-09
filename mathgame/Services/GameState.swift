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
        case buffSelect
        case gameOver
        case shop
        case stats
        case settings
        case help
    }

    var navigationPath: [Screen] = []
    var currentScreen: Screen = .menu

    // MARK: - Game Objects
    var player = Player()
    var session: GameSession?
    var blackjackSession: BlackjackSession?
    var audioManager = AudioManager()
    var hapticManager = HapticManager()

    // MARK: - Theme
    var currentTheme: Theme = .classic
    var availableThemes: [Theme] = Theme.allThemes

    // MARK: - UI State
    var isPaused: Bool = false
    var showPauseOverlay: Bool = false
    var newlyUnlockedAchievements: [Achievement] = []
    var showAchievementToast: Bool = false
    var currentAchievementToast: Achievement?

    // MARK: - Game Mode Selection
    var selectedGameMode: GameSession.GameMode = .classic

    // MARK: - Settings Navigation
    var showSettingsInPause: Bool = false

    private init() {}

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
    func startGame(mode: GameSession.GameMode) {
        selectedGameMode = mode
        player.resetForRun()

        if mode == .blackjack {
            blackjackSession = BlackjackSession()
            blackjackSession?.onTimerExpire = { [weak self] in
                Task { @MainActor in
                    self?.handleBlackjackTimeExpired()
                }
            }
            blackjackSession?.start()
        } else {
            session = GameSession()
            session?.onTimerExpire = { [weak self] in
                Task { @MainActor in
                    self?.handleTimeExpired()
                }
            }
            session?.start(mode: mode)
        }

        audioManager.playMusic(.playing)
        navigate(to: .game)
    }

    func handleBlackjackTimeExpired() {
        let result = player.handleWrongAnswer()

        switch result {
        case .gameOver:
            endGame()
        case .shieldUsed, .luckySave, .secondChanceUsed:
            audioManager.playSound(.wrong)
            hapticManager.playWrongFeedback()
            blackjackSession?.handleWrongAnswer()
        case .normal:
            audioManager.playSound(.wrong)
            hapticManager.playWrongFeedback()
            blackjackSession?.handleWrongAnswer()
        }
    }

    func handleTimeExpired() {
        // Time ran out - treat as wrong answer
        let result = player.handleWrongAnswer()

        switch result {
        case .gameOver:
            endGame()
        case .shieldUsed, .luckySave, .secondChanceUsed:
            audioManager.playSound(.wrong)
            hapticManager.playWrongFeedback()
            // Continue game with new question
            session?.generateQuestion()
        case .normal:
            audioManager.playSound(.wrong)
            hapticManager.playWrongFeedback()
            session?.increaseDifficulty()
            session?.generateQuestion()
        }
    }

    func handleAnswer(_ option: GameSession.AnswerOption) {
        guard let session = session else { return }

        // Don't process answer if timer has expired
        if session.mode.hasTimer && session.timeRemaining <= 0 {
            return
        }

        if option.isCorrect {
            // Correct answer
            player.handleCorrectAnswer()
            session.increaseDifficulty()
            session.handleBossBattleProgress()

            audioManager.playSound(.correct)
            hapticManager.playCorrectFeedback()

            // Check for buff selection
            if player.correctCount % 10 == 0 && session.mode.buffsEnabled {
                session.pauseTimer()
                audioManager.playMusic(.buffSelect)
                navigate(to: .buffSelect)
                return
            }

            // Generate next question
            session.generateQuestion()

        } else {
            // Wrong answer
            let result = player.handleWrongAnswer()

            switch result {
            case .gameOver:
                endGame()
            case .shieldUsed, .luckySave, .secondChanceUsed:
                audioManager.playSound(.wrong)
                // Continue game
                session.generateQuestion()
            case .normal:
                audioManager.playSound(.wrong)
                hapticManager.playWrongFeedback()
                session.increaseDifficulty()
                session.generateQuestion()
            }
        }
    }

    func selectBuff(_ buff: Buff) {
        player.addBuff(buff)
        audioManager.playSound(.buffSelect)
        audioManager.playMusic(.playing)

        // Resume timer when returning from buff selection
        session?.resumeTimer()

        // Remove buff select from navigation
        if let index = navigationPath.lastIndex(where: { $0 == .buffSelect }) {
            navigationPath.remove(at: index)
        }
        currentScreen = .game
    }

    func endGame() {
        session?.endGame()
        blackjackSession?.endGame()

        // Update high scores (only for math modes for now)
        if selectedGameMode != .blackjack {
            let _ = player.updateHighScores()
        }

        // Check achievements
        newlyUnlockedAchievements = player.checkAchievements()
        if let first = newlyUnlockedAchievements.first {
            currentAchievementToast = first
            showAchievementToast = true
            audioManager.playSound(.achievement)
        }

        // Update lifetime stats
        player.lifetimeStats.runsCompleted += 1

        audioManager.playMusic(.gameOver)
        navigate(to: .gameOver)
    }

    func restartGame() {
        setPauseState(false)
        resetNavigation()
        startGame(mode: selectedGameMode)
    }

    func returnToMenu() {
        // First dismiss pause overlay and reset pause state
        setPauseState(false)

        // Then clean up session
        session?.reset()
        session = nil
        blackjackSession?.reset()
        blackjackSession = nil

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
            blackjackSession?.pauseTimer()
            audioManager.pauseMusic()
        } else {
            session?.resumeTimer()
            blackjackSession?.resumeTimer()
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

    // MARK: - Theme
    func updateTheme(_ theme: Theme) {
        currentTheme = theme
    }

    // MARK: - Shop
    func purchaseTheme(_ theme: Theme) -> Bool {
        guard player.unlockTheme(theme.id, cost: theme.cost) else { return false }
        audioManager.playSound(.themeBuy)
        return true
    }

    func equipTheme(_ theme: Theme) {
        player.equipTheme(theme.id)
        currentTheme = theme

        // Update available themes to reflect equipped status
        if let index = availableThemes.firstIndex(where: { $0.id == theme.id }) {
            for i in availableThemes.indices {
                availableThemes[i].isEquipped = (i == index)
            }
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
