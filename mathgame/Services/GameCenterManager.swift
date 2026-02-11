//
//  GameCenterManager.swift
//  mathgame
//
//  Game Center integration for leaderboards and achievements
//

import GameKit

@Observable
@MainActor
class GameCenterManager {
    static let shared = GameCenterManager()

    var isAuthenticated = false
    var localPlayer: GKLocalPlayer?
    var authenticationError: String?

    enum LeaderboardID: String {
        case highScore = "com.ricaud.mathgame.leaderboard.highscore"
        case bestStreak = "com.ricaud.mathgame.leaderboard.streak"
        case mostCorrect = "com.ricaud.mathgame.leaderboard.correct"
        case weeklyHighScore = "com.ricaud.mathgame.leaderboard.highscore.weekly"

        var displayName: String {
            switch self {
            case .highScore: return "High Score"
            case .bestStreak: return "Best Streak"
            case .mostCorrect: return "Most Correct"
            case .weeklyHighScore: return "Weekly High Score"
            }
        }
    }

    enum AchievementID: String {
        case firstSteps = "com.ricaud.mathgame.achievement.firststeps"
        case speedDemon = "com.ricaud.mathgame.achievement.speeddemon"
        case streakMaster = "com.ricaud.mathgame.achievement.streakmaster"
        case themeCollector = "com.ricaud.mathgame.achievement.themecollector"
        case millionaire = "com.ricaud.mathgame.achievement.millionaire"
        case blackjackPro = "com.ricaud.mathgame.achievement.blackjackpro"

        var displayName: String {
            switch self {
            case .firstSteps: return "First Steps"
            case .speedDemon: return "Speed Demon"
            case .streakMaster: return "Streak Master"
            case .themeCollector: return "Theme Collector"
            case .millionaire: return "Millionaire"
            case .blackjackPro: return "Blackjack Pro"
            }
        }
    }

    private init() {}

    // MARK: - Authentication

    func authenticate() {
        GKLocalPlayer.local.authenticateHandler = { [weak self] viewController, error in
            guard let self = self else { return }

            if let viewController = viewController {
                // Need to present view controller for authentication
                // Store reference for later presentation
                self.authenticationError = "Please sign in to Game Center"
                self.isAuthenticated = false
                // The view controller should be presented by the app's root view controller
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootVC = windowScene.windows.first?.rootViewController {
                    rootVC.present(viewController, animated: true)
                }
            } else if let error = error {
                self.authenticationError = error.localizedDescription
                self.isAuthenticated = false
            } else {
                // Successfully authenticated
                self.localPlayer = GKLocalPlayer.local
                self.isAuthenticated = true
                self.authenticationError = nil
            }
        }
    }

    func authenticateWithPresentingViewController(_ viewController: UIViewController) {
        GKLocalPlayer.local.authenticateHandler = { [weak self] authViewController, error in
            guard let self = self else { return }

            if let authViewController = authViewController {
                viewController.present(authViewController, animated: true)
            } else if let error = error {
                self.authenticationError = error.localizedDescription
                self.isAuthenticated = false
            } else {
                self.localPlayer = GKLocalPlayer.local
                self.isAuthenticated = true
                self.authenticationError = nil
            }
        }
    }

    // MARK: - Score Submission

    func submitScore(_ score: Int, to leaderboard: LeaderboardID) async {
        guard isAuthenticated else { return }

        do {
            try await GKLeaderboard.submitScore(
                score,
                context: 0,
                player: GKLocalPlayer.local,
                leaderboardIDs: [leaderboard.rawValue]
            )
        } catch {
            print("Failed to submit score: \(error)")
        }
    }

    func submitScores(highScore: Int, bestStreak: Int, mostCorrect: Int) async {
        guard isAuthenticated else { return }

        await submitScore(highScore, to: .highScore)
        await submitScore(bestStreak, to: .bestStreak)
        await submitScore(mostCorrect, to: .mostCorrect)
        await submitScore(highScore, to: .weeklyHighScore)
    }

    // MARK: - Leaderboard View

    func showLeaderboard(_ leaderboard: LeaderboardID, from viewController: UIViewController) {
        guard isAuthenticated else { return }

        let gcVC = GKGameCenterViewController(leaderboardID: leaderboard.rawValue, playerScope: .global, timeScope: .allTime)
        gcVC.gameCenterDelegate = viewController as? GKGameCenterControllerDelegate
        viewController.present(gcVC, animated: true)
    }

    func showLeaderboards(from viewController: UIViewController) {
        guard isAuthenticated else { return }

        let gcVC = GKGameCenterViewController(state: .leaderboards)
        gcVC.gameCenterDelegate = viewController as? GKGameCenterControllerDelegate
        viewController.present(gcVC, animated: true)
    }

    // MARK: - Achievements

    func submitAchievement(_ achievement: AchievementID, percentComplete: Double) async {
        guard isAuthenticated else { return }

        let gkAchievement = GKAchievement(identifier: achievement.rawValue)
        gkAchievement.percentComplete = percentComplete

        do {
            try await GKAchievement.report([gkAchievement])
        } catch {
            print("Failed to submit achievement: \(error)")
        }
    }

    func showAchievements(from viewController: UIViewController) {
        guard isAuthenticated else { return }

        let gcVC = GKGameCenterViewController(state: .achievements)
        gcVC.gameCenterDelegate = viewController as? GKGameCenterControllerDelegate
        viewController.present(gcVC, animated: true)
    }
}
