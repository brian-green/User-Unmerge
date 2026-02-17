import SpriteKit

// MARK: - Level Theme

/// Represents the visual and atmospheric theme for a level.
enum LevelTheme: String, CaseIterable, Codable {
    case village
    case reef
    case ocean
    case jungle
    case cave
    case lava
    case island
    case darkSea
    case storm
    case sacred
}

// MARK: - Enemy Types

/// All enemy types available in Ocean Quest.
enum EnemyType: String, Codable {
    case kakamora           // Small coconut pirates, basic melee
    case kakamoraBrute      // Larger Kakamora, more HP
    case kakamoraRanged     // Throws coconuts
    case darkSeaCreature    // Underwater tentacle enemy
    case darkSeaJellyfish   // Pulsing jellyfish, contact damage
    case stormBird          // Flying enemy, swoops down
    case lavaMonster        // Rises from lava, throws fire
    case lavaBat            // Small flying enemy in lava levels
    case crabMinion         // Tamatoa's crab soldiers
    case shadowSpirit       // Fast-moving dark enemies
}

// MARK: - Boss Types

/// Boss enemies that appear at the end of certain levels.
enum BossType: String, Codable {
    case tamatoa            // Giant crab, Level 5
    case teKa               // Lava demon, Level 10
}

// MARK: - Collectible Types

/// Items the player can collect throughout levels.
enum CollectibleType: String, Codable {
    case seashell           // Basic currency
    case goldenSeashell     // Rare, worth more
    case heartPiece         // Restores health
    case extraLife          // Grants an extra life
    case starfish           // Bonus points
    case pearlOfWisdom      // Lore/story collectible
}

// MARK: - Power-Up Types

/// Temporary power-ups the player can acquire.
enum PowerUpType: String, Codable {
    case mauiHook           // Enhanced attack power and range
    case oceanBlessing      // Water speed boost + breathing
    case windSail           // Increased movement speed
    case teFitiHeart        // Invincibility + heal
    case coconutArmor       // Absorbs one hit
    case stingrayRide       // Brief fast travel across water
}

// MARK: - Platform Types

/// Different platform behaviors.
enum PlatformType: String, Codable {
    case `static`           // Does not move
    case moving             // Moves along a path
    case breakable          // Crumbles after player stands on it
    case floating           // Bobs on water surface
    case swinging           // Swings like a pendulum (rope platforms)
    case crumbling          // Falls after a delay when stepped on
}

// MARK: - Spawn Data Structures

/// Data defining where and how an enemy spawns in a level.
struct EnemySpawnData: Codable {
    let type: EnemyType
    let position: CGPoint
    let patrolRange: CGFloat
    let facingLeft: Bool

    init(type: EnemyType, position: CGPoint, patrolRange: CGFloat = 200, facingLeft: Bool = false) {
        self.type = type
        self.position = position
        self.patrolRange = patrolRange
        self.facingLeft = facingLeft
    }
}

/// Data defining where a collectible item spawns.
struct CollectibleSpawnData: Codable {
    let type: CollectibleType
    let position: CGPoint

    init(type: CollectibleType, position: CGPoint) {
        self.type = type
        self.position = position
    }
}

/// Data defining where a power-up spawns.
struct PowerUpSpawnData: Codable {
    let type: PowerUpType
    let position: CGPoint

    init(type: PowerUpType, position: CGPoint) {
        self.type = type
        self.position = position
    }
}

/// Data defining a platform's placement, size, and behavior.
struct PlatformData: Codable {
    let position: CGPoint
    let size: CGSize
    let type: PlatformType

    /// For moving platforms: the end position of the movement path.
    let moveTarget: CGPoint?
    /// For moving platforms: time to complete one movement cycle.
    let moveDuration: TimeInterval?

    init(
        position: CGPoint,
        size: CGSize,
        type: PlatformType = .static,
        moveTarget: CGPoint? = nil,
        moveDuration: TimeInterval? = nil
    ) {
        self.position = position
        self.size = size
        self.type = type
        self.moveTarget = moveTarget
        self.moveDuration = moveDuration
    }
}

/// Data defining a water zone in the level.
struct WaterZoneData: Codable {
    let position: CGPoint
    let size: CGSize
    let hasCurrents: Bool
    let currentDirection: CGVector

    /// Optional water color override for themed levels.
    let waterColor: CodableColor?

    init(
        position: CGPoint,
        size: CGSize,
        hasCurrents: Bool = false,
        currentDirection: CGVector = .zero,
        waterColor: CodableColor? = nil
    ) {
        self.position = position
        self.size = size
        self.hasCurrents = hasCurrents
        self.currentDirection = currentDirection
        self.waterColor = waterColor
    }
}

/// Data describing a ground segment within a level.
struct GroundSegmentData: Codable {
    let startX: CGFloat
    let endX: CGFloat
    let height: CGFloat

    init(startX: CGFloat, endX: CGFloat, height: CGFloat = 80) {
        self.startX = startX
        self.endX = endX
        self.height = height
    }
}

/// Data for boss encounter configuration.
struct BossData: Codable {
    let type: BossType
    let spawnPosition: CGPoint
    let arenaStartX: CGFloat
    let arenaEndX: CGFloat
    let health: Int

    init(type: BossType, spawnPosition: CGPoint, arenaStartX: CGFloat, arenaEndX: CGFloat, health: Int = 10) {
        self.type = type
        self.spawnPosition = spawnPosition
        self.arenaStartX = arenaStartX
        self.arenaEndX = arenaEndX
        self.health = health
    }
}

// MARK: - Background Color Data

/// A pair of colors representing sky gradient (top and bottom).
struct BackgroundColorData: Codable {
    let topColor: CodableColor
    let bottomColor: CodableColor

    init(topColor: CodableColor, bottomColor: CodableColor) {
        self.topColor = topColor
        self.bottomColor = bottomColor
    }
}

// MARK: - Codable Color Helper

/// A Codable wrapper for color components since SKColor/UIColor is not directly Codable.
struct CodableColor: Codable {
    let red: CGFloat
    let green: CGFloat
    let blue: CGFloat
    let alpha: CGFloat

    init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1.0) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    var skColor: SKColor {
        return SKColor(red: red, green: green, blue: blue, alpha: alpha)
    }

    /// Convenience initializer from SKColor.
    init(skColor: SKColor) {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        skColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        self.red = r
        self.green = g
        self.blue = b
        self.alpha = a
    }
}

// MARK: - Decoration Types

/// Decorative elements that add visual flair but have no gameplay impact.
enum DecorationType: String, Codable {
    case palmTree
    case coconutTree
    case rock
    case smallRock
    case coral
    case coralFan
    case crystal
    case glowingCrystal
    case flower
    case fern
    case tikiTorch
    case totemPole
    case driftwood
    case seaweed
    case stalactite
    case stalagmite
    case lavaRock
    case volcano
    case sacredStone
    case spiralShell
}

/// Data defining a decoration's placement.
struct DecorationData: Codable {
    let type: DecorationType
    let position: CGPoint
    let scale: CGFloat

    init(type: DecorationType, position: CGPoint, scale: CGFloat = 1.0) {
        self.type = type
        self.position = position
        self.scale = scale
    }
}

// MARK: - Level Configuration

/// Complete data container for one level, holding every piece of information needed
/// to construct the level scene.
struct LevelConfiguration {
    let levelNumber: Int
    let name: String
    let theme: LevelTheme
    let levelLength: CGFloat

    /// Player start position within the level.
    let playerStartPosition: CGPoint

    /// Ground segments (gaps between segments create pits).
    let groundSegments: [GroundSegmentData]

    /// All platforms in the level.
    let platforms: [PlatformData]

    /// All enemy spawn points.
    let enemies: [EnemySpawnData]

    /// All collectible spawn points.
    let collectibles: [CollectibleSpawnData]

    /// All power-up spawn points.
    let powerUps: [PowerUpSpawnData]

    /// Water zones within the level.
    let waterZones: [WaterZoneData]

    /// Decorative elements.
    let decorations: [DecorationData]

    /// Boss encounter data, if this level has one.
    let bossData: BossData?

    /// Background sky gradient colors.
    let backgroundColors: BackgroundColorData

    /// Ground surface color.
    let groundColor: CodableColor

    /// Name of the music track for this level (without extension).
    let musicTrackName: String

    /// Ambient sound effect name (without extension).
    let ambientSoundName: String?

    /// Target time in seconds for a 3-star speed run rating.
    let threeStarTime: TimeInterval

    /// Total seashells in the level (for completion tracking).
    var totalSeashells: Int {
        return collectibles.filter { $0.type == .seashell || $0.type == .goldenSeashell }.count
    }

    /// Whether this level has a boss fight.
    var hasBoss: Bool {
        return bossData != nil
    }

    /// Difficulty rating from 1-10.
    let difficulty: Int

    /// Tutorial text prompts shown at specific x-positions. Key = x position, Value = text.
    let tutorialPrompts: [CGFloat: String]

    init(
        levelNumber: Int,
        name: String,
        theme: LevelTheme,
        levelLength: CGFloat,
        playerStartPosition: CGPoint = CGPoint(x: 200, y: 300),
        groundSegments: [GroundSegmentData],
        platforms: [PlatformData] = [],
        enemies: [EnemySpawnData] = [],
        collectibles: [CollectibleSpawnData] = [],
        powerUps: [PowerUpSpawnData] = [],
        waterZones: [WaterZoneData] = [],
        decorations: [DecorationData] = [],
        bossData: BossData? = nil,
        backgroundColors: BackgroundColorData,
        groundColor: CodableColor = CodableColor(red: 0.45, green: 0.32, blue: 0.18),
        musicTrackName: String,
        ambientSoundName: String? = nil,
        threeStarTime: TimeInterval = 180,
        difficulty: Int = 1,
        tutorialPrompts: [CGFloat: String] = [:]
    ) {
        self.levelNumber = levelNumber
        self.name = name
        self.theme = theme
        self.levelLength = levelLength
        self.playerStartPosition = playerStartPosition
        self.groundSegments = groundSegments
        self.platforms = platforms
        self.enemies = enemies
        self.collectibles = collectibles
        self.powerUps = powerUps
        self.waterZones = waterZones
        self.decorations = decorations
        self.bossData = bossData
        self.backgroundColors = backgroundColors
        self.groundColor = groundColor
        self.musicTrackName = musicTrackName
        self.ambientSoundName = ambientSoundName
        self.threeStarTime = threeStarTime
        self.difficulty = difficulty
        self.tutorialPrompts = tutorialPrompts
    }
}
