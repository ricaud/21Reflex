//
//  StoreView.swift
//  21Reflex
//
//  Store with IAP items and themes
//

import StoreKit
import SwiftData
import SwiftUI

/// Main store view with IAP items and themes
struct StoreView: View {
    @State private var gameState = GameState.shared
    @State private var iapManager = IAPManager.shared
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext
    @Query private var persistentPlayers: [PersistentPlayer]

    @State private var showPurchaseConfirmation = false
    @State private var selectedTheme: Theme?
    @State private var showThemePurchaseSuccess = false
    @State private var purchasedTheme: Theme?
    @State private var showPurchaseSuccess = false
    @State private var showRestoreSuccess = false

    private var persistentPlayer: PersistentPlayer? {
        persistentPlayers.first
    }

    private var availableCoins: Int {
        persistentPlayer?.availableCoins ?? 0
    }

    var body: some View {
        ZStack {
            // Background
            gameState.currentTheme.effectiveBgColor(colorScheme)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Header with coin balance
                    headerSection

                    // IAP Section - Remove Ads
                    removeAdsSection

                    // Divider between sections
                    sectionDivider(title: "THEMES")

                    // Theme grid
                    themeGridSection
                }
                .padding()
            }
        }
        .task {
            // Load products when view appears
            await iapManager.loadProducts()
        }
        .alert("Purchase Theme?", isPresented: $showPurchaseConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Buy") {
                purchaseTheme()
            }
        } message: {
            if let theme = selectedTheme {
                Text("Purchase \(theme.name) theme for \(theme.cost) coins?")
            }
        }
        .alert("Error", isPresented: $iapManager.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(iapManager.errorMessage ?? "An error occurred")
        }
        .overlay {
            if showThemePurchaseSuccess, let theme = purchasedTheme {
                themePurchaseSuccessOverlay(theme: theme)
            }
            if showPurchaseSuccess {
                purchaseSuccessOverlay
            }
            if showRestoreSuccess {
                restoreSuccessOverlay
            }
            if iapManager.isLoading {
                loadingOverlay
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 12) {
            // Title
            VStack(spacing: 8) {
                // Decorative line
                Rectangle()
                    .fill(gameState.currentTheme.effectiveAccentColor(colorScheme))
                    .frame(height: 8)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(gameState.currentTheme.effectiveBorderColor(colorScheme), lineWidth: 3)
                    )

                Text("STORE")
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundStyle(gameState.currentTheme.effectiveTextColor(colorScheme))
                    .shadow(color: gameState.currentTheme.effectiveBorderColor(colorScheme), radius: 0, x: 3, y: 3)
            }

            // Coin balance
            HStack(spacing: 8) {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.yellow)

                Text("\(availableCoins)")
                    .font(.title2.bold())
                    .foregroundStyle(gameState.currentTheme.effectiveTextColor(colorScheme))

                Text("coins")
                    .font(.subheadline)
                    .foregroundStyle(gameState.currentTheme.effectiveTextColor(colorScheme).opacity(0.7))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(gameState.currentTheme.effectiveButtonColor(colorScheme))
            )
            .overlay(
                Capsule()
                    .stroke(gameState.currentTheme.effectiveBorderColor(colorScheme), lineWidth: 3)
            )
        }
    }

    // MARK: - Remove Ads Section

    @ViewBuilder
    private var removeAdsSection: some View {
        if !iapManager.hasRemovedAds {
            VStack(spacing: 16) {
                // Header with crown icon
                HStack(spacing: 12) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(.yellow)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("GO PREMIUM")
                            .font(.headline.bold())
                            .foregroundStyle(gameState.currentTheme.effectiveTextColor(colorScheme))

                        Text("Remove all banner ads permanently")
                            .font(.caption)
                            .foregroundStyle(gameState.currentTheme.effectiveTextColor(colorScheme).opacity(0.7))
                    }

                    Spacer()
                }

                // Benefits
                VStack(alignment: .leading, spacing: 8) {
                    benefitRow(icon: "checkmark.circle.fill", text: "No more banner ads")
                    benefitRow(icon: "checkmark.circle.fill", text: "Syncs across all your devices")
                    benefitRow(icon: "checkmark.circle", text: "App Icons & Card Themes (Coming soon!)")
                }

                // Purchase button
                if let product = iapManager.products.first(where: { $0.id == IAPProduct.removeAds.rawValue }) {
                    purchaseButton(product: product)
                } else {
                    // Fallback button while loading
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "cart.fill")
                            Text("Loading...")
                                .font(.headline.bold())
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.gray)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(true)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(gameState.currentTheme.effectiveButtonColor(colorScheme))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
            )
        } else {
            // Already purchased - show thank you
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(.green)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("PREMIUM ACTIVE")
                            .font(.headline.bold())
                            .foregroundStyle(.green)

                        Text("Thank you for your support!")
                            .font(.caption)
                            .foregroundStyle(gameState.currentTheme.effectiveTextColor(colorScheme).opacity(0.7))
                    }

                    Spacer()
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(gameState.currentTheme.effectiveButtonColor(colorScheme))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.green, lineWidth: 3)
            )
        }
    }

    private func benefitRow(icon: String, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(.green)
                .font(.caption)

            Text(text)
                .font(.caption)
                .foregroundStyle(gameState.currentTheme.effectiveTextColor(colorScheme).opacity(0.8))

            Spacer()
        }
    }

    private func purchaseButton(product: Product) -> some View {
        Button(action: {
            Task {
                let success = await iapManager.purchase(product)
                if success {
                    // Save premium status to PersistentPlayer for CloudKit sync
                    if let player = persistentPlayers.first {
                        player.isPremiumUser = true
                        player.markModified()
                        try? modelContext.save()
                    }

                    withAnimation(.spring()) {
                        showPurchaseSuccess = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            showPurchaseSuccess = false
                        }
                    }
                }
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: "cart.fill")
                Text(product.displayPrice)
                    .font(.headline.bold())
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                LinearGradient(
                    colors: [.orange, .red],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .orange.opacity(0.3), radius: 4, x: 0, y: 2)
        }
    }

    // MARK: - Section Divider

    private func sectionDivider(title: String) -> some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(gameState.currentTheme.effectiveBorderColor(colorScheme).opacity(0.3))
                .frame(height: 2)

            Text(title)
                .font(.caption.bold())
                .foregroundStyle(gameState.currentTheme.effectiveTextColor(colorScheme).opacity(0.6))

            Rectangle()
                .fill(gameState.currentTheme.effectiveBorderColor(colorScheme).opacity(0.3))
                .frame(height: 2)
        }
    }

    // MARK: - Theme Grid Section

    private var themeGridSection: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 16) {
            ForEach(gameState.availableThemes, id: \.id) { theme in
                ThemeCard(
                    theme: theme,
                    isUnlocked: theme.isUnlocked,
                    isEquipped: theme.isEquipped,
                    availableCoins: availableCoins,
                    colorScheme: colorScheme
                )
                .onTapGesture {
                    handleThemeTap(theme)
                }
            }
        }
    }

    // MARK: - Actions

    private func handleThemeTap(_ theme: Theme) {
        if theme.isUnlocked {
            equipTheme(theme)
        } else {
            selectedTheme = theme
            showPurchaseConfirmation = true
        }
    }

    private func equipTheme(_ theme: Theme) {
        // Unequip current theme
        if let current = gameState.availableThemes.first(where: { $0.isEquipped }) {
            current.isEquipped = false
        }

        // Equip new theme
        theme.isEquipped = true
        gameState.currentTheme = theme

        // Save theme states for CloudKit sync
        gameState.saveThemeStates(context: modelContext)

        // Play sound
        gameState.audioManager.playSound(.correct)
    }

    private func purchaseTheme() {
        guard let theme = selectedTheme else {
            print("[StoreView] No theme selected for purchase")
            return
        }

        // Check if user has enough coins
        guard availableCoins >= theme.cost else {
            print("[StoreView] Not enough coins. Have: \(availableCoins), Need: \(theme.cost)")
            return
        }

        guard let player = persistentPlayers.first else {
            print("[StoreView] No persistent player found")
            return
        }

        // Capture pre-purchase state for rollback
        let previousSpent = player.totalCoinsSpent
        let wasUnlocked = theme.isUnlocked

        // Apply changes
        player.totalCoinsSpent += theme.cost
        player.markModified()  // Update sync timestamp
        theme.isUnlocked = true

        print("[StoreView] Deducted \(theme.cost) coins. Remaining: \(player.availableCoins)")

        // Save theme states for sync tracking
        gameState.saveThemeStates(context: modelContext)

        // Attempt to save changes
        do {
            try modelContext.save()
            print("[StoreView] Purchase saved successfully")

            // Show success animation
            purchasedTheme = theme
            withAnimation(.spring()) {
                showThemePurchaseSuccess = true
            }

            // Play sound
            gameState.audioManager.playSound(.correct)

            // Hide success after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation {
                    showThemePurchaseSuccess = false
                }
            }
        } catch {
            // Rollback on failure
            player.totalCoinsSpent = previousSpent
            theme.isUnlocked = wasUnlocked
            print("[StoreView] Failed to save purchase: \(error)")
        }
    }

    // MARK: - Overlays

    private func themePurchaseSuccessOverlay(theme: Theme) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.green)

            Text("Unlocked!")
                .font(.title.bold())
                .foregroundStyle(.white)

            Text(theme.name)
                .font(.headline)
                .foregroundStyle(.white.opacity(0.9))
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.8))
        )
        .transition(.scale.combined(with: .opacity))
    }

    private var purchaseSuccessOverlay: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 60))
                .foregroundStyle(.green)

            Text("Purchase Complete!")
                .font(.title.bold())
                .foregroundStyle(.white)

            Text("Ads have been removed. Thank you!")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.9))
                .multilineTextAlignment(.center)
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.8))
        )
        .transition(.scale.combined(with: .opacity))
    }

    private var restoreSuccessOverlay: some View {
        VStack(spacing: 16) {
            Image(systemName: "arrow.counterclockwise.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.blue)

            Text("Purchases Restored")
                .font(.title.bold())
                .foregroundStyle(.white)
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.8))
        )
        .transition(.scale.combined(with: .opacity))
    }

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)

                Text("Processing...")
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.8))
            )
        }
        .transition(.opacity)
    }
}

// MARK: - Preview

#Preview {
    StoreView()
        .modelContainer(for: PersistentPlayer.self, inMemory: true)
}
