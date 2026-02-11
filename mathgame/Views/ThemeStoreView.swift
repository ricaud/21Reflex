//
//  ThemeStoreView.swift
//  mathgame
//
//  Theme store for purchasing and equipping themes
//

import SwiftUI
import SwiftData

struct ThemeStoreView: View {
    @State private var gameState = GameState.shared
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext
    @Query private var persistentPlayers: [PersistentPlayer]

    @State private var showPurchaseConfirmation = false
    @State private var selectedTheme: Theme?
    @State private var showPurchaseSuccess = false
    @State private var purchasedTheme: Theme?

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

            VStack(spacing: 16) {
                // Header with coin balance
                headerSection

                // Theme grid
                themeGrid
            }
            .padding()
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
        .overlay {
            if showPurchaseSuccess, let theme = purchasedTheme {
                purchaseSuccessOverlay(theme: theme)
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

                Text("THEME STORE")
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

    // MARK: - Theme Grid

    private var themeGrid: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 16) {
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
            .padding(.horizontal)
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

        // Play sound
        gameState.audioManager.playSound(.correct)
    }

    private func purchaseTheme() {
        guard let theme = selectedTheme else { return }

        // Check if user has enough coins
        guard availableCoins >= theme.cost else {
            // Not enough coins - could show an alert here
            return
        }

        // Deduct coins
        persistentPlayer?.totalCoinsSpent += theme.cost

        // Unlock theme
        theme.isUnlocked = true

        // Show success animation
        purchasedTheme = theme
        withAnimation(.spring()) {
            showPurchaseSuccess = true
        }

        // Play sound
        gameState.audioManager.playSound(.correct)

        // Hide success after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showPurchaseSuccess = false
            }
        }
    }

    // MARK: - Purchase Success Overlay

    private func purchaseSuccessOverlay(theme: Theme) -> some View {
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
}

// MARK: - Theme Card

struct ThemeCard: View {
    let theme: Theme
    let isUnlocked: Bool
    let isEquipped: Bool
    let availableCoins: Int
    let colorScheme: ColorScheme

    var canAfford: Bool {
        availableCoins >= theme.cost
    }

    var body: some View {
        VStack(spacing: 12) {
            // Theme preview
            themePreview

            // Theme name
            Text(theme.name)
                .font(.headline.bold())
                .foregroundStyle(isUnlocked ? theme.effectiveTextColor(colorScheme) : .gray)

            // Status button
            statusButton
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isEquipped ? theme.effectiveAccentColor(colorScheme).opacity(0.3) : theme.effectiveButtonColor(colorScheme))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    isEquipped ? theme.effectiveAccentColor(colorScheme) : theme.effectiveBorderColor(colorScheme),
                    lineWidth: isEquipped ? 4 : 2
                )
        )
        .opacity(isUnlocked ? 1.0 : 0.7)
    }

    // MARK: - Theme Preview

    private var themePreview: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.effectiveBgColor(colorScheme))
                .frame(height: 80)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(theme.effectiveBorderColor(colorScheme), lineWidth: 2)
                )

            // Sample elements
            VStack(spacing: 6) {
                // Sample card
                HStack(spacing: -8) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(theme.effectiveButtonColor(colorScheme))
                        .frame(width: 30, height: 40)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(theme.effectiveBorderColor(colorScheme), lineWidth: 1)
                        )

                    RoundedRectangle(cornerRadius: 4)
                        .fill(theme.effectiveButtonColor(colorScheme))
                        .frame(width: 30, height: 40)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(theme.effectiveBorderColor(colorScheme), lineWidth: 1)
                        )
                }

                // Sample button
                Capsule()
                    .fill(theme.effectiveButtonColor(colorScheme))
                    .frame(width: 60, height: 20)
                    .overlay(
                        Capsule()
                            .stroke(theme.effectiveBorderColor(colorScheme), lineWidth: 1)
                    )
            }

            // Lock overlay
            if !isUnlocked {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.5))

                VStack(spacing: 4) {
                    Image(systemName: "lock.fill")
                        .font(.title2)
                        .foregroundStyle(.white)

                    HStack(spacing: 4) {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundStyle(canAfford ? .yellow : .red)

                        Text("\(theme.cost)")
                            .font(.subheadline.bold())
                            .foregroundStyle(canAfford ? .white : .red)
                    }
                }
            }
        }
    }

    // MARK: - Status Button

    @ViewBuilder
    private var statusButton: some View {
        if isEquipped {
            Text("EQUIPPED")
                .font(.caption.bold())
                .foregroundStyle(theme.effectiveAccentColor(colorScheme))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(theme.effectiveAccentColor(colorScheme).opacity(0.2))
                )
                .overlay(
                    Capsule()
                        .stroke(theme.effectiveAccentColor(colorScheme), lineWidth: 2)
                )
        } else if isUnlocked {
            Text("EQUIP")
                .font(.caption.bold())
                .foregroundStyle(theme.effectiveButtonTextColor(colorScheme))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(theme.effectiveCorrectColor(colorScheme))
                )
        } else {
            Text(canAfford ? "BUY" : "LOCKED")
                .font(.caption.bold())
                .foregroundStyle(canAfford ? .white : .gray)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(canAfford ? Color.orange : Color.gray.opacity(0.3))
                )
        }
    }
}

// MARK: - Preview

#Preview {
    ThemeStoreView()
        .modelContainer(for: PersistentPlayer.self, inMemory: true)
}
