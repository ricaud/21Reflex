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
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false, cloudKitDatabase: .private("iCloud.com.ricaud.mathgame"))

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            // Log error and fallback to in-memory storage rather than crashing
            print("Failed to create persistent ModelContainer: \(error)")
            print("Falling back to in-memory storage")

            let fallbackConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            do {
                return try ModelContainer(for: schema, configurations: [fallbackConfig])
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
