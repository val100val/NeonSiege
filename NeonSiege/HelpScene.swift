import SpriteKit

/// In-game manual: rules, the full enemy roster with stats, and the armory
/// with buy/sell prices. Reached from the main menu HELP button.
final class HelpScene: SKScene {

    override init(size: CGSize) {
        super.init(size: size)
        scaleMode = platformScaleMode
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been used") }

    override func didMove(to view: SKView) {
        backgroundColor = Theme.background

        let title = makeLabel("FIELD MANUAL", size: 28, color: Theme.cyan, font: Theme.titleFont)
        title.position = CGPoint(x: size.width / 2, y: size.height - 40)
        addChild(title)

        let columnWidth = size.width / 3
        drawRules(centerX: columnWidth * 0.5)
        drawEnemies(centerX: columnWidth * 1.5)
        drawWeapons(centerX: columnWidth * 2.5)

        let back = neonRect(size: CGSize(width: 130, height: 32), corner: 8, color: Theme.lime, glow: 3, fillAlpha: 0.14)
        back.position = CGPoint(x: size.width / 2, y: 28)
        back.name = "help_back"
        addChild(back)
        let backLabel = makeLabel("BACK", size: 14, color: Theme.lime)
        backLabel.name = "help_back"
        backLabel.position = back.position
        addChild(backLabel)
    }

    // MARK: - Columns

    private var topY: CGFloat { size.height - 78 }
    private var lineGap: CGFloat { max(13, min(17, (size.height - 130) / 22)) }
    private var bodySize: CGFloat { max(8.5, min(11, size.height / 60)) }

    private func header(_ text: String, x: CGFloat, y: CGFloat, color: SKColor) {
        let label = makeLabel(text, size: bodySize + 3, color: color, font: Theme.titleFont)
        label.position = CGPoint(x: x, y: y)
        addChild(label)
    }

    private func line(_ text: String, x: CGFloat, y: CGFloat, color: SKColor = .white, size fontSize: CGFloat? = nil) {
        let label = makeLabel(text, size: fontSize ?? bodySize, color: color, font: Theme.font)
        label.position = CGPoint(x: x, y: y)
        addChild(label)
    }

    private func drawRules(centerX: CGFloat) {
        header("RULES", x: centerX, y: topY, color: Theme.cyan)
        let rules = [
            "Invaders march from the gates",
            "to steal your core shards.",
            "",
            "Build towers to block and",
            "reshape their path - you can",
            "never wall them in completely.",
            "",
            "A thief that reaches the core",
            "grabs a shard and runs home.",
            "Kill it to rescue the shard!",
            "",
            "Lose all shards = defeat.",
            "Survive every wave = victory.",
            "",
            "Wave 1 waits for your signal:",
            "study the map, build, launch.",
            "Call later waves early: +$15.",
            "",
            "Towers upgrade 3 times and",
            "sell back for 70% invested.",
        ]
        var y = topY - lineGap * 1.4
        for rule in rules {
            if !rule.isEmpty { line(rule, x: centerX, y: y, color: SKColor(white: 0.85, alpha: 1)) }
            y -= rule.isEmpty ? lineGap * 0.45 : lineGap
        }
    }

    private func drawEnemies(centerX: CGFloat) {
        header("ENEMIES", x: centerX, y: topY, color: Theme.magenta)
        line("NAME / HP / SPEED / BOUNTY", x: centerX, y: topY - lineGap * 1.3, color: Theme.dim, size: bodySize - 1)

        let notes: [EnemyType: String] = [
            .drone: "standard invader",
            .sprinter: "very fast",
            .swarm: "weak but many",
            .tank: "slow, armored",
            .phantom: "cloaks - untargetable",
            .boss: "boss every 5th wave",
            .juggernaut: "BOSS: armored giant",
            .colossus: "BOSS: splits on death!",
            .omega: "SUPERBOSS: resists slow",
        ]
        var y = topY - lineGap * 2.3
        for type in EnemyType.allCases {
            let speed = String(format: "%.1f", Double(type.speed))
            line("\(type.displayName.uppercased())  \(Int(type.baseHP))hp  \(speed)spd  $\(type.reward)",
                 x: centerX, y: y, color: type.color)
            line(notes[type] ?? "", x: centerX, y: y - lineGap * 0.62, color: Theme.dim, size: bodySize - 1.5)
            y -= lineGap * 1.78
        }
        line("HP scales up with wave + level.", x: centerX, y: y, color: Theme.dim, size: bodySize - 1)
    }

    private func drawWeapons(centerX: CGFloat) {
        header("ARMORY", x: centerX, y: topY, color: Theme.amber)
        line("NAME / BUY / SELL / DAMAGE", x: centerX, y: topY - lineGap * 1.3, color: Theme.dim, size: bodySize - 1)

        let notes: [TowerType: String] = [
            .pulse: "fast single-target laser",
            .cryo: "slows enemies 50%",
            .arc: "chains up to 3 targets",
            .rail: "pierces a whole line",
            .flak: "explosive splash damage",
            .wunder: "WUNDERWAFFE: nova hits ALL",
        ]
        var y = topY - lineGap * 2.3
        for type in TowerType.allCases {
            let sell = Int(Double(type.cost) * 0.7)
            line("\(type.name.uppercased())  buy $\(type.cost)  sell $\(sell)  dmg \(Int(type.baseDamage))",
                 x: centerX, y: y, color: type.color == .white ? SKColor(white: 0.95, alpha: 1) : type.color)
            line(notes[type] ?? "", x: centerX, y: y - lineGap * 0.62, color: Theme.dim, size: bodySize - 1.5)
            y -= lineGap * 1.78
        }
        y -= lineGap * 0.3
        line("Upgrades: +50% dmg, +10% range,", x: centerX, y: y, color: Theme.dim, size: bodySize - 1)
        line("faster fire. Cost rises per tier.", x: centerX, y: y - lineGap * 0.8, color: Theme.dim, size: bodySize - 1)
        line("Sell value = 70% of all invested.", x: centerX, y: y - lineGap * 1.6, color: Theme.dim, size: bodySize - 1)
    }

    // MARK: - Input

    #if os(iOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        handleTap(at: touch.location(in: self))
    }
    #else
    override func mouseDown(with event: NSEvent) {
        handleTap(at: event.location(in: self))
    }

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 { goBack() } // Esc
    }
    #endif

    private func handleTap(at point: CGPoint) {
        var node: SKNode? = atPoint(point)
        while let current = node {
            if current.name == "help_back" {
                goBack()
                return
            }
            node = current.parent
        }
    }

    private func goBack() {
        Sound.shared.play(.tap, on: self)
        Haptics.tap()
        view?.presentScene(MenuScene(size: size), transition: .fade(withDuration: 0.4))
    }
}
