import SpriteKit

class LevelCompleteScene: SKScene {

    private let sceneWidth: CGFloat = 1334
    private let sceneHeight: CGFloat = 750

    var completedLevel: Int = 1
    var score: Int = 0
    var timeElapsed: TimeInterval = 0
    var threeStarTime: TimeInterval = 180

    private let goldColor = SKColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.02, green: 0.1, blue: 0.25, alpha: 1.0)
        buildBackground()
        buildContent()
    }

    private func buildBackground() {
        // Starry sky particles
        for _ in 0..<40 {
            let star = SKShapeNode(circleOfRadius: CGFloat.random(in: 1...2.5))
            star.fillColor = SKColor(white: 1.0, alpha: CGFloat.random(in: 0.3...1.0))
            star.strokeColor = .clear
            star.position = CGPoint(x: CGFloat.random(in: 0...sceneWidth),
                                     y: CGFloat.random(in: 0...sceneHeight))
            star.zPosition = -10
            addChild(star)

            let twinkle = SKAction.repeatForever(SKAction.sequence([
                SKAction.fadeAlpha(to: 0.2, duration: Double.random(in: 0.5...2.0)),
                SKAction.fadeAlpha(to: 1.0, duration: Double.random(in: 0.5...2.0))
            ]))
            star.run(twinkle)
        }
    }

    private func buildContent() {
        // Title
        let title = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        title.text = "LEVEL COMPLETE!"
        title.fontSize = 48
        title.fontColor = goldColor
        title.position = CGPoint(x: sceneWidth / 2, y: sceneHeight * 0.78)
        title.zPosition = 100
        addChild(title)

        title.setScale(0.3)
        title.alpha = 0
        title.run(SKAction.group([
            SKAction.scale(to: 1.0, duration: 0.4),
            SKAction.fadeIn(withDuration: 0.4)
        ]))

        // Star rating
        let stars = calculateStars()
        GameManager.shared.completeLevel(completedLevel, stars: stars, score: score)

        buildStarDisplay(stars: stars)

        // Score display
        let scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreLabel.text = "Score: \(score)"
        scoreLabel.fontSize = 30
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: sceneWidth / 2, y: sceneHeight * 0.42)
        scoreLabel.zPosition = 100
        addChild(scoreLabel)

        // Time display
        let mins = Int(timeElapsed) / 60
        let secs = Int(timeElapsed) % 60
        let timeLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        timeLabel.text = String(format: "Time: %d:%02d", mins, secs)
        timeLabel.fontSize = 24
        timeLabel.fontColor = SKColor(white: 0.8, alpha: 1.0)
        timeLabel.position = CGPoint(x: sceneWidth / 2, y: sceneHeight * 0.36)
        timeLabel.zPosition = 100
        addChild(timeLabel)

        // Buttons
        buildButton(text: "Next Level", name: "nextLevel",
                     position: CGPoint(x: sceneWidth / 2 - 130, y: sceneHeight * 0.2),
                     color: SKColor(red: 0.0, green: 0.75, blue: 0.55, alpha: 1.0))

        buildButton(text: "Replay", name: "replay",
                     position: CGPoint(x: sceneWidth / 2 + 130, y: sceneHeight * 0.2),
                     color: SKColor(red: 0.0, green: 0.55, blue: 0.8, alpha: 1.0))

        buildButton(text: "Main Menu", name: "mainMenu",
                     position: CGPoint(x: sceneWidth / 2, y: sceneHeight * 0.1),
                     color: SKColor(red: 0.55, green: 0.4, blue: 0.7, alpha: 1.0))
    }

    private func calculateStars() -> Int {
        if timeElapsed <= threeStarTime {
            return 3
        } else if timeElapsed <= threeStarTime * 1.5 {
            return 2
        } else {
            return 1
        }
    }

    private func buildStarDisplay(stars: Int) {
        let starSpacing: CGFloat = 60
        let startX = sceneWidth / 2 - starSpacing

        for i in 0..<3 {
            let filled = i < stars
            let starNode = createStarShape(radius: 20, filled: filled)
            starNode.position = CGPoint(x: startX + CGFloat(i) * starSpacing, y: sceneHeight * 0.58)
            starNode.zPosition = 100

            starNode.setScale(0)
            starNode.alpha = 0

            let delay = Double(i) * 0.3 + 0.5
            let appear = SKAction.sequence([
                SKAction.wait(forDuration: delay),
                SKAction.group([
                    SKAction.scale(to: 1.3, duration: 0.2),
                    SKAction.fadeIn(withDuration: 0.2)
                ]),
                SKAction.scale(to: 1.0, duration: 0.1)
            ])
            starNode.run(appear)

            addChild(starNode)
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
        star.fillColor = filled ? goldColor : SKColor(red: 0.3, green: 0.3, blue: 0.35, alpha: 0.6)
        star.strokeColor = filled ? SKColor(red: 0.85, green: 0.65, blue: 0.0, alpha: 1.0) : .clear
        star.lineWidth = filled ? 2 : 0
        return star
    }

    private func buildButton(text: String, name: String, position: CGPoint, color: SKColor) {
        let container = SKNode()
        container.position = position
        container.zPosition = 100
        container.name = name

        let bg = SKShapeNode(rectOf: CGSize(width: 200, height: 48), cornerRadius: 12)
        bg.fillColor = color
        bg.strokeColor = SKColor(white: 1, alpha: 0.3)
        bg.lineWidth = 1.5
        bg.name = name
        container.addChild(bg)

        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = text
        label.fontSize = 22
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.name = name
        container.addChild(label)

        addChild(container)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)

        for node in touchedNodes {
            if let name = node.name ?? node.parent?.name {
                switch name {
                case "nextLevel":
                    let nextLevel = min(completedLevel + 1, 10)
                    transitionToGame(level: nextLevel)
                case "replay":
                    transitionToGame(level: completedLevel)
                case "mainMenu":
                    transitionToMainMenu()
                default:
                    break
                }
            }
        }
    }

    private func transitionToGame(level: Int) {
        let transition = SKTransition.fade(withDuration: 0.8)
        let gameScene = GameScene(size: size)
        gameScene.scaleMode = scaleMode
        gameScene.currentLevel = level
        view?.presentScene(gameScene, transition: transition)
    }

    private func transitionToMainMenu() {
        let transition = SKTransition.fade(withDuration: 0.8)
        let menu = MainMenuScene(size: size)
        menu.scaleMode = scaleMode
        view?.presentScene(menu, transition: transition)
    }
}
