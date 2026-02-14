//
//  AudioManager.swift
//  21Reflex
//
//  Audio playback management - Sound Effects only
//

import AVFoundation
import SwiftUI

@Observable
@MainActor
class AudioManager {
    enum SoundEffect: String, CaseIterable {
        case correct = "correct"
        case wrong = "wrong"
        case buffSelect = "buff_select"
        case gameOver = "game_over"
        case buttonClick = "button_click"
        case themeBuy = "theme_buy"
        case achievement = "achievement"
        case pause = "pause"
    }

    // MARK: - Settings
    var sfxVolume: Float = 0.8
    var hapticsEnabled: Bool = true
    var isMuted: Bool = false

    // MARK: - Players
    private var soundEffectPlayers: [SoundEffect: AVAudioPlayer] = [:]

    // MARK: - Initialization
    init() {
        setupAudioSession()
        generateSynthesizedSounds()
    }

    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("[AudioManager] Failed to set up audio session: \(error)")
        }
    }

    // MARK: - Volume Setters
    func setSFXVolume(_ volume: Float) {
        sfxVolume = volume
        GameState.shared.saveAudioSettings()
    }

    func setHapticsEnabled(_ enabled: Bool) {
        hapticsEnabled = enabled
        GameState.shared.hapticManager.isEnabled = enabled
        GameState.shared.saveAudioSettings()
    }

    func setMuted(_ muted: Bool) {
        isMuted = muted
        GameState.shared.saveAudioSettings()
    }

    // MARK: - Sound Effects
    func playSound(_ effect: SoundEffect) {
        guard !isMuted, sfxVolume > 0 else { return }

        if let player = soundEffectPlayers[effect] {
            player.volume = sfxVolume
            player.currentTime = 0
            player.play()
        }
    }

    func prepare() {
        generateSynthesizedSounds()
    }

    // MARK: - Synthesized Sounds
    private func generateSynthesizedSounds() {
        for effect in SoundEffect.allCases {
            if let soundData = generateSoundData(for: effect) {
                do {
                    let player = try AVAudioPlayer(data: soundData)
                    player.prepareToPlay()
                    soundEffectPlayers[effect] = player
                } catch {
                    print("[AudioManager] Failed to create player for \(effect): \(error)")
                }
            }
        }
    }

    private func generateSoundData(for effect: SoundEffect) -> Data? {
        let sampleRate: Double = 44100
        let duration: Double
        let frequency: Double
        let waveform: Waveform

        switch effect {
        case .correct:
            duration = 0.15
            frequency = 880
            waveform = .sine
        case .wrong:
            duration = 0.3
            frequency = 220
            waveform = .sawtooth
        case .buffSelect:
            duration = 0.2
            frequency = 660
            waveform = .sine
        case .gameOver:
            duration = 0.8
            frequency = 110
            waveform = .sawtooth
        case .buttonClick:
            duration = 0.05
            frequency = 440
            waveform = .square
        case .themeBuy:
            duration = 0.3
            frequency = 1047
            waveform = .sine
        case .achievement:
            duration = 0.4
            frequency = 523
            waveform = .sine
        case .pause:
            duration = 0.1
            frequency = 330
            waveform = .sine
        }

        return generateWaveform(
            waveform: waveform,
            frequency: frequency,
            duration: duration,
            sampleRate: sampleRate
        )
    }

    private enum Waveform {
        case sine, square, sawtooth
    }

    private func generateWaveform(waveform: Waveform, frequency: Double, duration: Double, sampleRate: Double) -> Data? {
        let totalSamples = Int(sampleRate * duration)
        var samples: [Float] = []

        for i in 0..<totalSamples {
            let t = Double(i) / sampleRate
            let phase = 2 * .pi * frequency * t
            var sample: Float = 0

            switch waveform {
            case .sine:
                sample = Float(sin(phase))
            case .square:
                sample = Float(sin(phase) > 0 ? 1 : -1)
            case .sawtooth:
                sample = Float(2 * (phase / (2 * .pi) - floor(phase / (2 * .pi) + 0.5)))
            }

            let envelope = min(t / 0.01, 1.0) * min((duration - t) / 0.1, 1.0)
            sample *= Float(envelope * 0.3)

            samples.append(sample)
        }

        return createAudioData(from: samples, sampleRate: sampleRate)
    }

    private func createAudioData(from samples: [Float], sampleRate: Double) -> Data? {
        let audioFormat = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: sampleRate,
            channels: 1,
            interleaved: false
        )

        guard let format = audioFormat else { return nil }

        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(samples.count))
        guard let audioBuffer = buffer else { return nil }

        audioBuffer.frameLength = AVAudioFrameCount(samples.count)

        if let data = audioBuffer.floatChannelData {
            for i in 0..<samples.count {
                data[0][i] = samples[i]
            }
        }

        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory() + UUID().uuidString + ".caf")
        defer { try? FileManager.default.removeItem(at: tempURL) }

        guard let audioFile = try? AVAudioFile(
            forWriting: tempURL,
            settings: format.settings,
            commonFormat: .pcmFormatFloat32,
            interleaved: false
        ) else { return nil }

        try? audioFile.write(from: audioBuffer)

        return try? Data(contentsOf: tempURL)
    }
}
