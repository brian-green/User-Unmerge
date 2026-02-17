import SpriteKit

class ParallaxLayer {
    let speed: CGFloat
    var nodes: [SKNode] = []
    let zPosition: CGFloat

    init(speed: CGFloat, zPosition: CGFloat) {
        self.speed = speed
        self.zPosition = zPosition
    }
}

class ParallaxBackground {
    private var layers: [ParallaxLayer] = []
    private let scene: SKScene
    private let sceneWidth: CGFloat

    init(scene: SKScene) {
        self.scene = scene
        self.sceneWidth = scene.size.width
    }

    func addLayer(
        textureName: String,
        speed: CGFloat,
        zPosition: CGFloat,
        yOffset: CGFloat = 0,
        tileCount: Int = 3
    ) {
        let layer = ParallaxLayer(speed: speed, zPosition: zPosition)

        for i in 0..<tileCount {
            let node = createLayerNode(textureName: textureName, index: i, yOffset: yOffset)
            node.zPosition = zPosition
            scene.addChild(node)
            layer.nodes.append(node)
        }

        layers.append(layer)
    }

    func addColorLayer(
        color: SKColor,
        size: CGSize,
        speed: CGFloat,
        zPosition: CGFloat,
        yOffset: CGFloat = 0,
        tileCount: Int = 3
    ) {
        let layer = ParallaxLayer(speed: speed, zPosition: zPosition)

        for i in 0..<tileCount {
            let node = SKSpriteNode(color: color, size: size)
            node.anchorPoint = CGPoint(x: 0, y: 0)
            node.position = CGPoint(x: CGFloat(i) * size.width, y: yOffset)
            node.zPosition = zPosition
            scene.addChild(node)
            layer.nodes.append(node)
        }

        layers.append(layer)
    }

    func addGradientLayer(
        topColor: SKColor,
        bottomColor: SKColor,
        size: CGSize,
        speed: CGFloat,
        zPosition: CGFloat,
        yOffset: CGFloat = 0
    ) {
        let layer = ParallaxLayer(speed: speed, zPosition: zPosition)

        let node = SKSpriteNode(color: .clear, size: size)
        node.anchorPoint = CGPoint(x: 0, y: 0)
        node.position = CGPoint(x: 0, y: yOffset)
        node.zPosition = zPosition

        let gradientShader = SKShader(source: """
            void main() {
                float y = v_tex_coord.y;
                vec4 top = vec4(\(topColor.redComponent), \(topColor.greenComponent), \(topColor.blueComponent), 1.0);
                vec4 bottom = vec4(\(bottomColor.redComponent), \(bottomColor.greenComponent), \(bottomColor.blueComponent), 1.0);
                gl_FragColor = mix(bottom, top, y);
            }
        """)
        node.shader = gradientShader
        scene.addChild(node)
        layer.nodes.append(node)

        layers.append(layer)
    }

    private func createLayerNode(textureName: String, index: Int, yOffset: CGFloat) -> SKSpriteNode {
        let texture = SKTexture(imageNamed: textureName)
        let node = SKSpriteNode(texture: texture)
        node.anchorPoint = CGPoint(x: 0, y: 0)
        node.position = CGPoint(x: CGFloat(index) * node.size.width, y: yOffset)
        return node
    }

    func update(cameraX: CGFloat) {
        for layer in layers {
            for (index, node) in layer.nodes.enumerated() {
                let nodeWidth = node.frame.width
                let offset = cameraX * layer.speed
                let baseX = CGFloat(index) * nodeWidth - offset

                let totalWidth = nodeWidth * CGFloat(layer.nodes.count)
                var adjustedX = baseX.truncatingRemainder(dividingBy: totalWidth)
                if adjustedX < -nodeWidth {
                    adjustedX += totalWidth
                }

                node.position.x = adjustedX
            }
        }
    }
}

extension SKColor {
    var redComponent: CGFloat {
        var r: CGFloat = 0
        getRed(&r, green: nil, blue: nil, alpha: nil)
        return r
    }
    var greenComponent: CGFloat {
        var g: CGFloat = 0
        getRed(nil, green: &g, blue: nil, alpha: nil)
        return g
    }
    var blueComponent: CGFloat {
        var b: CGFloat = 0
        getRed(nil, green: nil, blue: &b, alpha: nil)
        return b
    }
}
