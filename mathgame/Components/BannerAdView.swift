//
//  BannerAdView.swift
//  mathgame
//
//  SwiftUI wrapper for AdMob banner ads
//

import GoogleMobileAds
import SwiftUI

/// SwiftUI view that wraps a BannerView
struct BannerAdView: UIViewRepresentable {
    let placement: AdPlacement

    /// Fixed banner height (adaptive banners adjust width, height is typically 50-90pt)
    static let bannerHeight: CGFloat = 60

    func makeUIView(context: Context) -> UIView {
        // Create container view
        let containerView = UIView()
        containerView.backgroundColor = .clear

        // Get the banner ad from AdManager
        let bannerView = AdManager.shared.getBannerAd(for: placement)

        // Add banner to container
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(bannerView)

        // Center the banner and constrain its size
        NSLayoutConstraint.activate([
            bannerView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            bannerView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            bannerView.topAnchor.constraint(greaterThanOrEqualTo: containerView.topAnchor),
            bannerView.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor),
            bannerView.leadingAnchor.constraint(greaterThanOrEqualTo: containerView.leadingAnchor),
            bannerView.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor)
        ])

        return containerView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // Refresh the banner ad when view updates (e.g., on orientation change)
        AdManager.shared.refreshBannerAd(for: placement)
    }

    /// Get the appropriate frame for the banner based on current screen size
    static func bannerFrame(in containerSize: CGSize) -> CGRect {
        // Standard banner height is 50pt, but can be up to 90pt on iPad
        let bannerHeight: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 90 : 50
        let bannerWidth = min(containerSize.width, 468) // Max banner width
        let x = (containerSize.width - bannerWidth) / 2
        let y = (containerSize.height - bannerHeight) / 2
        return CGRect(x: x, y: y, width: bannerWidth, height: bannerHeight)
    }
}

/// View modifier that adds a banner ad at the bottom of a view
struct BottomBannerAd: ViewModifier {
    let placement: AdPlacement

    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            content
            BannerAdView(placement: placement)
                .frame(height: BannerAdView.bannerHeight)
                .frame(maxWidth: .infinity)
                .background(Color.clear)
        }
    }
}

extension View {
    /// Adds a banner ad at the bottom of the view
    func bannerAd(placement: AdPlacement) -> some View {
        modifier(BottomBannerAd(placement: placement))
    }
}

/// Preview provider for BannerAdView
#Preview {
    BannerAdView(placement: .menu)
        .frame(height: 60)
        .background(Color.gray.opacity(0.2))
}
