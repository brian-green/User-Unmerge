import SpriteKit

class MainMenuScene: SKScene {

    // MARK: - Constants
    private let sceneWidth: CGFloat = 1334
    private let sceneHeight: CGFloat = 750

    // MARK: - Colors
    private let skyTopColor = SKColor(red: 0.1, green: 0.5, blue: 0.9, alpha: 1.0)
    private let skyBottomColor = SKColor(red: 0.4, green: 0.75, blue: 1.0, alpha: 1.0)
    private let oceanDeepColor = SKColor(red: 0.0, green: 0.2, blue: 0.5, alpha: 1.0)
    private let oceanSurfaceColor = SKColor(red: 0.0, green: 0.55, blue: 0.8, alpha: 1.0)
    private let sandColor = SKColor(red: 0.93, green: 0.87, blue: 0.7, alpha: 1.0)
    private let palmTrunkColor = SKColor(red: 0.45, green: 0.3, blue: 0.15, alpha: 1.0)
    private let palmLeafColor = SKColor(red: 0.15, green: 0.6, blue: 0.2, alpha: 1.0)
    private let coralColor = SKColor(red: 1.0, green: 0.42, blue: 0.42, alpha: 1.0)
    private let goldColor = SKColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
    private let turquoiseColor = SKColor(red: 0.0, green: 0.81, blue: 0.82, alpha: 1.0)

    // MARK: - Nodes
    private var waveLayers: [[SKShapeNode]] = []
    private var cloudNodes: [SKSpriteNode] = []
    private var palmTreeNodes: [SKNode] = []

    // MARK: - Lifecycle
    override func didMove(to view: SKView) {
        backgroundColor = skyTopColor
        buildSkyGradient()
        buildClouds()
        buildOcean()
        buildIsland()
        buildPalmTrees()
        buildTitle()
        buildMenuButtons()
        buildDecorations()
        startAnimations()
    }

    // MARK: - Sky
    private func buildSkyGradient() {
        let stripeCount = 12
        let stripeHeight = sceneHeight * 0.55 / CGFloat(stripeCount)

        for i in 0..<stripeCount {
            let fraction = CGFloat(i) / CGFloat(stripeCount - 1)
            let r = lerp(skyTopColor.redComponent, skyBottomColor.redComponent, fraction)
            let g = lerp(skyTopColor.greenComponent, skyBottomColor.greenComponent, fraction)
            let b = lerp(skyTopColor.blueComponent, skyBottomColor.blueComponent, fraction)

            let stripe = SKSpriteNode(color: SKColor(red: r, green: g, blue: b, alpha: 1.0),
                                       size: CGSize(width: sceneWidth, height: stripeHeight + 1))
            stripe.anchorPoint = CGPoint(x: 0, y: 0)
            stripe.position = CGPoint(x: 0, y: sceneHeight - CGFloat(i + 1) * stripeHeight)
            stripe.zPosition = -100
            addChild(stripe)
        }

        // Sun
        let sunGlow = SKShapeNode(circleOfRadius: 80)
        sunGlow.fillColor = SKColor(red: 1.0, green: 0.95, blue: 0.6, alpha: 0.3)
        sunGlow.strokeColor = .clear
        sunGlow.position = CGPoint(x: sceneWidth * 0.8, y: sceneHeight * 0.78)
        sunGlow.zPosition = -95
        addChild(sunGlow)

        let sun = SKShapeNode(circleOfRadius: 45)
        sun.fillColor = SKColor(red: 1.0, green: 0.9, blue: 0.3, alpha: 1.0)
        sun.strokeColor = SKColor(red: 1.0, green: 0.95, blue: 0.6, alpha: 0.6)
        sun.lineWidth = 6
        sun.position = CGPoint(x: sceneWidth * 0.8, y: sceneHeight * 0.78)
        sun.zPosition = -94
        addChild(sun)

        let pulse = SKAction.repeatForever(SKAction.sequence([
            SKAction.scale(to: 1.08, duration: 2.0),
            SKAction.scale(to: 1.0, duration: 2.0)
        ]))
        sunGlow.run(pulse)
    }

    // MARK: - Clouds
    private func buildClouds() {
        let cloudData: [(x: CGFloat, y: CGFloat, scaleX: CGFloat, speed: CGFloat)] = [
            (200, sceneHeight * 0.85, 1.0, 12),
            (500, sceneHeight * 0.9, 1.4, 18),
            (900, sceneHeight * 0.82, 0.8, 10),
            (1200, sceneHeight * 0.88, 1.2, 15),
            (-100, sceneHeight * 0.92, 1.1, 20)
        ]

        for data in cloudData {
            let cloud = createCloud(scaleX: data.scaleX)
            cloud.position = CGPoint(x: data.x, y: data.y)
            cloud.zPosition = -90
            addChild(cloud)
            cloudNodes.append(cloud)

            let moveRight = SKAction.moveTo(x: sceneWidth + 200, duration: TimeInterval(data.speed))
            let reset = SKAction.moveTo(x: -200, duration: 0)
            let moveLeft = SKAction.moveTo(x: sceneWidth + 200, duration: TimeInterval(data.speed))
            cloud.run(SKAction.repeatForever(SKAction.sequence([moveRight, reset, moveLeft])))
        }
    }

    private func createCloud(scaleX: CGFloat) -> SKSpriteNode {
        let container = SKSpriteNode(color: .clear, size: CGSize(width: 120 * scaleX, height: 40))

        let puffs: [(dx: CGFloat, dy: CGFloat, radius: CGFloat)] = [
            (0, 0, 22), (-25, -3, 16), (28, -2, 18), (-10, 10, 14), (15, 8, 15)
        ]

        for puff in puffs {
            let circle = SKShapeNode(circleOfRadius: puff.radius)
            circle.fillColor = SKColor(white: 1.0, alpha: 0.9)
            circle.strokeColor = .clear
            circle.position = CGPoint(x: puff.dx * scaleX, y: puff.dy)
            container.addChild(circle)
        }

        return container
    }

    // MARK: - Ocean
    private func buildOcean() {
        // Deep ocean body
        let oceanBody = SKSpriteNode(color: oceanDeepColor,
                                      size: CGSize(width: sceneWidth, height: sceneHeight * 0.4))
        oceanBody.anchorPoint = CGPoint(x: 0, y: 0)
        oceanBody.position = CGPoint(x: 0, y: 0)
        oceanBody.zPosition = -50
        addChild(oceanBody)

        // Mid ocean
        let midOcean = SKSpriteNode(color: oceanSurfaceColor,
                                     size: CGSize(width: sceneWidth, height: sceneHeight * 0.1))
        midOcean.anchorPoint = CGPoint(x: 0, y: 0)
        midOcean.position = CGPoint(x: 0, y: sceneHeight * 0.35)
        midOcean.zPosition = -49
        addChild(midOcean)

        // Animated wave layers
        buildWaveLayer(yBase: sceneHeight * 0.45, amplitude: 10, frequency: 1.5,
                       color: SKColor(red: 0.0, green: 0.65, blue: 0.9, alpha: 0.7),
                       zPos: -40, segmentCount: 50, phaseOffset: 0)
        buildWaveLayer(yBase: sceneHeight * 0.42, amplitude: 8, frequency: 2.0,
                       color: SKColor(red: 0.0, green: 0.5, blue: 0.85, alpha: 0.6),
                       zPos: -41, segmentCount: 50, phaseOffset: 1.5)
        buildWaveLayer(yBase: sceneHeight * 0.39, amplitude: 6, frequency: 2.5,
                       color: SKColor(red: 0.0, green: 0.45, blue: 0.75, alpha: 0.5),
                       zPos: -42, segmentCount: 50, phaseOffset: 3.0)

        // Foam highlights on water
        for i in 0..<6 {
            let foam = SKShapeNode(ellipseOf: CGSize(width: CGFloat.random(in: 40...80), height: 4))
            foam.fillColor = SKColor(white: 1.0, alpha: 0.25)
            foam.strokeColor = .clear
            foam.position = CGPoint(x: CGFloat.random(in: 100...sceneWidth - 100),
                                     y: CGFloat.random(in: sceneHeight * 0.15...sceneHeight * 0.35))
            foam.zPosition = -45
            addChild(foam)

            let drift = SKAction.repeatForever(SKAction.sequence([
                SKAction.moveBy(x: CGFloat.random(in: -30...30), y: CGFloat.random(in: -5...5),
                                duration: Double.random(in: 3...6)),
                SKAction.moveBy(x: CGFloat.random(in: -30...30), y: CGFloat.random(in: -5...5),
                                duration: Double.random(in: 3...6))
            ]))
            let fade = SKAction.repeatForever(SKAction.sequence([
                SKAction.fadeAlpha(to: 0.1, duration: Double.random(in: 2...4)),
                SKAction.fadeAlpha(to: 0.3, duration: Double.random(in: 2...4))
            ]))
            foam.run(SKAction.group([drift, fade]))
            _ = i
        }
    }

    private func buildWaveLayer(yBase: CGFloat, amplitude: CGFloat, frequency: CGFloat,
                                 color: SKColor, zPos: CGFloat, segmentCount: Int, phaseOffset: CGFloat) {
        var segments: [SKShapeNode] = []
        let segmentWidth = sceneWidth / CGFloat(segmentCount)

        for i in 0..<segmentCount {
            let seg = SKShapeNode(rectOf: CGSize(width: segmentWidth + 1, height: amplitude * 2))
            seg.fillColor = color
            seg.strokeColor = .clear
            seg.position = CGPoint(x: CGFloat(i) * segmentWidth + segmentWidth / 2, y: yBase)
            seg.zPosition = zPos
            addChild(seg)
            segments.append(seg)
        }
        waveLayers.append(segments)
    }

    // MARK: - Island
    private func buildIsland() {
        // Sand mound on the left side
        let islandPath = CGMutablePath()
        islandPath.move(to: CGPoint(x: 0, y: sceneHeight * 0.45))
        islandPath.addQuadCurve(to: CGPoint(x: 400, y: sceneHeight * 0.45),
                                 control: CGPoint(x: 200, y: sceneHeight * 0.62))
        islandPath.addLine(to: CGPoint(x: 400, y: 0))
        islandPath.addLine(to: CGPoint(x: 0, y: 0))
        islandPath.closeSubpath()

        let island = SKShapeNode(path: islandPath)
        island.fillColor = sandColor
        island.strokeColor = SKColor(red: 0.82, green: 0.76, blue: 0.58, alpha: 1.0)
        island.lineWidth = 2
        island.zPosition = -30
        addChild(island)

        // Beach vegetation patches
        for i in 0..<5 {
            let bush = SKShapeNode(circleOfRadius: CGFloat.random(in: 10...20))
            bush.fillColor = SKColor(red: CGFloat.random(in: 0.2...0.4),
                                      green: CGFloat.random(in: 0.55...0.75),
                                      blue: CGFloat.random(in: 0.1...0.3), alpha: 0.9)
            bush.strokeColor = .clear
            bush.position = CGPoint(x: CGFloat.random(in: 30...350),
                                     y: sceneHeight * 0.48 + CGFloat.random(in: 0...30))
            bush.zPosition = -25
            addChild(bush)
            _ = i
        }

        // Small rocks on the beach
        for _ in 0..<4 {
            let rock = SKShapeNode(ellipseOf: CGSize(width: CGFloat.random(in: 8...16),
                                                      height: CGFloat.random(in: 6...10)))
            rock.fillColor = SKColor(red: 0.55, green: 0.52, blue: 0.48, alpha: 1.0)
            rock.strokeColor = .clear
            rock.position = CGPoint(x: CGFloat.random(in: 50...380),
                                     y: sceneHeight * 0.45 + CGFloat.random(in: -5...5))
            rock.zPosition = -28
            addChild(rock)
        }
    }

    // MARK: - Palm Trees
    private func buildPalmTrees() {
        buildPalmTree(at: CGPoint(x: 100, y: sceneHeight * 0.52), scale: 1.0, lean: 0.15)
        buildPalmTree(at: CGPoint(x: 250, y: sceneHeight * 0.55), scale: 0.8, lean: -0.1)
        buildPalmTree(at: CGPoint(x: 50, y: sceneHeight * 0.48), scale: 0.6, lean: 0.2)
    }

    private func buildPalmTree(at position: CGPoint, scale: CGFloat, lean: CGFloat) {
        let treeNode = SKNode()
        treeNode.position = position
        treeNode.zPosition = -20
        treeNode.setScale(scale)
        addChild(treeNode)
        palmTreeNodes.append(treeNode)

        // Trunk
        let trunkPath = CGMutablePath()
        trunkPath.move(to: CGPoint(x: 0, y: 0))
        trunkPath.addQuadCurve(to: CGPoint(x: lean * 100, y: 130),
                                control: CGPoint(x: lean * 40, y: 65))
        let trunk = SKShapeNode(path: trunkPath)
        trunk.strokeColor = palmTrunkColor
        trunk.lineWidth = 10
        trunk.lineCap = .round
        treeNode.addChild(trunk)

        // Trunk segments
        for i in 1..<6 {
            let y = CGFloat(i) * 22
            let x = lean * 100 * (y / 130)
            let ring = SKShapeNode(ellipseOf: CGSize(width: 12, height: 4))
            ring.position = CGPoint(x: x, y: y)
            ring.strokeColor = SKColor(red: 0.35, green: 0.22, blue: 0.1, alpha: 0.5)
            ring.lineWidth = 1
            ring.fillColor = .clear
            treeNode.addChild(ring)
        }

        // Fronds (leaves)
        let topPoint = CGPoint(x: lean * 100, y: 130)
        let frondAngles: [CGFloat] = [-0.9, -0.4, 0.0, 0.4, 0.9, -0.7, 0.7]
        for angle in frondAngles {
            let frond = createFrond(angle: angle)
            frond.position = topPoint
            treeNode.addChild(frond)
        }

        // Coconuts
        for i in 0..<3 {
            let coconut = SKShapeNode(circleOfRadius: 5)
            coconut.fillColor = SKColor(red: 0.55, green: 0.35, blue: 0.15, alpha: 1.0)
            coconut.strokeColor = SKColor(red: 0.4, green: 0.25, blue: 0.1, alpha: 1.0)
            coconut.lineWidth = 1
            coconut.position = CGPoint(x: topPoint.x + CGFloat(i - 1) * 8, y: topPoint.y - 8)
            treeNode.addChild(coconut)
        }
    }

    private func createFrond(angle: CGFloat) -> SKShapeNode {
        let length: CGFloat = 70
        let endX = cos(angle + .pi / 2) * length * 0.3 + sin(angle) * length
        let endY = sin(angle + .pi / 2) * length * 0.3 + cos(angle) * length * 0.4

        let frondPath = CGMutablePath()
        frondPath.move(to: .zero)
        frondPath.addQuadCurve(to: CGPoint(x: endX, y: endY),
                                control: CGPoint(x: endX * 0.5 + sin(angle) * 20,
                                                  y: endY * 0.5 + 20))

        let frond = SKShapeNode(path: frondPath)
        frond.strokeColor = palmLeafColor
        frond.lineWidth = 5
        frond.lineCap = .round
        frond.zPosition = 1

        // Leaf blades along the frond
        for t in stride(from: 0.3, through: 1.0, by: 0.15) {
            let px = endX * CGFloat(t)
            let py = endY * CGFloat(t)
            let blade = SKShapeNode(ellipseOf: CGSize(width: 18, height: 5))
            blade.fillColor = palmLeafColor
            blade.strokeColor = .clear
            blade.position = CGPoint(x: px, y: py)
            blade.zRotation = angle + .pi / 4
            frond.addChild(blade)
        }

        return frond
    }

    // MARK: - Title
    private func buildTitle() {
        // Title shadow
        let titleShadow = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        titleShadow.text = "Ocean Quest"
        titleShadow.fontSize = 72
        titleShadow.fontColor = SKColor(red: 0.0, green: 0.15, blue: 0.35, alpha: 0.5)
        titleShadow.position = CGPoint(x: sceneWidth * 0.55 + 3, y: sceneHeight * 0.72 - 3)
        titleShadow.zPosition = 200
        addChild(titleShadow)

        // Title main
        let title = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        title.text = "Ocean Quest"
        title.fontSize = 72
        title.fontColor = goldColor
        title.position = CGPoint(x: sceneWidth * 0.55, y: sceneHeight * 0.72)
        title.zPosition = 201
        addChild(title)

        // Title outline effect using a second label
        let titleOutline = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        titleOutline.text = "Ocean Quest"
        titleOutline.fontSize = 72
        titleOutline.fontColor = SKColor(red: 0.85, green: 0.55, blue: 0.0, alpha: 1.0)
        titleOutline.position = CGPoint(x: sceneWidth * 0.55 + 1, y: sceneHeight * 0.72 + 1)
        titleOutline.zPosition = 200.5
        addChild(titleOutline)

        // Subtitle
        let subtitle = SKLabelNode(fontNamed: "AvenirNext-Medium")
        subtitle.text = "A Polynesian Adventure"
        subtitle.fontSize = 22
        subtitle.fontColor = SKColor(white: 1.0, alpha: 0.9)
        subtitle.position = CGPoint(x: sceneWidth * 0.55, y: sceneHeight * 0.65)
        subtitle.zPosition = 201
        addChild(subtitle)

        // Title float animation
        let float = SKAction.repeatForever(SKAction.sequence([
            SKAction.moveBy(x: 0, y: 8, duration: 1.5),
            SKAction.moveBy(x: 0, y: -8, duration: 1.5)
        ]))
        title.run(float)
        titleShadow.run(float)
        titleOutline.run(float)
        subtitle.run(float)

        // Sparkle particles around the title
        for _ in 0..<8 {
            let sparkle = SKShapeNode(circleOfRadius: CGFloat.random(in: 1.5...3))
            sparkle.fillColor = goldColor
            sparkle.strokeColor = .clear
            sparkle.position = CGPoint(x: sceneWidth * 0.55 + CGFloat.random(in: -200...200),
                                        y: sceneHeight * 0.72 + CGFloat.random(in: -20...40))
            sparkle.zPosition = 202
            sparkle.alpha = 0
            addChild(sparkle)

            let twinkle = SKAction.repeatForever(SKAction.sequence([
                SKAction.wait(forDuration: Double.random(in: 0...3)),
                SKAction.fadeAlpha(to: 1.0, duration: 0.3),
                SKAction.fadeAlpha(to: 0.0, duration: 0.3),
                SKAction.wait(forDuration: Double.random(in: 1...4))
            ]))
            sparkle.run(twinkle)
        }
    }

    // MARK: - Menu Buttons
    private func buildMenuButtons() {
        let buttonCenterX = sceneWidth * 0.55
        let buttonStartY = sceneHeight * 0.46

        createMenuButton(text: "Play", position: CGPoint(x: buttonCenterX, y: buttonStartY),
                          name: "playButton",
                          color: SKColor(red: 0.0, green: 0.75, blue: 0.55, alpha: 1.0),
                          width: 220, height: 55, fontSize: 32)

        createMenuButton(text: "Select Level", position: CGPoint(x: buttonCenterX, y: buttonStartY - 70),
                          name: "levelSelectButton",
                          color: turquoiseColor,
                          width: 220, height: 55, fontSize: 28)

        createMenuButton(text: "Settings", position: CGPoint(x: buttonCenterX, y: buttonStartY - 140),
                          name: "settingsButton",
                          color: SKColor(red: 0.55, green: 0.4, blue: 0.7, alpha: 1.0),
                          width: 220, height: 55, fontSize: 28)
    }

    private func createMenuButton(text: String, position: CGPoint, name: String,
                                    color: SKColor, width: CGFloat, height: CGFloat, fontSize: CGFloat) {
        let container = SKNode()
        container.position = position
        container.name = name
        container.zPosition = 300

        // Button shadow
        let shadow = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: 14)
        shadow.fillColor = SKColor(white: 0, alpha: 0.3)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 3, y: -3)
        container.addChild(shadow)

        // Button background
        let bg = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: 14)
        bg.fillColor = color
        bg.strokeColor = SKColor(white: 1, alpha: 0.3)
        bg.lineWidth = 2
        bg.name = name
        container.addChild(bg)

        // Button highlight (top half for gloss)
        let highlight = SKShapeNode(rectOf: CGSize(width: width - 8, height: height / 2 - 4), cornerRadius: 10)
        highlight.fillColor = SKColor(white: 1, alpha: 0.15)
        highlight.strokeColor = .clear
        highlight.position = CGPoint(x: 0, y: height / 4 - 2)
        container.addChild(highlight)

        // Button text
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = text
        label.fontSize = fontSize
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.name = name
        container.addChild(label)

        addChild(container)

        // Subtle pulse
        let pulse = SKAction.repeatForever(SKAction.sequence([
            SKAction.scale(to: 1.03, duration: 1.2),
            SKAction.scale(to: 1.0, duration: 1.2)
        ]))
        container.run(pulse)
    }

    // MARK: - Decorations
    private func buildDecorations() {
        // Seashells on the beach
        let shellPositions: [(CGFloat, CGFloat)] = [
            (80, sceneHeight * 0.46), (160, sceneHeight * 0.47),
            (300, sceneHeight * 0.46), (370, sceneHeight * 0.44)
        ]
        for (x, y) in shellPositions {
            let shell = SKShapeNode(ellipseOf: CGSize(width: 8, height: 6))
            shell.fillColor = SKColor(red: 1.0, green: 0.85, blue: 0.75, alpha: 1.0)
            shell.strokeColor = coralColor
            shell.lineWidth = 1
            shell.position = CGPoint(x: x, y: y)
            shell.zPosition = -18
            addChild(shell)
        }

        // Starfish
        let starfish = createStarfish()
        starfish.position = CGPoint(x: 220, y: sceneHeight * 0.47)
        starfish.zPosition = -18
        addChild(starfish)

        // Distant islands (silhouettes)
        buildDistantIsland(at: CGPoint(x: sceneWidth * 0.65, y: sceneHeight * 0.44), width: 80, height: 30)
        buildDistantIsland(at: CGPoint(x: sceneWidth * 0.85, y: sceneHeight * 0.43), width: 60, height: 20)

        // Birds in the sky
        for _ in 0..<4 {
            let bird = createBird()
            bird.position = CGPoint(x: CGFloat.random(in: 400...sceneWidth),
                                     y: CGFloat.random(in: sceneHeight * 0.6...sceneHeight * 0.8))
            bird.zPosition = -85
            bird.setScale(CGFloat.random(in: 0.5...1.0))
            addChild(bird)

            let flyAcross = SKAction.repeatForever(SKAction.sequence([
                SKAction.moveTo(x: sceneWidth + 50, duration: Double.random(in: 8...15)),
                SKAction.moveTo(x: -50, duration: 0),
                SKAction.moveTo(x: sceneWidth + 50, duration: Double.random(in: 8...15))
            ]))
            bird.run(flyAcross)
        }

        // Animated character silhouette (small Moana figure on the beach)
        buildMoanaFigure()
    }

    private func createStarfish() -> SKNode {
        let node = SKNode()
        let armCount = 5
        for i in 0..<armCount {
            let angle = (CGFloat(i) / CGFloat(armCount)) * .pi * 2 - .pi / 2
            let arm = SKShapeNode(ellipseOf: CGSize(width: 4, height: 10))
            arm.fillColor = coralColor
            arm.strokeColor = .clear
            arm.position = CGPoint(x: cos(angle) * 5, y: sin(angle) * 5)
            arm.zRotation = angle
            node.addChild(arm)
        }
        node.setScale(0.8)
        return node
    }

    private func buildDistantIsland(at position: CGPoint, width: CGFloat, height: CGFloat) {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -width / 2, y: 0))
        path.addQuadCurve(to: CGPoint(x: width / 2, y: 0),
                           control: CGPoint(x: 0, y: height))
        path.closeSubpath()

        let island = SKShapeNode(path: path)
        island.fillColor = SKColor(red: 0.2, green: 0.45, blue: 0.3, alpha: 0.4)
        island.strokeColor = .clear
        island.position = position
        island.zPosition = -55
        addChild(island)
    }

    private func createBird() -> SKNode {
        let bird = SKNode()
        let leftWing = SKShapeNode()
        let leftPath = CGMutablePath()
        leftPath.move(to: .zero)
        leftPath.addQuadCurve(to: CGPoint(x: -10, y: 6), control: CGPoint(x: -5, y: 8))
        leftWing.path = leftPath
        leftWing.strokeColor = SKColor(red: 0.2, green: 0.2, blue: 0.25, alpha: 0.7)
        leftWing.lineWidth = 1.5
        bird.addChild(leftWing)

        let rightWing = SKShapeNode()
        let rightPath = CGMutablePath()
        rightPath.move(to: .zero)
        rightPath.addQuadCurve(to: CGPoint(x: 10, y: 6), control: CGPoint(x: 5, y: 8))
        rightWing.path = rightPath
        rightWing.strokeColor = SKColor(red: 0.2, green: 0.2, blue: 0.25, alpha: 0.7)
        rightWing.lineWidth = 1.5
        bird.addChild(rightWing)

        // Wing flap
        let flapUp = SKAction.run {
            let upLeft = CGMutablePath()
            upLeft.move(to: .zero)
            upLeft.addQuadCurve(to: CGPoint(x: -10, y: 8), control: CGPoint(x: -5, y: 10))
            leftWing.path = upLeft
            let upRight = CGMutablePath()
            upRight.move(to: .zero)
            upRight.addQuadCurve(to: CGPoint(x: 10, y: 8), control: CGPoint(x: 5, y: 10))
            rightWing.path = upRight
        }
        let flapDown = SKAction.run {
            let downLeft = CGMutablePath()
            downLeft.move(to: .zero)
            downLeft.addQuadCurve(to: CGPoint(x: -10, y: 2), control: CGPoint(x: -5, y: 0))
            leftWing.path = downLeft
            let downRight = CGMutablePath()
            downRight.move(to: .zero)
            downRight.addQuadCurve(to: CGPoint(x: 10, y: 2), control: CGPoint(x: 5, y: 0))
            rightWing.path = downRight
        }
        let flap = SKAction.repeatForever(SKAction.sequence([
            flapUp, SKAction.wait(forDuration: 0.3),
            flapDown, SKAction.wait(forDuration: 0.3)
        ]))
        bird.run(flap)

        return bird
    }

    private func buildMoanaFigure() {
        let figure = SKNode()
        figure.position = CGPoint(x: 340, y: sceneHeight * 0.47)
        figure.zPosition = -15
        figure.setScale(0.9)

        // Body
        let body = SKSpriteNode(color: SKColor(red: 0.76, green: 0.58, blue: 0.42, alpha: 1.0),
                                  size: CGSize(width: 12, height: 24))
        body.position = CGPoint(x: 0, y: 12)
        figure.addChild(body)

        // Head
        let head = SKShapeNode(circleOfRadius: 6)
        head.fillColor = SKColor(red: 0.76, green: 0.58, blue: 0.42, alpha: 1.0)
        head.strokeColor = .clear
        head.position = CGPoint(x: 0, y: 28)
        figure.addChild(head)

        // Hair
        let hair = SKSpriteNode(color: SKColor(red: 0.15, green: 0.1, blue: 0.08, alpha: 1.0),
                                  size: CGSize(width: 14, height: 10))
        hair.position = CGPoint(x: -1, y: 31)
        figure.addChild(hair)

        // Outfit
        let outfit = SKSpriteNode(color: SKColor(red: 0.85, green: 0.2, blue: 0.15, alpha: 1.0),
                                    size: CGSize(width: 12, height: 10))
        outfit.position = CGPoint(x: 0, y: 14)
        figure.addChild(outfit)

        addChild(figure)

        // Idle sway
        let sway = SKAction.repeatForever(SKAction.sequence([
            SKAction.rotate(toAngle: 0.05, duration: 1.5),
            SKAction.rotate(toAngle: -0.05, duration: 1.5)
        ]))
        figure.run(sway)
    }

    // MARK: - Animations
    private func startAnimations() {
        // Wave animation via scene update
        let waveAction = SKAction.repeatForever(SKAction.sequence([
            SKAction.wait(forDuration: 1.0 / 30.0),
            SKAction.run { [weak self] in self?.updateWaves() }
        ]))
        run(waveAction, withKey: "waveAnimation")

        // Palm tree sway
        for tree in palmTreeNodes {
            let sway = SKAction.repeatForever(SKAction.sequence([
                SKAction.rotate(toAngle: 0.04, duration: Double.random(in: 2.0...3.5)),
                SKAction.rotate(toAngle: -0.04, duration: Double.random(in: 2.0...3.5))
            ]))
            tree.run(sway)
        }
    }

    private var waveTime: CGFloat = 0

    private func updateWaves() {
        waveTime += 0.033

        for (layerIndex, layer) in waveLayers.enumerated() {
            let layerFrequency: CGFloat = [1.5, 2.0, 2.5][layerIndex]
            let layerPhase: CGFloat = [0, 1.5, 3.0][layerIndex]
            let layerAmplitude: CGFloat = [10, 8, 6][layerIndex]

            for (i, segment) in layer.enumerated() {
                let x = CGFloat(i) / CGFloat(layer.count)
                let offset = sin(x * layerFrequency * .pi * 2 + waveTime * 2.0 + layerPhase) * layerAmplitude
                segment.position.y = [sceneHeight * 0.45, sceneHeight * 0.42, sceneHeight * 0.39][layerIndex] + offset
            }
        }
    }

    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)

        for node in touchedNodes {
            if let name = node.name ?? node.parent?.name {
                switch name {
                case "playButton":
                    animateButtonPress(name: name) { [weak self] in
                        self?.transitionToGame(level: 1)
                    }
                case "levelSelectButton":
                    animateButtonPress(name: name) { [weak self] in
                        self?.transitionToLevelSelect()
                    }
                case "settingsButton":
                    animateButtonPress(name: name) { [weak self] in
                        self?.showSettings()
                    }
                default:
                    break
                }
            }
        }
    }

    private func animateButtonPress(name: String, completion: @escaping () -> Void) {
        guard let button = childNode(withName: name) else {
            completion()
            return
        }

        let press = SKAction.sequence([
            SKAction.scale(to: 0.92, duration: 0.08),
            SKAction.scale(to: 1.05, duration: 0.08),
            SKAction.scale(to: 1.0, duration: 0.06),
            SKAction.run(completion)
        ])
        button.run(press)
    }

    // MARK: - Scene Transitions
    private func transitionToGame(level: Int) {
        let transition = SKTransition.fade(withDuration: 0.8)
        let gameScene = GameScene(size: size)
        gameScene.scaleMode = scaleMode
        gameScene.currentLevel = level
        view?.presentScene(gameScene, transition: transition)
    }

    private func transitionToLevelSelect() {
        let transition = SKTransition.push(with: .left, duration: 0.6)
        let levelSelect = LevelSelectScene(size: size)
        levelSelect.scaleMode = scaleMode
        view?.presentScene(levelSelect, transition: transition)
    }

    private func showSettings() {
        // Settings panel overlay
        if childNode(withName: "settingsPanel") != nil { return }

        let overlay = SKSpriteNode(color: SKColor(white: 0, alpha: 0.6),
                                    size: CGSize(width: sceneWidth, height: sceneHeight))
        overlay.position = CGPoint(x: sceneWidth / 2, y: sceneHeight / 2)
        overlay.zPosition = 500
        overlay.name = "settingsOverlay"
        addChild(overlay)

        let panel = SKShapeNode(rectOf: CGSize(width: 400, height: 350), cornerRadius: 20)
        panel.fillColor = SKColor(red: 0.05, green: 0.2, blue: 0.4, alpha: 0.95)
        panel.strokeColor = goldColor
        panel.lineWidth = 3
        panel.position = CGPoint(x: sceneWidth / 2, y: sceneHeight / 2)
        panel.zPosition = 510
        panel.name = "settingsPanel"
        addChild(panel)

        let settingsTitle = SKLabelNode(fontNamed: "AvenirNext-Bold")
        settingsTitle.text = "Settings"
        settingsTitle.fontSize = 36
        settingsTitle.fontColor = goldColor
        settingsTitle.position = CGPoint(x: 0, y: 120)
        panel.addChild(settingsTitle)

        // Sound toggle
        let soundLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        soundLabel.text = "Sound: ON"
        soundLabel.fontSize = 24
        soundLabel.fontColor = .white
        soundLabel.position = CGPoint(x: 0, y: 50)
        soundLabel.name = "soundToggle"
        panel.addChild(soundLabel)

        // Music toggle
        let musicLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        musicLabel.text = "Music: ON"
        musicLabel.fontSize = 24
        musicLabel.fontColor = .white
        musicLabel.position = CGPoint(x: 0, y: 0)
        musicLabel.name = "musicToggle"
        panel.addChild(musicLabel)

        // Close button
        let closeButton = SKShapeNode(rectOf: CGSize(width: 160, height: 44), cornerRadius: 12)
        closeButton.fillColor = coralColor
        closeButton.strokeColor = .clear
        closeButton.position = CGPoint(x: 0, y: -100)
        closeButton.name = "closeSettings"
        panel.addChild(closeButton)

        let closeLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        closeLabel.text = "Close"
        closeLabel.fontSize = 22
        closeLabel.fontColor = .white
        closeLabel.verticalAlignmentMode = .center
        closeLabel.name = "closeSettings"
        closeButton.addChild(closeLabel)

        // Animate panel entrance
        panel.setScale(0.3)
        panel.alpha = 0
        panel.run(SKAction.group([
            SKAction.scale(to: 1.0, duration: 0.3),
            SKAction.fadeIn(withDuration: 0.3)
        ]))
    }

    private func dismissSettings() {
        if let panel = childNode(withName: "settingsPanel") {
            panel.run(SKAction.sequence([
                SKAction.group([
                    SKAction.scale(to: 0.3, duration: 0.2),
                    SKAction.fadeOut(duration: 0.2)
                ]),
                SKAction.removeFromParent()
            ]))
        }
        childNode(withName: "settingsOverlay")?.run(SKAction.sequence([
            SKAction.fadeOut(duration: 0.2),
            SKAction.removeFromParent()
        ]))
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)

        for node in touchedNodes {
            if node.name == "closeSettings" || node.parent?.name == "closeSettings" {
                dismissSettings()
                return
            }
            if node.name == "settingsOverlay" {
                dismissSettings()
                return
            }
        }
    }

    // MARK: - Helpers
    private func lerp(_ a: CGFloat, _ b: CGFloat, _ t: CGFloat) -> CGFloat {
        return a + (b - a) * t
    }
}
