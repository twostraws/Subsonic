<p align="center">
    <img src="https://www.hackingwithswift.com/files/subsonic/logo.png" alt="Sitrep logo" width="485" maxHeight="83" />
</p>

<p align="center">
    <img src="https://img.shields.io/badge/Swift-5.4-red.svg" />
    <a href="https://twitter.com/twostraws">
        <img src="https://img.shields.io/badge/Contact-@twostraws-blueviolet.svg?style=flat" alt="Twitter: @twostraws" />
    </a>
</p>

Subsonic is a small library that makes it easier to play audio with SwiftUI, allowing you to work both imperatively ("play this sound now") and declaratively ("play this sound when some state becomes true").

Subsonic works on iOS 14+, macOS 11+, tvOS 14+, and watchOS 7+.

Why "subsonic"? Because it's so small it's almost imperceptible ✨


## Installation

To use Subsonic in a SwiftPM project, add the following line to the dependencies in your Package.swift file:

```swift
.package(url: "https://github.com/twostraws/Subsonic", from: "0.1.0"),
```

You should then add `import Subsonic` to your Swift files as needed.


## Playing sounds

There are three ways to use Subsonic, depending on your needs.

If you just want to play an audio file from your bundle, call `play(sound:)` from inside any view:

```swift
Button("Play Sound") {
    play(sound: "example.mp3")
}
```

That will locate `example.mp3` in your main bundle, then play it immediately. If you want to load the file from a different bundle, [see below](#Options).

If you want to prepare a sound but not actually play it, call `prepare(sound:)` instead to receive back an `AVAudioPlayer` that you can then manipulate and play as you need:

```swift
Button("Play Sound") {
    let player = prepare(sound: "example.mp3")
    // configure as needed, then play when ready
}
```

**Important:** It is *your* responsibility to store the `player` object returned from `prepare(sound:)`, and play it when needed. If you don't store the returned object it will be destroyed immediately, and nothing will play.

Finally, if you want to have a sound start or stop playing based on the state of your program, use the `sound()` modifier on a SwiftUI view, attaching a binding to your state:

```swift
struct ContentView: View {
    @State private var isPlaying = false

    var body: some View {
        Button {
            isPlaying.toggle()
        } label: {
            if isPlaying {
                Image(systemName: "speaker.wave.3")
            } else {
                Image(systemName: "speaker")
            }
        }
        .sound("example.mp3", isPlaying: $isPlaying)
    }
}
```


## Stopping sounds

Once a sound is playing, stopping it depends on how you played it:

- If you used `play(sound:)` you can use `stop(sound: "example.mp3")` to stop all instances of example.mp3, or `stopAllManagedSounds()` to stop all sounds that were played using `play(sound:)`.
- If you used `prepare(sound:)` you are responsible both playing and stopping the sound yourself.
- If you used the `sound()` modifier to play your sound based on the state of your program, that same state is also responsible for stopping the sound.

**Important:** Calling `stopAllManagedSounds()` will have no effect on sounds that were not created using `play(sound:)` – that includes any sounds you created yourself, any sounds you created using `prepare(sound:)`, and any sounds that are playing using the `sound()` modifier.


## Options

When using `play(sound:)` and the `sound()` modifier, there are various extra parameters you can provide if needed:

- `bundle` controls which bundle contains your sound file. This defaults to `Bundle.main`.
- `volume` controls the relative loudness of the sound, where 0 is silence and 1 is maximum volume. This defaults to 1.
- `repeatCount` controls how many times the sound should be repeated. Set to 0 to play the sound once, set to 1 to play the sound twice, and so on, or use `.continuous` to repeat the sound indefinitely. This defaults to 0.

The `sound()` modifier also has an extra option, `playMode`, which controls what happens when the sound resumes playing after it was previously stopped. This is set to `.reset` by default, which means when a sound resumes playing it will start from the beginning, but you can also use `.continue` to have sounds pick up where they left off.

You can also pass a custom bundle when using `prepare(sound:)`, and again it defaults to `Bundle.main`. 


## Credits

Subsonic was created by Paul Hudson, and is copyright © Paul Hudson 2021. Subsonic is licensed under the MIT license; for the full license please see the LICENSE file.

If you find Subsonic useful, you might find my website full of Swift tutorials equally useful: [Hacking with Swift](https://www.hackingwithswift.com).
