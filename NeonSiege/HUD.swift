import SpriteKit

/// Heads-up display: top status bar + bottom build bar.
/// Interactive nodes carry names that GameScene resolves in touch handling.
final class HUD: SKNode {
    private let sceneSize: CGSize
    private var creditsLabel: SKLabelNode!
    private var shardsLabel: SKLabelNode!
    private var waveLabel: SKLabelNode!
    private var speedLabel: SKLabelNode!
    private var countdownButton: SKShapeNode!
    private var countdownLabel: SKLabelNode!
    private var buildButtons: [TowerType: SKShapeNode] = [:]
    private var buildCosts: [TowerType: Int] = [:]

    init(size: CGSize) {
        sceneSize = size
        super.init()
        zPosition = 100
        buildTopBar()
        buildBottomBar()
        buildCountdown()
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been used") }

    private func buildTopBar() {
        let bar = SKShapeNode(rectOf: CGSize(width: sceneSize.width, height: 44))
        bar.fillColor = Theme.panel
        bar.strokeColor = Theme.gridLine
        bar.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height - 22)
        addChild(bar)

        let shardIcon = SKShapeNode(path: hexagonPath(radius: 8))
        shardIcon.strokeColor = Theme.cyan
        shardIcon.fillColor = Theme.cyan.withAlphaComponent(0.5)
        shardIcon.glowWidth = 4
        shardIcon.position = CGPoint(x: 60, y: sceneSize.height - 22)
        addChild(shardIcon)

        shardsLabel = makeLabel("10", size: 17, color: Theme.cyan)
        shardsLabel.horizontalAlignmentMode = .left
        shardsLabel.position = CGPoint(x: 74, y: sceneSize.height - 22)
        addChild(shardsLabel)

        let creditIcon = neonCircle(radius: 8, color: Theme.amber, glow: 3, fillAlpha: 0.5)
        creditIcon.position = CGPoint(x: 135, y: sceneSize.height - 22)
        addChild(creditIcon)
        let creditGlyph = makeLabel("$", size: 11, color: .white)
        creditGlyph.position = creditIcon.position
        addChild(creditGlyph)

        creditsLabel = makeLabel("0", size: 17, color: Theme.amber)
        creditsLabel.horizontalAlignmentMode = .left
        creditsLabel.position = CGPoint(x: 149, y: sceneSize.height - 22)
        addChild(creditsLabel)

        waveLabel = makeLabel("WAVE 1/10", size: 16, color: .white)
        waveLabel.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height - 22)
        addChild(waveLabel)

        let speedButton = neonRect(size: CGSize(width: 52, height: 30), corner: 6, color: Theme.lime, glow: 2)
        speedButton.position = CGPoint(x: sceneSize.width - 155, y: sceneSize.height - 22)
        speedButton.name = "speed"
        addChild(speedButton)
        speedLabel = makeLabel("1x", size: 15, color: Theme.lime)
        speedLabel.name = "speed"
        speedLabel.position = speedButton.position
        addChild(speedLabel)

        let pauseButton = neonRect(size: CGSize(width: 52, height: 30), corner: 6, color: Theme.dim, glow: 2)
        pauseButton.position = CGPoint(x: sceneSize.width - 90, y: sceneSize.height - 22)
        pauseButton.name = "pause"
        addChild(pauseButton)
        let pauseGlyph = makeLabel("I I", size: 13, color: .white)
        pauseGlyph.name = "pause"
        pauseGlyph.position = pauseButton.position
        addChild(pauseGlyph)
    }

    private func buildBottomBar() {
        let bar = SKShapeNode(rectOf: CGSize(width: sceneSize.width, height: 62))
        bar.fillColor = Theme.panel
        bar.strokeColor = Theme.gridLine
        bar.position = CGPoint(x: sceneSize.width / 2, y: 31)
        addChild(bar)

        let types = TowerType.allCases
        let spacing: CGFloat = 10
        // Six build buttons must fit any landscape width, phone or Mac.
        let buttonWidth: CGFloat = min(132, (sceneSize.width - 32 - CGFloat(types.count - 1) * spacing) / CGFloat(types.count))
        let totalWidth = CGFloat(types.count) * buttonWidth + CGFloat(types.count - 1) * spacing
        var x = (sceneSize.width - totalWidth) / 2 + buttonWidth / 2

        for type in types {
            let button = neonRect(size: CGSize(width: buttonWidth, height: 50), corner: 8, color: type.color, glow: 2, fillAlpha: 0.10)
            button.position = CGPoint(x: x, y: 31)
            button.name = "build_\(type.name.lowercased())"
            addChild(button)

            let compact = buttonWidth < 116
            let glyphRadius: CGFloat = compact ? 9 : 12
            let glyph = SKShapeNode(path: hexagonPath(radius: glyphRadius))
            glyph.strokeColor = type.color
            glyph.fillColor = type.color.withAlphaComponent(0.3)
            glyph.glowWidth = 3
            glyph.position = CGPoint(x: -buttonWidth / 2 + (compact ? 16 : 22), y: 0)
            glyph.name = button.name
            button.addChild(glyph)

            let textX = -buttonWidth / 2 + (compact ? 29 : 40)
            let nameLabel = makeLabel(type.name, size: compact ? 11 : 14, color: .white)
            nameLabel.horizontalAlignmentMode = .left
            nameLabel.position = CGPoint(x: textX, y: compact ? 7 : 9)
            nameLabel.name = button.name
            button.addChild(nameLabel)

            let costLabel = makeLabel("$\(type.cost)", size: compact ? 10 : 12, color: Theme.amber, font: Theme.font)
            costLabel.horizontalAlignmentMode = .left
            costLabel.position = CGPoint(x: textX, y: compact ? -9 : -11)
            costLabel.name = button.name
            button.addChild(costLabel)

            buildButtons[type] = button
            buildCosts[type] = type.cost
            x += buttonWidth + spacing
        }
    }

    private func buildCountdown() {
        countdownButton = neonRect(size: CGSize(width: 280, height: 30), corner: 8, color: Theme.magenta, glow: 3, fillAlpha: 0.2)
        countdownButton.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height - 66)
        countdownButton.name = "callwave"
        addChild(countdownButton)
        countdownLabel = makeLabel("", size: 13, color: .white)
        countdownLabel.name = "callwave"
        countdownLabel.position = .zero
        countdownButton.addChild(countdownLabel)
        countdownButton.isHidden = true
    }

    // MARK: - Updates

    func setCredits(_ value: Int) {
        creditsLabel.text = "\(value)"
        for (type, button) in buildButtons {
            button.alpha = value >= (buildCosts[type] ?? 0) ? 1.0 : 0.35
        }
    }

    func setShards(_ value: Int) {
        shardsLabel.text = "\(value)"
    }

    func setWave(current: Int, total: Int) {
        waveLabel.text = "WAVE \(min(current, total))/\(total)"
    }

    func setSpeed(_ multiplier: Int) {
        speedLabel.text = "\(multiplier)x"
    }

    func setSelected(_ type: TowerType?) {
        for (t, button) in buildButtons {
            button.lineWidth = (t == type) ? 3.5 : 2
            button.glowWidth = (t == type) ? 6 : 2
            button.fillColor = t.color.withAlphaComponent(t == type ? 0.30 : 0.10)
        }
    }

    func setCountdown(_ text: String?) {
        if let text = text {
            countdownLabel.text = text
            countdownButton.isHidden = false
        } else {
            countdownButton.isHidden = true
        }
    }
}
