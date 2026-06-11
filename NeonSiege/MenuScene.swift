import SpriteKit

final class MenuScene: SKScene {
    private var soundLabel: SKLabelNode?

    override init(size: CGSize) {
        super.init(size: size)
        scaleMode = platformScaleMode
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been used") }

    override func didMove(to view: SKView) {
        backgroundColor = Theme.background
        drawBackdrop()

        let title = makeLabel("NEONSIEGE", size: 46, color: Theme.cyan, font: Theme.titleFont)
        title.position = CGPoint(x: size.width / 2, y: size.height - 64)
        title.zPosition = 10
        addChild(title)
        title.run(.repeatForever(.sequence([
            .fadeAlpha(to: 0.75, duration: 1.1),
            .fadeAlpha(to: 1.0, duration: 1.1),
        ])))

        let subtitle = makeLabel("DEFEND THE CORES. BEND THE MAZE.", size: 13, color: Theme.dim, font: Theme.font)
        subtitle.position = CGPoint(x: size.width / 2, y: size.height - 96)
        subtitle.zPosition = 10
        addChild(subtitle)

        drawLevelCards()

        let footer = makeLabel("Towers reshape the invaders' path. Kill shard thieves to rescue stolen cores.", size: 11, color: Theme.dim, font: Theme.font)
        footer.position = CGPoint(x: size.width / 2, y: 24)
        footer.zPosition = 10
        addChild(footer)

        let sound = makeLabel(Sound.shared.isEnabled ? "SOUND: ON" : "SOUND: OFF", size: 12, color: Theme.cyan)
        sound.horizontalAlignmentMode = .right
        sound.position = CGPoint(x: size.width - 24, y: 24)
        sound.zPosition = 10
        sound.name = "menu_sound"
        addChild(sound)
        soundLabel = sound

        Sound.shared.startMusic()
    }

    private func drawBackdrop() {
        let spacing: CGFloat = 36
        let path = CGMutablePath()
        var x: CGFloat = 0
        while x <= size.width {
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: size.height))
            x += spacing
        }
        var y: CGFloat = 0
        while y <= size.height {
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: size.width, y: y))
            y += spacing
        }
        let lines = SKShapeNode(path: path)
        lines.strokeColor = Theme.gridLine
        lines.lineWidth = 1
        lines.alpha = 0.35
        addChild(lines)

        for _ in 0..<14 {
            let dot = SKShapeNode(circleOfRadius: CGFloat.random(in: 1...2.5))
            let colors = [Theme.cyan, Theme.magenta, Theme.violet, Theme.lime]
            let color = colors.randomElement() ?? Theme.cyan
            dot.fillColor = color
            dot.strokeColor = .clear
            dot.glowWidth = 3
            dot.alpha = CGFloat.random(in: 0.3...0.7)
            dot.position = CGPoint(x: CGFloat.random(in: 0...size.width), y: CGFloat.random(in: 0...size.height))
            addChild(dot)
            let drift = SKAction.moveBy(x: CGFloat.random(in: -60...60), y: CGFloat.random(in: -40...40), duration: Double.random(in: 6...12))
            dot.run(.repeatForever(.sequence([drift, drift.reversed()])))
        }
    }

    private func drawLevelCards() {
        let levels = LevelLibrary.all
        let unlocked = Progress.unlockedLevel
        let perRow = 5
        let spacing: CGFloat = 14
        let cardWidth: CGFloat = min(128, (size.width - 60 - CGFloat(perRow - 1) * spacing) / CGFloat(perRow))
        // Fit two rows between title block and footer on any screen height.
        let cardHeight: CGFloat = min(124, (size.height - 170 - spacing) / 2)
        let totalWidth = CGFloat(perRow) * cardWidth + CGFloat(perRow - 1) * spacing
        let startX = (size.width - totalWidth) / 2 + cardWidth / 2
        let centerY = size.height / 2 - 28

        for (i, level) in levels.enumerated() {
            let row = i / perRow
            let col = i % perRow
            let x = startX + CGFloat(col) * (cardWidth + spacing)
            let y = centerY + (row == 0 ? (cardHeight + spacing) / 2 : -(cardHeight + spacing) / 2)
            let isUnlocked = level.id <= unlocked
            let color: SKColor = isUnlocked ? Theme.cyan : Theme.dim
            let card = neonRect(size: CGSize(width: cardWidth, height: cardHeight), corner: 12, color: color, glow: isUnlocked ? 4 : 1, fillAlpha: 0.10)
            card.position = CGPoint(x: x, y: y)
            card.zPosition = 10
            if isUnlocked { card.name = "level_\(level.id)" }
            addChild(card)

            let number = makeLabel("\(level.id)", size: 24, color: color, font: Theme.titleFont)
            number.position = CGPoint(x: 0, y: cardHeight / 2 - 28)
            number.name = card.name
            card.addChild(number)

            let name = makeLabel(level.name.uppercased(), size: 11, color: isUnlocked ? .white : Theme.dim)
            name.position = CGPoint(x: 0, y: 0)
            name.name = card.name
            card.addChild(name)

            let info = makeLabel("\(level.waves.count) WAVES", size: 9, color: Theme.dim, font: Theme.font)
            info.position = CGPoint(x: 0, y: -14)
            info.name = card.name
            card.addChild(info)

            if isUnlocked {
                let stars = Progress.stars(for: level.id)
                let starsText = stars > 0 ? String(repeating: "*", count: stars) : "-"
                let starsLabel = makeLabel(starsText, size: 14, color: stars > 0 ? Theme.amber : Theme.dim)
                starsLabel.position = CGPoint(x: 0, y: -cardHeight / 2 + 12)
                starsLabel.name = card.name
                card.addChild(starsLabel)
            } else {
                let lock = makeLabel("LOCKED", size: 10, color: Theme.dim)
                lock.position = CGPoint(x: 0, y: -cardHeight / 2 + 12)
                card.addChild(lock)
            }
        }
    }

    #if os(iOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        handleTap(at: touch.location(in: self))
    }
    #else
    override func mouseDown(with event: NSEvent) {
        handleTap(at: event.location(in: self))
    }
    #endif

    private func handleTap(at point: CGPoint) {
        var node: SKNode? = atPoint(point)
        while let current = node {
            if current.name == "menu_sound" {
                Sound.shared.toggle()
                Sound.shared.play(.tap, on: self)
                soundLabel?.text = Sound.shared.isEnabled ? "SOUND: ON" : "SOUND: OFF"
                Haptics.tap()
                return
            }
            if let name = current.name, name.hasPrefix("level_"),
               let id = Int(name.replacingOccurrences(of: "level_", with: "")) {
                Sound.shared.play(.tap, on: self)
                Haptics.tap()
                let scene = GameScene(level: LevelLibrary.level(id: id), size: size)
                view?.presentScene(scene, transition: .fade(withDuration: 0.5))
                return
            }
            node = current.parent
        }
    }
}
