//
//  CloudSyncManager.swift
//  mathgame
//
//  iCloud synchronization manager for progress sync
//

import CloudKit
import SwiftData

@Observable
@MainActor
class CloudSyncManager {
    static let shared = CloudSyncManager()

    var syncStatus: SyncStatus = .unknown
    var lastSyncDate: Date?
    var isICloudAvailable: Bool = false

    enum SyncStatus: Equatable {
        case unknown
        case syncing
        case synced
        case error(String)
        case disabled

        var description: String {
            switch self {
            case .unknown: return "Unknown"
            case .syncing: return "Syncing..."
            case .synced: return "Synced"
            case .error(let msg): return "Error: \(msg)"
            case .disabled: return "Disabled"
            }
        }
    }

    private let container: CKContainer
    private let privateDatabase: CKDatabase
    private let kvStore: NSUbiquitousKeyValueStore

    private init() {
        container = CKContainer.default()
        privateDatabase = container.privateCloudDatabase
        kvStore = NSUbiquitousKeyValueStore.default

        // Check iCloud availability
        checkICloudAvailability()

        // Setup notifications for external changes
        setupNotifications()
    }

    // MARK: - iCloud Availability

    private func checkICloudAvailability() {
        container.accountStatus { [weak self] status, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch status {
                case .available:
                    self.isICloudAvailable = true
                    self.syncStatus = .unknown
                case .noAccount:
                    self.isICloudAvailable = false
                    self.syncStatus = .disabled
                case .restricted:
                    self.isICloudAvailable = false
                    self.syncStatus = .disabled
                case .couldNotDetermine:
                    self.isICloudAvailable = false
                    if let error = error {
                        self.syncStatus = .error(error.localizedDescription)
                    } else {
                        self.syncStatus = .error("Could not determine iCloud status")
                    }
                @unknown default:
                    self.isICloudAvailable = false
                    self.syncStatus = .error("Unknown iCloud status")
                }
            }
        }
    }

    // MARK: - Notifications

    private func setupNotifications() {
        // Listen for iCloud key-value store changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKVStoreChange),
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: kvStore
        )

        // Listen for iCloud account changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAccountChange),
            name: .CKAccountChanged,
            object: nil
        )
    }

    @objc private func handleKVStoreChange(_ notification: Notification) {
        // Key-value store changed externally, update local settings
        // The settings are automatically synced via NSUbiquitousKeyValueStore
        // Just need to reload from UserDefaults/iCloud
    }

    @objc private func handleAccountChange(_ notification: Notification) {
        checkICloudAvailability()
    }

    // MARK: - Key-Value Store Sync (Settings)

    func syncSettingsToiCloud(musicVolume: Float, sfxVolume: Float, hapticsEnabled: Bool) {
        guard isICloudAvailable else { return }

        kvStore.set(musicVolume, forKey: "musicVolume")
        kvStore.set(sfxVolume, forKey: "sfxVolume")
        kvStore.set(hapticsEnabled, forKey: "hapticsEnabled")
        kvStore.synchronize()
    }

    func syncSettingsFromiCloud() -> (musicVolume: Float, sfxVolume: Float, hapticsEnabled: Bool)? {
        guard isICloudAvailable else { return nil }

        let musicVolume = kvStore.object(forKey: "musicVolume") as? Float ?? 0.7
        let sfxVolume = kvStore.object(forKey: "sfxVolume") as? Float ?? 0.8
        let hapticsEnabled = kvStore.object(forKey: "hapticsEnabled") as? Bool ?? true

        return (musicVolume, sfxVolume, hapticsEnabled)
    }

    // MARK: - CloudKit Sync (PersistentPlayer)

    func syncPersistentPlayerToCloud(_ player: PersistentPlayer) async {
        guard isICloudAvailable else { return }

        syncStatus = .syncing

        do {
            let record = try createCKRecord(from: player)
            let (saveResults, _) = try await privateDatabase.modifyRecords(saving: [record], deleting: [])

            // Check results
            for (recordID, result) in saveResults {
                switch result {
                case .success:
                    print("Successfully saved record: \(recordID)")
                case .failure(let error):
                    throw error
                }
            }

            lastSyncDate = Date()
            syncStatus = .synced
        } catch {
            syncStatus = .error(error.localizedDescription)
        }
    }

    func syncPersistentPlayerFromCloud() async -> PersistentPlayer? {
        guard isICloudAvailable else { return nil }

        syncStatus = .syncing

        do {
            let query = CKQuery(recordType: "PersistentPlayer", predicate: NSPredicate(value: true))
            let (matchResults, _) = try await privateDatabase.records(matching: query)

            guard let firstResult = matchResults.first else {
                syncStatus = .synced
                return nil
            }

            let (_, result) = firstResult
            switch result {
            case .success(let record):
                let player = try createPersistentPlayer(from: record)
                lastSyncDate = Date()
                syncStatus = .synced
                return player
            case .failure(let error):
                throw error
            }
        } catch {
            syncStatus = .error(error.localizedDescription)
            return nil
        }
    }

    // MARK: - Full Sync

    func sync() async {
        guard isICloudAvailable else {
            syncStatus = .disabled
            return
        }

        syncStatus = .syncing

        // Sync key-value store
        kvStore.synchronize()

        // Note: CloudKit sync for PersistentPlayer is handled separately
        // when the model context changes

        lastSyncDate = Date()
        syncStatus = .synced
    }

    // MARK: - Record Conversion

    private func createCKRecord(from player: PersistentPlayer) throws -> CKRecord {
        let recordID = CKRecord.ID(recordName: "persistentPlayer")
        let record = CKRecord(recordType: "PersistentPlayer", recordID: recordID)

        record["bestStreak"] = player.bestStreak
        record["highestCorrectCount"] = player.highestCorrectCount
        record["totalQuestionsAnswered"] = player.totalQuestionsAnswered
        record["totalCorrect"] = player.totalCorrect
        record["totalWrong"] = player.totalWrong
        record["runsCompleted"] = player.runsCompleted
        record["totalCoinsEarned"] = player.totalCoinsEarned
        record["totalCoinsSpent"] = player.totalCoinsSpent
        record["musicVolume"] = player.musicVolume
        record["sfxVolume"] = player.sfxVolume
        record["hapticsEnabled"] = player.hapticsEnabled
        record["equippedThemeID"] = player.equippedThemeID

        // New fields
        record["mostCoinsInRun"] = player.mostCoinsInRun
        record["topScores"] = player.topScores as CKRecordValue
        record["isMuted"] = player.isMuted
        record["firstStepsCompleted"] = player.firstStepsCompleted
        record["streakMasterProgress"] = player.streakMasterProgress
        record["millionaireProgress"] = player.millionaireProgress
        record["blackjackProProgress"] = player.blackjackProProgress
        record["themeCollectorProgress"] = player.themeCollectorProgress
        record["lastCloudKitSync"] = player.lastCloudKitSync

        return record
    }

    private func createPersistentPlayer(from record: CKRecord) throws -> PersistentPlayer {
        let player = PersistentPlayer()

        player.bestStreak = record["bestStreak"] as? Int ?? 0
        player.highestCorrectCount = record["highestCorrectCount"] as? Int ?? 0
        player.totalQuestionsAnswered = record["totalQuestionsAnswered"] as? Int ?? 0
        player.totalCorrect = record["totalCorrect"] as? Int ?? 0
        player.totalWrong = record["totalWrong"] as? Int ?? 0
        player.runsCompleted = record["runsCompleted"] as? Int ?? 0
        player.totalCoinsEarned = record["totalCoinsEarned"] as? Int ?? 0
        player.totalCoinsSpent = record["totalCoinsSpent"] as? Int ?? 0
        player.musicVolume = record["musicVolume"] as? Float ?? 0.7
        player.sfxVolume = record["sfxVolume"] as? Float ?? 0.8
        player.hapticsEnabled = record["hapticsEnabled"] as? Bool ?? true
        player.equippedThemeID = record["equippedThemeID"] as? String ?? "classic"

        // New fields
        player.mostCoinsInRun = record["mostCoinsInRun"] as? Int ?? 0
        player.topScores = record["topScores"] as? [Int] ?? []
        player.isMuted = record["isMuted"] as? Bool ?? false
        player.firstStepsCompleted = record["firstStepsCompleted"] as? Bool ?? false
        player.streakMasterProgress = record["streakMasterProgress"] as? Int ?? 0
        player.millionaireProgress = record["millionaireProgress"] as? Int ?? 0
        player.blackjackProProgress = record["blackjackProProgress"] as? Int ?? 0
        player.themeCollectorProgress = record["themeCollectorProgress"] as? Int ?? 0
        player.lastCloudKitSync = record["lastCloudKitSync"] as? Date

        return player
    }

    // MARK: - Conflict Resolution

    func resolveConflicts(local: PersistentPlayer, remote: PersistentPlayer) -> PersistentPlayer {
        // Merge strategy: Take the maximum values for stats and coins
        let merged = PersistentPlayer()

        merged.bestStreak = max(local.bestStreak, remote.bestStreak)
        merged.highestCorrectCount = max(local.highestCorrectCount, remote.highestCorrectCount)
        merged.totalQuestionsAnswered = max(local.totalQuestionsAnswered, remote.totalQuestionsAnswered)
        merged.totalCorrect = max(local.totalCorrect, remote.totalCorrect)
        merged.totalWrong = max(local.totalWrong, remote.totalWrong)
        merged.runsCompleted = max(local.runsCompleted, remote.runsCompleted)
        merged.totalCoinsEarned = max(local.totalCoinsEarned, remote.totalCoinsEarned)
        merged.totalCoinsSpent = max(local.totalCoinsSpent, remote.totalCoinsSpent)

        // For settings, prefer local values
        merged.musicVolume = local.musicVolume
        merged.sfxVolume = local.sfxVolume
        merged.hapticsEnabled = local.hapticsEnabled
        merged.equippedThemeID = local.equippedThemeID

        // New fields
        merged.mostCoinsInRun = max(local.mostCoinsInRun, remote.mostCoinsInRun)

        // Merge top scores: combine both arrays, sort descending, keep top 3
        var combinedScores = local.topScores + remote.topScores
        combinedScores.sort(by: >)
        merged.topScores = Array(combinedScores.prefix(3))

        // Audio settings prefer local
        merged.isMuted = local.isMuted

        // Achievement progress: take max
        merged.firstStepsCompleted = local.firstStepsCompleted || remote.firstStepsCompleted
        merged.streakMasterProgress = max(local.streakMasterProgress, remote.streakMasterProgress)
        merged.millionaireProgress = max(local.millionaireProgress, remote.millionaireProgress)
        merged.blackjackProProgress = max(local.blackjackProProgress, remote.blackjackProProgress)
        merged.themeCollectorProgress = max(local.themeCollectorProgress, remote.themeCollectorProgress)

        return merged
    }

    // MARK: - ThemeState Sync

    func syncThemeStateToCloud(_ themeState: ThemeState) async {
        guard isICloudAvailable else { return }

        do {
            let record = try createThemeStateRecord(from: themeState)
            let (saveResults, _) = try await privateDatabase.modifyRecords(saving: [record], deleting: [])

            for (_, result) in saveResults {
                switch result {
                case .success:
                    print("[CloudSync] Successfully saved ThemeState for \(themeState.themeID)")
                case .failure(let error):
                    print("[CloudSync] Failed to save ThemeState: \(error)")
                }
            }
        } catch {
            print("[CloudSync] Error syncing ThemeState: \(error)")
        }
    }

    func syncAllThemeStatesToCloud(_ themeStates: [ThemeState]) async {
        guard isICloudAvailable else { return }

        syncStatus = .syncing

        do {
            let records = try themeStates.map { try createThemeStateRecord(from: $0) }
            let (saveResults, _) = try await privateDatabase.modifyRecords(saving: records, deleting: [])

            var successCount = 0
            for (_, result) in saveResults {
                switch result {
                case .success:
                    successCount += 1
                case .failure(let error):
                    print("[CloudSync] Failed to save ThemeState: \(error)")
                }
            }

            print("[CloudSync] Synced \(successCount)/\(themeStates.count) ThemeStates")
            lastSyncDate = Date()
            syncStatus = .synced
        } catch {
            syncStatus = .error(error.localizedDescription)
        }
    }

    func syncThemeStatesFromCloud() async -> [ThemeState]? {
        guard isICloudAvailable else { return nil }

        syncStatus = .syncing

        do {
            let query = CKQuery(recordType: "ThemeState", predicate: NSPredicate(value: true))
            let (matchResults, _) = try await privateDatabase.records(matching: query)

            var themeStates: [ThemeState] = []
            for (_, result) in matchResults {
                switch result {
                case .success(let record):
                    if let themeState = try? createThemeState(from: record) {
                        themeStates.append(themeState)
                    }
                case .failure(let error):
                    print("[CloudSync] Failed to fetch ThemeState: \(error)")
                }
            }

            lastSyncDate = Date()
            syncStatus = .synced
            return themeStates
        } catch {
            syncStatus = .error(error.localizedDescription)
            return nil
        }
    }

    private func createThemeStateRecord(from themeState: ThemeState) throws -> CKRecord {
        let recordID = CKRecord.ID(recordName: "themeState-\(themeState.themeID)")
        let record = CKRecord(recordType: "ThemeState", recordID: recordID)

        record["themeID"] = themeState.themeID
        record["isUnlocked"] = themeState.isUnlocked
        record["isEquipped"] = themeState.isEquipped
        record["unlockDate"] = themeState.unlockDate
        record["lastModified"] = themeState.lastModified

        return record
    }

    private func createThemeState(from record: CKRecord) throws -> ThemeState {
        let themeID = record["themeID"] as? String ?? ""
        let themeState = ThemeState(themeID: themeID)

        themeState.isUnlocked = record["isUnlocked"] as? Bool ?? false
        themeState.isEquipped = record["isEquipped"] as? Bool ?? false
        themeState.unlockDate = record["unlockDate"] as? Date
        themeState.lastModified = record["lastModified"] as? Date ?? Date()

        return themeState
    }
}
