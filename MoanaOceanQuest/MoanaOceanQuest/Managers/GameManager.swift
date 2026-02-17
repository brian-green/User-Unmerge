import Foundation

/// Singleton that persists game progress using UserDefaults.
class GameManager {
    static let shared = GameManager()

    private let defaults = UserDefaults.standard
    private let highestLevelKey = "highestUnlockedLevel"
    private let starsPrefix = "level_stars_"
    private let highScorePrefix = "level_highscore_"
    private let totalScoreKey = "totalScore"
    private let soundEnabledKey = "soundEnabled"
    private let musicEnabledKey = "musicEnabled"

    private init() {
        if defaults.integer(forKey: highestLevelKey) == 0 {
            defaults.set(1, forKey: highestLevelKey)
        }
    }

    // MARK: - Level Progress
    var highestUnlockedLevel: Int {
        get { return max(defaults.integer(forKey: highestLevelKey), 1) }
        set { defaults.set(newValue, forKey: highestLevelKey) }
    }

    func starsForLevel(_ level: Int) -> Int {
        return defaults.integer(forKey: "\(starsPrefix)\(level)")
    }

    func setStars(_ stars: Int, forLevel level: Int) {
        let current = starsForLevel(level)
        if stars > current {
            defaults.set(stars, forKey: "\(starsPrefix)\(level)")
        }
    }

    func highScoreForLevel(_ level: Int) -> Int {
        return defaults.integer(forKey: "\(highScorePrefix)\(level)")
    }

    func setHighScore(_ score: Int, forLevel level: Int) {
        let current = highScoreForLevel(level)
        if score > current {
            defaults.set(score, forKey: "\(highScorePrefix)\(level)")
        }
    }

    func completeLevel(_ level: Int, stars: Int, score: Int) {
        setStars(stars, forLevel: level)
        setHighScore(score, forLevel: level)
        if level >= highestUnlockedLevel && level < 10 {
            highestUnlockedLevel = level + 1
        }
    }

    // MARK: - Total Score
    var totalScore: Int {
        get { return defaults.integer(forKey: totalScoreKey) }
        set { defaults.set(newValue, forKey: totalScoreKey) }
    }

    // MARK: - Settings
    var soundEnabled: Bool {
        get { return defaults.object(forKey: soundEnabledKey) == nil ? true : defaults.bool(forKey: soundEnabledKey) }
        set { defaults.set(newValue, forKey: soundEnabledKey) }
    }

    var musicEnabled: Bool {
        get { return defaults.object(forKey: musicEnabledKey) == nil ? true : defaults.bool(forKey: musicEnabledKey) }
        set { defaults.set(newValue, forKey: musicEnabledKey) }
    }

    // MARK: - Reset
    func resetAllProgress() {
        defaults.set(1, forKey: highestLevelKey)
        for i in 1...10 {
            defaults.removeObject(forKey: "\(starsPrefix)\(i)")
            defaults.removeObject(forKey: "\(highScorePrefix)\(i)")
        }
        defaults.set(0, forKey: totalScoreKey)
    }
}
