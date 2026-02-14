//
//  AdManager.swift
//  21Reflex
//
//  AdMob SDK management and ad loading
//

import Combine
import GoogleMobileAds
import SwiftUI

/// Central manager for AdMob ads
/// Supports banner ads currently, with hooks for future interstitial and rewarded ads
@MainActor
class AdManager: NSObject, ObservableObject {
    static let shared = AdManager()

    // MARK: - Configuration

    /// Set to true to disable ads (e.g., for premium users)
    @Published var isPremiumUser: Bool = false

    /// Test ad unit IDs from Google
    private let testBannerAdUnitID = "ca-app-pub-3940256099942544/2934735716"

    /// Production ad unit ID - replace with your actual ID before release
    private let productionBannerAdUnitID = "ca-app-pub-3940256099942544/2934735716" // TODO: Replace with production ID

    /// Current ad unit ID based on build configuration
    var bannerAdUnitID: String {
        #if DEBUG
        return testBannerAdUnitID
        #else
        return productionBannerAdUnitID
        #endif
    }

    // MARK: - State

    @Published var isInitialized = false
    @Published var initializationError: Error?

    // MARK: - Banner Ad Cache

    /// Cached banner ads for different placements
    private var bannerAds: [AdPlacement: BannerView] = [:]

    /// Banner ad sizes for different placements
    private var bannerSizes: [AdPlacement: CGSize] = [:]

    // MARK: - Initialization

    private override init() {
        super.init()
    }

    /// Initialize the AdMob SDK
    /// Call this early in the app lifecycle, before loading any ads
    func initialize() {
        guard !isInitialized else { return }

        MobileAds.shared.start { [weak self] status in
            Task { @MainActor in
                guard let self = self else { return }

                let adapterStatuses = status.adapterStatusesByClassName
                if let googleAdsStatus = adapterStatuses["GADMobileAds"] {
                    if googleAdsStatus.state == .ready {
                        self.isInitialized = true
                        print("[AdManager] AdMob SDK initialized successfully")
                    } else {
                        print("[AdManager] AdMob SDK initialization failed: \(googleAdsStatus.description)")
                    }
                }

                // Log all adapter statuses for debugging
                for (name, status) in adapterStatuses {
                    print("[AdManager] Adapter: \(name) - State: \(status.state.rawValue)")
                }
            }
        }
    }

    // MARK: - Banner Ads

    /// Get or create a banner ad for a specific placement
    func getBannerAd(for placement: AdPlacement, in viewController: UIViewController? = nil) -> BannerView {
        // Return cached banner if available
        if let existingAd = bannerAds[placement] {
            return existingAd
        }

        // Create new banner ad
        let bannerView = createBannerAd(for: placement, in: viewController)
        bannerAds[placement] = bannerView

        return bannerView
    }

    /// Create a new banner ad with proper sizing
    private func createBannerAd(for placement: AdPlacement, in viewController: UIViewController?) -> BannerView {
        // Get the current window scene for size calculations
        let windowScene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }

        let screenWidth = windowScene?.screen.bounds.width ?? UIScreen.main.bounds.width

        // Standard banner height: 50pt on iPhone, 90pt on iPad
        let bannerHeight: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 90 : 50
        bannerSizes[placement] = CGSize(width: screenWidth, height: bannerHeight)

        // Create banner with explicit frame - required by AdMob SDK
        let bannerView = BannerView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: bannerHeight))
        bannerView.adUnitID = bannerAdUnitID
        bannerView.rootViewController = viewController ?? topViewController()
        bannerView.delegate = self

        // Load the ad
        loadBannerAd(bannerView)

        return bannerView
    }

    /// Load a banner ad request
    private func loadBannerAd(_ bannerView: BannerView) {
        guard !isPremiumUser else {
            print("[AdManager] Not loading ad - user is premium")
            return
        }

        let request = Request()
        // Add extras for COPPA compliance if needed
        // let extras = Extras()
        // extras.additionalParameters = ["tag_for_child_directed_treatment": "1"]
        // request.register(extras)

        bannerView.load(request)
    }

    /// Refresh a banner ad (call when view appears or on orientation change)
    func refreshBannerAd(for placement: AdPlacement) {
        guard let bannerView = bannerAds[placement] else { return }

        // Update size for orientation changes
        let windowScene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }

        let screenWidth = windowScene?.screen.bounds.width ?? UIScreen.main.bounds.width

        // Standard banner height: 50pt on iPhone, 90pt on iPad
        let bannerHeight: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 90 : 50
        bannerSizes[placement] = CGSize(width: screenWidth, height: bannerHeight)

        // Update the banner frame to match new size
        bannerView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: bannerHeight)

        loadBannerAd(bannerView)
    }

    /// Remove and cleanup a banner ad
    func removeBannerAd(for placement: AdPlacement) {
        bannerAds.removeValue(forKey: placement)
        bannerSizes.removeValue(forKey: placement)
    }

    /// Get the expected banner height for a placement
    func bannerHeight(for placement: AdPlacement) -> CGFloat {
        return bannerSizes[placement]?.height ?? 50.0 // Default to 50pt if not loaded yet
    }

    // MARK: - Helper Methods

    /// Find the top-most view controller for presenting ads
    private func topViewController() -> UIViewController? {
        let windowScene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }

        let root = windowScene?.windows.first(where: \.isKeyWindow)?.rootViewController
        var current = root
        while let presented = current?.presentedViewController {
            current = presented
        }
        return current
    }

    // MARK: - Future Ad Types (Placeholders)

    /*
     // MARK: - Interstitial Ads

     private var interstitialAds: [AdPlacement: InterstitialAd] = [:]

     func loadInterstitialAd(for placement: AdPlacement) async {
         guard !isPremiumUser else { return }

         do {
             let ad = try await InterstitialAd.load(
                 withAdUnitID: interstitialAdUnitID,
                 request: Request()
             )
             interstitialAds[placement] = ad
             ad.fullScreenContentDelegate = self
         } catch {
             print("[AdManager] Failed to load interstitial: \(error)")
         }
     }

     func showInterstitialAd(for placement: AdPlacement, from viewController: UIViewController) -> Bool {
         guard let ad = interstitialAds[placement] else { return false }
         ad.present(fromRootViewController: viewController)
         interstitialAds.removeValue(forKey: placement)
         return true
     }

     // MARK: - Rewarded Ads

     private var rewardedAd: RewardedAd?

     func loadRewardedAd() async {
         guard !isPremiumUser else { return }

         do {
             let ad = try await RewardedAd.load(
                 withAdUnitID: rewardedAdUnitID,
                 request: Request()
             )
             rewardedAd = ad
             ad.fullScreenContentDelegate = self
         } catch {
             print("[AdManager] Failed to load rewarded ad: \(error)")
         }
     }

     func showRewardedAd(from viewController: UIViewController, onReward: @escaping () -> Void) -> Bool {
         guard let ad = rewardedAd else { return false }
         ad.present(fromRootViewController: viewController) {
             onReward()
         }
         rewardedAd = nil
         return true
     }
     */
}

// MARK: - Ad Placement Enum

/// Identifies different ad placements in the app
enum AdPlacement: String, CaseIterable, Hashable {
    case menu
    case game
    case stats
    case gameOver

    var displayName: String {
        switch self {
        case .menu: return "Main Menu"
        case .game: return "Game Screen"
        case .stats: return "Statistics"
        case .gameOver: return "Game Over"
        }
    }
}

// MARK: - BannerViewDelegate

extension AdManager: BannerViewDelegate {
    nonisolated func bannerViewDidReceiveAd(_ bannerView: BannerView) {
        Task { @MainActor in
            print("[AdManager] Banner ad loaded successfully")
        }
    }

    nonisolated func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
        Task { @MainActor in
            print("[AdManager] Banner ad failed to load: \(error.localizedDescription)")
        }
    }

    nonisolated func bannerViewDidRecordImpression(_ bannerView: BannerView) {
        Task { @MainActor in
            print("[AdManager] Banner ad impression recorded")
        }
    }

    nonisolated func bannerViewDidRecordClick(_ bannerView: BannerView) {
        Task { @MainActor in
            print("[AdManager] Banner ad clicked")
        }
    }

    nonisolated func bannerViewWillPresentScreen(_ bannerView: BannerView) {
        Task { @MainActor in
            print("[AdManager] Banner ad will present screen")
        }
    }

    nonisolated func bannerViewWillDismissScreen(_ bannerView: BannerView) {
        Task { @MainActor in
            print("[AdManager] Banner ad will dismiss screen")
        }
    }

    nonisolated func bannerViewDidDismissScreen(_ bannerView: BannerView) {
        Task { @MainActor in
            print("[AdManager] Banner ad did dismiss screen")
        }
    }
}

// MARK: - Full Screen Content Delegate (for future ad types)

/*
extension AdManager: FullScreenContentDelegate {
    nonisolated func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        Task { @MainActor in
            print("[AdManager] Ad failed to present: \(error.localizedDescription)")
        }
    }

    nonisolated func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        Task { @MainActor in
            print("[AdManager] Ad will present full screen")
        }
    }

    nonisolated func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        Task { @MainActor in
            print("[AdManager] Ad dismissed full screen")
        }
    }
}
*/
