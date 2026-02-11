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

        return merged
    }
}
