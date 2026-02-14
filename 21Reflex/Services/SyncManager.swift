//
//  SyncManager.swift
//  21Reflex
//
//  Lightweight iCloud sync status monitor (SwiftData native CloudKit)
//

import CloudKit
import SwiftUI

/// Monitors iCloud account status and provides sync state for UI
/// Does NOT perform manual CloudKit operations - relies on SwiftData native sync
@Observable
@MainActor
class SyncManager {
    static let shared = SyncManager()

    enum SyncState: Equatable {
        case unknown
        case synced(Date?)
        case syncing
        case offline
        case noAccount
        case restricted
        case accountChanged

        var description: String {
            switch self {
            case .unknown: return "Checking..."
            case .synced: return "Synced"
            case .syncing: return "Syncing..."
            case .offline: return "Offline"
            case .noAccount: return "iCloud Not Signed In"
            case .restricted: return "iCloud Restricted"
            case .accountChanged: return "Account Changed"
            }
        }

        var iconName: String {
            switch self {
            case .synced: return "checkmark.icloud"
            case .syncing: return "arrow.clockwise.icloud"
            case .offline, .noAccount: return "icloud.slash"
            case .restricted: return "exclamationmark.icloud"
            case .accountChanged: return "person.icloud"
            case .unknown: return "icloud"
            }
        }

        var color: Color {
            switch self {
            case .synced: return .green
            case .syncing: return .blue
            case .offline, .noAccount: return .orange
            case .restricted, .accountChanged: return .red
            case .unknown: return .gray
            }
        }
    }

    var state: SyncState = .unknown
    var isICloudAvailable: Bool = false

    private let container = CKContainer.default()
    nonisolated(unsafe) private var accountChangeTask: Task<Void, Never>?

    private init() {
        observeAccountChanges()
        Task {
            await checkICloudStatus()
        }
    }

    deinit {
        accountChangeTask?.cancel()
    }

    private func observeAccountChanges() {
        accountChangeTask = Task { [weak self] in
            guard let self else { return }
            for await _ in NotificationCenter.default.notifications(named: .CKAccountChanged) {
                self.state = .accountChanged
                await self.checkICloudStatus()
            }
        }
    }

    func checkICloudStatus() async {
        do {
            let status = try await container.accountStatus()
            await MainActor.run {
                switch status {
                case .available:
                    isICloudAvailable = true
                    state = .synced(nil)
                case .noAccount:
                    isICloudAvailable = false
                    state = .noAccount
                case .restricted:
                    isICloudAvailable = false
                    state = .restricted
                case .couldNotDetermine:
                    isICloudAvailable = false
                    state = .unknown
                @unknown default:
                    isICloudAvailable = false
                    state = .unknown
                }
            }
        } catch {
            await MainActor.run {
                isICloudAvailable = false
                state = .offline
            }
        }
    }

}
