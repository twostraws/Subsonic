//
// SubsonicPlayer.swift
// Part of Subsonic, a simple library for playing sounds in SwiftUI
//
// This file contains the SubsonicPlayer class, which handles
// loading and playing a single sound that publishes whether it
// is currently playing or not.
//
// Copyright (c) 2021 Paul Hudson.
// See LICENSE for license information.
//

import AVFoundation

/// Responsible for loading and playing a single sound attached to a SwiftUI view.
public class SubsonicPlayer: NSObject, ObservableObject, AVAudioPlayerDelegate {
    /// A Boolean representing whether this sound is currently playing.
    @Published public var isPlaying = false

    /// The internal audio player being managed by this object.
    private var audioPlayer: AVAudioPlayer?

    /// How loud to play this sound relative to other sounds in your app,
    /// specified in the range 0 (no volume) to 1 (maximum volume).
    public var volume: Double {
        didSet {
            audioPlayer?.volume = Float(volume)
        }
    }

    /// How many times to repeat this sound. Specifying 0 here
    /// (the default) will play the sound only once.
    public var repeatCount: SubsonicController.RepeatCount {
        didSet {
            audioPlayer?.numberOfLoops = repeatCount.value
        }
    }

    /// Whether playback should restart from the beginning each time, or
    /// continue from the last playback point.
    public var playMode: SubsonicController.PlayMode


    /// Creates a new instance by looking for a particular sound filename in a bundle of your choosing.of `.reset`.
    /// - Parameters:
    ///   - sound: The name of the sound file you want to load.
    ///   - bundle: The bundle containing the sound file. Defaults to the main bundle.
    ///   - volume: How loud to play this sound relative to other sounds in your app,
    ///     specified in the range 0 (no volume) to 1 (maximum volume).
    ///   - repeatCount: How many times to repeat this sound. Specifying 0 here
    ///     (the default) will play the sound only once.
    ///   - playMode: Whether playback should restart from the beginning each time, or
    ///     continue from the last playback point.
    public init(sound: String, bundle: Bundle = .main, volume: Double = 1.0, repeatCount: SubsonicController.RepeatCount = 0, playMode: SubsonicController.PlayMode = .reset) {
        audioPlayer = SubsonicController.shared.prepare(sound: sound, from: bundle)

        self.volume = volume
        self.repeatCount = repeatCount
        self.playMode = playMode

        super.init()

        audioPlayer?.delegate = self
    }

    /// Plays the current sound. If `playMode` is set to `.reset` this will play from the beginning,
    /// otherwise it will play from where the sound last left off.
    public func play() {
        isPlaying = true

        if playMode == .reset {
            audioPlayer?.currentTime = 0
        }

        audioPlayer?.play()
    }

    /// Stops the audio from playing.
    public func stop() {
        isPlaying = false
        audioPlayer?.stop()
    }

    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
    }
}

