//
//  AudioManager.swift
//  mathgame
//
//  Audio playback management
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

    enum MusicTrack: String {
        case menu = "menu"
        case playing = "playing"
        case buffSelect = "buff_select"
        case gameOver = "game_over"
    }

    // MARK: - Settings
    var musicVolume: Float = 0.7 {
        didSet {
            backgroundPlayer?.volume = musicVolume
        }
    }

    var sfxVolume: Float = 0.8
    var hapticsEnabled: Bool = true
    var isMuted: Bool = false {
        didSet {
            backgroundPlayer?.volume = isMuted ? 0 : musicVolume
        }
    }

    // MARK: - Players
    private var backgroundPlayer: AVAudioPlayer?
    private var soundEffectPlayers: [SoundEffect: AVAudioPlayer] = [:]
    private var currentTrack: MusicTrack?

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
            print("Failed to set up audio session: \(error)")
        }
    }

    // MARK: - Volume Setters
    func setMusicVolume(_ volume: Float) {
        musicVolume = volume
    }

    func setSFXVolume(_ volume: Float) {
        sfxVolume = volume
    }

    func setHapticsEnabled(_ enabled: Bool) {
        hapticsEnabled = enabled
    }

    // MARK: - Sound Effects
    func playSound(_ effect: SoundEffect) {
        guard !isMuted, sfxVolume > 0 else { return }

        // Try to play synthesized sound
        if let player = soundEffectPlayers[effect] {
            player.volume = sfxVolume
            player.currentTime = 0
            player.play()
        }
    }

    // MARK: - Background Music
    func playMusic(_ track: MusicTrack) {
        guard currentTrack != track else { return }
        currentTrack = track

        guard !isMuted, musicVolume > 0 else {
            backgroundPlayer?.stop()
            return
        }

        // Generate or load track
        let player = generateMusicTrack(track)
        player?.volume = musicVolume
        player?.numberOfLoops = -1 // Loop forever
        player?.play()

        backgroundPlayer?.stop()
        backgroundPlayer = player
    }

    func pauseMusic() {
        backgroundPlayer?.pause()
    }

    func resumeMusic() {
        guard !isMuted, musicVolume > 0 else { return }
        backgroundPlayer?.play()
    }

    func prepare() {
        // Pre-load audio resources
        generateSynthesizedSounds()
    }

    func stopMusic() {
        backgroundPlayer?.stop()
        currentTrack = nil
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
                    print("Failed to create player for \(effect): \(error)")
                }
            }
        }
    }

    private func generateSoundData(for effect: SoundEffect) -> Data? {
        // Generate simple waveforms for each sound effect
        let sampleRate: Double = 44100
        let duration: Double
        let frequency: Double
        let waveform: Waveform

        switch effect {
        case .correct:
            duration = 0.15
            frequency = 880 // A5
            waveform = .sine
        case .wrong:
            duration = 0.3
            frequency = 220 // A3
            waveform = .sawtooth
        case .buffSelect:
            duration = 0.2
            frequency = 660 // E5
            waveform = .sine
        case .gameOver:
            duration = 0.8
            frequency = 110 // A2
            waveform = .sawtooth
        case .buttonClick:
            duration = 0.05
            frequency = 440 // A4
            waveform = .square
        case .themeBuy:
            duration = 0.3
            frequency = 1047 // C6
            waveform = .sine
        case .achievement:
            duration = 0.4
            frequency = 523 // C5
            waveform = .sine
        case .pause:
            duration = 0.1
            frequency = 330 // E4
            waveform = .sine
        }

        return generateWaveform(
            waveform: waveform,
            frequency: frequency,
            duration: duration,
            sampleRate: sampleRate
        )
    }

    private func generateMusicTrack(_ track: MusicTrack) -> AVAudioPlayer? {
        // Generate simple background music loops
        let sampleRate: Double = 44100
        let duration = 4.0 // 4 second loops

        var samples: [Float] = []
        let totalSamples = Int(sampleRate * duration)

        for i in 0..<totalSamples {
            let t = Double(i) / sampleRate
            var sample: Float = 0

            switch track {
            case .menu:
                // Simple pleasant chord progression
                sample = Float(sin(2 * .pi * 262 * t) * 0.1 + // C4
                              sin(2 * .pi * 330 * t) * 0.1 + // E4
                              sin(2 * .pi * 392 * t) * 0.1)  // G4
            case .playing:
                // More energetic, faster tempo feel
                let beat = sin(2 * .pi * 4 * t) // 4Hz beat
                sample = Float(sin(2 * .pi * 440 * t) * 0.1 * (beat > 0 ? 1 : 0.5))
            case .buffSelect:
                // Magical ascending feel
                let freq = 440 + (t / duration) * 220
                sample = Float(sin(2 * .pi * freq * t) * 0.15)
            case .gameOver:
                // Sad descending
                let freq = 330 - (t / duration) * 110
                sample = Float(sin(2 * .pi * freq * t) * 0.15)
            }

            // Apply envelope
            let envelope = min(t / 0.1, 1.0) * min((duration - t) / 0.5, 1.0)
            sample *= Float(envelope)

            samples.append(sample)
        }

        return createAudioPlayer(from: samples, sampleRate: sampleRate)
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

            // Apply envelope
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

        // Write to temp file and read as Data
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

    private func createAudioPlayer(from samples: [Float], sampleRate: Double) -> AVAudioPlayer? {
        guard let data = createAudioData(from: samples, sampleRate: sampleRate) else { return nil }
        return try? AVAudioPlayer(data: data)
    }
}
