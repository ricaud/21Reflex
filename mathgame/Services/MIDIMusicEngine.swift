//
//  MIDIMusicEngine.swift
//  mathgame
//
//  MIDI-based music playback using AVFoundation
//  Generates jazz-style MIDI sequences programmatically
//

import AVFoundation
import SwiftUI

/// MIDI Music Engine for playing synthesized jazz loops
/// Generates MIDI data programmatically and plays via AVMIDIPlayer
@MainActor
@Observable
class MIDIMusicEngine {
    static let shared = MIDIMusicEngine()

    // MARK: - MIDI Components
    private var midiPlayer: AVMIDIPlayer?
    private var currentTrack: AudioManager.MusicTrack?
    private var currentThemeID: String = "default"

    // MARK: - State
    private(set) var isPlaying = false
    private(set) var isInitialized = false

    // MARK: - Volume Control
    private var _volume: Float = 0.7
    var volume: Float {
        get { _volume }
        set {
            _volume = newValue
            updateVolume()
        }
    }

    private var _isMuted: Bool = false
    var isMuted: Bool {
        get { _isMuted }
        set {
            _isMuted = newValue
            updateVolume()
        }
    }

    // MARK: - Initialization
    private init() {
        // Defer initialization to when first needed
    }

    // MARK: - Volume Control
    private func updateVolume() {
        // AVMIDIPlayer doesn't have a volume property
        // Volume is controlled by stopping/starting playback
        // Future: Use AVAudioEngine with sampler for volume control

        // If unmuting and we have a track, start playing
        if !_isMuted && _volume > 0 && !isPlaying && currentTrack != nil {
            resumeMusic()
        }

        // If muting, pause but keep track loaded
        if _isMuted && isPlaying {
            midiPlayer?.stop()
            isPlaying = false
        }
    }

    func setVolume(_ newVolume: Float) {
        volume = max(0, min(1, newVolume))
    }

    func setMuted(_ muted: Bool) {
        isMuted = muted
    }

    // MARK: - Music Playback

    /// Play music for a specific track
    func playMusic(_ track: AudioManager.MusicTrack, themeID: String? = nil) {
        let targetThemeID = themeID ?? "default"

        // Check if we're already playing this track for this theme
        if currentTrack == track && currentThemeID == targetThemeID && isPlaying {
            return
        }

        // Stop current playback
        stopMusic()

        // Update state
        currentTrack = track
        currentThemeID = targetThemeID

        // Generate and play the MIDI sequence
        generateAndPlayMusic(for: track)
    }

    /// Generate MIDI data and start playback
    private func generateAndPlayMusic(for track: AudioManager.MusicTrack) {
        // Generate MIDI data
        guard let midiData = generateMIDIData(for: track) else {
            print("[MIDIMusicEngine] Failed to generate MIDI for track: \(track)")
            return
        }

        do {
            // Create MIDI player
            // Note: AVMIDIPlayer requires a sound bank. We'll use the default system sounds.
            // For better sound, you can bundle a .sf2 soundfont file.
            midiPlayer = try AVMIDIPlayer(data: midiData, soundBankURL: nil)

            // Enable looping
            midiPlayer?.prepareToPlay()

            // Start playback
            if !isMuted && volume > 0 {
                midiPlayer?.play { [weak self] in
                    guard let self = self else { return }
                    // Loop when finished
                    Task { @MainActor in
                        self.loopPlayback()
                    }
                }
                isPlaying = true
                print("[MIDIMusicEngine] Playing: \(track)")
            }
        } catch {
            print("[MIDIMusicEngine] Failed to create MIDI player: \(error)")
        }
    }

    /// Loop playback seamlessly
    private func loopPlayback() {
        guard let track = currentTrack, isPlaying, !isMuted else { return }

        // Regenerate and replay
        generateAndPlayMusic(for: track)
    }

    /// Stop music playback
    func stopMusic() {
        midiPlayer?.stop()
        isPlaying = false
        print("[MIDIMusicEngine] Stopped playback")
    }

    /// Pause music playback
    func pauseMusic() {
        midiPlayer?.stop()
        isPlaying = false
        print("[MIDIMusicEngine] Paused playback")
    }

    /// Resume music playback
    func resumeMusic() {
        guard let track = currentTrack, !isMuted && volume > 0 else { return }

        generateAndPlayMusic(for: track)
        print("[MIDIMusicEngine] Resumed playback")
    }

    // MARK: - MIDI Generation

    /// Generate MIDI data for a specific track
    private func generateMIDIData(for track: AudioManager.MusicTrack) -> Data? {
        let composer = SimpleMIDIComposer()

        switch track {
        case .menu:
            return composer.generateMenuMusic()
        case .playing:
            return composer.generatePlayingMusic()
        case .buffSelect:
            return composer.generateMenuMusic() // Use menu music for buff select
        case .gameOver:
            return composer.generateGameOverMusic()
        }
    }
}

// MARK: - Simple MIDI Composer

/// Simple MIDI composer that generates jazz-style music
/// Creates raw MIDI file data without external dependencies
private struct SimpleMIDIComposer {

    // MARK: - MIDI Constants
    private let headerChunk: [UInt8] = [
        0x4D, 0x54, 0x68, 0x64, // "MThd"
        0x00, 0x00, 0x00, 0x06, // Header length (6 bytes)
        0x00, 0x00,             // Format 0 (single track)
        0x00, 0x01,             // Number of tracks (1)
        0x00, 0x60              // Division (96 ticks per quarter note)
    ]

    private let trackHeader: [UInt8] = [
        0x4D, 0x54, 0x72, 0x6B  // "MTrk"
    ]

    // MARK: - Music Generation

    /// Generate relaxed jazz menu music (20-25 seconds at 100 BPM)
    func generateMenuMusic() -> Data {
        var events: [MIDIEvent] = []

        // Set tempo (100 BPM = 600,000 microseconds per quarter note)
        events.append(.tempo(microsecondsPerQuarter: 600000))

        // Program changes (instruments)
        events.append(.programChange(channel: 0, program: 4))  // Electric piano
        events.append(.programChange(channel: 1, program: 33)) // Electric bass

        let progression: [(chord: [UInt8], bass: UInt8, duration: UInt32)] = [
            // Dm7 | G7 | Cmaj7 | Cmaj7 (ii-V-I-I)
            ([50, 53, 57, 62], 38, 384),  // Dm7
            ([55, 59, 62, 65], 43, 384),  // G7
            ([48, 52, 55, 59], 36, 384),  // Cmaj7
            ([48, 52, 55, 59], 36, 384),  // Cmaj7
        ]

        var time: UInt32 = 0

        // Play progression 3 times for ~24 seconds
        for _ in 0..<3 {
            for (chord, bass, duration) in progression {
                // Add chord (channel 0)
                for note in chord {
                    events.append(.noteOn(time: time, channel: 0, note: note, velocity: 60))
                }
                // Add bass (channel 1)
                events.append(.noteOn(time: time, channel: 1, note: bass, velocity: 80))

                // Schedule note offs
                let endTime = time + duration
                for note in chord {
                    events.append(.noteOff(time: endTime, channel: 0, note: note, velocity: 0))
                }
                events.append(.noteOff(time: endTime, channel: 1, note: bass, velocity: 0))

                time = endTime
            }
        }

        // End of track
        events.append(.endOfTrack(time: time))

        return buildMIDIFile(events: events)
    }

    /// Generate upbeat gameplay music (20-25 seconds at 140 BPM)
    func generatePlayingMusic() -> Data {
        var events: [MIDIEvent] = []

        // Set tempo (140 BPM = ~428,571 microseconds per quarter note)
        events.append(.tempo(microsecondsPerQuarter: 428571))

        // Program changes
        events.append(.programChange(channel: 0, program: 26)) // Jazz guitar
        events.append(.programChange(channel: 1, program: 33)) // Electric bass
        events.append(.programChange(channel: 9, program: 0))  // Drums

        let progression: [(root: UInt8, quality: ChordQuality, duration: UInt32)] = [
            (53, .major7, 384),   // Fmaj7
            (50, .minor7, 384),   // Dm7
            (55, .dominant7, 384), // G7
            (48, .major7, 384),   // Cmaj7
        ]

        var time: UInt32 = 0

        // Play progression 3 times
        for _ in 0..<3 {
            for (root, quality, duration) in progression {
                let chord = buildChord(root: root, quality: quality)

                // Play chord on beats 1 and 3
                for note in chord {
                    events.append(.noteOn(time: time, channel: 0, note: note, velocity: 70))
                    events.append(.noteOff(time: time + 180, channel: 0, note: note, velocity: 0))

                    events.append(.noteOn(time: time + 192, channel: 0, note: note, velocity: 60))
                    events.append(.noteOff(time: time + 372, channel: 0, note: note, velocity: 0))
                }

                // Walking bass
                let bassPattern: [UInt8] = [root - 12, root - 10, root - 8, root - 7]
                let beatDuration = duration / 4
                for (index, bassNote) in bassPattern.enumerated() {
                    let noteTime = time + UInt32(index) * beatDuration
                    events.append(.noteOn(time: noteTime, channel: 1, note: bassNote, velocity: 90))
                    events.append(.noteOff(time: noteTime + beatDuration - 10, channel: 1, note: bassNote, velocity: 0))
                }

                // Brush drums (soft ride pattern on channel 9)
                for beat in 0..<4 {
                    let drumTime = time + UInt32(beat) * (duration / 4)
                    // Ride cymbal (note 51)
                    events.append(.noteOn(time: drumTime, channel: 9, note: 51, velocity: 50))
                    events.append(.noteOff(time: drumTime + 50, channel: 9, note: 51, velocity: 0))
                }

                time += duration
            }
        }

        events.append(.endOfTrack(time: time))
        return buildMIDIFile(events: events)
    }

    /// Generate mellow game over music (20-25 seconds at 80 BPM)
    func generateGameOverMusic() -> Data {
        var events: [MIDIEvent] = []

        // Set tempo (80 BPM = 750,000 microseconds per quarter note)
        events.append(.tempo(microsecondsPerQuarter: 750000))

        // Program changes
        events.append(.programChange(channel: 0, program: 1))  // Acoustic grand piano
        events.append(.programChange(channel: 1, program: 32)) // Acoustic bass

        let progression: [(root: UInt8, quality: ChordQuality, duration: UInt32)] = [
            (63, .minor7, 768),   // Dm7
            (60, .major7, 768),   // Cmaj7
            (62, .minor7, 768),   // Dm7
            (58, .major7, 768),   // Bbmaj7
        ]

        var time: UInt32 = 0

        // Play progression 2 times for slower feel
        for _ in 0..<2 {
            for (root, quality, duration) in progression {
                let chord = buildChord(root: root, quality: quality)

                // Long sustained chords
                for note in chord {
                    events.append(.noteOn(time: time, channel: 0, note: note, velocity: 50))
                    events.append(.noteOff(time: time + duration - 20, channel: 0, note: note, velocity: 0))
                }

                // Simple bass
                let bassNote = root - 12
                events.append(.noteOn(time: time, channel: 1, note: bassNote, velocity: 70))
                events.append(.noteOff(time: time + duration - 20, channel: 1, note: bassNote, velocity: 0))

                time += duration
            }
        }

        events.append(.endOfTrack(time: time))
        return buildMIDIFile(events: events)
    }

    // MARK: - Helper Types

    private enum ChordQuality {
        case major7, minor7, dominant7, minor
    }

    private enum MIDIEvent {
        case tempo(microsecondsPerQuarter: UInt32)
        case programChange(channel: UInt8, program: UInt8)
        case noteOn(time: UInt32, channel: UInt8, note: UInt8, velocity: UInt8)
        case noteOff(time: UInt32, channel: UInt8, note: UInt8, velocity: UInt8)
        case endOfTrack(time: UInt32)
    }

    // MARK: - Helper Functions

    private func buildChord(root: UInt8, quality: ChordQuality) -> [UInt8] {
        switch quality {
        case .major7:
            return [root, root + 4, root + 7, root + 11]
        case .minor7:
            return [root, root + 3, root + 7, root + 10]
        case .dominant7:
            return [root, root + 4, root + 7, root + 10]
        case .minor:
            return [root, root + 3, root + 7]
        }
    }

    private func buildMIDIFile(events: [MIDIEvent]) -> Data {
        var trackData = Data()

        // Sort events by time
        let sortedEvents = events.sorted { e1, e2 in
            let t1 = getTime(from: e1)
            let t2 = getTime(from: e2)
            return t1 < t2
        }

        var lastTime: UInt32 = 0

        for event in sortedEvents {
            let eventTime = getTime(from: event)
            let deltaTime = eventTime - lastTime

            // Write variable-length delta time
            trackData.append(variableLengthQuantity(deltaTime))

            // Write event data
            trackData.append(eventData(for: event))

            lastTime = eventTime
        }

        // Build complete file
        var fileData = Data(headerChunk)

        // Track chunk
        fileData.append(contentsOf: trackHeader)
        fileData.append(contentsOf: UInt32(trackData.count).bigEndianBytes)
        fileData.append(trackData)

        return fileData
    }

    private func getTime(from event: MIDIEvent) -> UInt32 {
        switch event {
        case .tempo:
            return 0
        case .programChange:
            return 0
        case .noteOn(let time, _, _, _):
            return time
        case .noteOff(let time, _, _, _):
            return time
        case .endOfTrack(let time):
            return time
        }
    }

    private func eventData(for event: MIDIEvent) -> Data {
        var data = Data()

        switch event {
        case .tempo(let microsecondsPerQuarter):
            // Meta event: Set Tempo (FF 51 03 tttttt)
            data.append(contentsOf: [0xFF, 0x51, 0x03])
            data.append(contentsOf: microsecondsPerQuarter.bigEndianBytes[1...3])

        case .programChange(let channel, let program):
            // Program Change (C0-CF pp)
            data.append(0xC0 | (channel & 0x0F))
            data.append(program)

        case .noteOn(_, let channel, let note, let velocity):
            // Note On (90-9F nn vv)
            data.append(0x90 | (channel & 0x0F))
            data.append(note)
            data.append(velocity)

        case .noteOff(_, let channel, let note, let velocity):
            // Note Off (80-8F nn vv)
            data.append(0x80 | (channel & 0x0F))
            data.append(note)
            data.append(velocity)

        case .endOfTrack:
            // Meta event: End of Track (FF 2F 00)
            data.append(contentsOf: [0xFF, 0x2F, 0x00])
        }

        return data
    }

    /// Encode a UInt32 as a variable-length quantity (MIDI standard)
    private func variableLengthQuantity(_ value: UInt32) -> Data {
        var result = Data()
        var v = value

        // Build bytes from least significant to most
        var bytes: [UInt8] = [UInt8(v & 0x7F)]
        v >>= 7

        while v > 0 {
            bytes.append(UInt8(v & 0x7F) | 0x80)
            v >>= 7
        }

        // Reverse and add to result
        for byte in bytes.reversed() {
            result.append(byte)
        }

        return result
    }
}

// MARK: - UInt32 Extensions

private extension UInt32 {
    var bigEndianBytes: [UInt8] {
        return [
            UInt8((self >> 24) & 0xFF),
            UInt8((self >> 16) & 0xFF),
            UInt8((self >> 8) & 0xFF),
            UInt8(self & 0xFF)
        ]
    }
}
