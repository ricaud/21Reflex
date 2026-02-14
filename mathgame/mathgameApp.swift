//
//  mathgameApp.swift
//  mathgame
//
//  Main app entry point
//

import SwiftUI
import SwiftData
import GoogleMobileAds

@main
struct mathgameApp: App {
    @Environment(\.scenePhase) private var scenePhase

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            PersistentPlayer.self,
            Theme.self,
            ThemeState.self,
        ])

        // Configure for CloudKit sync (private database)
        let cloudKitConfig = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .private("iCloud.com.ricaud.21reflex")
        )

        do {
            // Try CloudKit-enabled storage first
            let container = try ModelContainer(for: schema, configurations: [cloudKitConfig])
            print("[mathgameApp] Successfully created CloudKit ModelContainer")
            return container
        } catch {
            print("[mathgameApp] Failed to create CloudKit ModelContainer: \(error)")
            print("[mathgameApp] Falling back to local storage (no sync)")

            // Fallback to local storage (works in simulator without iCloud)
            let localConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            do {
                let container = try ModelContainer(for: schema, configurations: [localConfig])
                print("[mathgameApp] Successfully created local ModelContainer")
                return container
            } catch {
                print("[mathgameApp] Failed to create local ModelContainer: \(error)")
                print("[mathgameApp] Falling back to in-memory storage")

                // Final fallback to in-memory
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
        }
    }()

    var body: some Scene {
        WindowGroup {
            MenuView()
                .onAppear {
                    // Initialize AdMob SDK
                    AdManager.shared.initialize()

                    // Authenticate with Game Center on launch
                    GameCenterManager.shared.authenticate()
                }
        }
        .modelContainer(sharedModelContainer)
        .onChange(of: scenePhase) { oldPhase, newPhase in
            GameState.shared.handleScenePhaseChange(newPhase)

            // SwiftData auto-saves on background; no manual sync needed
            // CloudKit sync is handled automatically by SwiftData
        }
    }
}
