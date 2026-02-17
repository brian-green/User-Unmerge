import SpriteKit

class NPCCharacter: SKSpriteNode {

    enum NPCType {
        case villager
        case maui
        case gramma
    }

    let npcType: NPCType
    var dialogueLines: [String]
    private var dialogueIndex = 0
    private var interactionRange: CGFloat = 80
    private var dialogueBubble: SKNode?

    init(type: NPCType, dialogueLines: [String]) {
        self.npcType = type
        self.dialogueLines = dialogueLines
        super.init(texture: nil, color: .clear, size: CGSize(width: 32, height: 48))

        self.name = "npc"
        self.zPosition = 45

        setupPhysics()
        buildVisuals()
        startIdleAnimation()
        buildInteractionIndicator()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupPhysics() {
        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 28, height: 44))
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = PhysicsCategory.npc
        physicsBody?.contactTestBitMask = PhysicsCategory.player
        physicsBody?.collisionBitMask = PhysicsCategory.none
    }

    private func buildVisuals() {
        switch npcType {
        case .villager:
            let body = SKSpriteNode(color: SKColor(red: 0.72, green: 0.55, blue: 0.4, alpha: 1.0),
                                     size: CGSize(width: 22, height: 32))
            body.position = CGPoint(x: 0, y: -4)
            addChild(body)

            let head = SKShapeNode(circleOfRadius: 8)
            head.fillColor = SKColor(red: 0.72, green: 0.55, blue: 0.4, alpha: 1.0)
            head.strokeColor = .clear
            head.position = CGPoint(x: 0, y: 18)
            addChild(head)

            let outfit = SKSpriteNode(color: SKColor(red: 0.4, green: 0.6, blue: 0.3, alpha: 1.0),
                                       size: CGSize(width: 22, height: 14))
            outfit.position = CGPoint(x: 0, y: -2)
            outfit.zPosition = 0.1
            addChild(outfit)

        case .maui:
            let body = SKSpriteNode(color: SKColor(red: 0.65, green: 0.45, blue: 0.3, alpha: 1.0),
                                     size: CGSize(width: 30, height: 38))
            body.position = CGPoint(x: 0, y: -2)
            addChild(body)

            let head = SKShapeNode(circleOfRadius: 10)
            head.fillColor = SKColor(red: 0.65, green: 0.45, blue: 0.3, alpha: 1.0)
            head.strokeColor = .clear
            head.position = CGPoint(x: 0, y: 22)
            addChild(head)

            // Maui's hair (curly)
            let hair = SKShapeNode(circleOfRadius: 12)
            hair.fillColor = SKColor(red: 0.15, green: 0.1, blue: 0.08, alpha: 1.0)
            hair.strokeColor = .clear
            hair.position = CGPoint(x: 0, y: 26)
            hair.zPosition = -0.1
            addChild(hair)

            // Tattoo marks
            for i in 0..<3 {
                let tattoo = SKShapeNode(rectOf: CGSize(width: 8, height: 2))
                tattoo.fillColor = SKColor(red: 0.2, green: 0.15, blue: 0.1, alpha: 0.7)
                tattoo.strokeColor = .clear
                tattoo.position = CGPoint(x: 0, y: CGFloat(i) * 6 - 8)
                tattoo.zPosition = 0.2
                addChild(tattoo)
            }

        case .gramma:
            let body = SKSpriteNode(color: SKColor(red: 0.7, green: 0.52, blue: 0.38, alpha: 1.0),
                                     size: CGSize(width: 24, height: 30))
            body.position = CGPoint(x: 0, y: -6)
            addChild(body)

            let head = SKShapeNode(circleOfRadius: 7)
            head.fillColor = SKColor(red: 0.7, green: 0.52, blue: 0.38, alpha: 1.0)
            head.strokeColor = .clear
            head.position = CGPoint(x: 0, y: 14)
            addChild(head)

            // White hair
            let hair = SKShapeNode(circleOfRadius: 9)
            hair.fillColor = SKColor(white: 0.85, alpha: 1.0)
            hair.strokeColor = .clear
            hair.position = CGPoint(x: 0, y: 17)
            hair.zPosition = -0.1
            addChild(hair)

            // Stingray manta ray tattoo
            let tattoo = SKShapeNode(ellipseOf: CGSize(width: 10, height: 6))
            tattoo.fillColor = SKColor(red: 0.3, green: 0.5, blue: 0.7, alpha: 0.5)
            tattoo.strokeColor = .clear
            tattoo.position = CGPoint(x: 0, y: -4)
            tattoo.zPosition = 0.2
            addChild(tattoo)
        }
    }

    private func buildInteractionIndicator() {
        let indicator = SKShapeNode(circleOfRadius: 6)
        indicator.fillColor = SKColor(red: 1.0, green: 0.9, blue: 0.3, alpha: 0.8)
        indicator.strokeColor = .clear
        indicator.position = CGPoint(x: 0, y: size.height / 2 + 12)
        indicator.zPosition = 1
        indicator.name = "interactionIndicator"
        addChild(indicator)

        let pulse = SKAction.repeatForever(SKAction.sequence([
            SKAction.scale(to: 1.3, duration: 0.5),
            SKAction.scale(to: 1.0, duration: 0.5)
        ]))
        indicator.run(pulse)
    }

    private func startIdleAnimation() {
        let sway = SKAction.repeatForever(SKAction.sequence([
            SKAction.rotate(toAngle: 0.03, duration: 2.0),
            SKAction.rotate(toAngle: -0.03, duration: 2.0)
        ]))
        run(sway, withKey: "idle")
    }

    func interact() -> String? {
        guard dialogueIndex < dialogueLines.count else {
            dialogueIndex = 0
            dismissDialogue()
            return nil
        }

        let line = dialogueLines[dialogueIndex]
        dialogueIndex += 1
        showDialogue(line)
        return line
    }

    private func showDialogue(_ text: String) {
        dismissDialogue()

        let bubble = SKNode()
        bubble.position = CGPoint(x: 0, y: size.height / 2 + 30)
        bubble.zPosition = 200

        let maxWidth: CGFloat = 200
        let label = SKLabelNode(fontNamed: "AvenirNext-Medium")
        label.text = text
        label.fontSize = 12
        label.fontColor = .white
        label.preferredMaxLayoutWidth = maxWidth - 16
        label.numberOfLines = 0
        label.verticalAlignmentMode = .center

        let bgWidth = min(maxWidth, label.frame.width + 20)
        let bgHeight = label.frame.height + 16
        let bg = SKShapeNode(rectOf: CGSize(width: bgWidth, height: bgHeight), cornerRadius: 8)
        bg.fillColor = SKColor(red: 0.05, green: 0.15, blue: 0.3, alpha: 0.9)
        bg.strokeColor = SKColor(white: 1.0, alpha: 0.3)
        bg.lineWidth = 1
        bubble.addChild(bg)
        bubble.addChild(label)

        addChild(bubble)
        dialogueBubble = bubble

        bubble.setScale(0.3)
        bubble.alpha = 0
        bubble.run(SKAction.group([
            SKAction.scale(to: 1.0, duration: 0.2),
            SKAction.fadeIn(withDuration: 0.2)
        ]))
    }

    func dismissDialogue() {
        dialogueBubble?.run(SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 0.3, duration: 0.15),
                SKAction.fadeOut(duration: 0.15)
            ]),
            SKAction.removeFromParent()
        ]))
        dialogueBubble = nil
    }

    func isPlayerInRange(_ playerPosition: CGPoint) -> Bool {
        let dist = hypot(playerPosition.x - position.x, playerPosition.y - position.y)
        return dist < interactionRange
    }
}
