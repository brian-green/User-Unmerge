import SpriteKit

class LevelManager {

    static let shared = LevelManager()

    private init() {}

    func configurationForLevel(_ levelNumber: Int) -> LevelConfiguration {
        switch levelNumber {
        case 1: return level1()
        case 2: return level2()
        case 3: return level3()
        case 4: return level4()
        case 5: return level5()
        case 6: return level6()
        case 7: return level7()
        case 8: return level8()
        case 9: return level9()
        case 10: return level10()
        default: return level1()
        }
    }

    // MARK: - Level 1: Motunui Village
    private func level1() -> LevelConfiguration {
        return LevelConfiguration(
            levelNumber: 1,
            name: "Motunui Village",
            theme: .village,
            levelLength: 4000,
            playerStartPosition: CGPoint(x: 200, y: 200),
            groundSegments: [
                GroundSegmentData(startX: 0, endX: 1200),
                GroundSegmentData(startX: 1300, endX: 2500),
                GroundSegmentData(startX: 2600, endX: 4000)
            ],
            platforms: [
                PlatformData(position: CGPoint(x: 1250, y: 150), size: CGSize(width: 80, height: 20)),
                PlatformData(position: CGPoint(x: 2000, y: 180), size: CGSize(width: 100, height: 20)),
                PlatformData(position: CGPoint(x: 2550, y: 140), size: CGSize(width: 70, height: 20))
            ],
            enemies: [
                EnemySpawnData(type: .kakamora, position: CGPoint(x: 800, y: 120)),
                EnemySpawnData(type: .kakamora, position: CGPoint(x: 1500, y: 120)),
                EnemySpawnData(type: .kakamora, position: CGPoint(x: 2200, y: 120)),
                EnemySpawnData(type: .kakamora, position: CGPoint(x: 3200, y: 120))
            ],
            collectibles: [
                CollectibleSpawnData(type: .seashell, position: CGPoint(x: 400, y: 120)),
                CollectibleSpawnData(type: .seashell, position: CGPoint(x: 600, y: 120)),
                CollectibleSpawnData(type: .seashell, position: CGPoint(x: 1000, y: 120)),
                CollectibleSpawnData(type: .seashell, position: CGPoint(x: 1500, y: 200)),
                CollectibleSpawnData(type: .seashell, position: CGPoint(x: 2000, y: 220)),
                CollectibleSpawnData(type: .goldenSeashell, position: CGPoint(x: 2800, y: 180)),
                CollectibleSpawnData(type: .heartPiece, position: CGPoint(x: 3500, y: 120))
            ],
            decorations: [
                DecorationData(type: .palmTree, position: CGPoint(x: 100, y: 80)),
                DecorationData(type: .coconutTree, position: CGPoint(x: 500, y: 80)),
                DecorationData(type: .flower, position: CGPoint(x: 300, y: 82)),
                DecorationData(type: .tikiTorch, position: CGPoint(x: 700, y: 80)),
                DecorationData(type: .fern, position: CGPoint(x: 1800, y: 82)),
                DecorationData(type: .palmTree, position: CGPoint(x: 2700, y: 80)),
                DecorationData(type: .totemPole, position: CGPoint(x: 3800, y: 80))
            ],
            backgroundColors: BackgroundColorData(
                topColor: CodableColor(red: 0.2, green: 0.6, blue: 0.95),
                bottomColor: CodableColor(red: 0.5, green: 0.8, blue: 1.0)
            ),
            groundColor: CodableColor(red: 0.45, green: 0.35, blue: 0.2),
            musicTrackName: "village_theme",
            ambientSoundName: "ocean_waves",
            threeStarTime: 120,
            difficulty: 1,
            tutorialPrompts: [
                300: "Tap left/right to move",
                700: "Tap jump to leap over enemies",
                1000: "Tap attack to defeat Kakamora!"
            ]
        )
    }

    // MARK: - Level 2: The Reef
    private func level2() -> LevelConfiguration {
        return LevelConfiguration(
            levelNumber: 2,
            name: "The Reef",
            theme: .reef,
            levelLength: 4500,
            playerStartPosition: CGPoint(x: 200, y: 200),
            groundSegments: [
                GroundSegmentData(startX: 0, endX: 800),
                GroundSegmentData(startX: 900, endX: 1800),
                GroundSegmentData(startX: 2000, endX: 3200),
                GroundSegmentData(startX: 3400, endX: 4500)
            ],
            platforms: [
                PlatformData(position: CGPoint(x: 850, y: 120), size: CGSize(width: 60, height: 20), type: .floating),
                PlatformData(position: CGPoint(x: 1900, y: 150), size: CGSize(width: 80, height: 20))
            ],
            enemies: [
                EnemySpawnData(type: .kakamora, position: CGPoint(x: 600, y: 120)),
                EnemySpawnData(type: .kakamora, position: CGPoint(x: 1200, y: 120)),
                EnemySpawnData(type: .darkSeaCreature, position: CGPoint(x: 1600, y: 200)),
                EnemySpawnData(type: .kakamora, position: CGPoint(x: 2800, y: 120)),
                EnemySpawnData(type: .kakamora, position: CGPoint(x: 3800, y: 120))
            ],
            collectibles: [
                CollectibleSpawnData(type: .seashell, position: CGPoint(x: 300, y: 120)),
                CollectibleSpawnData(type: .seashell, position: CGPoint(x: 500, y: 120)),
                CollectibleSpawnData(type: .seashell, position: CGPoint(x: 1000, y: 120)),
                CollectibleSpawnData(type: .seashell, position: CGPoint(x: 1400, y: 120)),
                CollectibleSpawnData(type: .seashell, position: CGPoint(x: 2500, y: 120)),
                CollectibleSpawnData(type: .goldenSeashell, position: CGPoint(x: 3000, y: 200)),
                CollectibleSpawnData(type: .starfish, position: CGPoint(x: 4000, y: 120))
            ],
            waterZones: [
                WaterZoneData(position: CGPoint(x: 1400, y: 100), size: CGSize(width: 400, height: 150))
            ],
            decorations: [
                DecorationData(type: .coral, position: CGPoint(x: 400, y: 82)),
                DecorationData(type: .seaweed, position: CGPoint(x: 1500, y: 30)),
                DecorationData(type: .coralFan, position: CGPoint(x: 1600, y: 30)),
                DecorationData(type: .spiralShell, position: CGPoint(x: 2200, y: 82)),
                DecorationData(type: .palmTree, position: CGPoint(x: 3600, y: 80))
            ],
            backgroundColors: BackgroundColorData(
                topColor: CodableColor(red: 0.15, green: 0.55, blue: 0.9),
                bottomColor: CodableColor(red: 0.0, green: 0.3, blue: 0.6)
            ),
            groundColor: CodableColor(red: 0.85, green: 0.78, blue: 0.6),
            musicTrackName: "reef_theme",
            threeStarTime: 150,
            difficulty: 2
        )
    }

    // MARK: - Level 3: Open Ocean
    private func level3() -> LevelConfiguration {
        return LevelConfiguration(
            levelNumber: 3,
            name: "Open Ocean",
            theme: .ocean,
            levelLength: 5000,
            playerStartPosition: CGPoint(x: 200, y: 200),
            groundSegments: [
                GroundSegmentData(startX: 0, endX: 600),
                GroundSegmentData(startX: 1200, endX: 2000),
                GroundSegmentData(startX: 2800, endX: 3500),
                GroundSegmentData(startX: 4200, endX: 5000)
            ],
            platforms: [
                PlatformData(position: CGPoint(x: 800, y: 140), size: CGSize(width: 100, height: 20), type: .floating),
                PlatformData(position: CGPoint(x: 1000, y: 180), size: CGSize(width: 80, height: 20), type: .floating),
                PlatformData(position: CGPoint(x: 2300, y: 150), size: CGSize(width: 120, height: 20),
                             type: .moving, moveTarget: CGPoint(x: 2600, y: 150), moveDuration: 3.0),
                PlatformData(position: CGPoint(x: 3700, y: 140), size: CGSize(width: 80, height: 20), type: .floating),
                PlatformData(position: CGPoint(x: 3900, y: 170), size: CGSize(width: 80, height: 20), type: .floating)
            ],
            enemies: [
                EnemySpawnData(type: .darkSeaCreature, position: CGPoint(x: 900, y: 200)),
                EnemySpawnData(type: .kakamora, position: CGPoint(x: 1500, y: 120)),
                EnemySpawnData(type: .stormBird, position: CGPoint(x: 2200, y: 350)),
                EnemySpawnData(type: .darkSeaCreature, position: CGPoint(x: 3200, y: 200)),
                EnemySpawnData(type: .kakamora, position: CGPoint(x: 4500, y: 120))
            ],
            collectibles: [
                CollectibleSpawnData(type: .seashell, position: CGPoint(x: 400, y: 120)),
                CollectibleSpawnData(type: .seashell, position: CGPoint(x: 800, y: 180)),
                CollectibleSpawnData(type: .seashell, position: CGPoint(x: 1500, y: 120)),
                CollectibleSpawnData(type: .goldenSeashell, position: CGPoint(x: 2400, y: 200)),
                CollectibleSpawnData(type: .heartPiece, position: CGPoint(x: 3300, y: 120)),
                CollectibleSpawnData(type: .seashell, position: CGPoint(x: 4700, y: 120))
            ],
            powerUps: [
                PowerUpSpawnData(type: .oceanBlessing, position: CGPoint(x: 1800, y: 150))
            ],
            waterZones: [
                WaterZoneData(position: CGPoint(x: 700, y: 80), size: CGSize(width: 500, height: 200)),
                WaterZoneData(position: CGPoint(x: 2100, y: 80), size: CGSize(width: 700, height: 200)),
                WaterZoneData(position: CGPoint(x: 3600, y: 80), size: CGSize(width: 600, height: 200))
            ],
            backgroundColors: BackgroundColorData(
                topColor: CodableColor(red: 0.1, green: 0.4, blue: 0.8),
                bottomColor: CodableColor(red: 0.0, green: 0.2, blue: 0.5)
            ),
            groundColor: CodableColor(red: 0.8, green: 0.72, blue: 0.55),
            musicTrackName: "ocean_theme",
            threeStarTime: 180,
            difficulty: 3
        )
    }

    // MARK: - Level 4-10 (simplified definitions)
    private func level4() -> LevelConfiguration {
        return LevelConfiguration(
            levelNumber: 4, name: "Kakamora Ambush", theme: .ocean, levelLength: 5000,
            groundSegments: [
                GroundSegmentData(startX: 0, endX: 1500),
                GroundSegmentData(startX: 1700, endX: 3500),
                GroundSegmentData(startX: 3700, endX: 5000)
            ],
            enemies: [
                EnemySpawnData(type: .kakamora, position: CGPoint(x: 500, y: 120)),
                EnemySpawnData(type: .kakamora, position: CGPoint(x: 700, y: 120)),
                EnemySpawnData(type: .kakamora, position: CGPoint(x: 900, y: 120)),
                EnemySpawnData(type: .kakamoraBrute, position: CGPoint(x: 1200, y: 120)),
                EnemySpawnData(type: .kakamora, position: CGPoint(x: 2000, y: 120)),
                EnemySpawnData(type: .kakamora, position: CGPoint(x: 2500, y: 120)),
                EnemySpawnData(type: .kakamoraBrute, position: CGPoint(x: 3000, y: 120)),
                EnemySpawnData(type: .stormBird, position: CGPoint(x: 4000, y: 350))
            ],
            collectibles: [
                CollectibleSpawnData(type: .seashell, position: CGPoint(x: 300, y: 120)),
                CollectibleSpawnData(type: .seashell, position: CGPoint(x: 1600, y: 180)),
                CollectibleSpawnData(type: .goldenSeashell, position: CGPoint(x: 2800, y: 200)),
                CollectibleSpawnData(type: .heartPiece, position: CGPoint(x: 4500, y: 120))
            ],
            powerUps: [
                PowerUpSpawnData(type: .coconutArmor, position: CGPoint(x: 1000, y: 150))
            ],
            backgroundColors: BackgroundColorData(
                topColor: CodableColor(red: 0.15, green: 0.45, blue: 0.8),
                bottomColor: CodableColor(red: 0.05, green: 0.25, blue: 0.5)
            ),
            musicTrackName: "battle_theme", threeStarTime: 160, difficulty: 4
        )
    }

    private func level5() -> LevelConfiguration {
        return LevelConfiguration(
            levelNumber: 5, name: "Lalotai", theme: .cave, levelLength: 5500,
            groundSegments: [
                GroundSegmentData(startX: 0, endX: 2000),
                GroundSegmentData(startX: 2200, endX: 4000),
                GroundSegmentData(startX: 4200, endX: 5500)
            ],
            enemies: [
                EnemySpawnData(type: .darkSeaCreature, position: CGPoint(x: 600, y: 200)),
                EnemySpawnData(type: .crabMinion, position: CGPoint(x: 1200, y: 120)),
                EnemySpawnData(type: .crabMinion, position: CGPoint(x: 1800, y: 120)),
                EnemySpawnData(type: .shadowSpirit, position: CGPoint(x: 2800, y: 150)),
                EnemySpawnData(type: .crabMinion, position: CGPoint(x: 3500, y: 120))
            ],
            collectibles: [
                CollectibleSpawnData(type: .seashell, position: CGPoint(x: 400, y: 120)),
                CollectibleSpawnData(type: .pearlOfWisdom, position: CGPoint(x: 1500, y: 200)),
                CollectibleSpawnData(type: .goldenSeashell, position: CGPoint(x: 3200, y: 180))
            ],
            bossData: BossData(type: .tamatoa, spawnPosition: CGPoint(x: 5000, y: 150),
                               arenaStartX: 4500, arenaEndX: 5500, health: 15),
            backgroundColors: BackgroundColorData(
                topColor: CodableColor(red: 0.08, green: 0.05, blue: 0.2),
                bottomColor: CodableColor(red: 0.15, green: 0.05, blue: 0.3)
            ),
            groundColor: CodableColor(red: 0.3, green: 0.25, blue: 0.35),
            musicTrackName: "lalotai_theme", threeStarTime: 200, difficulty: 5
        )
    }

    private func level6() -> LevelConfiguration {
        return LevelConfiguration(
            levelNumber: 6, name: "Tamatoa's Lair", theme: .cave, levelLength: 5000,
            groundSegments: [
                GroundSegmentData(startX: 0, endX: 1800),
                GroundSegmentData(startX: 2000, endX: 3500),
                GroundSegmentData(startX: 3700, endX: 5000)
            ],
            enemies: [
                EnemySpawnData(type: .crabMinion, position: CGPoint(x: 500, y: 120)),
                EnemySpawnData(type: .crabMinion, position: CGPoint(x: 1000, y: 120)),
                EnemySpawnData(type: .shadowSpirit, position: CGPoint(x: 1500, y: 150)),
                EnemySpawnData(type: .darkSeaCreature, position: CGPoint(x: 2500, y: 200)),
                EnemySpawnData(type: .crabMinion, position: CGPoint(x: 3200, y: 120)),
                EnemySpawnData(type: .shadowSpirit, position: CGPoint(x: 4200, y: 150))
            ],
            collectibles: [
                CollectibleSpawnData(type: .seashell, position: CGPoint(x: 300, y: 120)),
                CollectibleSpawnData(type: .goldenSeashell, position: CGPoint(x: 1700, y: 200)),
                CollectibleSpawnData(type: .heartPiece, position: CGPoint(x: 2800, y: 120)),
                CollectibleSpawnData(type: .pearlOfWisdom, position: CGPoint(x: 4500, y: 200))
            ],
            powerUps: [
                PowerUpSpawnData(type: .mauiHook, position: CGPoint(x: 2200, y: 150))
            ],
            backgroundColors: BackgroundColorData(
                topColor: CodableColor(red: 0.06, green: 0.03, blue: 0.15),
                bottomColor: CodableColor(red: 0.12, green: 0.04, blue: 0.25)
            ),
            groundColor: CodableColor(red: 0.25, green: 0.2, blue: 0.3),
            musicTrackName: "lair_theme", threeStarTime: 180, difficulty: 6
        )
    }

    private func level7() -> LevelConfiguration {
        return LevelConfiguration(
            levelNumber: 7, name: "Maui's Island", theme: .island, levelLength: 5500,
            groundSegments: [
                GroundSegmentData(startX: 0, endX: 2200),
                GroundSegmentData(startX: 2400, endX: 4000),
                GroundSegmentData(startX: 4200, endX: 5500)
            ],
            enemies: [
                EnemySpawnData(type: .kakamora, position: CGPoint(x: 800, y: 120)),
                EnemySpawnData(type: .stormBird, position: CGPoint(x: 1500, y: 350)),
                EnemySpawnData(type: .kakamora, position: CGPoint(x: 2800, y: 120)),
                EnemySpawnData(type: .stormBird, position: CGPoint(x: 3500, y: 350)),
                EnemySpawnData(type: .kakamoraBrute, position: CGPoint(x: 4800, y: 120))
            ],
            collectibles: [
                CollectibleSpawnData(type: .seashell, position: CGPoint(x: 400, y: 120)),
                CollectibleSpawnData(type: .seashell, position: CGPoint(x: 1200, y: 120)),
                CollectibleSpawnData(type: .goldenSeashell, position: CGPoint(x: 3200, y: 200)),
                CollectibleSpawnData(type: .extraLife, position: CGPoint(x: 5000, y: 200))
            ],
            powerUps: [
                PowerUpSpawnData(type: .windSail, position: CGPoint(x: 2000, y: 150))
            ],
            backgroundColors: BackgroundColorData(
                topColor: CodableColor(red: 0.2, green: 0.6, blue: 0.9),
                bottomColor: CodableColor(red: 0.4, green: 0.75, blue: 1.0)
            ),
            groundColor: CodableColor(red: 0.5, green: 0.38, blue: 0.22),
            musicTrackName: "island_theme", threeStarTime: 190, difficulty: 5
        )
    }

    private func level8() -> LevelConfiguration {
        return LevelConfiguration(
            levelNumber: 8, name: "Te Ka's Domain", theme: .lava, levelLength: 6000,
            groundSegments: [
                GroundSegmentData(startX: 0, endX: 1500),
                GroundSegmentData(startX: 1700, endX: 3000),
                GroundSegmentData(startX: 3300, endX: 4500),
                GroundSegmentData(startX: 4800, endX: 6000)
            ],
            enemies: [
                EnemySpawnData(type: .lavaMonster, position: CGPoint(x: 800, y: 120)),
                EnemySpawnData(type: .lavaBat, position: CGPoint(x: 1200, y: 300)),
                EnemySpawnData(type: .lavaMonster, position: CGPoint(x: 2200, y: 120)),
                EnemySpawnData(type: .lavaBat, position: CGPoint(x: 2800, y: 300)),
                EnemySpawnData(type: .lavaMonster, position: CGPoint(x: 3800, y: 120)),
                EnemySpawnData(type: .shadowSpirit, position: CGPoint(x: 4500, y: 150))
            ],
            collectibles: [
                CollectibleSpawnData(type: .seashell, position: CGPoint(x: 400, y: 120)),
                CollectibleSpawnData(type: .heartPiece, position: CGPoint(x: 1300, y: 120)),
                CollectibleSpawnData(type: .goldenSeashell, position: CGPoint(x: 3600, y: 200)),
                CollectibleSpawnData(type: .seashell, position: CGPoint(x: 5500, y: 120))
            ],
            powerUps: [
                PowerUpSpawnData(type: .coconutArmor, position: CGPoint(x: 2500, y: 150)),
                PowerUpSpawnData(type: .teFitiHeart, position: CGPoint(x: 4200, y: 150))
            ],
            backgroundColors: BackgroundColorData(
                topColor: CodableColor(red: 0.3, green: 0.1, blue: 0.05),
                bottomColor: CodableColor(red: 0.5, green: 0.15, blue: 0.0)
            ),
            groundColor: CodableColor(red: 0.25, green: 0.12, blue: 0.08),
            musicTrackName: "lava_theme", threeStarTime: 210, difficulty: 7
        )
    }

    private func level9() -> LevelConfiguration {
        return LevelConfiguration(
            levelNumber: 9, name: "The Storm", theme: .storm, levelLength: 5500,
            groundSegments: [
                GroundSegmentData(startX: 0, endX: 1200),
                GroundSegmentData(startX: 1400, endX: 2600),
                GroundSegmentData(startX: 2900, endX: 4000),
                GroundSegmentData(startX: 4300, endX: 5500)
            ],
            enemies: [
                EnemySpawnData(type: .stormBird, position: CGPoint(x: 700, y: 350)),
                EnemySpawnData(type: .stormBird, position: CGPoint(x: 1800, y: 350)),
                EnemySpawnData(type: .darkSeaCreature, position: CGPoint(x: 2300, y: 200)),
                EnemySpawnData(type: .stormBird, position: CGPoint(x: 3500, y: 350)),
                EnemySpawnData(type: .shadowSpirit, position: CGPoint(x: 4600, y: 150)),
                EnemySpawnData(type: .stormBird, position: CGPoint(x: 5000, y: 350))
            ],
            collectibles: [
                CollectibleSpawnData(type: .seashell, position: CGPoint(x: 500, y: 120)),
                CollectibleSpawnData(type: .heartPiece, position: CGPoint(x: 2000, y: 120)),
                CollectibleSpawnData(type: .goldenSeashell, position: CGPoint(x: 3800, y: 200)),
                CollectibleSpawnData(type: .extraLife, position: CGPoint(x: 5200, y: 200))
            ],
            waterZones: [
                WaterZoneData(position: CGPoint(x: 1300, y: 80), size: CGSize(width: 200, height: 150),
                              hasCurrents: true, currentDirection: CGVector(dx: 1, dy: 0)),
                WaterZoneData(position: CGPoint(x: 2700, y: 80), size: CGSize(width: 300, height: 200),
                              hasCurrents: true, currentDirection: CGVector(dx: -1, dy: 0))
            ],
            backgroundColors: BackgroundColorData(
                topColor: CodableColor(red: 0.15, green: 0.15, blue: 0.25),
                bottomColor: CodableColor(red: 0.1, green: 0.15, blue: 0.3)
            ),
            groundColor: CodableColor(red: 0.35, green: 0.32, blue: 0.28),
            musicTrackName: "storm_theme", threeStarTime: 200, difficulty: 8
        )
    }

    private func level10() -> LevelConfiguration {
        return LevelConfiguration(
            levelNumber: 10, name: "Te Fiti's Restoration", theme: .sacred, levelLength: 6000,
            groundSegments: [
                GroundSegmentData(startX: 0, endX: 2000),
                GroundSegmentData(startX: 2200, endX: 3800),
                GroundSegmentData(startX: 4000, endX: 6000)
            ],
            enemies: [
                EnemySpawnData(type: .lavaMonster, position: CGPoint(x: 600, y: 120)),
                EnemySpawnData(type: .shadowSpirit, position: CGPoint(x: 1200, y: 150)),
                EnemySpawnData(type: .lavaMonster, position: CGPoint(x: 1800, y: 120)),
                EnemySpawnData(type: .stormBird, position: CGPoint(x: 2800, y: 350)),
                EnemySpawnData(type: .shadowSpirit, position: CGPoint(x: 3500, y: 150)),
                EnemySpawnData(type: .lavaMonster, position: CGPoint(x: 4200, y: 120))
            ],
            collectibles: [
                CollectibleSpawnData(type: .seashell, position: CGPoint(x: 300, y: 120)),
                CollectibleSpawnData(type: .goldenSeashell, position: CGPoint(x: 1500, y: 200)),
                CollectibleSpawnData(type: .heartPiece, position: CGPoint(x: 2500, y: 120)),
                CollectibleSpawnData(type: .pearlOfWisdom, position: CGPoint(x: 3200, y: 200)),
                CollectibleSpawnData(type: .goldenSeashell, position: CGPoint(x: 4800, y: 200))
            ],
            powerUps: [
                PowerUpSpawnData(type: .teFitiHeart, position: CGPoint(x: 1000, y: 150)),
                PowerUpSpawnData(type: .mauiHook, position: CGPoint(x: 3000, y: 150))
            ],
            bossData: BossData(type: .teKa, spawnPosition: CGPoint(x: 5500, y: 180),
                               arenaStartX: 5000, arenaEndX: 6000, health: 20),
            backgroundColors: BackgroundColorData(
                topColor: CodableColor(red: 0.25, green: 0.1, blue: 0.05),
                bottomColor: CodableColor(red: 0.1, green: 0.3, blue: 0.2)
            ),
            groundColor: CodableColor(red: 0.3, green: 0.25, blue: 0.15),
            musicTrackName: "final_theme", threeStarTime: 240, difficulty: 10
        )
    }
}
