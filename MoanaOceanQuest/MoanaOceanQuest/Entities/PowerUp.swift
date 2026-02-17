import SpriteKit

class PowerUp: SKNode {

    let type: PowerUpType
    let duration: TimeInterval
    private var visualNode: SKNode!
    private var collected = false

    init(type: PowerUpType) {
        self.type = type
        switch type {
        case .mauiHook: self.duration = 10.0
        case .oceanBlessing: self.duration = 15.0
        case .windSail: self.duration = 8.0
        case .teFitiHeart: self.duration = 5.0
        case .coconutArmor: self.duration = 0 // One-hit shield
        case .stingrayRide: self.duration = 6.0
        }
        super.init()

        self.name = "powerUp"
        self.zPosition = 42

        buildVisual()
        setupPhysics()
        startAnimation()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func buildVisual() {
        visualNode = SKNode()
        addChild(visualNode)

        // Glowing base circle
        let baseGlow = SKShapeNode(circleOfRadius: 14)
        baseGlow.strokeColor = .clear
        baseGlow.zPosition = -0.1

        switch type {
        case .mauiHook:
            baseGlow.fillColor = SKColor(red: 0.6, green: 0.5, blue: 0.3, alpha: 0.3)
            visualNode.addChild(baseGlow)

            // Hook shape
            let hookPath = CGMutablePath()
            hookPath.move(to: CGPoint(x: 0, y: 10))
            hookPath.addLine(to: CGPoint(x: 0, y: -2))
            hookPath.addQuadCurve(to: CGPoint(x: 8, y: -2), control: CGPoint(x: 4, y: -10))
            let hook = SKShapeNode(path: hookPath)
            hook.strokeColor = SKColor(red: 0.7, green: 0.6, blue: 0.35, alpha: 1.0)
            hook.lineWidth = 3.0
            hook.lineCap = .round
            hook.glowWidth = 2.0
            visualNode.addChild(hook)

        case .oceanBlessing:
            baseGlow.fillColor = SKColor(red: 0.0, green: 0.5, blue: 1.0, alpha: 0.3)
            visualNode.addChild(baseGlow)

            let droplet = SKShapeNode(circleOfRadius: 7)
            droplet.fillColor = SKColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 0.9)
            droplet.strokeColor = SKColor(red: 0.3, green: 0.7, blue: 1.0, alpha: 1.0)
            droplet.lineWidth = 1.5
            droplet.glowWidth = 3.0
            visualNode.addChild(droplet)

        case .windSail:
            baseGlow.fillColor = SKColor(red: 0.8, green: 0.9, blue: 1.0, alpha: 0.3)
            visualNode.addChild(baseGlow)

            let sailPath = CGMutablePath()
            sailPath.move(to: CGPoint(x: -6, y: -8))
            sailPath.addLine(to: CGPoint(x: -6, y: 8))
            sailPath.addQuadCurve(to: CGPoint(x: -6, y: -8), control: CGPoint(x: 8, y: 0))
            let sail = SKShapeNode(path: sailPath)
            sail.fillColor = SKColor(red: 0.9, green: 0.85, blue: 0.7, alpha: 0.9)
            sail.strokeColor = SKColor(red: 0.7, green: 0.6, blue: 0.4, alpha: 1.0)
            sail.lineWidth = 1.5
            visualNode.addChild(sail)

        case .teFitiHeart:
            baseGlow.fillColor = SKColor(red: 0.0, green: 1.0, blue: 0.5, alpha: 0.3)
            visualNode.addChild(baseGlow)

            let heartPath = CGMutablePath()
            heartPath.addEllipse(in: CGRect(x: -6, y: -6, width: 12, height: 12))
            let heart = SKShapeNode(path: heartPath)
            heart.fillColor = SKColor(red: 0.2, green: 0.9, blue: 0.5, alpha: 1.0)
            heart.strokeColor = SKColor(red: 0.1, green: 0.7, blue: 0.4, alpha: 1.0)
            heart.lineWidth = 1.5
            heart.glowWidth = 5.0
            visualNode.addChild(heart)

            // Spiral pattern
            let spiral = SKShapeNode(circleOfRadius: 3)
            spiral.fillColor = SKColor(red: 0.3, green: 1.0, blue: 0.6, alpha: 0.8)
            spiral.strokeColor = .clear
            spiral.glowWidth = 2.0
            visualNode.addChild(spiral)

        case .coconutArmor:
            baseGlow.fillColor = SKColor(red: 0.5, green: 0.35, blue: 0.2, alpha: 0.3)
            visualNode.addChild(baseGlow)

            let coconut = SKShapeNode(circleOfRadius: 8)
            coconut.fillColor = SKColor(red: 0.45, green: 0.3, blue: 0.15, alpha: 1.0)
            coconut.strokeColor = SKColor(red: 0.35, green: 0.22, blue: 0.1, alpha: 1.0)
            coconut.lineWidth = 2.0
            visualNode.addChild(coconut)

            // Shield cross
            let cross1 = SKShapeNode(rectOf: CGSize(width: 2, height: 12))
            cross1.fillColor = SKColor(red: 0.55, green: 0.4, blue: 0.25, alpha: 0.8)
            cross1.strokeColor = .clear
            visualNode.addChild(cross1)

            let cross2 = SKShapeNode(rectOf: CGSize(width: 12, height: 2))
            cross2.fillColor = SKColor(red: 0.55, green: 0.4, blue: 0.25, alpha: 0.8)
            cross2.strokeColor = .clear
            visualNode.addChild(cross2)

        case .stingrayRide:
            baseGlow.fillColor = SKColor(red: 0.3, green: 0.5, blue: 0.8, alpha: 0.3)
            visualNode.addChild(baseGlow)

            let rayPath = CGMutablePath()
            rayPath.move(to: CGPoint(x: 0, y: 4))
            rayPath.addQuadCurve(to: CGPoint(x: -10, y: -2), control: CGPoint(x: -8, y: 4))
            rayPath.addQuadCurve(to: CGPoint(x: 0, y: -6), control: CGPoint(x: -5, y: -5))
            rayPath.addQuadCurve(to: CGPoint(x: 10, y: -2), control: CGPoint(x: 5, y: -5))
            rayPath.addQuadCurve(to: CGPoint(x: 0, y: 4), control: CGPoint(x: 8, y: 4))
            let ray = SKShapeNode(path: rayPath)
            ray.fillColor = SKColor(red: 0.3, green: 0.5, blue: 0.7, alpha: 0.9)
            ray.strokeColor = SKColor(red: 0.2, green: 0.4, blue: 0.6, alpha: 1.0)
            ray.lineWidth = 1.5
            visualNode.addChild(ray)
        }
    }

    private func setupPhysics() {
        let body = SKPhysicsBody(circleOfRadius: 14)
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.powerUp
        body.contactTestBitMask = PhysicsCategory.player
        body.collisionBitMask = PhysicsCategory.none
        self.physicsBody = body
    }

    private func startAnimation() {
        let float = SKAction.repeatForever(SKAction.sequence([
            SKAction.moveBy(x: 0, y: 5, duration: 0.8),
            SKAction.moveBy(x: 0, y: -5, duration: 0.8)
        ]))
        visualNode.run(float)

        let pulse = SKAction.repeatForever(SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.5),
            SKAction.scale(to: 1.0, duration: 0.5)
        ]))
        visualNode.run(pulse)
    }

    func collect() {
        guard !collected else { return }
        collected = true

        physicsBody?.categoryBitMask = PhysicsCategory.none
        physicsBody?.contactTestBitMask = PhysicsCategory.none

        let collectSequence = SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 2.0, duration: 0.3),
                SKAction.fadeOut(duration: 0.3)
            ]),
            SKAction.removeFromParent()
        ])
        run(collectSequence)
    }
}
