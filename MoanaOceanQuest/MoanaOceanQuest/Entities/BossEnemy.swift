import SpriteKit

// MARK: - Tamatoa Boss (Giant Crab)

class TamataoBoss: SKNode {

    var health: Int
    let maxHealth: Int
    let damage: Int = 2
    var isAlive: Bool { return health > 0 }
    var phase: Int = 1

    private var bodyNode: SKShapeNode!
    private var leftClaw: SKNode!
    private var rightClaw: SKNode!
    private var shellNode: SKShapeNode!
    private var eyeStalkLeft: SKNode!
    private var eyeStalkRight: SKNode!

    private var attackTimer: TimeInterval = 0
    private let attackInterval: TimeInterval = 2.5
    private var chargeTimer: TimeInterval = 0
    private var isCharging = false

    // Health bar
    private var healthBarBG: SKSpriteNode!
    private var healthBarFill: SKSpriteNode!

    init(health: Int = 15) {
        self.health = health
        self.maxHealth = health
        super.init()

        self.name = "boss_tamatoa"
        self.zPosition = 50

        buildVisuals()
        setupPhysics()
        buildHealthBar()
        startIdleAnimation()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func buildVisuals() {
        // Main shell body
        shellNode = SKShapeNode(ellipseOf: CGSize(width: 100, height: 80))
        shellNode.fillColor = SKColor(red: 0.5, green: 0.25, blue: 0.6, alpha: 1.0)
        shellNode.strokeColor = SKColor(red: 0.6, green: 0.3, blue: 0.7, alpha: 1.0)
        shellNode.lineWidth = 3
        shellNode.zPosition = 0.1
        addChild(shellNode)

        // Shell decorations (treasure/bling)
        let blingPositions: [(x: CGFloat, y: CGFloat, r: CGFloat)] = [
            (-15, 15, 5), (10, 20, 4), (25, 5, 3), (-25, -5, 4),
            (0, 25, 3), (15, -10, 5), (-20, 10, 3)
        ]
        for pos in blingPositions {
            let gem = SKShapeNode(circleOfRadius: pos.r)
            gem.fillColor = [
                SKColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0),
                SKColor(red: 0.2, green: 0.8, blue: 1.0, alpha: 1.0),
                SKColor(red: 1.0, green: 0.3, blue: 0.5, alpha: 1.0)
            ].randomElement()!
            gem.strokeColor = .clear
            gem.position = CGPoint(x: pos.x, y: pos.y)
            gem.zPosition = 0.2
            gem.glowWidth = 2.0
            shellNode.addChild(gem)
        }

        // Body/underbelly
        let belly = SKShapeNode(ellipseOf: CGSize(width: 70, height: 40))
        belly.fillColor = SKColor(red: 0.8, green: 0.55, blue: 0.35, alpha: 1.0)
        belly.strokeColor = .clear
        belly.position = CGPoint(x: 0, y: -35)
        belly.zPosition = 0.05
        addChild(belly)

        // Legs
        for i in 0..<6 {
            let side: CGFloat = i < 3 ? -1 : 1
            let index = i < 3 ? i : i - 3
            let leg = SKShapeNode(rectOf: CGSize(width: 6, height: 20), cornerRadius: 3)
            leg.fillColor = SKColor(red: 0.8, green: 0.55, blue: 0.35, alpha: 1.0)
            leg.strokeColor = .clear
            leg.position = CGPoint(x: side * (20 + CGFloat(index) * 12), y: -45)
            leg.zRotation = side * 0.3
            leg.zPosition = 0.02
            addChild(leg)
        }

        // Left claw
        leftClaw = buildClaw()
        leftClaw.position = CGPoint(x: -55, y: -15)
        leftClaw.xScale = -1
        addChild(leftClaw)

        // Right claw
        rightClaw = buildClaw()
        rightClaw.position = CGPoint(x: 55, y: -15)
        addChild(rightClaw)

        // Eye stalks
        eyeStalkLeft = buildEyeStalk()
        eyeStalkLeft.position = CGPoint(x: -15, y: 35)
        addChild(eyeStalkLeft)

        eyeStalkRight = buildEyeStalk()
        eyeStalkRight.position = CGPoint(x: 15, y: 35)
        addChild(eyeStalkRight)

        // Mouth
        let mouthPath = CGMutablePath()
        mouthPath.move(to: CGPoint(x: -12, y: -30))
        mouthPath.addQuadCurve(to: CGPoint(x: 12, y: -30), control: CGPoint(x: 0, y: -40))
        let mouth = SKShapeNode(path: mouthPath)
        mouth.strokeColor = SKColor(red: 0.3, green: 0.1, blue: 0.15, alpha: 1.0)
        mouth.lineWidth = 3
        mouth.zPosition = 0.3
        addChild(mouth)
    }

    private func buildClaw() -> SKNode {
        let claw = SKNode()

        let upperClaw = SKShapeNode()
        let upperPath = CGMutablePath()
        upperPath.move(to: CGPoint(x: 0, y: 0))
        upperPath.addLine(to: CGPoint(x: 20, y: 5))
        upperPath.addLine(to: CGPoint(x: 30, y: 12))
        upperPath.addLine(to: CGPoint(x: 25, y: 3))
        upperPath.addLine(to: CGPoint(x: 20, y: -2))
        upperPath.closeSubpath()
        upperClaw.path = upperPath
        upperClaw.fillColor = SKColor(red: 0.85, green: 0.5, blue: 0.3, alpha: 1.0)
        upperClaw.strokeColor = SKColor(red: 0.7, green: 0.4, blue: 0.2, alpha: 1.0)
        upperClaw.lineWidth = 2
        upperClaw.name = "upperClaw"
        claw.addChild(upperClaw)

        let lowerClaw = SKShapeNode()
        let lowerPath = CGMutablePath()
        lowerPath.move(to: CGPoint(x: 0, y: 0))
        lowerPath.addLine(to: CGPoint(x: 20, y: -2))
        lowerPath.addLine(to: CGPoint(x: 28, y: -10))
        lowerPath.addLine(to: CGPoint(x: 22, y: -5))
        lowerPath.addLine(to: CGPoint(x: 15, y: 0))
        lowerPath.closeSubpath()
        lowerClaw.path = lowerPath
        lowerClaw.fillColor = SKColor(red: 0.85, green: 0.5, blue: 0.3, alpha: 1.0)
        lowerClaw.strokeColor = SKColor(red: 0.7, green: 0.4, blue: 0.2, alpha: 1.0)
        lowerClaw.lineWidth = 2
        lowerClaw.name = "lowerClaw"
        claw.addChild(lowerClaw)

        return claw
    }

    private func buildEyeStalk() -> SKNode {
        let stalk = SKNode()

        let stalkLine = SKShapeNode(rectOf: CGSize(width: 4, height: 20))
        stalkLine.fillColor = SKColor(red: 0.8, green: 0.55, blue: 0.35, alpha: 1.0)
        stalkLine.strokeColor = .clear
        stalkLine.position = CGPoint(x: 0, y: 10)
        stalk.addChild(stalkLine)

        let eye = SKShapeNode(circleOfRadius: 6)
        eye.fillColor = SKColor(red: 0.9, green: 0.9, blue: 0.1, alpha: 1.0)
        eye.strokeColor = .clear
        eye.position = CGPoint(x: 0, y: 22)
        stalk.addChild(eye)

        let pupil = SKShapeNode(circleOfRadius: 3)
        pupil.fillColor = .black
        pupil.strokeColor = .clear
        pupil.zPosition = 0.1
        eye.addChild(pupil)

        return stalk
    }

    private func setupPhysics() {
        let body = SKPhysicsBody(rectangleOf: CGSize(width: 90, height: 70))
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.boss
        body.contactTestBitMask = PhysicsCategory.player | PhysicsCategory.projectile
        body.collisionBitMask = PhysicsCategory.ground
        self.physicsBody = body
    }

    private func buildHealthBar() {
        let barWidth: CGFloat = 100
        let barHeight: CGFloat = 8

        healthBarBG = SKSpriteNode(color: SKColor(red: 0.3, green: 0.0, blue: 0.0, alpha: 0.8),
                                    size: CGSize(width: barWidth, height: barHeight))
        healthBarBG.position = CGPoint(x: 0, y: 55)
        healthBarBG.zPosition = 10
        addChild(healthBarBG)

        healthBarFill = SKSpriteNode(color: SKColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 1.0),
                                      size: CGSize(width: barWidth, height: barHeight))
        healthBarFill.anchorPoint = CGPoint(x: 0, y: 0.5)
        healthBarFill.position = CGPoint(x: -barWidth / 2, y: 55)
        healthBarFill.zPosition = 11
        addChild(healthBarFill)
    }

    private func updateHealthBar() {
        let barWidth: CGFloat = 100
        let healthPercent = CGFloat(health) / CGFloat(maxHealth)
        healthBarFill.size.width = barWidth * healthPercent

        if healthPercent > 0.5 {
            healthBarFill.color = SKColor(red: 0.2, green: 0.9, blue: 0.2, alpha: 1.0)
        } else if healthPercent > 0.25 {
            healthBarFill.color = SKColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0)
        } else {
            healthBarFill.color = SKColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 1.0)
        }
    }

    private func startIdleAnimation() {
        // Eye stalk sway
        let swayLeft = SKAction.repeatForever(SKAction.sequence([
            SKAction.rotate(toAngle: 0.2, duration: 1.0),
            SKAction.rotate(toAngle: -0.2, duration: 1.0)
        ]))
        eyeStalkLeft.run(swayLeft)

        let swayRight = SKAction.repeatForever(SKAction.sequence([
            SKAction.rotate(toAngle: -0.15, duration: 1.2),
            SKAction.rotate(toAngle: 0.15, duration: 1.2)
        ]))
        eyeStalkRight.run(swayRight)

        // Body bob
        let bob = SKAction.repeatForever(SKAction.sequence([
            SKAction.moveBy(x: 0, y: 3, duration: 1.5),
            SKAction.moveBy(x: 0, y: -3, duration: 1.5)
        ]))
        run(bob, withKey: "idle")
    }

    func takeDamage(_ amount: Int) {
        guard isAlive else { return }

        health -= amount
        updateHealthBar()

        // Flash
        let flash = SKAction.sequence([
            SKAction.colorize(with: .white, colorBlendFactor: 0.8, duration: 0.05),
            SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.1)
        ])
        shellNode.run(flash)

        // Phase transition at 50% health
        if health <= maxHealth / 2 && phase == 1 {
            phase = 2
            enterPhaseTwo()
        }

        if health <= 0 {
            die()
        }
    }

    private func enterPhaseTwo() {
        // Shell turns red-orange, becomes more aggressive
        let colorChange = SKAction.colorize(with: SKColor(red: 0.8, green: 0.2, blue: 0.3, alpha: 1.0),
                                             colorBlendFactor: 0.5, duration: 0.5)
        shellNode.run(colorChange)

        // Faster attacks
        let shake = SKAction.sequence([
            SKAction.moveBy(x: -5, y: 0, duration: 0.05),
            SKAction.moveBy(x: 10, y: 0, duration: 0.05),
            SKAction.moveBy(x: -10, y: 0, duration: 0.05),
            SKAction.moveBy(x: 5, y: 0, duration: 0.05)
        ])
        run(SKAction.repeat(shake, count: 4))
    }

    func update(deltaTime: TimeInterval, playerPosition: CGPoint) {
        guard isAlive else { return }

        attackTimer += deltaTime
        let interval = phase == 1 ? attackInterval : attackInterval * 0.6

        if attackTimer >= interval {
            attackTimer = 0
            performAttack(toward: playerPosition)
        }

        // Face player
        let direction: CGFloat = playerPosition.x > position.x ? 1 : -1
        xScale = direction > 0 ? abs(xScale) : -abs(xScale)
    }

    private func performAttack(toward target: CGPoint) {
        let dist = hypot(target.x - position.x, target.y - position.y)

        if dist < 120 {
            // Claw snap attack
            clawAttack()
        } else {
            // Charge toward player
            chargeAttack(toward: target)
        }
    }

    private func clawAttack() {
        let snap = SKAction.sequence([
            SKAction.rotate(toAngle: -0.5, duration: 0.1),
            SKAction.rotate(toAngle: 0.3, duration: 0.05),
            SKAction.rotate(toAngle: 0, duration: 0.2)
        ])

        let side = Bool.random() ? leftClaw : rightClaw
        side?.run(snap)
    }

    private func chargeAttack(toward target: CGPoint) {
        guard !isCharging else { return }
        isCharging = true

        let direction: CGFloat = target.x > position.x ? 1 : -1
        let chargeDistance: CGFloat = 150

        let charge = SKAction.sequence([
            SKAction.moveBy(x: -direction * 20, y: 0, duration: 0.3),
            SKAction.moveBy(x: direction * (chargeDistance + 20), y: 0, duration: 0.4),
            SKAction.wait(forDuration: 0.5),
            SKAction.run { [weak self] in self?.isCharging = false }
        ])
        run(charge, withKey: "charge")
    }

    func die() {
        health = 0
        physicsBody?.categoryBitMask = PhysicsCategory.none

        createDeathEffect()

        let deathSequence = SKAction.sequence([
            SKAction.group([
                SKAction.fadeOut(duration: 1.0),
                SKAction.scale(to: 0.3, duration: 1.0)
            ]),
            SKAction.run {
                NotificationCenter.default.post(name: .levelComplete, object: nil)
            },
            SKAction.removeFromParent()
        ])
        run(deathSequence)
    }

    private func createDeathEffect() {
        guard let parent = self.parent else { return }
        // Treasure explosion
        for _ in 0..<20 {
            let gem = SKShapeNode(circleOfRadius: CGFloat.random(in: 3...7))
            gem.fillColor = [
                SKColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0),
                SKColor(red: 0.2, green: 0.8, blue: 1.0, alpha: 1.0),
                SKColor(red: 1.0, green: 0.3, blue: 0.5, alpha: 1.0)
            ].randomElement()!
            gem.strokeColor = .clear
            gem.glowWidth = 2.0
            gem.position = self.position
            gem.zPosition = 60
            parent.addChild(gem)

            let move = SKAction.moveBy(x: CGFloat.random(in: -100...100),
                                        y: CGFloat.random(in: -50...100),
                                        duration: 1.0)
            let fade = SKAction.fadeOut(duration: 1.2)
            gem.run(SKAction.sequence([
                SKAction.group([move, fade]),
                SKAction.removeFromParent()
            ]))
        }
    }
}

// MARK: - Te Ka Boss (Lava Demon)

class TeKaBoss: SKNode {

    var health: Int
    let maxHealth: Int
    let damage: Int = 3
    var isAlive: Bool { return health > 0 }
    var phase: Int = 1

    private var bodyNode: SKShapeNode!
    private var lavaGlow: SKShapeNode!
    private var attackTimer: TimeInterval = 0
    private let attackInterval: TimeInterval = 2.0
    private var fireballTimer: TimeInterval = 0

    private var healthBarBG: SKSpriteNode!
    private var healthBarFill: SKSpriteNode!

    init(health: Int = 20) {
        self.health = health
        self.maxHealth = health
        super.init()

        self.name = "boss_teka"
        self.zPosition = 50

        buildVisuals()
        setupPhysics()
        buildHealthBar()
        startAmbientAnimation()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func buildVisuals() {
        // Massive lava body
        bodyNode = SKShapeNode(rectOf: CGSize(width: 80, height: 120), cornerRadius: 10)
        bodyNode.fillColor = SKColor(red: 0.2, green: 0.08, blue: 0.02, alpha: 1.0)
        bodyNode.strokeColor = SKColor(red: 1.0, green: 0.4, blue: 0.0, alpha: 0.8)
        bodyNode.lineWidth = 3
        bodyNode.zPosition = 0.1
        addChild(bodyNode)

        // Lava glow overlay
        lavaGlow = SKShapeNode(rectOf: CGSize(width: 70, height: 110), cornerRadius: 8)
        lavaGlow.fillColor = SKColor(red: 1.0, green: 0.3, blue: 0.0, alpha: 0.25)
        lavaGlow.strokeColor = .clear
        lavaGlow.zPosition = 0.15
        addChild(lavaGlow)

        // Lava cracks
        for i in 0..<5 {
            let crack = SKShapeNode()
            let path = CGMutablePath()
            let startY = CGFloat.random(in: -50...50)
            path.move(to: CGPoint(x: CGFloat.random(in: -30...30), y: startY))
            path.addLine(to: CGPoint(x: CGFloat.random(in: -30...30), y: startY + CGFloat.random(in: 10...30)))
            crack.path = path
            crack.strokeColor = SKColor(red: 1.0, green: CGFloat.random(in: 0.4...0.7), blue: 0.0, alpha: 0.8)
            crack.lineWidth = 2.0
            crack.glowWidth = 3.0
            crack.zPosition = 0.2
            addChild(crack)
            _ = i
        }

        // Eyes - menacing orange
        let leftEye = SKShapeNode(circleOfRadius: 8)
        leftEye.fillColor = SKColor(red: 1.0, green: 0.7, blue: 0.0, alpha: 1.0)
        leftEye.strokeColor = .clear
        leftEye.position = CGPoint(x: -15, y: 30)
        leftEye.zPosition = 0.3
        leftEye.glowWidth = 5.0
        addChild(leftEye)

        let rightEye = SKShapeNode(circleOfRadius: 8)
        rightEye.fillColor = SKColor(red: 1.0, green: 0.7, blue: 0.0, alpha: 1.0)
        rightEye.strokeColor = .clear
        rightEye.position = CGPoint(x: 15, y: 30)
        rightEye.zPosition = 0.3
        rightEye.glowWidth = 5.0
        addChild(rightEye)

        // Mouth - jagged lava maw
        let mouthPath = CGMutablePath()
        mouthPath.move(to: CGPoint(x: -20, y: 10))
        mouthPath.addLine(to: CGPoint(x: -12, y: 5))
        mouthPath.addLine(to: CGPoint(x: -5, y: 10))
        mouthPath.addLine(to: CGPoint(x: 0, y: 2))
        mouthPath.addLine(to: CGPoint(x: 5, y: 10))
        mouthPath.addLine(to: CGPoint(x: 12, y: 5))
        mouthPath.addLine(to: CGPoint(x: 20, y: 10))
        let mouth = SKShapeNode(path: mouthPath)
        mouth.strokeColor = SKColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0)
        mouth.fillColor = SKColor(red: 1.0, green: 0.3, blue: 0.0, alpha: 0.6)
        mouth.lineWidth = 2
        mouth.zPosition = 0.3
        addChild(mouth)

        // Arms - molten rock
        let leftArm = SKShapeNode(rectOf: CGSize(width: 20, height: 50), cornerRadius: 5)
        leftArm.fillColor = SKColor(red: 0.25, green: 0.1, blue: 0.03, alpha: 1.0)
        leftArm.strokeColor = SKColor(red: 1.0, green: 0.4, blue: 0.0, alpha: 0.6)
        leftArm.lineWidth = 2
        leftArm.position = CGPoint(x: -50, y: 0)
        leftArm.zPosition = 0.05
        addChild(leftArm)

        let rightArm = SKShapeNode(rectOf: CGSize(width: 20, height: 50), cornerRadius: 5)
        rightArm.fillColor = SKColor(red: 0.25, green: 0.1, blue: 0.03, alpha: 1.0)
        rightArm.strokeColor = SKColor(red: 1.0, green: 0.4, blue: 0.0, alpha: 0.6)
        rightArm.lineWidth = 2
        rightArm.position = CGPoint(x: 50, y: 0)
        rightArm.zPosition = 0.05
        addChild(rightArm)
    }

    private func setupPhysics() {
        let body = SKPhysicsBody(rectangleOf: CGSize(width: 70, height: 110))
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.boss
        body.contactTestBitMask = PhysicsCategory.player | PhysicsCategory.projectile
        body.collisionBitMask = PhysicsCategory.ground
        self.physicsBody = body
    }

    private func buildHealthBar() {
        let barWidth: CGFloat = 120
        let barHeight: CGFloat = 10

        healthBarBG = SKSpriteNode(color: SKColor(red: 0.3, green: 0.0, blue: 0.0, alpha: 0.8),
                                    size: CGSize(width: barWidth, height: barHeight))
        healthBarBG.position = CGPoint(x: 0, y: 80)
        healthBarBG.zPosition = 10
        addChild(healthBarBG)

        healthBarFill = SKSpriteNode(color: SKColor(red: 1.0, green: 0.3, blue: 0.0, alpha: 1.0),
                                      size: CGSize(width: barWidth, height: barHeight))
        healthBarFill.anchorPoint = CGPoint(x: 0, y: 0.5)
        healthBarFill.position = CGPoint(x: -barWidth / 2, y: 80)
        healthBarFill.zPosition = 11
        addChild(healthBarFill)
    }

    private func updateHealthBar() {
        let barWidth: CGFloat = 120
        let healthPercent = CGFloat(health) / CGFloat(maxHealth)
        healthBarFill.size.width = barWidth * healthPercent
    }

    private func startAmbientAnimation() {
        let pulse = SKAction.repeatForever(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.4, duration: 0.8),
            SKAction.fadeAlpha(to: 0.2, duration: 0.8)
        ]))
        lavaGlow.run(pulse)
    }

    func takeDamage(_ amount: Int) {
        guard isAlive else { return }

        health -= amount
        updateHealthBar()

        let flash = SKAction.sequence([
            SKAction.colorize(with: .white, colorBlendFactor: 0.5, duration: 0.05),
            SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.15)
        ])
        bodyNode.run(flash)

        if health <= maxHealth / 2 && phase == 1 {
            phase = 2
        }

        if health <= 0 {
            die()
        }
    }

    func update(deltaTime: TimeInterval, playerPosition: CGPoint) {
        guard isAlive else { return }

        attackTimer += deltaTime
        let interval = phase == 1 ? attackInterval : attackInterval * 0.5

        if attackTimer >= interval {
            attackTimer = 0
            shootFireball(toward: playerPosition)
        }

        // Spawn fire particles
        fireballTimer += deltaTime
        if fireballTimer >= 0.2 {
            fireballTimer = 0
            spawnFireParticle()
        }
    }

    private func shootFireball(toward target: CGPoint) {
        guard let parent = self.parent else { return }

        let fireball = SKShapeNode(circleOfRadius: 12)
        fireball.fillColor = SKColor(red: 1.0, green: 0.4, blue: 0.0, alpha: 1.0)
        fireball.strokeColor = SKColor(red: 1.0, green: 0.7, blue: 0.0, alpha: 0.8)
        fireball.lineWidth = 2
        fireball.glowWidth = 6.0
        fireball.name = "bossFireball"
        fireball.position = self.position
        fireball.zPosition = 55

        let fireballBody = SKPhysicsBody(circleOfRadius: 12)
        fireballBody.isDynamic = true
        fireballBody.affectedByGravity = false
        fireballBody.categoryBitMask = PhysicsCategory.enemy
        fireballBody.contactTestBitMask = PhysicsCategory.player | PhysicsCategory.ground
        fireballBody.collisionBitMask = PhysicsCategory.none
        fireball.physicsBody = fireballBody

        parent.addChild(fireball)

        let dx = target.x - position.x
        let dy = target.y - position.y
        let distance = hypot(dx, dy)
        let speed: CGFloat = phase == 1 ? 180 : 250
        fireball.physicsBody?.velocity = CGVector(dx: (dx / distance) * speed,
                                                    dy: (dy / distance) * speed)

        fireball.run(SKAction.sequence([
            SKAction.wait(forDuration: 4.0),
            SKAction.fadeOut(duration: 0.2),
            SKAction.removeFromParent()
        ]))
    }

    private func spawnFireParticle() {
        guard let parent = self.parent else { return }

        let particle = SKShapeNode(circleOfRadius: CGFloat.random(in: 3...6))
        particle.fillColor = SKColor(red: 1.0, green: CGFloat.random(in: 0.3...0.7), blue: 0.0, alpha: 0.8)
        particle.strokeColor = .clear
        particle.position = CGPoint(x: position.x + CGFloat.random(in: -30...30),
                                     y: position.y + 55)
        particle.zPosition = 52
        parent.addChild(particle)

        let rise = SKAction.moveBy(x: CGFloat.random(in: -10...10), y: CGFloat.random(in: 20...50), duration: 0.6)
        let fade = SKAction.fadeOut(duration: 0.6)
        particle.run(SKAction.sequence([
            SKAction.group([rise, fade]),
            SKAction.removeFromParent()
        ]))
    }

    func die() {
        health = 0
        physicsBody?.categoryBitMask = PhysicsCategory.none

        guard let parent = self.parent else { return }

        // Massive lava explosion
        for _ in 0..<30 {
            let particle = SKShapeNode(circleOfRadius: CGFloat.random(in: 4...10))
            particle.fillColor = [
                SKColor(red: 1.0, green: 0.3, blue: 0.0, alpha: 0.9),
                SKColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 0.9),
                SKColor(red: 0.8, green: 0.1, blue: 0.0, alpha: 0.9)
            ].randomElement()!
            particle.strokeColor = .clear
            particle.position = self.position
            particle.zPosition = 60
            parent.addChild(particle)

            let move = SKAction.moveBy(x: CGFloat.random(in: -120...120),
                                        y: CGFloat.random(in: -60...120),
                                        duration: 1.0)
            let fade = SKAction.fadeOut(duration: 1.2)
            particle.run(SKAction.sequence([
                SKAction.group([move, fade]),
                SKAction.removeFromParent()
            ]))
        }

        let deathSequence = SKAction.sequence([
            SKAction.group([
                SKAction.fadeOut(duration: 1.5),
                SKAction.scale(to: 0.2, duration: 1.5)
            ]),
            SKAction.run {
                NotificationCenter.default.post(name: .levelComplete, object: nil)
            },
            SKAction.removeFromParent()
        ])
        run(deathSequence)
    }
}
