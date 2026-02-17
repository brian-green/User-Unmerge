import SpriteKit

class HUDOverlay: SKNode {

    private let sceneSize: CGSize
    private var healthNodes: [SKShapeNode] = []
    private var scoreLabel: SKLabelNode!
    private var levelLabel: SKLabelNode!
    private var timerLabel: SKLabelNode!
    private var collectibleCountLabel: SKLabelNode!

    // Control buttons
    private var leftButton: SKShapeNode!
    private var rightButton: SKShapeNode!
    private var jumpButton: SKShapeNode!
    private var attackButton: SKShapeNode!
    private var dashButton: SKShapeNode!
    private var pauseButton: SKNode!

    // Pause menu
    private var pauseOverlay: SKNode?

    var score: Int = 0 {
        didSet { scoreLabel.text = "Score: \(score)" }
    }

    var collectibleCount: Int = 0 {
        didSet { collectibleCountLabel.text = "\(collectibleCount)" }
    }

    init(sceneSize: CGSize) {
        self.sceneSize = sceneSize
        super.init()

        self.zPosition = 1000
        self.name = "hud"

        buildHealthDisplay()
        buildScoreDisplay()
        buildControls()
        buildPauseButton()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Health Display
    private func buildHealthDisplay() {
        let startX: CGFloat = 30
        let y: CGFloat = sceneSize.height - 35

        for i in 0..<3 {
            let heartPath = CGMutablePath()
            heartPath.addEllipse(in: CGRect(x: -8, y: -8, width: 16, height: 16))
            let heart = SKShapeNode(path: heartPath)
            heart.fillColor = SKColor(red: 1.0, green: 0.2, blue: 0.3, alpha: 1.0)
            heart.strokeColor = SKColor(red: 0.8, green: 0.1, blue: 0.2, alpha: 1.0)
            heart.lineWidth = 1.5
            heart.position = CGPoint(x: startX + CGFloat(i) * 28, y: y)
            heart.name = "heart_\(i)"
            addChild(heart)
            healthNodes.append(heart)
        }
    }

    func updateHealth(_ currentHealth: Int, maxHealth: Int) {
        for (i, heart) in healthNodes.enumerated() {
            if i < currentHealth {
                heart.fillColor = SKColor(red: 1.0, green: 0.2, blue: 0.3, alpha: 1.0)
                heart.alpha = 1.0
            } else {
                heart.fillColor = SKColor(red: 0.3, green: 0.15, blue: 0.18, alpha: 0.5)
                heart.alpha = 0.5
            }
        }
    }

    // MARK: - Score Display
    private func buildScoreDisplay() {
        scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 20
        scoreLabel.fontColor = .white
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 30, y: sceneSize.height - 65)
        addChild(scoreLabel)

        // Collectible counter
        let shellIcon = SKShapeNode(ellipseOf: CGSize(width: 14, height: 10))
        shellIcon.fillColor = SKColor(red: 1.0, green: 0.85, blue: 0.7, alpha: 1.0)
        shellIcon.strokeColor = SKColor(red: 0.9, green: 0.7, blue: 0.5, alpha: 1.0)
        shellIcon.lineWidth = 1
        shellIcon.position = CGPoint(x: sceneSize.width - 100, y: sceneSize.height - 35)
        addChild(shellIcon)

        collectibleCountLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        collectibleCountLabel.text = "0"
        collectibleCountLabel.fontSize = 18
        collectibleCountLabel.fontColor = .white
        collectibleCountLabel.horizontalAlignmentMode = .left
        collectibleCountLabel.verticalAlignmentMode = .center
        collectibleCountLabel.position = CGPoint(x: sceneSize.width - 82, y: sceneSize.height - 35)
        addChild(collectibleCountLabel)

        // Level label
        levelLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        levelLabel.text = ""
        levelLabel.fontSize = 16
        levelLabel.fontColor = SKColor(white: 1.0, alpha: 0.7)
        levelLabel.horizontalAlignmentMode = .center
        levelLabel.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height - 30)
        addChild(levelLabel)

        // Timer
        timerLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        timerLabel.text = "0:00"
        timerLabel.fontSize = 18
        timerLabel.fontColor = SKColor(white: 1.0, alpha: 0.8)
        timerLabel.horizontalAlignmentMode = .center
        timerLabel.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height - 55)
        addChild(timerLabel)
    }

    func setLevelName(_ name: String) {
        levelLabel.text = name
    }

    func updateTimer(_ seconds: TimeInterval) {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        timerLabel.text = String(format: "%d:%02d", mins, secs)
    }

    // MARK: - Controls
    private func buildControls() {
        let controlAlpha: CGFloat = 0.35
        let buttonRadius: CGFloat = 30

        // Left button
        leftButton = SKShapeNode(circleOfRadius: buttonRadius)
        leftButton.fillColor = SKColor(white: 1.0, alpha: controlAlpha)
        leftButton.strokeColor = SKColor(white: 1.0, alpha: 0.5)
        leftButton.lineWidth = 2
        leftButton.position = CGPoint(x: 60, y: 60)
        leftButton.name = "control_left"
        addChild(leftButton)

        let leftArrow = SKLabelNode(fontNamed: "AvenirNext-Bold")
        leftArrow.text = "<"
        leftArrow.fontSize = 28
        leftArrow.fontColor = .white
        leftArrow.verticalAlignmentMode = .center
        leftArrow.name = "control_left"
        leftButton.addChild(leftArrow)

        // Right button
        rightButton = SKShapeNode(circleOfRadius: buttonRadius)
        rightButton.fillColor = SKColor(white: 1.0, alpha: controlAlpha)
        rightButton.strokeColor = SKColor(white: 1.0, alpha: 0.5)
        rightButton.lineWidth = 2
        rightButton.position = CGPoint(x: 140, y: 60)
        rightButton.name = "control_right"
        addChild(rightButton)

        let rightArrow = SKLabelNode(fontNamed: "AvenirNext-Bold")
        rightArrow.text = ">"
        rightArrow.fontSize = 28
        rightArrow.fontColor = .white
        rightArrow.verticalAlignmentMode = .center
        rightArrow.name = "control_right"
        rightButton.addChild(rightArrow)

        // Jump button
        jumpButton = SKShapeNode(circleOfRadius: buttonRadius + 5)
        jumpButton.fillColor = SKColor(red: 0.2, green: 0.7, blue: 1.0, alpha: controlAlpha)
        jumpButton.strokeColor = SKColor(red: 0.3, green: 0.8, blue: 1.0, alpha: 0.5)
        jumpButton.lineWidth = 2
        jumpButton.position = CGPoint(x: sceneSize.width - 70, y: 70)
        jumpButton.name = "control_jump"
        addChild(jumpButton)

        let jumpLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        jumpLabel.text = "^"
        jumpLabel.fontSize = 30
        jumpLabel.fontColor = .white
        jumpLabel.verticalAlignmentMode = .center
        jumpLabel.name = "control_jump"
        jumpButton.addChild(jumpLabel)

        // Attack button
        attackButton = SKShapeNode(circleOfRadius: buttonRadius)
        attackButton.fillColor = SKColor(red: 0.2, green: 0.9, blue: 0.5, alpha: controlAlpha)
        attackButton.strokeColor = SKColor(red: 0.3, green: 1.0, blue: 0.6, alpha: 0.5)
        attackButton.lineWidth = 2
        attackButton.position = CGPoint(x: sceneSize.width - 150, y: 55)
        attackButton.name = "control_attack"
        addChild(attackButton)

        let attackLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        attackLabel.text = "ATK"
        attackLabel.fontSize = 14
        attackLabel.fontColor = .white
        attackLabel.verticalAlignmentMode = .center
        attackLabel.name = "control_attack"
        attackButton.addChild(attackLabel)

        // Dash button
        dashButton = SKShapeNode(circleOfRadius: buttonRadius - 5)
        dashButton.fillColor = SKColor(red: 0.8, green: 0.5, blue: 1.0, alpha: controlAlpha)
        dashButton.strokeColor = SKColor(red: 0.9, green: 0.6, blue: 1.0, alpha: 0.5)
        dashButton.lineWidth = 2
        dashButton.position = CGPoint(x: sceneSize.width - 140, y: 130)
        dashButton.name = "control_dash"
        addChild(dashButton)

        let dashLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        dashLabel.text = "DSH"
        dashLabel.fontSize = 12
        dashLabel.fontColor = .white
        dashLabel.verticalAlignmentMode = .center
        dashLabel.name = "control_dash"
        dashButton.addChild(dashLabel)
    }

    // MARK: - Pause
    private func buildPauseButton() {
        pauseButton = SKNode()
        pauseButton.position = CGPoint(x: sceneSize.width - 40, y: sceneSize.height - 35)
        pauseButton.zPosition = 1
        pauseButton.name = "control_pause"

        let bg = SKShapeNode(rectOf: CGSize(width: 36, height: 36), cornerRadius: 8)
        bg.fillColor = SKColor(white: 0, alpha: 0.4)
        bg.strokeColor = SKColor(white: 1, alpha: 0.3)
        bg.lineWidth = 1.5
        bg.name = "control_pause"
        pauseButton.addChild(bg)

        // Pause bars
        let bar1 = SKSpriteNode(color: .white, size: CGSize(width: 4, height: 16))
        bar1.position = CGPoint(x: -5, y: 0)
        bar1.name = "control_pause"
        pauseButton.addChild(bar1)

        let bar2 = SKSpriteNode(color: .white, size: CGSize(width: 4, height: 16))
        bar2.position = CGPoint(x: 5, y: 0)
        bar2.name = "control_pause"
        pauseButton.addChild(bar2)

        addChild(pauseButton)
    }

    func showPauseMenu(in scene: SKScene) {
        guard pauseOverlay == nil else { return }

        let overlay = SKNode()
        overlay.zPosition = 2000
        overlay.name = "pauseOverlay"

        let dimmer = SKSpriteNode(color: SKColor(white: 0, alpha: 0.6),
                                   size: sceneSize)
        dimmer.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2)
        dimmer.name = "pauseDimmer"
        overlay.addChild(dimmer)

        let panel = SKShapeNode(rectOf: CGSize(width: 300, height: 250), cornerRadius: 16)
        panel.fillColor = SKColor(red: 0.05, green: 0.15, blue: 0.35, alpha: 0.95)
        panel.strokeColor = SKColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
        panel.lineWidth = 3
        panel.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2)
        overlay.addChild(panel)

        let pauseTitle = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        pauseTitle.text = "PAUSED"
        pauseTitle.fontSize = 36
        pauseTitle.fontColor = SKColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
        pauseTitle.position = CGPoint(x: 0, y: 70)
        panel.addChild(pauseTitle)

        createPauseButton(text: "Resume", name: "pause_resume",
                           position: CGPoint(x: 0, y: 20),
                           color: SKColor(red: 0.0, green: 0.75, blue: 0.55, alpha: 1.0),
                           parent: panel)

        createPauseButton(text: "Restart", name: "pause_restart",
                           position: CGPoint(x: 0, y: -35),
                           color: SKColor(red: 0.0, green: 0.55, blue: 0.8, alpha: 1.0),
                           parent: panel)

        createPauseButton(text: "Main Menu", name: "pause_menu",
                           position: CGPoint(x: 0, y: -90),
                           color: SKColor(red: 0.7, green: 0.3, blue: 0.3, alpha: 1.0),
                           parent: panel)

        scene.addChild(overlay)
        pauseOverlay = overlay
    }

    private func createPauseButton(text: String, name: String, position: CGPoint, color: SKColor, parent: SKNode) {
        let button = SKShapeNode(rectOf: CGSize(width: 200, height: 40), cornerRadius: 10)
        button.fillColor = color
        button.strokeColor = .clear
        button.position = position
        button.name = name
        parent.addChild(button)

        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = text
        label.fontSize = 20
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.name = name
        button.addChild(label)
    }

    func dismissPauseMenu() {
        pauseOverlay?.removeFromParent()
        pauseOverlay = nil
    }

    var isPauseMenuShowing: Bool {
        return pauseOverlay != nil
    }

    // MARK: - Notifications
    func showLevelStartBanner(_ levelName: String) {
        let banner = SKNode()
        banner.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2)
        banner.zPosition = 1500
        addChild(banner)

        let bg = SKShapeNode(rectOf: CGSize(width: 400, height: 80), cornerRadius: 12)
        bg.fillColor = SKColor(red: 0.0, green: 0.15, blue: 0.35, alpha: 0.9)
        bg.strokeColor = SKColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 0.8)
        bg.lineWidth = 2
        banner.addChild(bg)

        let label = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        label.text = levelName
        label.fontSize = 32
        label.fontColor = SKColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
        label.verticalAlignmentMode = .center
        banner.addChild(label)

        banner.setScale(0.3)
        banner.alpha = 0

        let show = SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 1.0, duration: 0.3),
                SKAction.fadeIn(withDuration: 0.3)
            ]),
            SKAction.wait(forDuration: 2.0),
            SKAction.group([
                SKAction.fadeOut(duration: 0.5),
                SKAction.moveBy(x: 0, y: 30, duration: 0.5)
            ]),
            SKAction.removeFromParent()
        ])
        banner.run(show)
    }

    func showPowerUpNotification(_ powerUpName: String) {
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = powerUpName
        label.fontSize = 22
        label.fontColor = SKColor(red: 0.3, green: 1.0, blue: 0.6, alpha: 1.0)
        label.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height * 0.35)
        label.zPosition = 1500
        addChild(label)

        let animate = SKAction.sequence([
            SKAction.group([
                SKAction.moveBy(x: 0, y: 30, duration: 1.0),
                SKAction.fadeOut(duration: 1.0)
            ]),
            SKAction.removeFromParent()
        ])
        label.run(animate)
    }
}
