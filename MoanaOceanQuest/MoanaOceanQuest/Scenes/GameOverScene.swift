import SpriteKit

class GameOverScene: SKScene {

    private let sceneWidth: CGFloat = 1334
    private let sceneHeight: CGFloat = 750

    var failedLevel: Int = 1
    var score: Int = 0

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.05, green: 0.02, blue: 0.1, alpha: 1.0)
        buildBackground()
        buildContent()
    }

    private func buildBackground() {
        // Dark atmosphere with dim particles
        for _ in 0..<20 {
            let particle = SKShapeNode(circleOfRadius: CGFloat.random(in: 1...2))
            particle.fillColor = SKColor(red: 0.3, green: 0.15, blue: 0.4, alpha: CGFloat.random(in: 0.1...0.4))
            particle.strokeColor = .clear
            particle.position = CGPoint(x: CGFloat.random(in: 0...sceneWidth),
                                         y: CGFloat.random(in: 0...sceneHeight))
            particle.zPosition = -10
            addChild(particle)

            let drift = SKAction.repeatForever(SKAction.sequence([
                SKAction.moveBy(x: CGFloat.random(in: -20...20),
                                y: CGFloat.random(in: -10...10),
                                duration: Double.random(in: 3...6)),
                SKAction.moveBy(x: CGFloat.random(in: -20...20),
                                y: CGFloat.random(in: -10...10),
                                duration: Double.random(in: 3...6))
            ]))
            particle.run(drift)
        }
    }

    private func buildContent() {
        // Game Over title
        let titleShadow = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        titleShadow.text = "GAME OVER"
        titleShadow.fontSize = 56
        titleShadow.fontColor = SKColor(red: 0.5, green: 0.0, blue: 0.0, alpha: 0.5)
        titleShadow.position = CGPoint(x: sceneWidth / 2 + 3, y: sceneHeight * 0.65 - 3)
        titleShadow.zPosition = 99
        addChild(titleShadow)

        let title = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        title.text = "GAME OVER"
        title.fontSize = 56
        title.fontColor = SKColor(red: 1.0, green: 0.25, blue: 0.2, alpha: 1.0)
        title.position = CGPoint(x: sceneWidth / 2, y: sceneHeight * 0.65)
        title.zPosition = 100
        addChild(title)

        // Fade in animation
        title.alpha = 0
        titleShadow.alpha = 0
        let fadeIn = SKAction.fadeIn(withDuration: 0.8)
        title.run(fadeIn)
        titleShadow.run(fadeIn)

        // Score
        let scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreLabel.text = "Score: \(score)"
        scoreLabel.fontSize = 28
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: sceneWidth / 2, y: sceneHeight * 0.5)
        scoreLabel.zPosition = 100
        addChild(scoreLabel)

        // High score
        let highScore = GameManager.shared.highScoreForLevel(failedLevel)
        let highScoreLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        highScoreLabel.text = "Best: \(highScore)"
        highScoreLabel.fontSize = 20
        highScoreLabel.fontColor = SKColor(white: 0.6, alpha: 1.0)
        highScoreLabel.position = CGPoint(x: sceneWidth / 2, y: sceneHeight * 0.44)
        highScoreLabel.zPosition = 100
        addChild(highScoreLabel)

        // Buttons
        buildButton(text: "Try Again", name: "retry",
                     position: CGPoint(x: sceneWidth / 2 - 130, y: sceneHeight * 0.28),
                     color: SKColor(red: 0.0, green: 0.75, blue: 0.55, alpha: 1.0))

        buildButton(text: "Main Menu", name: "mainMenu",
                     position: CGPoint(x: sceneWidth / 2 + 130, y: sceneHeight * 0.28),
                     color: SKColor(red: 0.55, green: 0.4, blue: 0.7, alpha: 1.0))
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

        // Pop in
        container.setScale(0.5)
        container.alpha = 0
        container.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.group([
                SKAction.scale(to: 1.0, duration: 0.3),
                SKAction.fadeIn(withDuration: 0.3)
            ])
        ]))
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)

        for node in touchedNodes {
            if let name = node.name ?? node.parent?.name {
                switch name {
                case "retry":
                    transitionToGame(level: failedLevel)
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
