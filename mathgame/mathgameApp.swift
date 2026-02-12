//
//  mathgameApp.swift
//  mathgame
//
//  Main app entry point
//

import SwiftUI
import SwiftData

@main
struct mathgameApp: App {
    @Environment(\.scenePhase) private var scenePhase

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            PersistentPlayer.self,
        ])

        // Try local storage first (works in simulator and on device)
        let localConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            // First try local persistent storage (no CloudKit)
            let container = try ModelContainer(for: schema, configurations: [localConfig])
            print("[mathgameApp] Successfully created local ModelContainer")
            return container
        } catch {
            print("[mathgameApp] Failed to create local ModelContainer: \(error)")
            print("[mathgameApp] Falling back to in-memory storage")

            // Fallback to in-memory for preview/simulator issues
            let fallbackConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            do {
                let container = try ModelContainer(for: schema, configurations: [fallbackConfig])
                print("[mathgameApp] Successfully created in-memory ModelContainer")
                return container
            } catch {
                // Only crash if even in-memory fails (critical system issue)
                fatalError("Critical: Cannot create any ModelContainer: \(error)")
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            MenuView()
                .onAppear {
                    // Authenticate with Game Center on launch
                    GameCenterManager.shared.authenticate()
                }
        }
        .modelContainer(sharedModelContainer)
        .onChange(of: scenePhase) { oldPhase, newPhase in
            GameState.shared.handleScenePhaseChange(newPhase)

            // Trigger iCloud sync on background
            if newPhase == .background {
                Task {
                    await CloudSyncManager.shared.sync()
                }
            }
        }
    }
}
