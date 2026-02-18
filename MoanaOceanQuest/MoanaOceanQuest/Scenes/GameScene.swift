import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    // MARK: - Properties
    var currentLevel: Int = 1

    private var player: PlayerCharacter!
    private var hud: HUDOverlay!
    private var cameraNode: SKCameraNode!
    private var parallaxBackground: ParallaxBackground!
    private var levelConfig: LevelConfiguration!

    // Enemies
    private var enemies: [BaseEnemy] = []
    private var boss: SKNode? // Can be TamataoBoss or TeKaBoss

    // Water surfaces for updating
    private var waterSurfaces: [WaterSurface] = []

    // Game state
    private var score: Int = 0
    private var collectibleCount: Int = 0
    private var gameTime: TimeInterval = 0
    private var lastUpdateTime: TimeInterval = 0
    private var isGameOver = false
    private var isGamePaused = false
    private var levelComplete = false

    // Touch tracking
    private var activeTouches: [UITouch: String] = [:]
    private var isMovingLeft = false
    private var isMovingRight = false

    // MARK: - Scene Lifecycle
    override func didMove(to view: SKView) {
        physicsWorld.gravity = CGVector(dx: 0, dy: -15)
        physicsWorld.contactDelegate = self

        levelConfig = LevelManager.shared.configurationForLevel(currentLevel)

        setupCamera()
        buildLevel()
        spawnPlayer()
        setupHUD()
        setupNotifications()

        AudioManager.shared.playBackgroundMusic(levelConfig.musicTrackName)

        hud.showLevelStartBanner(levelConfig.name)
    }

    // MARK: - Camera
    private func setupCamera() {
        cameraNode = SKCameraNode()
        camera = cameraNode
        addChild(cameraNode)
    }

    private func updateCamera() {
        guard let player = player else { return }

        let targetX = max(size.width / 2,
                          min(player.position.x, levelConfig.levelLength - size.width / 2))
        let targetY = max(size.height / 2, player.position.y + 50)

        let lerpFactor: CGFloat = 0.08
        cameraNode.position.x += (targetX - cameraNode.position.x) * lerpFactor
        cameraNode.position.y += (targetY - cameraNode.position.y) * lerpFactor

        // Keep HUD fixed to camera
        hud.position = CGPoint(x: cameraNode.position.x - size.width / 2,
                                y: cameraNode.position.y - size.height / 2)
    }

    // MARK: - Level Building
    private func buildLevel() {
        buildBackground()

        TileMapBuilder.buildGround(segments: levelConfig.groundSegments,
                                    groundColor: levelConfig.groundColor, in: self)

        for platformData in levelConfig.platforms {
            TileMapBuilder.buildPlatform(platformData, in: self)
        }

        for waterData in levelConfig.waterZones {
            TileMapBuilder.buildWaterZone(waterData, in: self)
        }

        for decorData in levelConfig.decorations {
            TileMapBuilder.buildDecoration(decorData, in: self)
        }

        TileMapBuilder.buildBoundaries(levelLength: levelConfig.levelLength,
                                        sceneHeight: size.height, in: self)

        spawnEnemies()
        spawnCollectibles()
        spawnPowerUps()
        spawnBoss()
    }

    private func buildBackground() {
        parallaxBackground = ParallaxBackground(scene: self)

        let bgColors = levelConfig.backgroundColors
        parallaxBackground.addGradientLayer(
            topColor: bgColors.topColor.skColor,
            bottomColor: bgColors.bottomColor.skColor,
            size: CGSize(width: size.width * 3, height: size.height),
            speed: 0.0,
            zPosition: -200,
            yOffset: 0
        )

        parallaxBackground.addColorLayer(
            color: bgColors.bottomColor.skColor.withAlphaComponent(0.3),
            size: CGSize(width: size.width, height: size.height * 0.4),
            speed: 0.1,
            zPosition: -180,
            yOffset: 0
        )
    }

    // MARK: - Spawning
    private func spawnPlayer() {
        player = PlayerCharacter()
        player.position = levelConfig.playerStartPosition
        addChild(player)
    }

    private func spawnEnemies() {
        for spawnData in levelConfig.enemies {
            let enemy: BaseEnemy

            switch spawnData.type {
            case .kakamora, .kakamoraBrute, .kakamoraRanged:
                enemy = KakamoraEnemy()
            case .darkSeaCreature, .darkSeaJellyfish:
                enemy = DarkSeaCreature()
            case .stormBird:
                enemy = StormBird()
            case .lavaMonster, .lavaBat:
                enemy = LavaMonster()
            case .crabMinion:
                let crab = KakamoraEnemy()
                crab.name = "crabMinion"
                enemy = crab
            case .shadowSpirit:
                let spirit = KakamoraEnemy()
                spirit.name = "shadowSpirit"
                enemy = spirit
            }

            enemy.position = spawnData.position
            if spawnData.facingLeft {
                enemy.xScale = -abs(enemy.xScale)
            }
            enemy.patrolDistance = spawnData.patrolRange

            addChild(enemy)
            enemies.append(enemy)
        }
    }

    private func spawnCollectibles() {
        for spawnData in levelConfig.collectibles {
            let collectible = Collectible(type: spawnData.type)
            collectible.position = spawnData.position
            addChild(collectible)
        }
    }

    private func spawnPowerUps() {
        for spawnData in levelConfig.powerUps {
            let powerUp = PowerUp(type: spawnData.type)
            powerUp.position = spawnData.position
            addChild(powerUp)
        }
    }

    private func spawnBoss() {
        guard let bossData = levelConfig.bossData else { return }

        switch bossData.type {
        case .tamatoa:
            let tamatoa = TamataoBoss(health: bossData.health)
            tamatoa.position = bossData.spawnPosition
            addChild(tamatoa)
            boss = tamatoa

        case .teKa:
            let teKa = TeKaBoss(health: bossData.health)
            teKa.position = bossData.spawnPosition
            addChild(teKa)
            boss = teKa
        }
    }

    // MARK: - HUD
    private func setupHUD() {
        hud = HUDOverlay(sceneSize: size)
        hud.setLevelName(levelConfig.name)
        cameraNode.addChild(hud)
        // Initial position offset
        hud.position = CGPoint(x: -size.width / 2, y: -size.height / 2)
    }

    // MARK: - Notifications
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handlePlayerDied),
                                                name: .playerDied, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleLevelComplete),
                                                name: .levelComplete, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleEnemyDefeated(_:)),
                                                name: .enemyDefeated, object: nil)
    }

    @objc private func handlePlayerDied() {
        guard !isGameOver else { return }
        isGameOver = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.transitionToGameOver()
        }
    }

    @objc private func handleLevelComplete() {
        guard !levelComplete else { return }
        levelComplete = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.transitionToLevelComplete()
        }
    }

    @objc private func handleEnemyDefeated(_ notification: Notification) {
        if let scoreValue = notification.userInfo?["score"] as? Int {
            score += scoreValue
            hud.score = score
        }
    }

    // MARK: - Update Loop
    override func update(_ currentTime: TimeInterval) {
        guard !isGameOver && !levelComplete else { return }

        let deltaTime: TimeInterval
        if lastUpdateTime == 0 {
            deltaTime = 1.0 / 60.0
        } else {
            deltaTime = currentTime - lastUpdateTime
        }
        lastUpdateTime = currentTime

        if isGamePaused { return }

        gameTime += deltaTime

        // Update player
        player.update(deltaTime: deltaTime)
        handleMovementInput()

        // Update HUD
        hud.updateHealth(player.getHealth(), maxHealth: player.getMaxHealth())
        hud.updateTimer(gameTime)

        // Update enemies
        for enemy in enemies where enemy.isAlive {
            enemy.update(deltaTime: deltaTime, playerPosition: player.position)
        }

        // Update boss
        if let tamatoa = boss as? TamataoBoss {
            tamatoa.update(deltaTime: deltaTime, playerPosition: player.position)
        } else if let teKa = boss as? TeKaBoss {
            teKa.update(deltaTime: deltaTime, playerPosition: player.position)
        }

        // Update water surfaces
        enumerateChildNodes(withName: "water") { node, _ in
            if let water = node as? WaterSurface {
                water.update(deltaTime: deltaTime)
            }
        }

        // Update camera
        updateCamera()

        // Update parallax
        parallaxBackground.update(cameraX: cameraNode.position.x)

        // Check for death pit
        if player.position.y < -100 {
            player.die()
        }

        // Check level end
        if player.position.x >= levelConfig.levelLength - 100 && levelConfig.bossData == nil {
            NotificationCenter.default.post(name: .levelComplete, object: nil)
        }
    }

    private func handleMovementInput() {
        if isMovingLeft {
            player.moveLeft()
        } else if isMovingRight {
            player.moveRight()
        } else {
            player.stopMoving()
        }
    }

    // MARK: - Physics Contact
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        let nodeA = contact.bodyA.node
        let nodeB = contact.bodyB.node

        // Player + Ground/Platform
        if collision == PhysicsCategory.player | PhysicsCategory.ground ||
           collision == PhysicsCategory.player | PhysicsCategory.platform {
            if contact.contactNormal.dy > 0.5 {
                player.landed()
            }
        }

        // Player + Enemy
        if collision == PhysicsCategory.player | PhysicsCategory.enemy {
            if !player.getIsInvulnerable() {
                player.takeDamage(1)
            }
        }

        // Player + Boss
        if collision == PhysicsCategory.player | PhysicsCategory.boss {
            if !player.getIsInvulnerable() {
                player.takeDamage(2)
            }
        }

        // Player + Collectible
        if collision == PhysicsCategory.player | PhysicsCategory.collectible {
            let collectibleNode = (nodeA?.name == "collectible" ? nodeA : nodeB) as? Collectible
            if let collectible = collectibleNode {
                handleCollectible(collectible)
            }
        }

        // Player + PowerUp
        if collision == PhysicsCategory.player | PhysicsCategory.powerUp {
            let powerUpNode = (nodeA?.name == "powerUp" ? nodeA : nodeB) as? PowerUp
            if let powerUp = powerUpNode {
                handlePowerUp(powerUp)
            }
        }

        // Player + Water
        if collision == PhysicsCategory.player | PhysicsCategory.water {
            player.enteredWater()
        }

        // Projectile + Enemy
        if collision == PhysicsCategory.projectile | PhysicsCategory.enemy {
            let enemyNode = (nodeA?.physicsBody?.categoryBitMask == PhysicsCategory.enemy ? nodeA : nodeB)
            if let enemy = enemyNode as? BaseEnemy {
                enemy.takeDamage(player.attackDamage)
            }
            // Remove fireball if hit
            let projectileNode = (nodeA?.physicsBody?.categoryBitMask == PhysicsCategory.projectile ? nodeA : nodeB)
            if projectileNode?.name == "playerAttack" {
                // Attack box is handled by PlayerCharacter
            }
        }

        // Projectile + Boss
        if collision == PhysicsCategory.projectile | PhysicsCategory.boss {
            if let tamatoa = boss as? TamataoBoss {
                tamatoa.takeDamage(player.attackDamage)
            } else if let teKa = boss as? TeKaBoss {
                teKa.takeDamage(player.attackDamage)
            }
        }

        // Player + Death pit
        if collision == PhysicsCategory.player | PhysicsCategory.boundary {
            let boundaryNode = nodeA?.name == "deathPit" ? nodeA : (nodeB?.name == "deathPit" ? nodeB : nil)
            if boundaryNode != nil {
                player.die()
            }
        }
    }

    func didEnd(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        // Player left ground
        if collision == PhysicsCategory.player | PhysicsCategory.ground ||
           collision == PhysicsCategory.player | PhysicsCategory.platform {
            player.leftGround()
        }

        // Player left water
        if collision == PhysicsCategory.player | PhysicsCategory.water {
            player.exitedWater()
        }
    }

    // MARK: - Collectible & PowerUp Handling
    private func handleCollectible(_ collectible: Collectible) {
        score += collectible.scoreValue
        hud.score = score

        switch collectible.type {
        case .seashell, .goldenSeashell:
            collectibleCount += 1
            hud.collectibleCount = collectibleCount
        case .heartPiece:
            player.heal(1)
        case .extraLife:
            // Extra life logic
            break
        case .starfish:
            break
        case .pearlOfWisdom:
            break
        }

        collectible.collect()
    }

    private func handlePowerUp(_ powerUp: PowerUp) {
        let powerUpName: String

        switch powerUp.type {
        case .mauiHook:
            powerUpName = "Maui's Hook!"
            player.attackDamage = 3
            scheduleRemovePowerUp(duration: powerUp.duration) { [weak self] in
                self?.player.attackDamage = 1
            }
        case .oceanBlessing:
            powerUpName = "Ocean Blessing!"
            player.canDoubleJump = true
        case .windSail:
            powerUpName = "Wind Sail!"
        case .teFitiHeart:
            powerUpName = "Heart of Te Fiti!"
            player.heal(3)
        case .coconutArmor:
            powerUpName = "Coconut Armor!"
        case .stingrayRide:
            powerUpName = "Stingray Ride!"
        }

        hud.showPowerUpNotification(powerUpName)
        powerUp.collect()
    }

    private func scheduleRemovePowerUp(duration: TimeInterval, removal: @escaping () -> Void) {
        let wait = SKAction.sequence([
            SKAction.wait(forDuration: duration),
            SKAction.run(removal)
        ])
        run(wait)
    }

    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: cameraNode)
            let hudLocation = CGPoint(x: location.x + size.width / 2,
                                       y: location.y + size.height / 2)

            // Check pause menu buttons first
            if hud.isPauseMenuShowing {
                handlePauseMenuTouch(location: touch.location(in: self))
                return
            }

            // Map touch to control
            if let controlName = hitTestControl(at: hudLocation) {
                activeTouches[touch] = controlName
                handleControlDown(controlName)
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Could implement joystick-style control here
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if let controlName = activeTouches[touch] {
                handleControlUp(controlName)
                activeTouches.removeValue(forKey: touch)
            }
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }

    private func hitTestControl(at point: CGPoint) -> String? {
        // Check HUD control areas
        let controls: [(name: String, center: CGPoint, radius: CGFloat)] = [
            ("control_left", CGPoint(x: 60, y: 60), 35),
            ("control_right", CGPoint(x: 140, y: 60), 35),
            ("control_jump", CGPoint(x: size.width - 70, y: 70), 40),
            ("control_attack", CGPoint(x: size.width - 150, y: 55), 35),
            ("control_dash", CGPoint(x: size.width - 140, y: 130), 30),
            ("control_pause", CGPoint(x: size.width - 40, y: size.height - 35), 25)
        ]

        for control in controls {
            let dist = hypot(point.x - control.center.x, point.y - control.center.y)
            if dist <= control.radius {
                return control.name
            }
        }

        return nil
    }

    private func handleControlDown(_ control: String) {
        switch control {
        case "control_left":
            isMovingLeft = true
            isMovingRight = false
        case "control_right":
            isMovingRight = true
            isMovingLeft = false
        case "control_jump":
            player.jump()
        case "control_attack":
            player.attack()
        case "control_dash":
            player.dash()
        case "control_pause":
            togglePause()
        default:
            break
        }
    }

    private func handleControlUp(_ control: String) {
        switch control {
        case "control_left":
            isMovingLeft = false
        case "control_right":
            isMovingRight = false
        default:
            break
        }
    }

    // MARK: - Pause
    private func togglePause() {
        if hud.isPauseMenuShowing {
            hud.dismissPauseMenu()
            isGamePaused = false
            self.isPaused = false
        } else {
            hud.showPauseMenu(in: self)
            isGamePaused = true
        }
    }

    private func handlePauseMenuTouch(location: CGPoint) {
        let touchedNodes = nodes(at: location)

        for node in touchedNodes {
            if let name = node.name ?? node.parent?.name {
                switch name {
                case "pause_resume", "pauseDimmer":
                    togglePause()
                case "pause_restart":
                    restartLevel()
                case "pause_menu":
                    transitionToMainMenu()
                default:
                    break
                }
            }
        }
    }

    // MARK: - Transitions
    private func restartLevel() {
        hud.dismissPauseMenu()
        let transition = SKTransition.fade(withDuration: 0.5)
        let newScene = GameScene(size: size)
        newScene.scaleMode = scaleMode
        newScene.currentLevel = currentLevel
        view?.presentScene(newScene, transition: transition)
    }

    private func transitionToMainMenu() {
        hud.dismissPauseMenu()
        let transition = SKTransition.fade(withDuration: 0.8)
        let menu = MainMenuScene(size: size)
        menu.scaleMode = scaleMode
        view?.presentScene(menu, transition: transition)
    }

    private func transitionToLevelComplete() {
        let transition = SKTransition.fade(withDuration: 0.8)
        let completeScene = LevelCompleteScene(size: size)
        completeScene.scaleMode = scaleMode
        completeScene.completedLevel = currentLevel
        completeScene.score = score
        completeScene.timeElapsed = gameTime
        completeScene.threeStarTime = levelConfig.threeStarTime
        view?.presentScene(completeScene, transition: transition)
    }

    private func transitionToGameOver() {
        let transition = SKTransition.fade(withDuration: 0.8)
        let gameOver = GameOverScene(size: size)
        gameOver.scaleMode = scaleMode
        gameOver.failedLevel = currentLevel
        gameOver.score = score
        view?.presentScene(gameOver, transition: transition)
    }

    // MARK: - Cleanup
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
