import SpriteKit

enum PlayerState {
    case idle
    case running
    case jumping
    case falling
    case swimming
    case attacking
    case hurt
    case dead
}

class PlayerCharacter: SKSpriteNode {

    // MARK: - Properties
    var playerState: PlayerState = .idle {
        didSet { updateAnimation() }
    }

    private var health: Int = 3
    private var maxHealth: Int = 3
    private var isInvulnerable = false
    private var invulnerabilityTimer: TimeInterval = 0
    private let invulnerabilityDuration: TimeInterval = 1.5

    var isOnGround = false
    var isInWater = false
    var canDoubleJump = true
    private var hasDoubleJumped = false

    // Movement
    private let moveSpeed: CGFloat = 300
    private let jumpForce: CGFloat = 550
    private let waterJumpForce: CGFloat = 350
    private let swimSpeed: CGFloat = 200
    private let maxVelocityX: CGFloat = 400
    private let maxVelocityY: CGFloat = 700

    // Attack
    private var canAttack = true
    private let attackCooldown: TimeInterval = 0.4
    var attackDamage: Int = 1

    // Dash
    private var canDash = true
    private let dashSpeed: CGFloat = 600
    private let dashDuration: TimeInterval = 0.25
    private let dashCooldown: TimeInterval = 1.0
    private var isDashing = false

    // Visual
    private var bodySprite: SKSpriteNode!
    private var hairSprite: SKSpriteNode!

    // MARK: - Initialization
    init() {
        let texture = PlayerCharacter.createPlayerTexture()
        super.init(texture: texture, color: .clear, size: CGSize(width: 40, height: 56))

        self.name = "player"
        self.zPosition = 100

        setupPhysicsBody()
        buildCharacterVisuals()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupPhysicsBody() {
        let bodySize = CGSize(width: 28, height: 50)
        physicsBody = SKPhysicsBody(rectangleOf: bodySize)
        physicsBody?.mass = 0.3
        physicsBody?.friction = 0.2
        physicsBody?.restitution = 0.0
        physicsBody?.allowsRotation = false
        physicsBody?.linearDamping = 0.1

        physicsBody?.categoryBitMask = PhysicsCategory.player
        physicsBody?.contactTestBitMask = PhysicsCategory.ground | PhysicsCategory.enemy |
            PhysicsCategory.collectible | PhysicsCategory.powerUp | PhysicsCategory.water |
            PhysicsCategory.platform | PhysicsCategory.boss
        physicsBody?.collisionBitMask = PhysicsCategory.ground | PhysicsCategory.boundary | PhysicsCategory.platform
    }

    private func buildCharacterVisuals() {
        // Body - tan skin, island girl
        bodySprite = SKSpriteNode(color: SKColor(red: 0.76, green: 0.58, blue: 0.42, alpha: 1.0),
                                   size: CGSize(width: 28, height: 40))
        bodySprite.position = CGPoint(x: 0, y: -4)
        bodySprite.zPosition = 0.1
        addChild(bodySprite)

        // Hair - long dark flowing hair
        hairSprite = SKSpriteNode(color: SKColor(red: 0.15, green: 0.1, blue: 0.08, alpha: 1.0),
                                   size: CGSize(width: 32, height: 24))
        hairSprite.position = CGPoint(x: -2, y: 16)
        hairSprite.zPosition = 0.2
        addChild(hairSprite)

        // Outfit - red/orange top
        let outfit = SKSpriteNode(color: SKColor(red: 0.85, green: 0.2, blue: 0.15, alpha: 1.0),
                                   size: CGSize(width: 26, height: 16))
        outfit.position = CGPoint(x: 0, y: 0)
        outfit.zPosition = 0.3
        addChild(outfit)

        // Skirt - tan/brown island wrap
        let skirt = SKSpriteNode(color: SKColor(red: 0.72, green: 0.55, blue: 0.3, alpha: 1.0),
                                  size: CGSize(width: 28, height: 14))
        skirt.position = CGPoint(x: 0, y: -14)
        skirt.zPosition = 0.3
        addChild(skirt)

        // Necklace - the Heart of Te Fiti (glowing green)
        let necklace = SKSpriteNode(color: SKColor(red: 0.2, green: 0.9, blue: 0.5, alpha: 1.0),
                                     size: CGSize(width: 6, height: 6))
        necklace.position = CGPoint(x: 0, y: 6)
        necklace.zPosition = 0.4
        addChild(necklace)

        // Necklace glow
        let glow = SKShapeNode(circleOfRadius: 8)
        glow.fillColor = SKColor(red: 0.2, green: 1.0, blue: 0.5, alpha: 0.3)
        glow.strokeColor = .clear
        glow.position = CGPoint(x: 0, y: 6)
        glow.zPosition = 0.35
        addChild(glow)

        let pulseAction = SKAction.repeatForever(
            SKAction.sequence([
                SKAction.fadeAlpha(to: 0.5, duration: 1.0),
                SKAction.fadeAlpha(to: 0.2, duration: 1.0)
            ])
        )
        glow.run(pulseAction)

        // Eyes
        let leftEye = SKSpriteNode(color: SKColor(red: 0.25, green: 0.15, blue: 0.1, alpha: 1.0),
                                    size: CGSize(width: 4, height: 5))
        leftEye.position = CGPoint(x: -5, y: 12)
        leftEye.zPosition = 0.5
        addChild(leftEye)

        let rightEye = SKSpriteNode(color: SKColor(red: 0.25, green: 0.15, blue: 0.1, alpha: 1.0),
                                     size: CGSize(width: 4, height: 5))
        rightEye.position = CGPoint(x: 5, y: 12)
        rightEye.zPosition = 0.5
        addChild(rightEye)
    }

    static func createPlayerTexture() -> SKTexture {
        let size = CGSize(width: 40, height: 56)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            UIColor.clear.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
        }
        return SKTexture(image: image)
    }

    // MARK: - Movement
    func moveRight() {
        guard playerState != .dead && playerState != .hurt else { return }
        let velocity = isInWater ? swimSpeed : moveSpeed
        physicsBody?.velocity.dx = min((physicsBody?.velocity.dx ?? 0) + velocity * 0.3, maxVelocityX)
        xScale = abs(xScale)

        if isOnGround && playerState != .jumping {
            playerState = .running
        }
    }

    func moveLeft() {
        guard playerState != .dead && playerState != .hurt else { return }
        let velocity = isInWater ? swimSpeed : moveSpeed
        physicsBody?.velocity.dx = max((physicsBody?.velocity.dx ?? 0) - velocity * 0.3, -maxVelocityX)
        xScale = -abs(xScale)

        if isOnGround && playerState != .jumping {
            playerState = .running
        }
    }

    func stopMoving() {
        if isOnGround && playerState == .running {
            playerState = .idle
        }
    }

    func jump() {
        guard playerState != .dead && playerState != .hurt else { return }

        if isInWater {
            physicsBody?.velocity.dy = waterJumpForce
            return
        }

        if isOnGround {
            physicsBody?.velocity.dy = jumpForce
            isOnGround = false
            hasDoubleJumped = false
            playerState = .jumping
            createJumpParticles()
        } else if canDoubleJump && !hasDoubleJumped {
            physicsBody?.velocity.dy = jumpForce * 0.8
            hasDoubleJumped = true
            createJumpParticles()
        }
    }

    func attack() {
        guard canAttack && playerState != .dead && playerState != .hurt else { return }

        canAttack = false
        playerState = .attacking

        // Create attack hitbox
        let attackRange: CGFloat = 45
        let attackBox = SKSpriteNode(color: SKColor(red: 0.2, green: 0.9, blue: 0.5, alpha: 0.4),
                                      size: CGSize(width: attackRange, height: 30))
        attackBox.name = "playerAttack"
        attackBox.position = CGPoint(x: (xScale > 0 ? 1 : -1) * attackRange / 2, y: 0)
        attackBox.zPosition = 101

        let attackBody = SKPhysicsBody(rectangleOf: attackBox.size)
        attackBody.isDynamic = false
        attackBody.categoryBitMask = PhysicsCategory.projectile
        attackBody.contactTestBitMask = PhysicsCategory.enemy | PhysicsCategory.boss
        attackBody.collisionBitMask = PhysicsCategory.none
        attackBox.physicsBody = attackBody
        addChild(attackBox)

        // Attack effect - green wave (Heart of Te Fiti power)
        let wave = SKShapeNode(circleOfRadius: 5)
        wave.fillColor = SKColor(red: 0.2, green: 1.0, blue: 0.5, alpha: 0.8)
        wave.strokeColor = .clear
        wave.position = attackBox.position
        wave.zPosition = 102
        addChild(wave)

        let expandAndFade = SKAction.group([
            SKAction.scale(to: 4.0, duration: 0.3),
            SKAction.fadeOut(duration: 0.3)
        ])
        wave.run(SKAction.sequence([expandAndFade, SKAction.removeFromParent()]))

        // Remove attack hitbox after short duration
        let removeAttack = SKAction.sequence([
            SKAction.wait(forDuration: 0.15),
            SKAction.removeFromParent()
        ])
        attackBox.run(removeAttack)

        // Cooldown
        let cooldown = SKAction.sequence([
            SKAction.wait(forDuration: attackCooldown),
            SKAction.run { [weak self] in
                self?.canAttack = true
                if self?.isOnGround == true {
                    self?.playerState = .idle
                }
            }
        ])
        run(cooldown)
    }

    // MARK: - Dash
    func dash() {
        guard canDash && !isDashing && playerState != .dead && playerState != .hurt else { return }

        canDash = false
        isDashing = true

        let direction: CGFloat = xScale > 0 ? 1 : -1
        physicsBody?.velocity.dx = dashSpeed * direction
        physicsBody?.velocity.dy = 0

        // Temporary invulnerability during dash
        isInvulnerable = true

        // Dash trail effect
        createDashTrail()

        // End dash
        let endDash = SKAction.sequence([
            SKAction.wait(forDuration: dashDuration),
            SKAction.run { [weak self] in
                self?.isDashing = false
                self?.isInvulnerable = false
            }
        ])
        run(endDash, withKey: "dash")

        // Cooldown
        let cooldown = SKAction.sequence([
            SKAction.wait(forDuration: dashCooldown),
            SKAction.run { [weak self] in
                self?.canDash = true
            }
        ])
        run(cooldown, withKey: "dashCooldown")
    }

    private func createDashTrail() {
        let trailCount = 5
        for i in 0..<trailCount {
            let delay = Double(i) * 0.05
            let afterImage = SKSpriteNode(color: SKColor(red: 0.2, green: 0.8, blue: 1.0, alpha: 0.5),
                                           size: self.size)
            afterImage.zPosition = self.zPosition - 1

            let spawnTrail = SKAction.sequence([
                SKAction.wait(forDuration: delay),
                SKAction.run { [weak self] in
                    guard let self = self, let parent = self.parent else { return }
                    afterImage.position = self.position
                    afterImage.xScale = self.xScale
                    parent.addChild(afterImage)

                    let fade = SKAction.sequence([
                        SKAction.fadeOut(duration: 0.3),
                        SKAction.removeFromParent()
                    ])
                    afterImage.run(fade)
                }
            ])
            run(spawnTrail)
        }
    }

    // MARK: - Damage
    func takeDamage(_ amount: Int = 1) {
        guard !isInvulnerable && playerState != .dead else { return }

        health -= amount

        if health <= 0 {
            health = 0
            die()
            return
        }

        playerState = .hurt
        isInvulnerable = true

        // Knockback
        let knockbackDirection: CGFloat = xScale > 0 ? -1 : 1
        physicsBody?.velocity = CGVector(dx: knockbackDirection * 200, dy: 300)

        // Flash effect
        let flash = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.3, duration: 0.1),
            SKAction.fadeAlpha(to: 1.0, duration: 0.1)
        ])
        let flashSequence = SKAction.repeat(flash, count: 5)
        run(flashSequence) { [weak self] in
            self?.isInvulnerable = false
            if self?.playerState == .hurt {
                self?.playerState = .idle
            }
        }
    }

    func heal(_ amount: Int = 1) {
        health = min(health + amount, maxHealth)
    }

    func die() {
        playerState = .dead
        physicsBody?.velocity = .zero
        physicsBody?.categoryBitMask = PhysicsCategory.none
        physicsBody?.collisionBitMask = PhysicsCategory.none

        let deathSequence = SKAction.sequence([
            SKAction.group([
                SKAction.fadeOut(duration: 1.0),
                SKAction.moveBy(x: 0, y: 30, duration: 1.0)
            ]),
            SKAction.run { [weak self] in
                NotificationCenter.default.post(name: .playerDied, object: self)
            }
        ])
        run(deathSequence)
    }

    // MARK: - Update
    func update(deltaTime: TimeInterval) {
        // Clamp velocity
        if let velocity = physicsBody?.velocity {
            physicsBody?.velocity.dx = max(min(velocity.dx, maxVelocityX), -maxVelocityX)
            physicsBody?.velocity.dy = max(min(velocity.dy, maxVelocityY), -maxVelocityY)
        }

        // Update invulnerability
        if isInvulnerable {
            invulnerabilityTimer += deltaTime
            if invulnerabilityTimer >= invulnerabilityDuration {
                isInvulnerable = false
                invulnerabilityTimer = 0
                alpha = 1.0
            }
        }

        // State based on velocity
        if playerState != .dead && playerState != .hurt && playerState != .attacking {
            if isInWater {
                playerState = .swimming
            } else if !isOnGround {
                playerState = (physicsBody?.velocity.dy ?? 0) > 0 ? .jumping : .falling
            } else if abs(physicsBody?.velocity.dx ?? 0) < 10 {
                playerState = .idle
            }
        }

        // Hair animation
        let windOffset = sin(CGFloat(CACurrentMediaTime()) * 3) * 3
        hairSprite?.position.x = -2 + windOffset
    }

    // MARK: - Ground Contact
    func landed() {
        isOnGround = true
        hasDoubleJumped = false
        if playerState != .dead && playerState != .hurt {
            playerState = .idle
        }
    }

    func leftGround() {
        isOnGround = false
    }

    // MARK: - Water Contact
    func enteredWater() {
        isInWater = true
        physicsBody?.linearDamping = 3.0
        playerState = .swimming
        createSplashEffect()
    }

    func exitedWater() {
        isInWater = false
        physicsBody?.linearDamping = 0.1
    }

    // MARK: - Effects
    private func createJumpParticles() {
        for _ in 0..<5 {
            let particle = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...4))
            particle.fillColor = SKColor(red: 0.9, green: 0.85, blue: 0.7, alpha: 0.8)
            particle.strokeColor = .clear
            particle.position = CGPoint(x: position.x + CGFloat.random(in: -10...10),
                                        y: position.y - 25)
            particle.zPosition = 99
            parent?.addChild(particle)

            let moveUp = SKAction.moveBy(x: CGFloat.random(in: -20...20), y: CGFloat.random(in: -10...20), duration: 0.4)
            let fade = SKAction.fadeOut(duration: 0.4)
            particle.run(SKAction.sequence([SKAction.group([moveUp, fade]), SKAction.removeFromParent()]))
        }
    }

    private func createSplashEffect() {
        for _ in 0..<8 {
            let droplet = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...5))
            droplet.fillColor = SKColor(red: 0.3, green: 0.7, blue: 1.0, alpha: 0.8)
            droplet.strokeColor = .clear
            droplet.position = CGPoint(x: position.x + CGFloat.random(in: -15...15),
                                        y: position.y)
            droplet.zPosition = 105
            parent?.addChild(droplet)

            let moveUp = SKAction.moveBy(x: CGFloat.random(in: -30...30), y: CGFloat.random(in: 20...60), duration: 0.5)
            let fade = SKAction.fadeOut(duration: 0.5)
            droplet.run(SKAction.sequence([SKAction.group([moveUp, fade]), SKAction.removeFromParent()]))
        }
    }

    // MARK: - Animation
    private func updateAnimation() {
        removeAction(forKey: "stateAnimation")

        switch playerState {
        case .idle:
            let breathe = SKAction.sequence([
                SKAction.scaleY(to: 1.02, duration: 0.8),
                SKAction.scaleY(to: 1.0, duration: 0.8)
            ])
            run(SKAction.repeatForever(breathe), withKey: "stateAnimation")

        case .running:
            let bob = SKAction.sequence([
                SKAction.moveBy(x: 0, y: 2, duration: 0.15),
                SKAction.moveBy(x: 0, y: -2, duration: 0.15)
            ])
            run(SKAction.repeatForever(bob), withKey: "stateAnimation")

        case .swimming:
            let swim = SKAction.sequence([
                SKAction.rotate(toAngle: 0.1, duration: 0.3),
                SKAction.rotate(toAngle: -0.1, duration: 0.3)
            ])
            run(SKAction.repeatForever(swim), withKey: "stateAnimation")

        case .attacking:
            let slash = SKAction.sequence([
                SKAction.scaleX(to: xScale * 1.2, duration: 0.1),
                SKAction.scaleX(to: xScale, duration: 0.1)
            ])
            run(slash, withKey: "stateAnimation")

        default:
            break
        }
    }

    // MARK: - Getters
    func getHealth() -> Int { return health }
    func getMaxHealth() -> Int { return maxHealth }
    func getIsInvulnerable() -> Bool { return isInvulnerable }
}

// MARK: - Notifications
extension Notification.Name {
    static let playerDied = Notification.Name("playerDied")
    static let levelComplete = Notification.Name("levelComplete")
}
