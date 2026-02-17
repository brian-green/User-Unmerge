import SpriteKit

class Collectible: SKNode {

    let type: CollectibleType
    private var visualNode: SKNode!
    private var collected = false

    init(type: CollectibleType) {
        self.type = type
        super.init()

        self.name = "collectible"
        self.zPosition = 40

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

        switch type {
        case .seashell:
            let shell = SKShapeNode(ellipseOf: CGSize(width: 16, height: 12))
            shell.fillColor = SKColor(red: 1.0, green: 0.85, blue: 0.7, alpha: 1.0)
            shell.strokeColor = SKColor(red: 0.9, green: 0.7, blue: 0.5, alpha: 1.0)
            shell.lineWidth = 1.5
            visualNode.addChild(shell)

            // Shell ridges
            for i in 0..<3 {
                let ridge = SKShapeNode()
                let path = CGMutablePath()
                let offset = CGFloat(i - 1) * 4
                path.move(to: CGPoint(x: offset, y: -5))
                path.addQuadCurve(to: CGPoint(x: offset, y: 5), control: CGPoint(x: offset + 2, y: 0))
                ridge.path = path
                ridge.strokeColor = SKColor(red: 0.85, green: 0.65, blue: 0.45, alpha: 0.6)
                ridge.lineWidth = 1.0
                visualNode.addChild(ridge)
            }

        case .goldenSeashell:
            let shell = SKShapeNode(ellipseOf: CGSize(width: 18, height: 14))
            shell.fillColor = SKColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
            shell.strokeColor = SKColor(red: 0.85, green: 0.65, blue: 0.0, alpha: 1.0)
            shell.lineWidth = 2.0
            shell.glowWidth = 3.0
            visualNode.addChild(shell)

            let sparkle = SKShapeNode(circleOfRadius: 2)
            sparkle.fillColor = .white
            sparkle.strokeColor = .clear
            sparkle.position = CGPoint(x: 3, y: 3)
            sparkle.glowWidth = 2.0
            visualNode.addChild(sparkle)

        case .heartPiece:
            let heartPath = CGMutablePath()
            heartPath.move(to: CGPoint(x: 0, y: -6))
            heartPath.addCurve(to: CGPoint(x: 0, y: 6),
                               control1: CGPoint(x: -12, y: -2),
                               control2: CGPoint(x: -6, y: 10))
            heartPath.addCurve(to: CGPoint(x: 0, y: -6),
                               control1: CGPoint(x: 6, y: 10),
                               control2: CGPoint(x: 12, y: -2))
            let heart = SKShapeNode(path: heartPath)
            heart.fillColor = SKColor(red: 1.0, green: 0.2, blue: 0.3, alpha: 1.0)
            heart.strokeColor = SKColor(red: 0.8, green: 0.1, blue: 0.2, alpha: 1.0)
            heart.lineWidth = 1.5
            visualNode.addChild(heart)

        case .extraLife:
            let star = createStarPath(points: 5, outerRadius: 10, innerRadius: 5)
            let starNode = SKShapeNode(path: star)
            starNode.fillColor = SKColor(red: 0.2, green: 0.9, blue: 0.5, alpha: 1.0)
            starNode.strokeColor = SKColor(red: 0.1, green: 0.7, blue: 0.4, alpha: 1.0)
            starNode.lineWidth = 1.5
            starNode.glowWidth = 2.0
            visualNode.addChild(starNode)

        case .starfish:
            let star = createStarPath(points: 5, outerRadius: 10, innerRadius: 5)
            let starNode = SKShapeNode(path: star)
            starNode.fillColor = SKColor(red: 1.0, green: 0.42, blue: 0.42, alpha: 1.0)
            starNode.strokeColor = SKColor(red: 0.85, green: 0.3, blue: 0.3, alpha: 1.0)
            starNode.lineWidth = 1.5
            visualNode.addChild(starNode)

        case .pearlOfWisdom:
            let pearl = SKShapeNode(circleOfRadius: 8)
            pearl.fillColor = SKColor(red: 0.9, green: 0.9, blue: 0.95, alpha: 1.0)
            pearl.strokeColor = SKColor(red: 0.7, green: 0.7, blue: 0.8, alpha: 1.0)
            pearl.lineWidth = 1.5
            pearl.glowWidth = 4.0
            visualNode.addChild(pearl)

            let highlight = SKShapeNode(circleOfRadius: 3)
            highlight.fillColor = SKColor(white: 1.0, alpha: 0.6)
            highlight.strokeColor = .clear
            highlight.position = CGPoint(x: -2, y: 2)
            visualNode.addChild(highlight)
        }
    }

    private func setupPhysics() {
        let body = SKPhysicsBody(circleOfRadius: 12)
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.collectible
        body.contactTestBitMask = PhysicsCategory.player
        body.collisionBitMask = PhysicsCategory.none
        self.physicsBody = body
    }

    private func startAnimation() {
        let float = SKAction.repeatForever(SKAction.sequence([
            SKAction.moveBy(x: 0, y: 6, duration: 1.0),
            SKAction.moveBy(x: 0, y: -6, duration: 1.0)
        ]))
        visualNode.run(float)

        if type == .goldenSeashell || type == .extraLife {
            let rotate = SKAction.repeatForever(SKAction.rotate(byAngle: .pi * 2, duration: 3.0))
            visualNode.run(rotate)
        }
    }

    func collect() {
        guard !collected else { return }
        collected = true

        physicsBody?.categoryBitMask = PhysicsCategory.none
        physicsBody?.contactTestBitMask = PhysicsCategory.none

        let collectSequence = SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 1.5, duration: 0.2),
                SKAction.fadeOut(duration: 0.3),
                SKAction.moveBy(x: 0, y: 30, duration: 0.3)
            ]),
            SKAction.removeFromParent()
        ])
        run(collectSequence)

        createCollectParticles()
    }

    private func createCollectParticles() {
        guard let parent = self.parent else { return }
        for _ in 0..<6 {
            let particle = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...4))
            particle.fillColor = type == .goldenSeashell ? SKColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 0.9) :
                                 SKColor(red: 1.0, green: 0.9, blue: 0.7, alpha: 0.9)
            particle.strokeColor = .clear
            particle.position = self.position
            particle.zPosition = 50
            parent.addChild(particle)

            let move = SKAction.moveBy(x: CGFloat.random(in: -30...30),
                                        y: CGFloat.random(in: 10...40),
                                        duration: 0.5)
            let fade = SKAction.fadeOut(duration: 0.5)
            particle.run(SKAction.sequence([
                SKAction.group([move, fade]),
                SKAction.removeFromParent()
            ]))
        }
    }

    private func createStarPath(points: Int, outerRadius: CGFloat, innerRadius: CGFloat) -> CGPath {
        let path = CGMutablePath()
        for i in 0..<(points * 2) {
            let angle = (CGFloat(i) / CGFloat(points * 2)) * .pi * 2 - .pi / 2
            let r = (i % 2 == 0) ? outerRadius : innerRadius
            let x = cos(angle) * r
            let y = sin(angle) * r
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        return path
    }

    var scoreValue: Int {
        switch type {
        case .seashell: return 50
        case .goldenSeashell: return 200
        case .heartPiece: return 0
        case .extraLife: return 0
        case .starfish: return 100
        case .pearlOfWisdom: return 500
        }
    }
}
