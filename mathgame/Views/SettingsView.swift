//
//  SettingsView.swift
//  mathgame
//
//  Audio and game settings
//

import SwiftUI

struct SettingsView: View {
    @State private var gameState = GameState.shared
    @Environment(\.colorScheme) private var colorScheme
    @State private var musicVolume: Double
    @State private var sfxVolume: Double
    @State private var hapticsEnabled: Bool

    init() {
        let audioManager = GameState.shared.audioManager
        _musicVolume = State(initialValue: Double(audioManager.musicVolume))
        _sfxVolume = State(initialValue: Double(audioManager.sfxVolume))
        _hapticsEnabled = State(initialValue: audioManager.hapticsEnabled)
    }

    var body: some View {
        ZStack {
            // Background
            gameState.currentTheme.effectiveBgColor(colorScheme)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection

                    // iCloud Sync panel
                    syncPanel

                    // Settings panel
                    settingsPanel

                    // Test buttons
                    testSection
                }
                .padding()
            }
        }
    }

    private var headerSection: some View {
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

            Text("SETTINGS")
                .font(.system(size: 36, weight: .black, design: .rounded))
                .foregroundStyle(gameState.currentTheme.effectiveTextColor(colorScheme))
                .shadow(color: gameState.currentTheme.effectiveBorderColor(colorScheme), radius: 0, x: 3, y: 3)
        }
    }

    private var syncPanel: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "icloud")
                    .font(.title2)
                    .foregroundStyle(.blue)
                    .frame(width: 30)

                VStack(alignment: .leading, spacing: 2) {
                    Text("iCloud Sync")
                        .font(.headline)
                        .foregroundStyle(gameState.currentTheme.effectiveTextColor(colorScheme))

                    Text(syncStatusText)
                        .font(.caption)
                        .foregroundStyle(syncStatusColor)
                }

                Spacer()

                // Sync status icon
                Image(systemName: syncStatusIcon)
                    .foregroundStyle(syncStatusColor)
            }

            if let lastSync = CloudSyncManager.shared.lastSyncDate {
                Text("Last synced: \(timeAgoString(from: lastSync))")
                    .font(.caption)
                    .foregroundStyle(gameState.currentTheme.effectiveTextColor(colorScheme).opacity(0.6))
            }

            // Sync Now button
            Button(action: {
                Task {
                    await CloudSyncManager.shared.sync()
                }
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.clockwise")
                    Text("Sync Now")
                }
                .font(.subheadline.bold())
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue)
                )
            }
            .disabled(CloudSyncManager.shared.syncStatus == .syncing || !CloudSyncManager.shared.isICloudAvailable)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(gameState.currentTheme.effectiveButtonColor(colorScheme))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(gameState.currentTheme.effectiveBorderColor(colorScheme), lineWidth: 4)
        )
    }

    private var syncStatusText: String {
        switch CloudSyncManager.shared.syncStatus {
        case .unknown:
            return "Checking iCloud status..."
        case .syncing:
            return "Syncing..."
        case .synced:
            return "Up to date"
        case .error(let msg):
            return "Error: \(msg)"
        case .disabled:
            return "iCloud not available"
        }
    }

    private var syncStatusIcon: String {
        switch CloudSyncManager.shared.syncStatus {
        case .unknown:
            return "questionmark.circle"
        case .syncing:
            return "arrow.clockwise"
        case .synced:
            return "checkmark.circle.fill"
        case .error:
            return "exclamationmark.triangle.fill"
        case .disabled:
            return "xmark.circle.fill"
        }
    }

    private var syncStatusColor: Color {
        switch CloudSyncManager.shared.syncStatus {
        case .unknown:
            return .gray
        case .syncing:
            return .blue
        case .synced:
            return .green
        case .error:
            return .red
        case .disabled:
            return .gray
        }
    }

    private func timeAgoString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    private var settingsPanel: some View {
        VStack(spacing: 24) {
            // Music Volume
            volumeRow(
                icon: "music.note",
                iconColor: .blue,
                label: "Music Volume",
                volume: $musicVolume
            )
            .onChange(of: musicVolume) { _, newValue in
                gameState.audioManager.setMusicVolume(Float(newValue))
            }

            // SFX Volume
            volumeRow(
                icon: "speaker.wave.2.fill",
                iconColor: .orange,
                label: "Sound Effects",
                volume: $sfxVolume
            )
            .onChange(of: sfxVolume) { _, newValue in
                gameState.audioManager.setSFXVolume(Float(newValue))
            }

            Divider()
                .background(gameState.currentTheme.effectiveBorderColor(colorScheme))

            // Haptics toggle
            Toggle(isOn: $hapticsEnabled) {
                HStack(spacing: 12) {
                    Image(systemName: "iphone.radiowaves.left.and.right")
                        .font(.title2)
                        .foregroundStyle(.purple)
                        .frame(width: 30)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Haptic Feedback")
                            .font(.headline)
                            .foregroundStyle(gameState.currentTheme.effectiveTextColor(colorScheme))

                        Text("Vibrate on actions")
                            .font(.caption)
                            .foregroundStyle(gameState.currentTheme.effectiveTextColor(colorScheme).opacity(0.6))
                    }
                }
            }
            .tint(gameState.currentTheme.effectiveCorrectColor(colorScheme))
            .onChange(of: hapticsEnabled) { _, newValue in
                gameState.audioManager.setHapticsEnabled(newValue)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(gameState.currentTheme.effectiveButtonColor(colorScheme))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(gameState.currentTheme.effectiveBorderColor(colorScheme), lineWidth: 4)
        )
    }

    private func volumeRow(icon: String, iconColor: Color, label: String, volume: Binding<Double>) -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(iconColor)
                    .frame(width: 30)

                Text(label)
                    .font(.headline)
                    .foregroundStyle(gameState.currentTheme.effectiveTextColor(colorScheme))

                Spacer()

                Text("\(Int(volume.wrappedValue * 100))%")
                    .font(.caption.bold())
                    .foregroundStyle(gameState.currentTheme.effectiveTextColor(colorScheme).opacity(0.6))
                    .frame(width: 40)
            }

            Slider(value: volume, in: 0...1, step: 0.1)
                .tint(gameState.currentTheme.effectiveAccentColor(colorScheme))
        }
    }

    private var testSection: some View {
        VStack(spacing: 12) {
            Text("TEST SOUNDS")
                .font(.caption.bold())
                .foregroundStyle(gameState.currentTheme.effectiveTextColor(colorScheme).opacity(0.6))

            HStack(spacing: 12) {
                testButton(title: "Correct", color: gameState.currentTheme.effectiveCorrectColor(colorScheme)) {
                    gameState.audioManager.playSound(.correct)
                }

                testButton(title: "Wrong", color: gameState.currentTheme.effectiveWrongColor(colorScheme)) {
                    gameState.audioManager.playSound(.wrong)
                }
            }
        }
    }

    private func testButton(title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.caption.bold())
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(color)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

#Preview {
    SettingsView()
}
