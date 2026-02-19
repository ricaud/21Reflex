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
            print("[21ReflexApp] Successfully created CloudKit ModelContainer")
            return container
        } catch {
            print("[21ReflexApp] Failed to create CloudKit ModelContainer: \(error)")
            print("[21ReflexApp] Falling back to local storage (no sync)")

            // Fallback to local storage (works in simulator without iCloud)
            let localConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            do {
                let container = try ModelContainer(for: schema, configurations: [localConfig])
                print("[21ReflexApp] Successfully created local ModelContainer")
                return container
            } catch {
                print("[21ReflexApp] Failed to create local ModelContainer: \(error)")
                print("[21ReflexApp] Falling back to in-memory storage")

                // Final fallback to in-memory
                let fallbackConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
                do {
                    let container = try ModelContainer(for: schema, configurations: [fallbackConfig])
                    print("[21ReflexApp] Successfully created in-memory ModelContainer")
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
