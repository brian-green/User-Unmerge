import SpriteKit

class WaterSurface: SKNode {
    private var waterNodes: [SKSpriteNode] = []
    private let segmentWidth: CGFloat = 40
    private let waterHeight: CGFloat
    private let totalWidth: CGFloat
    private var time: CGFloat = 0

    var waveAmplitude: CGFloat = 8.0
    var waveFrequency: CGFloat = 2.0
    var waveSpeed: CGFloat = 3.0

    init(width: CGFloat, height: CGFloat, color: SKColor = SKColor(red: 0.0, green: 0.4, blue: 0.8, alpha: 0.6)) {
        self.totalWidth = width
        self.waterHeight = height
        super.init()

        let segmentCount = Int(ceil(width / segmentWidth))
        for i in 0..<segmentCount {
            let segment = SKSpriteNode(color: color, size: CGSize(width: segmentWidth + 1, height: height))
            segment.anchorPoint = CGPoint(x: 0, y: 1)
            segment.position = CGPoint(x: CGFloat(i) * segmentWidth, y: 0)
            segment.alpha = 0.7
            addChild(segment)
            waterNodes.append(segment)
        }

        let waterBody = SKSpriteNode(color: color, size: CGSize(width: width, height: height))
        waterBody.anchorPoint = CGPoint(x: 0, y: 1)
        waterBody.position = CGPoint(x: 0, y: -height * 0.3)
        waterBody.alpha = 0.5
        waterBody.zPosition = -1
        addChild(waterBody)

        setupPhysicsBody(width: width, height: height)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupPhysicsBody(width: CGFloat, height: CGFloat) {
        let bodySize = CGSize(width: width, height: height)
        let body = SKPhysicsBody(rectangleOf: bodySize, center: CGPoint(x: width / 2, y: -height / 2))
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.water
        body.contactTestBitMask = PhysicsCategory.player
        body.collisionBitMask = PhysicsCategory.none
        self.physicsBody = body
    }

    func update(deltaTime: TimeInterval) {
        time += CGFloat(deltaTime)

        for (index, node) in waterNodes.enumerated() {
            let x = CGFloat(index) * segmentWidth
            let waveOffset = sin((x / totalWidth) * waveFrequency * .pi * 2 + time * waveSpeed) * waveAmplitude
            node.position.y = waveOffset
        }
    }
}

class WaterCurrentZone: SKNode {
    let currentDirection: CGVector
    let currentStrength: CGFloat

    init(size: CGSize, direction: CGVector, strength: CGFloat) {
        self.currentDirection = direction
        self.currentStrength = strength
        super.init()

        let visual = SKSpriteNode(color: SKColor(red: 0, green: 0.6, blue: 1.0, alpha: 0.3), size: size)
        addChild(visual)

        let body = SKPhysicsBody(rectangleOf: size)
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.water
        body.contactTestBitMask = PhysicsCategory.player
        body.collisionBitMask = PhysicsCategory.none
        self.physicsBody = body

        addCurrentParticles(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addCurrentParticles(size: CGSize) {
        let emitter = SKEmitterNode()
        emitter.particleBirthRate = 20
        emitter.particleLifetime = 2.0
        emitter.particleColor = SKColor(red: 0.7, green: 0.9, blue: 1.0, alpha: 0.6)
        emitter.particleSize = CGSize(width: 4, height: 4)
        emitter.particleSpeed = 50
        emitter.emissionAngle = atan2(currentDirection.dy, currentDirection.dx)
        emitter.emissionAngleRange = 0.3
        emitter.particleAlphaSpeed = -0.3
        emitter.particlePositionRange = CGVector(dx: size.width, dy: size.height)
        addChild(emitter)
    }

    func applyCurrentTo(player: SKNode) {
        let force = CGVector(
            dx: currentDirection.dx * currentStrength,
            dy: currentDirection.dy * currentStrength
        )
        player.physicsBody?.applyForce(force)
    }
}
