//
//  SettingsView.swift
//  mathgame
//
//  Audio and game settings
//

import SwiftUI

struct SettingsView: View {
    @State private var gameState = GameState.shared
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
            gameState.currentTheme.bgColor
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // Header
                headerSection

                // Settings panel
                settingsPanel

                Spacer()

                // Test buttons
                testSection
            }
            .padding()
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

            Text("SETTINGS")
                .font(.system(size: 36, weight: .black, design: .rounded))
                .foregroundStyle(gameState.currentTheme.textColor)
                .shadow(color: gameState.currentTheme.borderColor, radius: 0, x: 3, y: 3)
        }
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
                .background(gameState.currentTheme.borderColor)

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
                            .foregroundStyle(gameState.currentTheme.textColor)

                        Text("Vibrate on actions")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .tint(gameState.currentTheme.correctColor)
            .onChange(of: hapticsEnabled) { _, newValue in
                gameState.audioManager.setHapticsEnabled(newValue)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(gameState.currentTheme.buttonColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(gameState.currentTheme.borderColor, lineWidth: 4)
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
                    .foregroundStyle(gameState.currentTheme.textColor)

                Spacer()

                Text("\(Int(volume.wrappedValue * 100))%")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                    .frame(width: 40)
            }

            Slider(value: volume, in: 0...1, step: 0.1)
                .tint(gameState.currentTheme.accentColor)
        }
    }

    private var testSection: some View {
        VStack(spacing: 12) {
            Text("TEST SOUNDS")
                .font(.caption.bold())
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                testButton(title: "Correct", color: gameState.currentTheme.correctColor) {
                    gameState.audioManager.playSound(.correct)
                }

                testButton(title: "Wrong", color: gameState.currentTheme.wrongColor) {
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
