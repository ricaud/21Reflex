//
//  TwentyOneReflexApp.swift
//  21Reflex
//
//  Main app entry point
//

import SwiftUI
import SwiftData
import GoogleMobileAds
import StoreKit

@main
struct TwentyOneReflexApp: App {
    @Environment(\.scenePhase) private var scenePhase

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            PersistentPlayer.self,
            Theme.self,
            ThemeState.self,
            StoryProgress.self,
            NightHistory.self,
        ])

        // Configure for CloudKit sync (private database)
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .private("iCloud.com.ricaud.21reflex")
        )

        do {
            let container = try ModelContainer(for: schema, configurations: [config])
            print("[21ReflexApp] Successfully created ModelContainer")
            return container
        } catch {
            print("[21ReflexApp] Failed to create ModelContainer: \(error)")

            // Fallback to in-memory only
            let fallbackConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            do {
                let container = try ModelContainer(for: schema, configurations: [fallbackConfig])
                print("[21ReflexApp] Using in-memory ModelContainer")
                return container
            } catch {
                fatalError("Critical: Cannot create ModelContainer: \(error)")
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

                    // Check IAP entitlements on launch
                    Task {
                        await IAPManager.shared.checkEntitlements()
                    }
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
