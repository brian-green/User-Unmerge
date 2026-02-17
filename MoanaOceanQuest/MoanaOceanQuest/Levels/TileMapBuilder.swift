import SpriteKit

class TileMapBuilder {

    static func buildGround(segments: [GroundSegmentData], groundColor: CodableColor, in scene: SKScene) {
        for segment in segments {
            let width = segment.endX - segment.startX
            let height = segment.height

            let ground = SKSpriteNode(color: groundColor.skColor,
                                       size: CGSize(width: width, height: height))
            ground.anchorPoint = CGPoint(x: 0, y: 0)
            ground.position = CGPoint(x: segment.startX, y: 0)
            ground.zPosition = -5
            ground.name = "ground"

            let body = SKPhysicsBody(rectangleOf: ground.size,
                                      center: CGPoint(x: width / 2, y: height / 2))
            body.isDynamic = false
            body.friction = 0.6
            body.restitution = 0.0
            body.categoryBitMask = PhysicsCategory.ground
            body.contactTestBitMask = PhysicsCategory.player
            body.collisionBitMask = PhysicsCategory.player | PhysicsCategory.enemy
            ground.physicsBody = body

            scene.addChild(ground)

            // Surface detail strip
            let surfaceStrip = SKSpriteNode(
                color: SKColor(red: groundColor.red * 1.15,
                               green: groundColor.green * 1.2,
                               blue: groundColor.blue * 0.9,
                               alpha: 1.0),
                size: CGSize(width: width, height: 4))
            surfaceStrip.anchorPoint = CGPoint(x: 0, y: 0)
            surfaceStrip.position = CGPoint(x: 0, y: height - 4)
            surfaceStrip.zPosition = 0.1
            ground.addChild(surfaceStrip)
        }
    }

    static func buildPlatform(_ data: PlatformData, in scene: SKScene) {
        let platform = SKSpriteNode(color: SKColor(red: 0.5, green: 0.4, blue: 0.3, alpha: 1.0),
                                     size: data.size)
        platform.position = data.position
        platform.zPosition = -3
        platform.name = "platform"

        let body = SKPhysicsBody(rectangleOf: data.size)
        body.isDynamic = false
        body.friction = 0.8
        body.categoryBitMask = PhysicsCategory.platform
        body.contactTestBitMask = PhysicsCategory.player
        body.collisionBitMask = PhysicsCategory.player | PhysicsCategory.enemy
        platform.physicsBody = body

        scene.addChild(platform)

        switch data.type {
        case .moving:
            if let target = data.moveTarget, let duration = data.moveDuration {
                let moveToEnd = SKAction.move(to: target, duration: duration)
                let moveToStart = SKAction.move(to: data.position, duration: duration)
                let sequence = SKAction.repeatForever(SKAction.sequence([moveToEnd, moveToStart]))
                platform.run(sequence)
            }

        case .breakable:
            platform.color = SKColor(red: 0.6, green: 0.45, blue: 0.3, alpha: 0.8)
            // Cracks drawn on the surface
            let crack = SKShapeNode()
            let crackPath = CGMutablePath()
            crackPath.move(to: CGPoint(x: -data.size.width * 0.3, y: 0))
            crackPath.addLine(to: CGPoint(x: 0, y: data.size.height * 0.2))
            crackPath.addLine(to: CGPoint(x: data.size.width * 0.3, y: -data.size.height * 0.1))
            crack.path = crackPath
            crack.strokeColor = SKColor(red: 0.4, green: 0.3, blue: 0.2, alpha: 0.5)
            crack.lineWidth = 1.0
            crack.zPosition = 0.1
            platform.addChild(crack)

        case .floating:
            platform.color = SKColor(red: 0.6, green: 0.5, blue: 0.3, alpha: 0.9)
            let bob = SKAction.repeatForever(SKAction.sequence([
                SKAction.moveBy(x: 0, y: 5, duration: 1.0),
                SKAction.moveBy(x: 0, y: -5, duration: 1.0)
            ]))
            platform.run(bob)

        case .crumbling:
            platform.color = SKColor(red: 0.55, green: 0.42, blue: 0.28, alpha: 0.9)

        case .swinging:
            let pivot = SKNode()
            pivot.position = CGPoint(x: data.position.x, y: data.position.y + 60)
            scene.addChild(pivot)

            platform.position = CGPoint(x: data.position.x, y: data.position.y)
            let swing = SKAction.repeatForever(SKAction.sequence([
                SKAction.rotate(toAngle: 0.4, duration: 1.5),
                SKAction.rotate(toAngle: -0.4, duration: 1.5)
            ]))
            pivot.run(swing)

        case .static:
            break
        }
    }

    static func buildWaterZone(_ data: WaterZoneData, in scene: SKScene) {
        let waterColor = data.waterColor?.skColor ?? SKColor(red: 0.0, green: 0.4, blue: 0.8, alpha: 0.6)
        let waterSurface = WaterSurface(width: data.size.width, height: data.size.height, color: waterColor)
        waterSurface.position = data.position
        waterSurface.zPosition = 5
        waterSurface.name = "water"
        scene.addChild(waterSurface)

        if data.hasCurrents {
            let currentZone = WaterCurrentZone(
                size: data.size,
                direction: data.currentDirection,
                strength: 80
            )
            currentZone.position = data.position
            currentZone.zPosition = 6
            scene.addChild(currentZone)
        }
    }

    static func buildDecoration(_ data: DecorationData, in scene: SKScene) {
        let decoration = createDecorationNode(type: data.type)
        decoration.position = data.position
        decoration.setScale(data.scale)
        decoration.zPosition = -8
        scene.addChild(decoration)
    }

    private static func createDecorationNode(type: DecorationType) -> SKNode {
        let node = SKNode()

        switch type {
        case .palmTree:
            let trunk = SKShapeNode(rectOf: CGSize(width: 8, height: 60))
            trunk.fillColor = SKColor(red: 0.45, green: 0.3, blue: 0.15, alpha: 1.0)
            trunk.strokeColor = .clear
            trunk.position = CGPoint(x: 0, y: 30)
            node.addChild(trunk)

            let leaves = SKShapeNode(circleOfRadius: 20)
            leaves.fillColor = SKColor(red: 0.15, green: 0.6, blue: 0.2, alpha: 1.0)
            leaves.strokeColor = .clear
            leaves.position = CGPoint(x: 0, y: 65)
            node.addChild(leaves)

        case .coconutTree:
            let trunk = SKShapeNode(rectOf: CGSize(width: 8, height: 70))
            trunk.fillColor = SKColor(red: 0.5, green: 0.35, blue: 0.18, alpha: 1.0)
            trunk.strokeColor = .clear
            trunk.position = CGPoint(x: 0, y: 35)
            node.addChild(trunk)

            let leaves = SKShapeNode(circleOfRadius: 22)
            leaves.fillColor = SKColor(red: 0.2, green: 0.55, blue: 0.15, alpha: 1.0)
            leaves.strokeColor = .clear
            leaves.position = CGPoint(x: 0, y: 75)
            node.addChild(leaves)

            for i in 0..<3 {
                let coconut = SKShapeNode(circleOfRadius: 4)
                coconut.fillColor = SKColor(red: 0.5, green: 0.35, blue: 0.15, alpha: 1.0)
                coconut.strokeColor = .clear
                coconut.position = CGPoint(x: CGFloat(i - 1) * 6, y: 62)
                node.addChild(coconut)
            }

        case .rock, .smallRock:
            let size: CGFloat = type == .rock ? 20 : 10
            let rock = SKShapeNode(ellipseOf: CGSize(width: size * 1.4, height: size))
            rock.fillColor = SKColor(red: 0.5, green: 0.48, blue: 0.45, alpha: 1.0)
            rock.strokeColor = SKColor(red: 0.4, green: 0.38, blue: 0.35, alpha: 1.0)
            rock.lineWidth = 1.0
            node.addChild(rock)

        case .coral, .coralFan:
            let coral = SKShapeNode(circleOfRadius: 12)
            coral.fillColor = SKColor(red: 1.0, green: 0.42, blue: 0.42, alpha: 0.9)
            coral.strokeColor = .clear
            node.addChild(coral)

            let branch = SKShapeNode(rectOf: CGSize(width: 4, height: 15))
            branch.fillColor = SKColor(red: 1.0, green: 0.5, blue: 0.5, alpha: 0.9)
            branch.strokeColor = .clear
            branch.position = CGPoint(x: 0, y: 12)
            node.addChild(branch)

        case .crystal, .glowingCrystal:
            let crystalPath = CGMutablePath()
            crystalPath.move(to: CGPoint(x: 0, y: 20))
            crystalPath.addLine(to: CGPoint(x: -6, y: 0))
            crystalPath.addLine(to: CGPoint(x: 6, y: 0))
            crystalPath.closeSubpath()
            let crystal = SKShapeNode(path: crystalPath)
            crystal.fillColor = type == .glowingCrystal ?
                SKColor(red: 0.3, green: 0.9, blue: 1.0, alpha: 0.9) :
                SKColor(red: 0.6, green: 0.5, blue: 0.8, alpha: 0.9)
            crystal.strokeColor = .clear
            node.addChild(crystal)

            if type == .glowingCrystal {
                crystal.glowWidth = 5.0
                let pulse = SKAction.repeatForever(SKAction.sequence([
                    SKAction.fadeAlpha(to: 0.5, duration: 1.0),
                    SKAction.fadeAlpha(to: 1.0, duration: 1.0)
                ]))
                crystal.run(pulse)
            }

        case .flower:
            let stem = SKShapeNode(rectOf: CGSize(width: 2, height: 12))
            stem.fillColor = SKColor(red: 0.2, green: 0.6, blue: 0.2, alpha: 1.0)
            stem.strokeColor = .clear
            stem.position = CGPoint(x: 0, y: 6)
            node.addChild(stem)

            let petals = SKShapeNode(circleOfRadius: 5)
            petals.fillColor = SKColor(red: 1.0, green: 0.5, blue: 0.6, alpha: 1.0)
            petals.strokeColor = .clear
            petals.position = CGPoint(x: 0, y: 14)
            node.addChild(petals)

        case .fern:
            for i in 0..<3 {
                let frond = SKShapeNode(ellipseOf: CGSize(width: 6, height: 18))
                frond.fillColor = SKColor(red: 0.15, green: 0.55, blue: 0.2, alpha: 0.9)
                frond.strokeColor = .clear
                frond.position = CGPoint(x: CGFloat(i - 1) * 6, y: 8)
                frond.zRotation = CGFloat(i - 1) * 0.3
                node.addChild(frond)
            }

        case .tikiTorch:
            let pole = SKShapeNode(rectOf: CGSize(width: 5, height: 40))
            pole.fillColor = SKColor(red: 0.5, green: 0.35, blue: 0.2, alpha: 1.0)
            pole.strokeColor = .clear
            pole.position = CGPoint(x: 0, y: 20)
            node.addChild(pole)

            let flame = SKShapeNode(circleOfRadius: 6)
            flame.fillColor = SKColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 0.8)
            flame.strokeColor = .clear
            flame.glowWidth = 4.0
            flame.position = CGPoint(x: 0, y: 44)
            node.addChild(flame)

            let flicker = SKAction.repeatForever(SKAction.sequence([
                SKAction.fadeAlpha(to: 0.5, duration: 0.2),
                SKAction.fadeAlpha(to: 1.0, duration: 0.2)
            ]))
            flame.run(flicker)

        case .totemPole:
            let pole = SKShapeNode(rectOf: CGSize(width: 16, height: 50))
            pole.fillColor = SKColor(red: 0.5, green: 0.35, blue: 0.2, alpha: 1.0)
            pole.strokeColor = SKColor(red: 0.4, green: 0.28, blue: 0.15, alpha: 1.0)
            pole.lineWidth = 2
            pole.position = CGPoint(x: 0, y: 25)
            node.addChild(pole)

            // Face carving
            let face = SKShapeNode(rectOf: CGSize(width: 12, height: 12))
            face.fillColor = SKColor(red: 0.45, green: 0.3, blue: 0.18, alpha: 1.0)
            face.strokeColor = .clear
            face.position = CGPoint(x: 0, y: 35)
            node.addChild(face)

        case .driftwood:
            let wood = SKShapeNode(rectOf: CGSize(width: 30, height: 6), cornerRadius: 3)
            wood.fillColor = SKColor(red: 0.55, green: 0.42, blue: 0.28, alpha: 0.8)
            wood.strokeColor = .clear
            wood.zRotation = CGFloat.random(in: -0.3...0.3)
            node.addChild(wood)

        case .seaweed:
            for i in 0..<3 {
                let strand = SKShapeNode(rectOf: CGSize(width: 3, height: 25))
                strand.fillColor = SKColor(red: 0.1, green: 0.5, blue: 0.2, alpha: 0.8)
                strand.strokeColor = .clear
                strand.position = CGPoint(x: CGFloat(i - 1) * 5, y: 12)
                strand.zRotation = CGFloat(i - 1) * 0.15
                node.addChild(strand)
            }

            let sway = SKAction.repeatForever(SKAction.sequence([
                SKAction.rotate(toAngle: 0.1, duration: 1.5),
                SKAction.rotate(toAngle: -0.1, duration: 1.5)
            ]))
            node.run(sway)

        case .stalactite:
            let stalPath = CGMutablePath()
            stalPath.move(to: CGPoint(x: -8, y: 0))
            stalPath.addLine(to: CGPoint(x: 0, y: -25))
            stalPath.addLine(to: CGPoint(x: 8, y: 0))
            stalPath.closeSubpath()
            let stal = SKShapeNode(path: stalPath)
            stal.fillColor = SKColor(red: 0.5, green: 0.48, blue: 0.45, alpha: 1.0)
            stal.strokeColor = .clear
            node.addChild(stal)

        case .stalagmite:
            let stagPath = CGMutablePath()
            stagPath.move(to: CGPoint(x: -8, y: 0))
            stagPath.addLine(to: CGPoint(x: 0, y: 25))
            stagPath.addLine(to: CGPoint(x: 8, y: 0))
            stagPath.closeSubpath()
            let stag = SKShapeNode(path: stagPath)
            stag.fillColor = SKColor(red: 0.5, green: 0.48, blue: 0.45, alpha: 1.0)
            stag.strokeColor = .clear
            node.addChild(stag)

        case .lavaRock:
            let rock = SKShapeNode(ellipseOf: CGSize(width: 22, height: 16))
            rock.fillColor = SKColor(red: 0.3, green: 0.12, blue: 0.05, alpha: 1.0)
            rock.strokeColor = SKColor(red: 1.0, green: 0.4, blue: 0.0, alpha: 0.5)
            rock.lineWidth = 1.5
            node.addChild(rock)

        case .volcano:
            let volPath = CGMutablePath()
            volPath.move(to: CGPoint(x: -40, y: 0))
            volPath.addLine(to: CGPoint(x: -10, y: 60))
            volPath.addLine(to: CGPoint(x: 10, y: 60))
            volPath.addLine(to: CGPoint(x: 40, y: 0))
            volPath.closeSubpath()
            let vol = SKShapeNode(path: volPath)
            vol.fillColor = SKColor(red: 0.35, green: 0.2, blue: 0.12, alpha: 1.0)
            vol.strokeColor = .clear
            node.addChild(vol)

        case .sacredStone:
            let stone = SKShapeNode(rectOf: CGSize(width: 20, height: 30), cornerRadius: 3)
            stone.fillColor = SKColor(red: 0.4, green: 0.45, blue: 0.5, alpha: 1.0)
            stone.strokeColor = SKColor(red: 0.2, green: 0.9, blue: 0.5, alpha: 0.5)
            stone.lineWidth = 2
            stone.glowWidth = 3.0
            stone.position = CGPoint(x: 0, y: 15)
            node.addChild(stone)

        case .spiralShell:
            let shell = SKShapeNode(circleOfRadius: 10)
            shell.fillColor = SKColor(red: 0.9, green: 0.8, blue: 0.7, alpha: 1.0)
            shell.strokeColor = SKColor(red: 0.7, green: 0.6, blue: 0.5, alpha: 1.0)
            shell.lineWidth = 1.5
            node.addChild(shell)
        }

        return node
    }

    static func buildBoundaries(levelLength: CGFloat, sceneHeight: CGFloat, in scene: SKScene) {
        // Left boundary
        let leftWall = SKNode()
        leftWall.position = CGPoint(x: 0, y: sceneHeight / 2)
        leftWall.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 1, height: sceneHeight * 2))
        leftWall.physicsBody?.isDynamic = false
        leftWall.physicsBody?.categoryBitMask = PhysicsCategory.boundary
        scene.addChild(leftWall)

        // Right boundary
        let rightWall = SKNode()
        rightWall.position = CGPoint(x: levelLength, y: sceneHeight / 2)
        rightWall.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 1, height: sceneHeight * 2))
        rightWall.physicsBody?.isDynamic = false
        rightWall.physicsBody?.categoryBitMask = PhysicsCategory.boundary
        scene.addChild(rightWall)

        // Death pit at bottom
        let deathPit = SKNode()
        deathPit.position = CGPoint(x: levelLength / 2, y: -50)
        deathPit.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: levelLength + 200, height: 10))
        deathPit.physicsBody?.isDynamic = false
        deathPit.physicsBody?.categoryBitMask = PhysicsCategory.boundary
        deathPit.physicsBody?.contactTestBitMask = PhysicsCategory.player
        deathPit.name = "deathPit"
        scene.addChild(deathPit)
    }
}
