import SpriteKit

// MARK: - Base Enemy Protocol

protocol Enemy: AnyObject {
    var health: Int { get set }
    var maxHealth: Int { get }
    var damage: Int { get }
    var scoreValue: Int { get }
    var isAlive: Bool { get }
    func takeDamage(_ amount: Int)
    func update(deltaTime: TimeInterval, playerPosition: CGPoint)
    func die()
}

// MARK: - Enemy State

enum EnemyState {
    case idle
    case patrolling
    case chasing
    case attacking
    case hurt
    case dead
}

// MARK: - Base Enemy Node

class BaseEnemy: SKSpriteNode, Enemy {

    var health: Int
    let maxHealth: Int
    let damage: Int
    let scoreValue: Int
    var enemyState: EnemyState = .patrolling
    var isAlive: Bool { return health > 0 }

    // Patrol
    var patrolDirection: CGFloat = 1.0
    var patrolDistance: CGFloat = 150.0
    var patrolSpeed: CGFloat = 80.0
    private var patrolOriginX: CGFloat = 0
    private var distanceTraveled: CGFloat = 0

    // Detection
    var detectionRange: CGFloat = 250.0
    var attackRange: CGFloat = 60.0

    // Visual
    var healthBarBackground: SKSpriteNode?
    var healthBarFill: SKSpriteNode?

    init(health: Int, damage: Int, scoreValue: Int, size: CGSize) {
        self.health = health
        self.maxHealth = health
        self.damage = damage
        self.scoreValue = scoreValue
        super.init(texture: nil, color: .clear, size: size)
        self.zPosition = 50
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupPhysics(bodySize: CGSize) {
        physicsBody = SKPhysicsBody(rectangleOf: bodySize)
        physicsBody?.isDynamic = true
        physicsBody?.allowsRotation = false
        physicsBody?.friction = 0.3
        physicsBody?.restitution = 0.0
        physicsBody?.mass = 0.5
        physicsBody?.categoryBitMask = PhysicsCategory.enemy
        physicsBody?.contactTestBitMask = PhysicsCategory.player | PhysicsCategory.projectile
        physicsBody?.collisionBitMask = PhysicsCategory.ground | PhysicsCategory.boundary | PhysicsCategory.platform
    }

    func setupHealthBar() {
        let barWidth: CGFloat = size.width * 0.8
        let barHeight: CGFloat = 4

        healthBarBackground = SKSpriteNode(color: SKColor(red: 0.3, green: 0.0, blue: 0.0, alpha: 0.8),
                                            size: CGSize(width: barWidth, height: barHeight))
        healthBarBackground?.position = CGPoint(x: 0, y: size.height / 2 + 6)
        healthBarBackground?.zPosition = 2
        addChild(healthBarBackground!)

        healthBarFill = SKSpriteNode(color: SKColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 1.0),
                                      size: CGSize(width: barWidth, height: barHeight))
        healthBarFill?.anchorPoint = CGPoint(x: 0, y: 0.5)
        healthBarFill?.position = CGPoint(x: -barWidth / 2, y: size.height / 2 + 6)
        healthBarFill?.zPosition = 3
        addChild(healthBarFill!)
    }

    func updateHealthBar() {
        let barWidth = size.width * 0.8
        let healthPercent = CGFloat(health) / CGFloat(maxHealth)
        healthBarFill?.size.width = barWidth * healthPercent

        if healthPercent > 0.5 {
            healthBarFill?.color = SKColor(red: 0.2, green: 0.9, blue: 0.2, alpha: 1.0)
        } else if healthPercent > 0.25 {
            healthBarFill?.color = SKColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0)
        } else {
            healthBarFill?.color = SKColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 1.0)
        }
    }

    func takeDamage(_ amount: Int) {
        guard isAlive && enemyState != .dead else { return }

        health -= amount
        updateHealthBar()

        // Flash red
        let flashRed = SKAction.sequence([
            SKAction.colorize(with: .red, colorBlendFactor: 0.8, duration: 0.05),
            SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.1)
        ])
        run(flashRed)

        // Hurt knockback
        let knockDirection: CGFloat = patrolDirection > 0 ? -1 : 1
        physicsBody?.applyImpulse(CGVector(dx: knockDirection * 30, dy: 20))

        if health <= 0 {
            die()
        } else {
            enemyState = .hurt
            let recoverAction = SKAction.sequence([
                SKAction.wait(forDuration: 0.3),
                SKAction.run { [weak self] in
                    if self?.enemyState == .hurt {
                        self?.enemyState = .patrolling
                    }
                }
            ])
            run(recoverAction, withKey: "recover")
        }
    }

    func die() {
        enemyState = .dead
        health = 0
        physicsBody?.categoryBitMask = PhysicsCategory.none
        physicsBody?.contactTestBitMask = PhysicsCategory.none
        physicsBody?.collisionBitMask = PhysicsCategory.none
        physicsBody?.isDynamic = false

        createDeathEffect()

        let deathSequence = SKAction.sequence([
            SKAction.group([
                SKAction.fadeOut(duration: 0.5),
                SKAction.scale(to: 0.1, duration: 0.5),
                SKAction.rotate(byAngle: .pi * 2, duration: 0.5)
            ]),
            SKAction.removeFromParent()
        ])
        run(deathSequence)

        NotificationCenter.default.post(name: .enemyDefeated,
                                        object: self,
                                        userInfo: ["score": scoreValue])
    }

    func createDeathEffect() {
        guard let parent = self.parent else { return }
        for _ in 0..<8 {
            let particle = SKShapeNode(circleOfRadius: CGFloat.random(in: 3...6))
            particle.fillColor = SKColor(red: 1.0, green: 0.9, blue: 0.3, alpha: 0.9)
            particle.strokeColor = .clear
            particle.position = self.position
            particle.zPosition = 60
            parent.addChild(particle)

            let moveAction = SKAction.moveBy(x: CGFloat.random(in: -40...40),
                                              y: CGFloat.random(in: -20...50),
                                              duration: 0.6)
            let fadeAction = SKAction.fadeOut(duration: 0.6)
            particle.run(SKAction.sequence([
                SKAction.group([moveAction, fadeAction]),
                SKAction.removeFromParent()
            ]))
        }
    }

    func patrol(deltaTime: TimeInterval) {
        let movement = patrolSpeed * patrolDirection * CGFloat(deltaTime)
        position.x += movement
        distanceTraveled += abs(movement)

        if distanceTraveled >= patrolDistance {
            patrolDirection *= -1
            distanceTraveled = 0
            xScale = patrolDirection > 0 ? abs(xScale) : -abs(xScale)
        }
    }

    func chasePlayer(playerPosition: CGPoint, deltaTime: TimeInterval) {
        let direction: CGFloat = playerPosition.x > position.x ? 1 : -1
        position.x += patrolSpeed * 1.5 * direction * CGFloat(deltaTime)
        xScale = direction > 0 ? abs(xScale) : -abs(xScale)
    }

    func distanceTo(point: CGPoint) -> CGFloat {
        return hypot(point.x - position.x, point.y - position.y)
    }

    func update(deltaTime: TimeInterval, playerPosition: CGPoint) {
        guard isAlive && enemyState != .dead && enemyState != .hurt else { return }

        let dist = distanceTo(point: playerPosition)

        if dist < attackRange {
            enemyState = .attacking
        } else if dist < detectionRange {
            enemyState = .chasing
            chasePlayer(playerPosition: playerPosition, deltaTime: deltaTime)
        } else {
            enemyState = .patrolling
            patrol(deltaTime: deltaTime)
        }
    }
}

// MARK: - Kakamora Enemy (Small Coconut Pirates)

class KakamoraEnemy: BaseEnemy {

    private var bodyNode: SKShapeNode!
    private var leftEye: SKShapeNode!
    private var rightEye: SKShapeNode!
    private var warPaint: SKShapeNode!

    init() {
        super.init(health: 2, damage: 1, scoreValue: 100, size: CGSize(width: 24, height: 28))
        self.name = "kakamora"
        self.patrolSpeed = 100
        self.patrolDistance = 120
        self.detectionRange = 180
        self.attackRange = 30

        setupPhysics(bodySize: CGSize(width: 20, height: 24))
        physicsBody?.mass = 0.2
        buildVisuals()
        setupHealthBar()
        startIdleAnimation()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func buildVisuals() {
        // Coconut body (brown circle)
        bodyNode = SKShapeNode(circleOfRadius: 12)
        bodyNode.fillColor = SKColor(red: 0.45, green: 0.28, blue: 0.15, alpha: 1.0)
        bodyNode.strokeColor = SKColor(red: 0.35, green: 0.2, blue: 0.1, alpha: 1.0)
        bodyNode.lineWidth = 1.5
        bodyNode.position = .zero
        bodyNode.zPosition = 0.1
        addChild(bodyNode)

        // Coconut texture lines
        let line1 = SKShapeNode()
        let path1 = CGMutablePath()
        path1.move(to: CGPoint(x: -8, y: -5))
        path1.addQuadCurve(to: CGPoint(x: 8, y: -5), control: CGPoint(x: 0, y: 3))
        line1.path = path1
        line1.strokeColor = SKColor(red: 0.35, green: 0.2, blue: 0.1, alpha: 0.6)
        line1.lineWidth = 1.0
        line1.zPosition = 0.2
        addChild(line1)

        // War paint (red tribal marks)
        warPaint = SKShapeNode(rectOf: CGSize(width: 18, height: 3))
        warPaint.fillColor = SKColor(red: 0.9, green: 0.15, blue: 0.1, alpha: 1.0)
        warPaint.strokeColor = .clear
        warPaint.position = CGPoint(x: 0, y: 2)
        warPaint.zPosition = 0.3
        addChild(warPaint)

        // Eyes - menacing white dots with dark pupils
        leftEye = SKShapeNode(circleOfRadius: 3)
        leftEye.fillColor = .white
        leftEye.strokeColor = .clear
        leftEye.position = CGPoint(x: -4, y: 4)
        leftEye.zPosition = 0.4
        addChild(leftEye)

        let leftPupil = SKShapeNode(circleOfRadius: 1.5)
        leftPupil.fillColor = SKColor(red: 0.1, green: 0.05, blue: 0.0, alpha: 1.0)
        leftPupil.strokeColor = .clear
        leftPupil.position = CGPoint(x: 1, y: 0)
        leftPupil.zPosition = 0.1
        leftEye.addChild(leftPupil)

        rightEye = SKShapeNode(circleOfRadius: 3)
        rightEye.fillColor = .white
        rightEye.strokeColor = .clear
        rightEye.position = CGPoint(x: 4, y: 4)
        rightEye.zPosition = 0.4
        addChild(rightEye)

        let rightPupil = SKShapeNode(circleOfRadius: 1.5)
        rightPupil.fillColor = SKColor(red: 0.1, green: 0.05, blue: 0.0, alpha: 1.0)
        rightPupil.strokeColor = .clear
        rightPupil.position = CGPoint(x: 1, y: 0)
        rightPupil.zPosition = 0.1
        rightEye.addChild(rightPupil)

        // Angry mouth
        let mouth = SKShapeNode()
        let mouthPath = CGMutablePath()
        mouthPath.move(to: CGPoint(x: -3, y: -3))
        mouthPath.addLine(to: CGPoint(x: 0, y: -5))
        mouthPath.addLine(to: CGPoint(x: 3, y: -3))
        mouth.path = mouthPath
        mouth.strokeColor = SKColor(red: 0.1, green: 0.05, blue: 0.0, alpha: 1.0)
        mouth.lineWidth = 1.5
        mouth.zPosition = 0.4
        addChild(mouth)

        // Tiny legs
        let leftLeg = SKSpriteNode(color: SKColor(red: 0.45, green: 0.28, blue: 0.15, alpha: 1.0),
                                    size: CGSize(width: 4, height: 6))
        leftLeg.position = CGPoint(x: -5, y: -14)
        leftLeg.zPosition = 0.05
        addChild(leftLeg)

        let rightLeg = SKSpriteNode(color: SKColor(red: 0.45, green: 0.28, blue: 0.15, alpha: 1.0),
                                     size: CGSize(width: 4, height: 6))
        rightLeg.position = CGPoint(x: 5, y: -14)
        rightLeg.zPosition = 0.05
        addChild(rightLeg)

        // Tiny spear in hand
        let spear = SKSpriteNode(color: SKColor(red: 0.6, green: 0.5, blue: 0.3, alpha: 1.0),
                                  size: CGSize(width: 2, height: 20))
        spear.position = CGPoint(x: 10, y: 2)
        spear.zRotation = -0.3
        spear.zPosition = 0.3
        addChild(spear)

        let spearTip = SKShapeNode(circleOfRadius: 2)
        spearTip.fillColor = SKColor(red: 0.6, green: 0.6, blue: 0.65, alpha: 1.0)
        spearTip.strokeColor = .clear
        spearTip.position = CGPoint(x: 0, y: 10)
        spearTip.zPosition = 0.1
        spear.addChild(spearTip)
    }

    private func startIdleAnimation() {
        let bounce = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 2, duration: 0.2),
            SKAction.moveBy(x: 0, y: -2, duration: 0.2)
        ])
        bodyNode.run(SKAction.repeatForever(bounce), withKey: "idle")
    }

    override func update(deltaTime: TimeInterval, playerPosition: CGPoint) {
        super.update(deltaTime: deltaTime, playerPosition: playerPosition)

        if enemyState == .attacking {
            // Kakamora hop attack
            if action(forKey: "hopAttack") == nil {
                let hopAttack = SKAction.sequence([
                    SKAction.moveBy(x: patrolDirection * 30, y: 15, duration: 0.2),
                    SKAction.moveBy(x: 0, y: -15, duration: 0.15),
                    SKAction.wait(forDuration: 0.5)
                ])
                run(hopAttack, withKey: "hopAttack")
            }
        }
    }

    /// Spawns a group of Kakamora enemies in formation
    static func spawnGroup(count: Int, at position: CGPoint, spacing: CGFloat = 30) -> [KakamoraEnemy] {
        var group: [KakamoraEnemy] = []
        for i in 0..<count {
            let enemy = KakamoraEnemy()
            enemy.position = CGPoint(x: position.x + CGFloat(i) * spacing, y: position.y)
            group.append(enemy)
        }
        return group
    }
}

// MARK: - Lava Monster (Fire-based enemy)

class LavaMonster: BaseEnemy {

    private var bodyNode: SKShapeNode!
    private var glowNode: SKShapeNode!
    private var fireParticleTimer: TimeInterval = 0
    private let fireParticleInterval: TimeInterval = 0.15
    private var attackTimer: TimeInterval = 0
    private let attackInterval: TimeInterval = 2.5

    init() {
        super.init(health: 4, damage: 2, scoreValue: 300, size: CGSize(width: 40, height: 48))
        self.name = "lavaMonster"
        self.patrolSpeed = 50
        self.patrolDistance = 100
        self.detectionRange = 300
        self.attackRange = 250 // Ranged attacker

        setupPhysics(bodySize: CGSize(width: 34, height: 44))
        physicsBody?.mass = 1.0
        buildVisuals()
        setupHealthBar()
        startAmbientAnimation()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func buildVisuals() {
        // Lava body (dark rock with glowing cracks)
        bodyNode = SKShapeNode(rectOf: CGSize(width: 36, height: 44), cornerRadius: 6)
        bodyNode.fillColor = SKColor(red: 0.25, green: 0.1, blue: 0.05, alpha: 1.0)
        bodyNode.strokeColor = SKColor(red: 1.0, green: 0.4, blue: 0.0, alpha: 0.8)
        bodyNode.lineWidth = 2.0
        bodyNode.zPosition = 0.1
        addChild(bodyNode)

        // Lava glow
        glowNode = SKShapeNode(rectOf: CGSize(width: 30, height: 38), cornerRadius: 4)
        glowNode.fillColor = SKColor(red: 1.0, green: 0.3, blue: 0.0, alpha: 0.3)
        glowNode.strokeColor = .clear
        glowNode.zPosition = 0.05
        addChild(glowNode)

        // Lava cracks - vertical
        let crack1 = SKShapeNode()
        let crackPath1 = CGMutablePath()
        crackPath1.move(to: CGPoint(x: -5, y: -18))
        crackPath1.addLine(to: CGPoint(x: -3, y: -8))
        crackPath1.addLine(to: CGPoint(x: -7, y: 0))
        crackPath1.addLine(to: CGPoint(x: -4, y: 10))
        crackPath1.addLine(to: CGPoint(x: -6, y: 18))
        crack1.path = crackPath1
        crack1.strokeColor = SKColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 0.9)
        crack1.lineWidth = 2.0
        crack1.glowWidth = 3.0
        crack1.zPosition = 0.2
        addChild(crack1)

        let crack2 = SKShapeNode()
        let crackPath2 = CGMutablePath()
        crackPath2.move(to: CGPoint(x: 6, y: -15))
        crackPath2.addLine(to: CGPoint(x: 4, y: -5))
        crackPath2.addLine(to: CGPoint(x: 8, y: 5))
        crackPath2.addLine(to: CGPoint(x: 5, y: 15))
        crack2.path = crackPath2
        crack2.strokeColor = SKColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 0.8)
        crack2.lineWidth = 1.5
        crack2.glowWidth = 2.0
        crack2.zPosition = 0.2
        addChild(crack2)

        // Horizontal crack
        let crack3 = SKShapeNode()
        let crackPath3 = CGMutablePath()
        crackPath3.move(to: CGPoint(x: -14, y: 3))
        crackPath3.addLine(to: CGPoint(x: -3, y: 1))
        crackPath3.addLine(to: CGPoint(x: 4, y: 4))
        crackPath3.addLine(to: CGPoint(x: 14, y: 2))
        crack3.path = crackPath3
        crack3.strokeColor = SKColor(red: 1.0, green: 0.7, blue: 0.1, alpha: 0.7)
        crack3.lineWidth = 1.5
        crack3.glowWidth = 2.0
        crack3.zPosition = 0.2
        addChild(crack3)

        // Eyes - glowing orange
        let leftEye = SKShapeNode(circleOfRadius: 4)
        leftEye.fillColor = SKColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0)
        leftEye.strokeColor = .clear
        leftEye.position = CGPoint(x: -8, y: 10)
        leftEye.zPosition = 0.3
        leftEye.glowWidth = 3.0
        addChild(leftEye)

        let rightEye = SKShapeNode(circleOfRadius: 4)
        rightEye.fillColor = SKColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0)
        rightEye.strokeColor = .clear
        rightEye.position = CGPoint(x: 8, y: 10)
        rightEye.zPosition = 0.3
        rightEye.glowWidth = 3.0
        addChild(rightEye)

        // Mouth - jagged lava opening
        let mouth = SKShapeNode()
        let mouthPath = CGMutablePath()
        mouthPath.move(to: CGPoint(x: -8, y: -2))
        mouthPath.addLine(to: CGPoint(x: -4, y: -6))
        mouthPath.addLine(to: CGPoint(x: 0, y: -2))
        mouthPath.addLine(to: CGPoint(x: 4, y: -6))
        mouthPath.addLine(to: CGPoint(x: 8, y: -2))
        mouth.path = mouthPath
        mouth.strokeColor = SKColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1.0)
        mouth.fillColor = SKColor(red: 1.0, green: 0.3, blue: 0.0, alpha: 0.8)
        mouth.lineWidth = 1.5
        mouth.zPosition = 0.3
        addChild(mouth)
    }

    private func startAmbientAnimation() {
        // Pulsing glow
        let pulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.5, duration: 0.8),
            SKAction.fadeAlpha(to: 0.2, duration: 0.8)
        ])
        glowNode.run(SKAction.repeatForever(pulse))

        // Body shimmer
        let shimmer = SKAction.sequence([
            SKAction.colorize(with: SKColor(red: 0.35, green: 0.15, blue: 0.05, alpha: 1.0),
                              colorBlendFactor: 0.3, duration: 0.5),
            SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.5)
        ])
        bodyNode.run(SKAction.repeatForever(shimmer))
    }

    override func update(deltaTime: TimeInterval, playerPosition: CGPoint) {
        super.update(deltaTime: deltaTime, playerPosition: playerPosition)

        // Fire particles
        fireParticleTimer += deltaTime
        if fireParticleTimer >= fireParticleInterval {
            fireParticleTimer = 0
            spawnFireParticle()
        }

        // Fireball attack
        let dist = distanceTo(point: playerPosition)
        if dist < detectionRange && dist > 50 {
            attackTimer += deltaTime
            if attackTimer >= attackInterval {
                attackTimer = 0
                shootFireball(toward: playerPosition)
            }
        }
    }

    private func spawnFireParticle() {
        guard let parent = self.parent else { return }

        let particle = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...4))
        let colors: [SKColor] = [
            SKColor(red: 1.0, green: 0.4, blue: 0.0, alpha: 0.8),
            SKColor(red: 1.0, green: 0.7, blue: 0.0, alpha: 0.8),
            SKColor(red: 1.0, green: 0.2, blue: 0.0, alpha: 0.7)
        ]
        particle.fillColor = colors.randomElement()!
        particle.strokeColor = .clear
        particle.position = CGPoint(x: position.x + CGFloat.random(in: -12...12),
                                     y: position.y + size.height / 2)
        particle.zPosition = 55
        parent.addChild(particle)

        let rise = SKAction.moveBy(x: CGFloat.random(in: -8...8), y: CGFloat.random(in: 15...35), duration: 0.5)
        let fade = SKAction.fadeOut(duration: 0.5)
        let shrink = SKAction.scale(to: 0.1, duration: 0.5)
        particle.run(SKAction.sequence([
            SKAction.group([rise, fade, shrink]),
            SKAction.removeFromParent()
        ]))
    }

    func shootFireball(toward target: CGPoint) {
        guard let parent = self.parent else { return }

        let fireball = SKShapeNode(circleOfRadius: 8)
        fireball.fillColor = SKColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0)
        fireball.strokeColor = SKColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 0.8)
        fireball.lineWidth = 2.0
        fireball.glowWidth = 5.0
        fireball.name = "fireball"
        fireball.position = self.position
        fireball.zPosition = 55

        // Inner core
        let core = SKShapeNode(circleOfRadius: 4)
        core.fillColor = SKColor(red: 1.0, green: 1.0, blue: 0.5, alpha: 1.0)
        core.strokeColor = .clear
        core.zPosition = 0.1
        fireball.addChild(core)

        // Physics
        let fireballBody = SKPhysicsBody(circleOfRadius: 8)
        fireballBody.isDynamic = true
        fireballBody.affectedByGravity = false
        fireballBody.categoryBitMask = PhysicsCategory.enemy
        fireballBody.contactTestBitMask = PhysicsCategory.player | PhysicsCategory.ground
        fireballBody.collisionBitMask = PhysicsCategory.none
        fireball.physicsBody = fireballBody

        parent.addChild(fireball)

        // Direction toward player
        let dx = target.x - position.x
        let dy = target.y - position.y
        let distance = hypot(dx, dy)
        let normalizedDx = dx / distance
        let normalizedDy = dy / distance
        let speed: CGFloat = 200

        fireball.physicsBody?.velocity = CGVector(dx: normalizedDx * speed, dy: normalizedDy * speed)

        // Pulsing animation
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.3, duration: 0.15),
            SKAction.scale(to: 0.9, duration: 0.15)
        ])
        fireball.run(SKAction.repeatForever(pulse))

        // Auto-destroy after time
        fireball.run(SKAction.sequence([
            SKAction.wait(forDuration: 3.0),
            SKAction.fadeOut(duration: 0.2),
            SKAction.removeFromParent()
        ]))
    }

    override func createDeathEffect() {
        guard let parent = self.parent else { return }
        // Lava explosion
        for _ in 0..<12 {
            let particle = SKShapeNode(circleOfRadius: CGFloat.random(in: 3...8))
            let lavaColors: [SKColor] = [
                SKColor(red: 1.0, green: 0.3, blue: 0.0, alpha: 0.9),
                SKColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 0.9),
                SKColor(red: 0.8, green: 0.1, blue: 0.0, alpha: 0.9)
            ]
            particle.fillColor = lavaColors.randomElement()!
            particle.strokeColor = .clear
            particle.position = self.position
            particle.zPosition = 60
            parent.addChild(particle)

            let move = SKAction.moveBy(x: CGFloat.random(in: -60...60),
                                        y: CGFloat.random(in: -30...70),
                                        duration: 0.8)
            let fade = SKAction.fadeOut(duration: 0.8)
            particle.run(SKAction.sequence([
                SKAction.group([move, fade]),
                SKAction.removeFromParent()
            ]))
        }
    }
}

// MARK: - Dark Sea Creature (Underwater Tentacle Enemy)

class DarkSeaCreature: BaseEnemy {

    private var bodyNode: SKShapeNode!
    private var tentacles: [SKShapeNode] = []
    private var eyeNode: SKShapeNode!
    private var tentacleTimer: TimeInterval = 0
    private let tentacleAnimInterval: TimeInterval = 0.05
    private var grabTimer: TimeInterval = 0
    private let grabInterval: TimeInterval = 3.0

    init() {
        super.init(health: 5, damage: 1, scoreValue: 250, size: CGSize(width: 50, height: 60))
        self.name = "darkSeaCreature"
        self.patrolSpeed = 40
        self.patrolDistance = 80
        self.detectionRange = 200
        self.attackRange = 80

        setupPhysics(bodySize: CGSize(width: 40, height: 50))
        physicsBody?.mass = 0.8
        physicsBody?.affectedByGravity = false // Floats in water
        physicsBody?.linearDamping = 2.0
        buildVisuals()
        setupHealthBar()
        startFloatingAnimation()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func buildVisuals() {
        // Main body - dark purple/black sea creature
        bodyNode = SKShapeNode(ellipseOf: CGSize(width: 36, height: 30))
        bodyNode.fillColor = SKColor(red: 0.15, green: 0.05, blue: 0.25, alpha: 1.0)
        bodyNode.strokeColor = SKColor(red: 0.3, green: 0.1, blue: 0.5, alpha: 0.8)
        bodyNode.lineWidth = 2.0
        bodyNode.position = CGPoint(x: 0, y: 10)
        bodyNode.zPosition = 0.1
        addChild(bodyNode)

        // Bioluminescent spots
        let spotPositions: [(x: CGFloat, y: CGFloat)] = [
            (-8, 14), (6, 16), (-3, 8), (10, 10), (-12, 12)
        ]
        for pos in spotPositions {
            let spot = SKShapeNode(circleOfRadius: 2)
            spot.fillColor = SKColor(red: 0.3, green: 0.8, blue: 1.0, alpha: 0.8)
            spot.strokeColor = .clear
            spot.position = CGPoint(x: pos.x, y: pos.y)
            spot.zPosition = 0.2
            spot.glowWidth = 2.0
            addChild(spot)

            let blink = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.3, duration: CGFloat.random(in: 0.5...1.5)),
                SKAction.fadeAlpha(to: 1.0, duration: CGFloat.random(in: 0.5...1.5))
            ])
            spot.run(SKAction.repeatForever(blink))
        }

        // Central eye
        eyeNode = SKShapeNode(circleOfRadius: 6)
        eyeNode.fillColor = SKColor(red: 0.9, green: 0.1, blue: 0.3, alpha: 1.0)
        eyeNode.strokeColor = SKColor(red: 0.5, green: 0.0, blue: 0.2, alpha: 1.0)
        eyeNode.lineWidth = 1.5
        eyeNode.position = CGPoint(x: 0, y: 14)
        eyeNode.zPosition = 0.3
        addChild(eyeNode)

        // Slit pupil
        let pupil = SKShapeNode(rectOf: CGSize(width: 2, height: 8), cornerRadius: 1)
        pupil.fillColor = SKColor(red: 0.1, green: 0.0, blue: 0.05, alpha: 1.0)
        pupil.strokeColor = .clear
        pupil.zPosition = 0.1
        eyeNode.addChild(pupil)

        // Tentacles (4 main ones)
        let tentacleCount = 4
        let spacing = 10.0
        let startX = -CGFloat(tentacleCount - 1) * spacing / 2

        for i in 0..<tentacleCount {
            let tentacle = createTentacle()
            tentacle.position = CGPoint(x: startX + CGFloat(i) * spacing, y: -5)
            tentacle.zPosition = 0.05
            addChild(tentacle)
            tentacles.append(tentacle)
        }
    }

    private func createTentacle() -> SKShapeNode {
        let tentacle = SKShapeNode()
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addCurve(to: CGPoint(x: CGFloat.random(in: -8...8), y: -25),
                       control1: CGPoint(x: -6, y: -8),
                       control2: CGPoint(x: 6, y: -18))
        tentacle.path = path
        tentacle.strokeColor = SKColor(red: 0.2, green: 0.08, blue: 0.35, alpha: 0.9)
        tentacle.lineWidth = 3.0
        tentacle.lineCap = .round

        // Suction cups (small circles along tentacle)
        for j in 0..<3 {
            let cup = SKShapeNode(circleOfRadius: 1.5)
            cup.fillColor = SKColor(red: 0.3, green: 0.15, blue: 0.5, alpha: 0.7)
            cup.strokeColor = .clear
            cup.position = CGPoint(x: CGFloat.random(in: -4...4), y: CGFloat(-j * 8 - 4))
            cup.zPosition = 0.1
            tentacle.addChild(cup)
        }

        return tentacle
    }

    private func startFloatingAnimation() {
        let float = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 6, duration: 1.5),
            SKAction.moveBy(x: 0, y: -6, duration: 1.5)
        ])
        run(SKAction.repeatForever(float), withKey: "float")
    }

    override func update(deltaTime: TimeInterval, playerPosition: CGPoint) {
        guard isAlive && enemyState != .dead else { return }

        let dist = distanceTo(point: playerPosition)

        // Tentacle sway animation
        tentacleTimer += deltaTime
        if tentacleTimer >= tentacleAnimInterval {
            tentacleTimer = 0
            for (i, tentacle) in tentacles.enumerated() {
                let phase = CGFloat(i) * 0.8 + CGFloat(CACurrentMediaTime()) * 2.0
                let swayX = sin(phase) * 4
                let path = CGMutablePath()
                path.move(to: CGPoint(x: 0, y: 0))
                path.addCurve(to: CGPoint(x: swayX, y: -25),
                               control1: CGPoint(x: -6 + swayX * 0.3, y: -8),
                               control2: CGPoint(x: 6 + swayX * 0.5, y: -18))
                tentacle.path = path
            }
        }

        // Track player with eye
        if dist < detectionRange {
            let dx = playerPosition.x - position.x
            let dy = playerPosition.y - position.y
            let angle = atan2(dy, dx)
            let eyeOffset: CGFloat = 2.0
            eyeNode.children.first?.position = CGPoint(x: cos(angle) * eyeOffset, y: sin(angle) * eyeOffset)
        }

        // Grab attack - extends tentacles toward player
        if dist < attackRange {
            grabTimer += deltaTime
            if grabTimer >= grabInterval {
                grabTimer = 0
                performGrabAttack(toward: playerPosition)
            }
        }

        // Slow chase in water
        if dist < detectionRange && dist > attackRange {
            let direction: CGFloat = playerPosition.x > position.x ? 1 : -1
            let vertDirection: CGFloat = playerPosition.y > position.y ? 1 : -1
            position.x += patrolSpeed * direction * CGFloat(deltaTime)
            position.y += patrolSpeed * 0.5 * vertDirection * CGFloat(deltaTime)
            xScale = direction > 0 ? abs(xScale) : -abs(xScale)
        }
    }

    private func performGrabAttack(toward target: CGPoint) {
        guard let parent = self.parent else { return }

        // Extend a dark tentacle toward player
        let attackTentacle = SKShapeNode()
        let dx = target.x - position.x
        let dy = target.y - position.y

        let path = CGMutablePath()
        path.move(to: position)
        path.addCurve(to: target,
                       control1: CGPoint(x: position.x + dx * 0.3, y: position.y + dy * 0.5 + 20),
                       control2: CGPoint(x: position.x + dx * 0.7, y: position.y + dy * 0.5 - 20))
        attackTentacle.path = path
        attackTentacle.strokeColor = SKColor(red: 0.2, green: 0.05, blue: 0.35, alpha: 0.8)
        attackTentacle.lineWidth = 4.0
        attackTentacle.glowWidth = 3.0
        attackTentacle.zPosition = 45
        attackTentacle.name = "grabTentacle"

        // Physics for the tip
        let tipNode = SKShapeNode(circleOfRadius: 8)
        tipNode.fillColor = SKColor(red: 0.25, green: 0.05, blue: 0.4, alpha: 0.6)
        tipNode.strokeColor = .clear
        tipNode.position = target
        tipNode.zPosition = 46
        tipNode.name = "grabTentacle"

        let tipBody = SKPhysicsBody(circleOfRadius: 8)
        tipBody.isDynamic = false
        tipBody.categoryBitMask = PhysicsCategory.enemy
        tipBody.contactTestBitMask = PhysicsCategory.player
        tipBody.collisionBitMask = PhysicsCategory.none
        tipNode.physicsBody = tipBody

        parent.addChild(attackTentacle)
        parent.addChild(tipNode)

        // Retract after a moment
        let retract = SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.fadeOut(duration: 0.3),
            SKAction.removeFromParent()
        ])
        attackTentacle.run(retract)
        tipNode.run(retract)
    }

    override func createDeathEffect() {
        guard let parent = self.parent else { return }
        // Ink cloud effect
        for _ in 0..<10 {
            let ink = SKShapeNode(circleOfRadius: CGFloat.random(in: 5...12))
            ink.fillColor = SKColor(red: 0.1, green: 0.0, blue: 0.2, alpha: 0.7)
            ink.strokeColor = .clear
            ink.position = self.position
            ink.zPosition = 55
            parent.addChild(ink)

            let expand = SKAction.scale(to: CGFloat.random(in: 2...4), duration: 1.0)
            let fade = SKAction.fadeOut(duration: 1.2)
            let move = SKAction.moveBy(x: CGFloat.random(in: -30...30),
                                        y: CGFloat.random(in: -20...20),
                                        duration: 1.0)
            ink.run(SKAction.sequence([
                SKAction.group([expand, fade, move]),
                SKAction.removeFromParent()
            ]))
        }
    }
}

// MARK: - Storm Bird (Flying Enemy)

class StormBird: BaseEnemy {

    private var bodyNode: SKShapeNode!
    private var leftWing: SKShapeNode!
    private var rightWing: SKShapeNode!
    private var swoopTimer: TimeInterval = 0
    private let swoopInterval: TimeInterval = 3.0
    private var isSwooping = false
    private var baseY: CGFloat = 0
    private var flyingPhase: CGFloat = 0

    init() {
        super.init(health: 3, damage: 1, scoreValue: 200, size: CGSize(width: 48, height: 32))
        self.name = "stormBird"
        self.patrolSpeed = 120
        self.patrolDistance = 250
        self.detectionRange = 350
        self.attackRange = 150

        setupPhysics(bodySize: CGSize(width: 40, height: 20))
        physicsBody?.mass = 0.3
        physicsBody?.affectedByGravity = false
        physicsBody?.linearDamping = 1.0
        buildVisuals()
        setupHealthBar()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func buildVisuals() {
        // Body - dark stormy gray-blue
        bodyNode = SKShapeNode(ellipseOf: CGSize(width: 24, height: 16))
        bodyNode.fillColor = SKColor(red: 0.25, green: 0.3, blue: 0.4, alpha: 1.0)
        bodyNode.strokeColor = SKColor(red: 0.4, green: 0.45, blue: 0.55, alpha: 0.8)
        bodyNode.lineWidth = 1.5
        bodyNode.zPosition = 0.1
        addChild(bodyNode)

        // Chest - lighter
        let chest = SKShapeNode(ellipseOf: CGSize(width: 12, height: 10))
        chest.fillColor = SKColor(red: 0.5, green: 0.55, blue: 0.65, alpha: 1.0)
        chest.strokeColor = .clear
        chest.position = CGPoint(x: 0, y: -2)
        chest.zPosition = 0.15
        addChild(chest)

        // Left wing
        leftWing = SKShapeNode()
        let leftPath = CGMutablePath()
        leftPath.move(to: CGPoint(x: -8, y: 2))
        leftPath.addLine(to: CGPoint(x: -24, y: 10))
        leftPath.addLine(to: CGPoint(x: -22, y: 4))
        leftPath.addLine(to: CGPoint(x: -18, y: 6))
        leftPath.addLine(to: CGPoint(x: -14, y: 0))
        leftPath.addLine(to: CGPoint(x: -8, y: -2))
        leftPath.closeSubpath()
        leftWing.path = leftPath
        leftWing.fillColor = SKColor(red: 0.3, green: 0.35, blue: 0.5, alpha: 1.0)
        leftWing.strokeColor = SKColor(red: 0.2, green: 0.25, blue: 0.35, alpha: 0.8)
        leftWing.lineWidth = 1.0
        leftWing.zPosition = 0.05
        addChild(leftWing)

        // Right wing
        rightWing = SKShapeNode()
        let rightPath = CGMutablePath()
        rightPath.move(to: CGPoint(x: 8, y: 2))
        rightPath.addLine(to: CGPoint(x: 24, y: 10))
        rightPath.addLine(to: CGPoint(x: 22, y: 4))
        rightPath.addLine(to: CGPoint(x: 18, y: 6))
        rightPath.addLine(to: CGPoint(x: 14, y: 0))
        rightPath.addLine(to: CGPoint(x: 8, y: -2))
        rightPath.closeSubpath()
        rightWing.path = rightPath
        rightWing.fillColor = SKColor(red: 0.3, green: 0.35, blue: 0.5, alpha: 1.0)
        rightWing.strokeColor = SKColor(red: 0.2, green: 0.25, blue: 0.35, alpha: 0.8)
        rightWing.lineWidth = 1.0
        rightWing.zPosition = 0.05
        addChild(rightWing)

        // Head
        let head = SKShapeNode(circleOfRadius: 6)
        head.fillColor = SKColor(red: 0.25, green: 0.3, blue: 0.4, alpha: 1.0)
        head.strokeColor = .clear
        head.position = CGPoint(x: 0, y: 10)
        head.zPosition = 0.2
        addChild(head)

        // Beak
        let beak = SKShapeNode()
        let beakPath = CGMutablePath()
        beakPath.move(to: CGPoint(x: -2, y: 10))
        beakPath.addLine(to: CGPoint(x: 6, y: 8))
        beakPath.addLine(to: CGPoint(x: -2, y: 7))
        beakPath.closeSubpath()
        beak.path = beakPath
        beak.fillColor = SKColor(red: 0.7, green: 0.6, blue: 0.2, alpha: 1.0)
        beak.strokeColor = .clear
        beak.zPosition = 0.3
        addChild(beak)

        // Eyes - piercing yellow
        let eye = SKShapeNode(circleOfRadius: 2)
        eye.fillColor = SKColor(red: 1.0, green: 0.9, blue: 0.2, alpha: 1.0)
        eye.strokeColor = .clear
        eye.position = CGPoint(x: 2, y: 11)
        eye.zPosition = 0.3
        eye.glowWidth = 1.5
        addChild(eye)

        // Storm electricity crackling
        let spark1 = createSparkNode()
        spark1.position = CGPoint(x: -18, y: 6)
        addChild(spark1)

        let spark2 = createSparkNode()
        spark2.position = CGPoint(x: 18, y: 6)
        addChild(spark2)

        // Tail feathers
        let tail = SKShapeNode()
        let tailPath = CGMutablePath()
        tailPath.move(to: CGPoint(x: -3, y: -6))
        tailPath.addLine(to: CGPoint(x: -6, y: -16))
        tailPath.addLine(to: CGPoint(x: 0, y: -12))
        tailPath.addLine(to: CGPoint(x: 6, y: -16))
        tailPath.addLine(to: CGPoint(x: 3, y: -6))
        tailPath.closeSubpath()
        tail.path = tailPath
        tail.fillColor = SKColor(red: 0.2, green: 0.25, blue: 0.35, alpha: 1.0)
        tail.strokeColor = SKColor(red: 0.3, green: 0.35, blue: 0.5, alpha: 0.6)
        tail.lineWidth = 1.0
        tail.zPosition = 0.02
        addChild(tail)
    }

    private func createSparkNode() -> SKShapeNode {
        let spark = SKShapeNode()
        let sparkPath = CGMutablePath()
        sparkPath.move(to: CGPoint(x: 0, y: 0))
        sparkPath.addLine(to: CGPoint(x: 2, y: -3))
        sparkPath.addLine(to: CGPoint(x: -1, y: -3))
        sparkPath.addLine(to: CGPoint(x: 1, y: -6))
        spark.path = sparkPath
        spark.strokeColor = SKColor(red: 0.7, green: 0.8, blue: 1.0, alpha: 0.9)
        spark.lineWidth = 1.5
        spark.glowWidth = 2.0
        spark.zPosition = 0.4

        let flicker = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.0, duration: 0.1),
            SKAction.fadeAlpha(to: 1.0, duration: 0.05),
            SKAction.wait(forDuration: CGFloat.random(in: 0.3...0.8)),
            SKAction.fadeAlpha(to: 0.0, duration: 0.05),
            SKAction.fadeAlpha(to: 0.8, duration: 0.1),
            SKAction.wait(forDuration: CGFloat.random(in: 0.2...0.6))
        ])
        spark.run(SKAction.repeatForever(flicker))

        return spark
    }

    override func update(deltaTime: TimeInterval, playerPosition: CGPoint) {
        guard isAlive && enemyState != .dead && enemyState != .hurt else { return }

        if baseY == 0 { baseY = position.y }

        // Wing flapping animation
        flyingPhase += CGFloat(deltaTime) * 6.0
        let wingAngle = sin(flyingPhase) * 0.4
        leftWing.zRotation = wingAngle
        rightWing.zRotation = -wingAngle

        // Floating motion
        let floatOffset = sin(flyingPhase * 0.5) * 15
        if !isSwooping {
            position.y = baseY + floatOffset
        }

        let dist = distanceTo(point: playerPosition)

        // Patrol in the air
        if dist >= detectionRange {
            enemyState = .patrolling
            patrol(deltaTime: deltaTime)
            return
        }

        // Swoop attack
        swoopTimer += deltaTime
        if dist < attackRange && swoopTimer >= swoopInterval && !isSwooping {
            swoopTimer = 0
            performSwoop(toward: playerPosition)
        } else if !isSwooping && dist < detectionRange {
            // Circle above player
            let circleX = playerPosition.x + cos(flyingPhase * 0.3) * 80
            let direction: CGFloat = circleX > position.x ? 1 : -1
            position.x += patrolSpeed * direction * CGFloat(deltaTime)
            xScale = direction > 0 ? abs(xScale) : -abs(xScale)
        }
    }

    private func performSwoop(toward target: CGPoint) {
        isSwooping = true
        enemyState = .attacking

        let swoopTarget = CGPoint(x: target.x, y: target.y + 10)
        let swoopDown = SKAction.move(to: swoopTarget, duration: 0.4)
        swoopDown.timingMode = .easeIn

        let returnUp = SKAction.move(to: CGPoint(x: position.x + patrolDirection * 60, y: baseY),
                                      duration: 0.6)
        returnUp.timingMode = .easeOut

        let swoopSequence = SKAction.sequence([
            swoopDown,
            SKAction.wait(forDuration: 0.1),
            returnUp,
            SKAction.run { [weak self] in
                self?.isSwooping = false
                self?.enemyState = .patrolling
            }
        ])
        run(swoopSequence, withKey: "swoop")

        // Lightning trail during swoop
        createLightningTrail()
    }

    private func createLightningTrail() {
        guard let parent = self.parent else { return }

        for i in 0..<4 {
            let delay = Double(i) * 0.1
            let spark = SKShapeNode(circleOfRadius: 3)
            spark.fillColor = SKColor(red: 0.7, green: 0.8, blue: 1.0, alpha: 0.8)
            spark.strokeColor = .clear
            spark.glowWidth = 4.0
            spark.zPosition = 48

            let spawnSpark = SKAction.sequence([
                SKAction.wait(forDuration: delay),
                SKAction.run { [weak self] in
                    guard let self = self else { return }
                    spark.position = self.position
                    parent.addChild(spark)

                    let fade = SKAction.sequence([
                        SKAction.fadeOut(duration: 0.3),
                        SKAction.removeFromParent()
                    ])
                    spark.run(fade)
                }
            ])
            run(spawnSpark)
        }
    }

    override func createDeathEffect() {
        guard let parent = self.parent else { return }
        // Feather burst + lightning sparks
        for _ in 0..<10 {
            let feather = SKShapeNode(ellipseOf: CGSize(width: 4, height: 8))
            feather.fillColor = SKColor(red: 0.35, green: 0.4, blue: 0.55, alpha: 0.9)
            feather.strokeColor = .clear
            feather.position = self.position
            feather.zPosition = 60
            parent.addChild(feather)

            let move = SKAction.moveBy(x: CGFloat.random(in: -50...50),
                                        y: CGFloat.random(in: -20...40),
                                        duration: 0.8)
            let spin = SKAction.rotate(byAngle: CGFloat.random(in: -3...3), duration: 0.8)
            let fade = SKAction.fadeOut(duration: 1.0)
            feather.run(SKAction.sequence([
                SKAction.group([move, spin, fade]),
                SKAction.removeFromParent()
            ]))
        }

        // Lightning sparks
        for _ in 0..<5 {
            let spark = SKShapeNode(circleOfRadius: 2)
            spark.fillColor = SKColor(red: 0.8, green: 0.9, blue: 1.0, alpha: 1.0)
            spark.strokeColor = .clear
            spark.glowWidth = 4.0
            spark.position = self.position
            spark.zPosition = 61
            parent.addChild(spark)

            let move = SKAction.moveBy(x: CGFloat.random(in: -30...30),
                                        y: CGFloat.random(in: -15...30),
                                        duration: 0.4)
            let fade = SKAction.fadeOut(duration: 0.4)
            spark.run(SKAction.sequence([
                SKAction.group([move, fade]),
                SKAction.removeFromParent()
            ]))
        }
    }
}

// MARK: - Notifications

extension Notification.Name {
    static let enemyDefeated = Notification.Name("enemyDefeated")
}
