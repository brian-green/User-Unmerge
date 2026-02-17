import AVFoundation
import SpriteKit

class AudioManager {
    static let shared = AudioManager()

    private var backgroundMusicPlayer: AVAudioPlayer?
    private var currentTrack: String?
    private var soundEffectPlayers: [String: AVAudioPlayer] = [:]

    private init() {}

    // MARK: - Background Music
    func playBackgroundMusic(_ filename: String, loop: Bool = true) {
        guard GameManager.shared.musicEnabled else { return }
        guard currentTrack != filename else { return }

        stopBackgroundMusic()
        currentTrack = filename

        guard let url = Bundle.main.url(forResource: filename, withExtension: nil)
                ?? Bundle.main.url(forResource: filename, withExtension: "mp3")
                ?? Bundle.main.url(forResource: filename, withExtension: "m4a") else {
            return
        }

        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundMusicPlayer?.numberOfLoops = loop ? -1 : 0
            backgroundMusicPlayer?.volume = 0.5
            backgroundMusicPlayer?.prepareToPlay()
            backgroundMusicPlayer?.play()
        } catch {
            // Audio file not found or cannot be played
        }
    }

    func stopBackgroundMusic() {
        backgroundMusicPlayer?.stop()
        backgroundMusicPlayer = nil
        currentTrack = nil
    }

    func pauseBackgroundMusic() {
        backgroundMusicPlayer?.pause()
    }

    func resumeBackgroundMusic() {
        guard GameManager.shared.musicEnabled else { return }
        backgroundMusicPlayer?.play()
    }

    func setMusicVolume(_ volume: Float) {
        backgroundMusicPlayer?.volume = volume
    }

    // MARK: - Sound Effects
    func playSoundEffect(_ filename: String, in scene: SKScene) {
        guard GameManager.shared.soundEnabled else { return }

        // Try using SKAction for simple playback
        if let _ = Bundle.main.url(forResource: filename, withExtension: nil)
            ?? Bundle.main.url(forResource: filename, withExtension: "wav")
            ?? Bundle.main.url(forResource: filename, withExtension: "mp3") {

            let playAction = SKAction.playSoundFileNamed(filename, waitForCompletion: false)
            scene.run(playAction)
        }
    }

    // MARK: - Settings
    func updateMusicState() {
        if GameManager.shared.musicEnabled {
            resumeBackgroundMusic()
        } else {
            pauseBackgroundMusic()
        }
    }
}
