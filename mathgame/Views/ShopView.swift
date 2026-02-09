//
//  ShopView.swift
//  mathgame
//
//  Theme shop with purchase and equip functionality
//

import SwiftUI

struct ShopView: View {
    @State private var gameState = GameState.shared
    @State private var showPurchaseConfirmation = false
    @State private var selectedTheme: Theme?

    enum ThemeStatus {
        case equipped, owned, locked
    }

    var body: some View {
        ZStack {
            // Background
            gameState.currentTheme.bgColor
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // Header
                headerSection

                // Total coins display
                totalCoinsDisplay

                // Theme list
                themeList

                Spacer()
            }
            .padding()
        }
        .alert("Purchase Theme?", isPresented: $showPurchaseConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Buy", role: .none) {
                if let theme = selectedTheme {
                    purchaseTheme(theme)
                }
            }
        } message: {
            if let theme = selectedTheme {
                Text("Purchase \(theme.name) for \(theme.cost) coins?")
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            // Decorative line
            Rectangle()
                .fill(gameState.currentTheme.accentColor)
                .frame(height: 8)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(gameState.currentTheme.borderColor, lineWidth: 3)
                )

            Text("THEME SHOP")
                .font(.system(size: 36, weight: .black, design: .rounded))
                .foregroundStyle(gameState.currentTheme.textColor)
                .shadow(color: gameState.currentTheme.borderColor, radius: 0, x: 3, y: 3)
        }
    }

    private var totalCoinsDisplay: some View {
        HStack(spacing: 8) {
            Diamond()
                .fill(Color(red: 0.9, green: 0.75, blue: 0.2))
                .frame(width: 24, height: 24)

            Text("\(gameState.player.totalCoins)")
                .font(.title.bold())
                .foregroundStyle(Color(red: 0.9, green: 0.75, blue: 0.2))
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(gameState.currentTheme.buttonColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(gameState.currentTheme.borderColor, lineWidth: 3)
        )
    }

    private var themeList: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(gameState.availableThemes) { theme in
                    themeCard(for: theme)
                }
            }
            .padding(.horizontal)
        }
    }

    private func themeCard(for theme: Theme) -> some View {
        let status = themeStatus(for: theme)

        return Button(action: {
            handleThemeTap(theme, status: status)
        }) {
            HStack(spacing: 16) {
                // Color preview
                colorPreview(for: theme)

                // Theme info
                VStack(alignment: .leading, spacing: 4) {
                    Text(theme.name)
                        .font(.headline.bold())
                        .foregroundStyle(.primary)

                    Text(themeDescription(for: theme))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Status indicator
                statusView(for: status, cost: theme.cost)
            }
            .padding()
            .background(backgroundColor(for: status))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor(for: status), lineWidth: status == .equipped ? 4 : 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func colorPreview(for theme: Theme) -> some View {
        VStack(spacing: 4) {
            Circle()
                .fill(theme.bgColor)
                .frame(width: 30, height: 30)
                .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))

            HStack(spacing: 4) {
                Circle()
                    .fill(theme.accentColor)
                    .frame(width: 12, height: 12)
                Circle()
                    .fill(theme.buttonColor)
                    .frame(width: 12, height: 12)
            }
        }
        .frame(width: 50)
    }

    @ViewBuilder
    private func statusView(for status: ThemeStatus, cost: Int) -> some View {
        switch status {
        case .equipped:
            Text("EQUIPPED")
                .font(.caption.bold())
                .foregroundStyle(.green)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color.green.opacity(0.2))
                )

        case .owned:
            Text("OWNED")
                .font(.caption)
                .foregroundStyle(.gray)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                )

        case .locked:
            HStack(spacing: 4) {
                Image(systemName: "diamond.fill")
                    .foregroundStyle(Color(red: 0.9, green: 0.75, blue: 0.2))
                Text("\(cost)")
                    .font(.caption.bold())
                    .foregroundStyle(.primary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(Color.gray.opacity(0.2))
            )
        }
    }

    private func backgroundColor(for status: ThemeStatus) -> Color {
        switch status {
        case .equipped:
            return Color.green.opacity(0.1)
        case .owned:
            return Color.gray.opacity(0.1)
        case .locked:
            return Color.gray.opacity(0.05)
        }
    }

    private func borderColor(for status: ThemeStatus) -> Color {
        switch status {
        case .equipped:
            return .green
        case .owned:
            return .gray
        case .locked:
            return .gray.opacity(0.5)
        }
    }

    private func themeStatus(for theme: Theme) -> ThemeStatus {
        if theme.isEquipped {
            return .equipped
        } else if theme.isUnlocked {
            return .owned
        } else {
            return .locked
        }
    }

    private func themeDescription(for theme: Theme) -> String {
        switch theme.id {
        case "classic":
            return "Clean white and blue design"
        case "candy":
            return "Sweet pink and purple colors"
        case "ocean":
            return "Calm blue and teal colors"
        case "retro":
            return "Classic green terminal style"
        case "neon":
            return "Electric purple and cyan glow"
        default:
            return "Custom theme"
        }
    }

    private func handleThemeTap(_ theme: Theme, status: ThemeStatus) {
        switch status {
        case .equipped:
            // Already equipped, do nothing
            break
        case .owned:
            // Equip the theme
            gameState.equipTheme(theme)
            gameState.audioManager.playSound(.buttonClick)
        case .locked:
            // Show purchase confirmation
            selectedTheme = theme
            showPurchaseConfirmation = true
        }
    }

    private func purchaseTheme(_ theme: Theme) {
        if gameState.purchaseTheme(theme) {
            gameState.audioManager.playSound(.themeBuy)
        }
    }
}

// Diamond shape for coin icon
struct Diamond: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let midX = rect.midX
        let midY = rect.midY
        let width = rect.width / 2
        let height = rect.height / 2

        path.move(to: CGPoint(x: midX, y: midY - height))
        path.addLine(to: CGPoint(x: midX + width, y: midY))
        path.addLine(to: CGPoint(x: midX, y: midY + height))
        path.addLine(to: CGPoint(x: midX - width, y: midY))
        path.closeSubpath()

        return path
    }
}

#Preview {
    ShopView()
}
