//
// SubsonicController.swift
// Part of Subsonic, a simple library for playing sounds in SwiftUI
//
// This file contains the main SubsonicController class, which handles
// imperatively playing audio from any view, by calling play().
// It also wraps up the code to prepare audio from a bundle, which is
// used both here and in `SubsonicPlayerModifier`.
//
//  Created by Paul Hudson on 13/11/2021.
//

import AVFoundation

/// The main class responsible for loading and playing sounds.
public class SubsonicController: NSObject, AVAudioPlayerDelegate {
    /// When bound to some SwiftUI state, this controls how an audio player
    /// responds when playing for a second time.
    public enum PlayMode {
        /// Restarting a sound should start from the beginning each time.
        case reset

        /// Restarting a sound should pick up where it left off, or start from the
        /// beginning if it ended previously.
        case `continue`
    }

    /// With AVAudioPlayer, specifying -1 for `numberOfLoops` means the
    /// audio should loop forever. To avoid exposing that in this library, we wrap
    /// the repeat count inside this custom struct, allowing `.continuous` instead.
    public struct RepeatCount: ExpressibleByIntegerLiteral, Equatable {
        public static let continuous: RepeatCount = -1
        public let value: Int

        public init(integerLiteral value: Int) {
            self.value = value
        }
    }

    /// This class is *not* designed to be instantiated; please use the `shared` singleton.
    override private init() { }

    /// The main access point to this class. It's a singleton because sounds must
    /// be loaded and stored in order to continue playing after calling play().
    public static let shared = SubsonicController()

    /// The collection of AVAudioPlayer instances that are currently playing.
    private var playingSounds = Set<AVAudioPlayer>()

    /// Loads, prepares, then plays a single sound from your bundle.
    /// - Parameters:
    ///   - sound: The name of the sound file you want to load.
    ///   - bundle: The bundle containing the sound file. Defaults to the main bundle.
    ///   - volume: How loud to play this sound relative to other sounds in your app,
    ///   specified in the range 0 (no volume) to 1 (maximum volume).
    ///   - repeatCount: How many times to repeat this sound. Specifying 0 here
    ///   (the default) will play the sound only once.
    public func play(sound: String, from bundle: Bundle = .main, volume: Double = 1, repeatCount: RepeatCount = 0) {
        DispatchQueue.global().async {
            guard let player = self.prepare(sound: sound, from: bundle) else { return }

            player.numberOfLoops = repeatCount.value
            player.volume = Float(volume)
            player.delegate = self
            player.play()

            // We need to keep track of all sounds that are currently
            // being managed by us, so we insert them into the
            // `playingSounds` set on the main queue.
            DispatchQueue.main.async {
                self.playingSounds.insert(player)
            }
        }
    }

    /// Prepares a sound for playback, sending back the audio player for you to
    /// use however you want.
    /// - Parameters:
    ///   - sound: The name of the sound file you want to load.
    ///   - bundle: The bundle containing the sound file. Defaults to the main bundle.
    /// - Returns: The prepared AVAudioPlayer instance, ready to play.
    @discardableResult///
    public func prepare(sound: String, from bundle: Bundle = .main) -> AVAudioPlayer? {
        guard let url = bundle.url(forResource: sound, withExtension: nil) else {
            print("Failed to find \(sound) in \(bundle.bundleURL.lastPathComponent).")
            return nil
        }

        guard let player = try? AVAudioPlayer(contentsOf: url) else {
            print("Failed to load \(sound) from \(bundle.bundleURL.lastPathComponent).")
            return nil
        }

        player.prepareToPlay()
        return player
    }

    /// Called when one of our sounds has finished, so we can remove it from the
    /// set of active sounds and Swift can release the memory.
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playingSounds.remove(player)
    }

    /// Stops one specific sound file currently being played centrally by Subsonic.
    public func stop(sound: String) {
        for playingSound in playingSounds {
            if playingSound.url?.lastPathComponent == sound {
                playingSound.stop()
            }
        }
    }

    /// Stops all sounds currently being played centrally by Subsonic.
    public func stopAllManagedSounds() {
        for playingSound in playingSounds {
            playingSound.stop()
        }
    }
}
