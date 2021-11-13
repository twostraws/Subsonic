//
// SubsonicPlayerModifier.swift
// Part of Subsonic, a simple library for playing sounds in SwiftUI
//
// This file contains the SwiftUI view modifier for playing sounds
// declaratively, so that we can make a sound stop or start based
// on some program state.
//
// Copyright (c) 2021 Paul Hudson.
// See LICENSE for license information.
//

import AVFoundation
import SwiftUI

/// Attaches sounds to a SwiftUI view so they can play based on some program state.
public struct SubsonicPlayerModifier: ViewModifier {
    /// Internal class responsible for communicating AVAudioPlayer events back to our SwiftUI modifier.
    private class PlayerDelegate: NSObject, AVAudioPlayerDelegate {
        /// The function to be called when a sound has finished playing.
        var onFinish: ((Bool) -> Void)?

        /// Called by an AVAudioPlayer when it finishes.
        /// - Parameters:
        ///   - player: The audio player in question.
        ///   - flag: Whether playback finished successfully or not.
        func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
            onFinish?(flag)
        }
    }

    /// The name of the sound file you want to load.
    let sound: String

    /// The bundle containing the sound file. Defaults to the main bundle.
    var from: Bundle = .main

    /// Tracks whether the sound should currently be playing or not.
    @Binding var isPlaying: Bool

    /// How loud to play this sound relative to other sounds in your app,
    /// specified in the range 0 (no volume) to 1 (maximum volume).
    let volume: Double

    /// How many times to repeat this sound. Specifying 0 here (the default)
    /// will play the sound only once.
    let repeatCount: SubsonicController.RepeatCount

    /// Whether playback should restart from the beginning each time, or
    /// continue from the last playback point.
    var playMode: SubsonicController.PlayMode = .reset

    /// Our internal audio player, marked @State to keep it alive when our
    /// modifier is recreated.
    @State private var audioPlayer: AVAudioPlayer?

    /// The delegate for our internal audio player, marked @State to keep it
    /// alive when our modifier is recreated.
    @State private var audioPlayerDelegate: PlayerDelegate?

    public func body(content: Content) -> some View {
        content
            .onChange(of: isPlaying) { playing in
                if playing {
                    // When `playMode` is set to `.reset` we need to make sure
                    // all play requests start at time 0.
                    if playMode == .reset {
                        audioPlayer?.currentTime = 0
                    }

                    audioPlayer?.play()
                } else {
                    audioPlayer?.stop()
                }
            }
            .onAppear(perform: prepareAudio)
            .onChange(of: volume) { _ in updateAudio() }
            .onChange(of: repeatCount) { _ in updateAudio() }
            .onChange(of: sound) { _ in prepareAudio() }
            .onChange(of: from) { _ in prepareAudio() }
    }

    /// Called to initialize all our audio, either because we're just setting up or
    /// because we're changing sound/bundle.
    ///
    /// Doing this work here rather than in an initializer stop SwiftUI from recreating the
    /// audio data every time the view is changed, and also delays the work of loading
    /// audio until the responsible view is actually visible.
    private func prepareAudio() {
        // This SwiftUI modifier is a struct, so we can't set ourselves
        // up as the delegate for our AVAudioPlayer. So, instead we
        // have a little shim: we create a dedicated `PlayerDelegate`
        // class instance that acts as the audio delegate, and forwards
        // its `audioPlayerDidFinishPlaying()` on to us as a callback.
        audioPlayerDelegate = PlayerDelegate()

        // Load the audio player, but *do not* play – playback should
        // only happen when the isPlaying Boolean becomes true.
        audioPlayer = SubsonicController.shared.prepare(sound: sound, from: from)
        audioPlayerDelegate?.onFinish = audioFinished
        audioPlayer?.delegate = audioPlayerDelegate

        updateAudio()
    }

    /// Changes the playback parameters for an existing sound.
    private func updateAudio() {
        audioPlayer?.volume = Float(volume)
        audioPlayer?.numberOfLoops = repeatCount.value
    }

    /// Called when our internal player has finished playing, and sets the `isPlaying` Boolean back to false.
    func audioFinished(_ successfully: Bool) {
        isPlaying = false
    }
}
