import SpriteKit

class LevelSelectScene: SKScene {

    // MARK: - Constants
    private let sceneWidth: CGFloat = 1334
    private let sceneHeight: CGFloat = 750

    // MARK: - Level Data
    private struct LevelInfo {
        let number: Int
        let name: String
        let mapPosition: CGPoint
    }

    private let levels: [LevelInfo] = [
        LevelInfo(number: 1, name: "Motunui Village",
                  mapPosition: CGPoint(x: 180, y: 420)),
        LevelInfo(number: 2, name: "The Reef",
                  mapPosition: CGPoint(x: 350, y: 340)),
        LevelInfo(number: 3, name: "Open Ocean",
                  mapPosition: CGPoint(x: 530, y: 280)),
        LevelInfo(number: 4, name: "Kakamora Ambush",
                  mapPosition: CGPoint(x: 680, y: 370)),
        LevelInfo(number: 5, name: "Lalotai",
                  mapPosition: CGPoint(x: 820, y: 280)),
        LevelInfo(number: 6, name: "Tamatoa's Lair",
                  mapPosition: CGPoint(x: 900, y: 420)),
        LevelInfo(number: 7, name: "Maui's Island",
                  mapPosition: CGPoint(x: 1020, y: 330)),
        LevelInfo(number: 8, name: "Te Ka's Domain",
                  mapPosition: CGPoint(x: 1100, y: 460)),
        LevelInfo(number: 9, name: "The Storm",
                  mapPosition: CGPoint(x: 1180, y: 320)),
        LevelInfo(number: 10, name: "Te Fiti's Restoration",
                  mapPosition: CGPoint(x: 1240, y: 200))
    ]

    // MARK: - Colors
    private let oceanColor = SKColor(red: 0.05, green: 0.3, blue: 0.6, alpha: 1.0)
    private let deepOceanColor = SKColor(red: 0.02, green: 0.15, blue: 0.4, alpha: 1.0)
    private let islandColor = SKColor(red: 0.93, green: 0.87, blue: 0.7, alpha: 1.0)
    private let greenColor = SKColor(red: 0.2, green: 0.65, blue: 0.25, alpha: 1.0)
    private let lockedColor = SKColor(red: 0.35, green: 0.35, blue: 0.4, alpha: 1.0)
    private let goldColor = SKColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
    private let starEmptyColor = SKColor(red: 0.4, green: 0.4, blue: 0.45, alpha: 0.6)
    private let turquoiseColor = SKColor(red: 0.0, green: 0.81, blue: 0.82, alpha: 1.0)

    // MARK: - State
    private var levelButtons: [SKNode] = []
    private var selectedLevel: Int?

    // MARK: - Lifecycle
    override func didMove(to view: SKView) {
        backgroundColor = oceanColor
        buildBackground()
        buildTitle()
        buildLevelNodes()
        buildDottedPath()
        buildBackButton()
        buildLegend()
        startAnimations()
    }

    // MARK: - Background
    private func buildBackground() {
        // Ocean gradient stripes
        let stripeCount = 8
        let stripeHeight = sceneHeight / CGFloat(stripeCount)
        for i in 0..<stripeCount {
            let fraction = CGFloat(i) / CGFloat(stripeCount - 1)
            let r = lerp(0.05, 0.02, fraction)
            let g = lerp(0.35, 0.15, fraction)
            let b = lerp(0.65, 0.45, fraction)
            let stripe = SKSpriteNode(color: SKColor(red: r, green: g, blue: b, alpha: 1.0),
                                       size: CGSize(width: sceneWidth, height: stripeHeight + 1))
            stripe.anchorPoint = CGPoint(x: 0, y: 0)
            stripe.position = CGPoint(x: 0, y: sceneHeight - CGFloat(i + 1) * stripeHeight)
            stripe.zPosition = -100
            addChild(stripe)
        }

        // Decorative wave lines across the map
        for row in 0..<6 {
            let y = CGFloat(row) * 130 + 50
            buildMapWaveLine(y: y, amplitude: 5, segments: 60,
                              color: SKColor(red: 0.1, green: 0.4, blue: 0.7, alpha: 0.15))
        }

        // Compass rose in the corner
        buildCompassRose(at: CGPoint(x: 80, y: sceneHeight - 100))
    }

    private func buildMapWaveLine(y: CGFloat, amplitude: CGFloat, segments: Int, color: SKColor) {
        let segWidth = sceneWidth / CGFloat(segments)
        for i in 0..<segments {
            let x = CGFloat(i) * segWidth + segWidth / 2
            let offset = sin(CGFloat(i) * 0.3) * amplitude
            let dot = SKShapeNode(circleOfRadius: 1.5)
            dot.fillColor = color
            dot.strokeColor = .clear
            dot.position = CGPoint(x: x, y: y + offset)
            dot.zPosition = -90
            addChild(dot)
        }
    }

    private func buildCompassRose(at position: CGPoint) {
        let compass = SKNode()
        compass.position = position
        compass.zPosition = -80
        compass.setScale(0.6)

        let circle = SKShapeNode(circleOfRadius: 35)
        circle.fillColor = SKColor(red: 0.8, green: 0.7, blue: 0.5, alpha: 0.3)
        circle.strokeColor = SKColor(red: 0.8, green: 0.7, blue: 0.5, alpha: 0.5)
        circle.lineWidth = 2
        compass.addChild(circle)

        let directions = ["N", "E", "S", "W"]
        let angles: [CGFloat] = [.pi / 2, 0, -.pi / 2, .pi]
        for (i, dir) in directions.enumerated() {
            let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
            label.text = dir
            label.fontSize = 14
            label.fontColor = SKColor(red: 0.8, green: 0.7, blue: 0.5, alpha: 0.6)
            label.verticalAlignmentMode = .center
            label.horizontalAlignmentMode = .center
            label.position = CGPoint(x: cos(angles[i]) * 28, y: sin(angles[i]) * 28)
            compass.addChild(label)
        }

        // Arrow pointing north
        let arrowPath = CGMutablePath()
        arrowPath.move(to: CGPoint(x: 0, y: 10))
        arrowPath.addLine(to: CGPoint(x: -5, y: -5))
        arrowPath.addLine(to: CGPoint(x: 5, y: -5))
        arrowPath.closeSubpath()
        let arrow = SKShapeNode(path: arrowPath)
        arrow.fillColor = SKColor(red: 0.8, green: 0.7, blue: 0.5, alpha: 0.5)
        arrow.strokeColor = .clear
        compass.addChild(arrow)

        addChild(compass)
    }

    // MARK: - Title
    private func buildTitle() {
        let titleBG = SKShapeNode(rectOf: CGSize(width: 400, height: 55), cornerRadius: 12)
        titleBG.fillColor = SKColor(red: 0.0, green: 0.15, blue: 0.35, alpha: 0.8)
        titleBG.strokeColor = goldColor
        titleBG.lineWidth = 2
        titleBG.position = CGPoint(x: sceneWidth / 2, y: sceneHeight - 45)
        titleBG.zPosition = 100
        addChild(titleBG)

        let title = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        title.text = "Select Your Voyage"
        title.fontSize = 32
        title.fontColor = goldColor
        title.verticalAlignmentMode = .center
        title.position = CGPoint(x: sceneWidth / 2, y: sceneHeight - 45)
        title.zPosition = 101
        addChild(title)
    }

    // MARK: - Level Nodes
    private func buildLevelNodes() {
        let maxUnlocked = GameManager.shared.highestUnlockedLevel

        for levelInfo in levels {
            let isUnlocked = levelInfo.number <= maxUnlocked
            let stars = GameManager.shared.starsForLevel(levelInfo.number)
            let node = createIslandButton(level: levelInfo, unlocked: isUnlocked, stars: stars)
            addChild(node)
            levelButtons.append(node)
        }
    }

    private func createIslandButton(level: LevelInfo, unlocked: Bool, stars: Int) -> SKNode {
        let container = SKNode()
        container.position = level.mapPosition
        container.zPosition = 10
        container.name = "level_\(level.number)"

        // Island shape
        let islandSize: CGFloat = unlocked ? 50 : 40
        let islandPath = CGMutablePath()
        islandPath.move(to: CGPoint(x: -islandSize / 2, y: 0))
        islandPath.addQuadCurve(to: CGPoint(x: islandSize / 2, y: 0),
                                 control: CGPoint(x: 0, y: islandSize * 0.6))
        islandPath.addQuadCurve(to: CGPoint(x: -islandSize / 2, y: 0),
                                 control: CGPoint(x: 0, y: -islandSize * 0.2))
        islandPath.closeSubpath()

        let island = SKShapeNode(path: islandPath)
        island.fillColor = unlocked ? islandColor : lockedColor
        island.strokeColor = unlocked ? SKColor(red: 0.7, green: 0.6, blue: 0.4, alpha: 1.0) : SKColor(red: 0.25, green: 0.25, blue: 0.3, alpha: 1.0)
        island.lineWidth = 2
        island.name = "level_\(level.number)"
        container.addChild(island)

        if unlocked {
            // Vegetation on island
            let vegetation = SKShapeNode(circleOfRadius: islandSize * 0.25)
            vegetation.fillColor = greenColor
            vegetation.strokeColor = .clear
            vegetation.position = CGPoint(x: 0, y: islandSize * 0.2)
            container.addChild(vegetation)

            // Small palm tree
            let palmTrunk = SKShapeNode(rectOf: CGSize(width: 3, height: 18))
            palmTrunk.fillColor = SKColor(red: 0.45, green: 0.3, blue: 0.15, alpha: 1.0)
            palmTrunk.strokeColor = .clear
            palmTrunk.position = CGPoint(x: CGFloat.random(in: -5...5), y: islandSize * 0.35)
            container.addChild(palmTrunk)

            let leafCluster = SKShapeNode(circleOfRadius: 7)
            leafCluster.fillColor = SKColor(red: 0.15, green: 0.55, blue: 0.2, alpha: 1.0)
            leafCluster.strokeColor = .clear
            leafCluster.position = CGPoint(x: palmTrunk.position.x, y: palmTrunk.position.y + 12)
            container.addChild(leafCluster)

            // Water ring around island
            let waterRing = SKShapeNode(circleOfRadius: islandSize * 0.6)
            waterRing.fillColor = .clear
            waterRing.strokeColor = turquoiseColor.withAlphaComponent(0.4)
            waterRing.lineWidth = 2
            waterRing.position = CGPoint(x: 0, y: islandSize * 0.1)
            container.addChild(waterRing)
        }

        // Level number badge
        let badgeRadius: CGFloat = 14
        let badge = SKShapeNode(circleOfRadius: badgeRadius)
        badge.fillColor = unlocked ? SKColor(red: 0.0, green: 0.55, blue: 0.8, alpha: 1.0) : lockedColor
        badge.strokeColor = unlocked ? .white : SKColor(white: 0.5, alpha: 1.0)
        badge.lineWidth = 2
        badge.position = CGPoint(x: 0, y: -islandSize * 0.3)
        badge.zPosition = 5
        badge.name = "level_\(level.number)"
        container.addChild(badge)

        if unlocked {
            let numberLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
            numberLabel.text = "\(level.number)"
            numberLabel.fontSize = 16
            numberLabel.fontColor = .white
            numberLabel.verticalAlignmentMode = .center
            numberLabel.name = "level_\(level.number)"
            badge.addChild(numberLabel)
        } else {
            // Lock icon (simple padlock shape)
            let lockBody = SKShapeNode(rectOf: CGSize(width: 10, height: 8), cornerRadius: 1)
            lockBody.fillColor = SKColor(white: 0.6, alpha: 1.0)
            lockBody.strokeColor = .clear
            lockBody.position = CGPoint(x: 0, y: -2)
            badge.addChild(lockBody)

            let lockArc = SKShapeNode(circleOfRadius: 5)
            lockArc.fillColor = .clear
            lockArc.strokeColor = SKColor(white: 0.6, alpha: 1.0)
            lockArc.lineWidth = 2
            lockArc.position = CGPoint(x: 0, y: 4)
            badge.addChild(lockArc)

            // Cover bottom half of arc
            let lockCover = SKSpriteNode(color: lockedColor, size: CGSize(width: 12, height: 6))
            lockCover.position = CGPoint(x: 0, y: 1)
            lockCover.zPosition = 1
            badge.addChild(lockCover)
        }

        // Level name label
        let nameLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        nameLabel.text = level.name
        nameLabel.fontSize = 11
        nameLabel.fontColor = unlocked ? .white : SKColor(white: 0.5, alpha: 1.0)
        nameLabel.position = CGPoint(x: 0, y: -islandSize * 0.3 - 22)
        nameLabel.zPosition = 6
        container.addChild(nameLabel)

        // Star rating
        if unlocked {
            buildStarRating(stars: stars, parent: container,
                             position: CGPoint(x: 0, y: -islandSize * 0.3 - 36))
        }

        // Glow for current highest unlocked level
        if unlocked && level.number == GameManager.shared.highestUnlockedLevel {
            let glow = SKShapeNode(circleOfRadius: islandSize * 0.7)
            glow.fillColor = SKColor(red: 0.2, green: 0.9, blue: 0.5, alpha: 0.15)
            glow.strokeColor = SKColor(red: 0.2, green: 0.9, blue: 0.5, alpha: 0.4)
            glow.lineWidth = 2
            glow.position = CGPoint(x: 0, y: islandSize * 0.1)
            glow.zPosition = -1
            container.addChild(glow)

            let pulse = SKAction.repeatForever(SKAction.sequence([
                SKAction.scale(to: 1.15, duration: 1.0),
                SKAction.scale(to: 1.0, duration: 1.0)
            ]))
            glow.run(pulse)
        }

        return container
    }

    private func buildStarRating(stars: Int, parent: SKNode, position: CGPoint) {
        let starSpacing: CGFloat = 18
        let startX = position.x - starSpacing

        for i in 0..<3 {
            let filled = i < stars
            let star = createStarShape(radius: 6, filled: filled)
            star.position = CGPoint(x: startX + CGFloat(i) * starSpacing, y: position.y)
            star.zPosition = 6
            parent.addChild(star)
        }
    }

    private func createStarShape(radius: CGFloat, filled: Bool) -> SKShapeNode {
        let points = 5
        let path = CGMutablePath()
        for i in 0..<(points * 2) {
            let angle = (CGFloat(i) / CGFloat(points * 2)) * .pi * 2 - .pi / 2
            let r = (i % 2 == 0) ? radius : radius * 0.45
            let x = cos(angle) * r
            let y = sin(angle) * r
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()

        let star = SKShapeNode(path: path)
        star.fillColor = filled ? goldColor : starEmptyColor
        star.strokeColor = filled ? SKColor(red: 0.85, green: 0.65, blue: 0.0, alpha: 1.0) : .clear
        star.lineWidth = filled ? 1 : 0
        return star
    }

    // MARK: - Dotted Path
    private func buildDottedPath() {
        for i in 0..<(levels.count - 1) {
            let start = levels[i].mapPosition
            let end = levels[i + 1].mapPosition
            let unlocked = i + 2 <= GameManager.shared.highestUnlockedLevel

            let distance = hypot(end.x - start.x, end.y - start.y)
            let dotCount = Int(distance / 12)

            for d in 0..<dotCount {
                let t = CGFloat(d) / CGFloat(dotCount)
                let x = start.x + (end.x - start.x) * t
                let y = start.y + (end.y - start.y) * t

                let dot = SKShapeNode(circleOfRadius: 2)
                dot.fillColor = unlocked
                    ? SKColor(red: 0.9, green: 0.8, blue: 0.5, alpha: 0.7)
                    : SKColor(white: 0.3, alpha: 0.4)
                dot.strokeColor = .clear
                dot.position = CGPoint(x: x, y: y)
                dot.zPosition = 1
                addChild(dot)
            }
        }
    }

    // MARK: - Back Button
    private func buildBackButton() {
        let backContainer = SKNode()
        backContainer.position = CGPoint(x: 80, y: sceneHeight - 45)
        backContainer.zPosition = 100
        backContainer.name = "backButton"

        let bg = SKShapeNode(rectOf: CGSize(width: 90, height: 40), cornerRadius: 10)
        bg.fillColor = SKColor(red: 0.0, green: 0.35, blue: 0.55, alpha: 0.9)
        bg.strokeColor = SKColor(white: 1.0, alpha: 0.3)
        bg.lineWidth = 1.5
        bg.name = "backButton"
        backContainer.addChild(bg)

        // Arrow
        let arrowPath = CGMutablePath()
        arrowPath.move(to: CGPoint(x: -10, y: 0))
        arrowPath.addLine(to: CGPoint(x: -2, y: 6))
        arrowPath.move(to: CGPoint(x: -10, y: 0))
        arrowPath.addLine(to: CGPoint(x: -2, y: -6))
        let arrow = SKShapeNode(path: arrowPath)
        arrow.strokeColor = .white
        arrow.lineWidth = 2.5
        arrow.lineCap = .round
        arrow.position = CGPoint(x: -18, y: 0)
        arrow.name = "backButton"
        backContainer.addChild(arrow)

        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = "Back"
        label.fontSize = 18
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.position = CGPoint(x: 8, y: 0)
        label.name = "backButton"
        backContainer.addChild(label)

        addChild(backContainer)
    }

    // MARK: - Legend
    private func buildLegend() {
        let legendY: CGFloat = 40

        let starFull = createStarShape(radius: 8, filled: true)
        starFull.position = CGPoint(x: sceneWidth - 180, y: legendY)
        starFull.zPosition = 100
        addChild(starFull)

        let legendLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        legendLabel.text = "= Completed"
        legendLabel.fontSize = 13
        legendLabel.fontColor = SKColor(white: 0.7, alpha: 1.0)
        legendLabel.horizontalAlignmentMode = .left
        legendLabel.verticalAlignmentMode = .center
        legendLabel.position = CGPoint(x: sceneWidth - 168, y: legendY)
        legendLabel.zPosition = 100
        addChild(legendLabel)

        let lockIcon = SKShapeNode(circleOfRadius: 8)
        lockIcon.fillColor = lockedColor
        lockIcon.strokeColor = SKColor(white: 0.5, alpha: 1.0)
        lockIcon.lineWidth = 1.5
        lockIcon.position = CGPoint(x: sceneWidth - 310, y: legendY)
        lockIcon.zPosition = 100
        addChild(lockIcon)

        let lockedLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        lockedLabel.text = "= Locked"
        lockedLabel.fontSize = 13
        lockedLabel.fontColor = SKColor(white: 0.7, alpha: 1.0)
        lockedLabel.horizontalAlignmentMode = .left
        lockedLabel.verticalAlignmentMode = .center
        lockedLabel.position = CGPoint(x: sceneWidth - 298, y: legendY)
        lockedLabel.zPosition = 100
        addChild(lockedLabel)
    }

    // MARK: - Animations
    private func startAnimations() {
        // Gentle bob on unlocked islands
        let maxUnlocked = GameManager.shared.highestUnlockedLevel
        for (i, button) in levelButtons.enumerated() {
            if i + 1 <= maxUnlocked {
                let delay = Double(i) * 0.15
                let bob = SKAction.sequence([
                    SKAction.wait(forDuration: delay),
                    SKAction.repeatForever(SKAction.sequence([
                        SKAction.moveBy(x: 0, y: 4, duration: Double.random(in: 1.5...2.5)),
                        SKAction.moveBy(x: 0, y: -4, duration: Double.random(in: 1.5...2.5))
                    ]))
                ])
                button.run(bob)
            }
        }

        // Subtle ocean shimmer
        let shimmer = SKAction.repeatForever(SKAction.sequence([
            SKAction.run { [weak self] in
                guard let self = self else { return }
                let sparkle = SKShapeNode(circleOfRadius: CGFloat.random(in: 1...3))
                sparkle.fillColor = SKColor(white: 1.0, alpha: CGFloat.random(in: 0.1...0.3))
                sparkle.strokeColor = .clear
                sparkle.position = CGPoint(x: CGFloat.random(in: 0...self.sceneWidth),
                                            y: CGFloat.random(in: 0...self.sceneHeight))
                sparkle.zPosition = -50
                self.addChild(sparkle)
                sparkle.run(SKAction.sequence([
                    SKAction.fadeOut(duration: Double.random(in: 1...3)),
                    SKAction.removeFromParent()
                ]))
            },
            SKAction.wait(forDuration: 0.3)
        ]))
        run(shimmer, withKey: "shimmer")
    }

    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)

        for node in touchedNodes {
            if let name = node.name ?? node.parent?.name ?? node.parent?.parent?.name {
                if name == "backButton" {
                    animatePress(nodeName: name) { [weak self] in
                        self?.transitionToMainMenu()
                    }
                    return
                }

                if name.hasPrefix("level_") {
                    if let levelNum = Int(name.replacingOccurrences(of: "level_", with: "")) {
                        if levelNum <= GameManager.shared.highestUnlockedLevel {
                            highlightLevel(levelNum)
                            animatePress(nodeName: name) { [weak self] in
                                self?.transitionToGame(level: levelNum)
                            }
                        } else {
                            shakeLockedLevel(levelNum)
                        }
                    }
                    return
                }
            }
        }
    }

    private func highlightLevel(_ level: Int) {
        selectedLevel = level
    }

    private func shakeLockedLevel(_ level: Int) {
        guard let button = levelButtons[safe: level - 1] else { return }
        let shake = SKAction.sequence([
            SKAction.moveBy(x: -5, y: 0, duration: 0.05),
            SKAction.moveBy(x: 10, y: 0, duration: 0.05),
            SKAction.moveBy(x: -10, y: 0, duration: 0.05),
            SKAction.moveBy(x: 10, y: 0, duration: 0.05),
            SKAction.moveBy(x: -5, y: 0, duration: 0.05)
        ])
        button.run(shake)
    }

    private func animatePress(nodeName: String, completion: @escaping () -> Void) {
        if let node = childNode(withName: nodeName) ?? levelButtons.first(where: { $0.name == nodeName }) {
            let press = SKAction.sequence([
                SKAction.scale(to: 0.9, duration: 0.08),
                SKAction.scale(to: 1.05, duration: 0.1),
                SKAction.scale(to: 1.0, duration: 0.06),
                SKAction.run(completion)
            ])
            node.run(press)
        } else {
            completion()
        }
    }

    // MARK: - Transitions
    private func transitionToMainMenu() {
        let transition = SKTransition.push(with: .right, duration: 0.6)
        let menu = MainMenuScene(size: size)
        menu.scaleMode = scaleMode
        view?.presentScene(menu, transition: transition)
    }

    private func transitionToGame(level: Int) {
        let transition = SKTransition.fade(withDuration: 0.8)
        let gameScene = GameScene(size: size)
        gameScene.scaleMode = scaleMode
        gameScene.currentLevel = level
        view?.presentScene(gameScene, transition: transition)
    }

    // MARK: - Helpers
    private func lerp(_ a: CGFloat, _ b: CGFloat, _ t: CGFloat) -> CGFloat {
        return a + (b - a) * t
    }
}

// MARK: - Safe Array Subscript
private extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

