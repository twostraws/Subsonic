//
// ViewExtensions.swift
// Part of Subsonic, a simple library for playing sounds in SwiftUI
//
// This file contains `View` extensions that make Subsonic audio
// easier to play.
//
// Copyright (c) 2021 Paul Hudson.
// See LICENSE for license information.
//

import SwiftUI

extension View {
    /// Plays a single sound immediately.
    /// - Parameters:
    ///   - sound: The name of the sound file you want to load.
    ///   - bundle: The bundle containing the sound file. Defaults to the main bundle.
    ///   - volume: How loud to play this sound relative to other sounds in your app,
    ///   specified in the range 0 (no volume) to 1 (maximum volume).
    ///   - repeatCount: How many times to repeat this sound. Specifying 0 here
    ///   (the default) will play the sound only once.
    public func play(sound: String, from bundle: Bundle = .main, volume: Double = 1, repeatCount: SubsonicController.RepeatCount = 0) {
        SubsonicController.shared.play(sound: sound, from: bundle, volume: volume, repeatCount: repeatCount)
    }

    /// Plays or stops a single sound based on the isPlaying Boolean
    /// - Parameters:
    ///   - sound: The name of the sound file you want to load.
    ///   - bundle: The bundle containing the sound file. Defaults to the main bundle.
    ///   - isPlaying: A Boolean tracking whether the sound should currently be playing.
    ///   - volume: How loud to play this sound relative to other sounds in your app,
    ///   specified in the range 0 (no volume) to 1 (maximum volume).
    ///   - repeatCount: How many times to repeat this sound. Specifying 0 here
    ///   (the default) will play the sound only once.
    ///   - playMode: Whether playback should restart from the beginning each time,
    ///   or continue from the last playback point. Defaults to `.reset`.
    /// - Returns: A new view that plays the sound when isPlaying becomes true.
    public func sound(_ sound: String, from bundle: Bundle = .main, isPlaying: Binding<Bool>, volume: Double = 1, repeatCount: SubsonicController.RepeatCount = 0, playMode: SubsonicController.PlayMode = .reset) -> some View {
        self.modifier(
            SubsonicPlayerModifier(sound: sound, from: bundle, isPlaying: isPlaying, volume: volume, repeatCount: repeatCount, playMode: playMode)
        )
    }

    /// Stops one specific sound played using `play(sound:)`. This will *not* stop sounds
    /// that you have bound to your app's state using the `sound()` modifier.
    public func stop(sound: String) {
        SubsonicController.shared.stop(sound: sound)
    }

    /// Stops all sounds that were played using `play(sound:)`. This will *not* stop sounds
    /// that you have bound to your app's state using the `sound()` modifier.
    public func stopAllManagedSounds() {
        SubsonicController.shared.stopAllManagedSounds()
    }
}
