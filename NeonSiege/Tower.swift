import SpriteKit

enum TowerType: CaseIterable {
    case pulse, cryo, arc, rail

    var name: String {
        switch self {
        case .pulse: return "Pulse"
        case .cryo: return "Cryo"
        case .arc: return "Arc"
        case .rail: return "Rail"
        }
    }

    var cost: Int {
        switch self {
        case .pulse: return 50
        case .cryo: return 70
        case .arc: return 110
        case .rail: return 160
        }
    }

    var baseDamage: Double {
        switch self {
        case .pulse: return 7
        case .cryo: return 4
        case .arc: return 16
        case .rail: return 46
        }
    }

    /// Range in cells.
    var baseRange: CGFloat {
        switch self {
        case .pulse: return 2.3
        case .cryo: return 2.2
        case .arc: return 2.6
        case .rail: return 4.5
        }
    }

    var baseInterval: TimeInterval {
        switch self {
        case .pulse: return 0.4
        case .cryo: return 0.75
        case .arc: return 1.05
        case .rail: return 1.7
        }
    }

    var color: SKColor {
        switch self {
        case .pulse: return Theme.cyan
        case .cryo: return Theme.ice
        case .arc: return Theme.magenta
        case .rail: return Theme.amber
        }
    }

    var blurb: String {
        switch self {
        case .pulse: return "Fast single-target laser"
        case .cryo: return "Slows and chips enemies"
        case .arc: return "Chains up to 3 targets"
        case .rail: return "Piercing long-range shot"
        }
    }
}

final class Tower: SKNode {
    let type: TowerType
    let cell: Cell
    private(set) var tier: Int = 0   // 0...3
    private(set) var invested: Int
    var cooldown: TimeInterval = 0
    private let barrel: SKShapeNode
    private var tierPips: [SKShapeNode] = []

    static let maxTier = 3

    init(type: TowerType, cell: Cell, cellSize: CGFloat) {
        self.type = type
        self.cell = cell
        self.invested = type.cost

        barrel = SKShapeNode(rectOf: CGSize(width: cellSize * 0.16, height: cellSize * 0.42), cornerRadius: 2)
        barrel.fillColor = type.color
        barrel.strokeColor = .clear
        barrel.position = CGPoint(x: 0, y: cellSize * 0.18)

        super.init()

        let base = SKShapeNode(path: hexagonPath(radius: cellSize * 0.38))
        base.strokeColor = type.color
        base.lineWidth = 2
        base.glowWidth = 5
        base.fillColor = type.color.withAlphaComponent(0.22)
        addChild(base)

        let pivot = SKNode()
        pivot.addChild(barrel)
        addChild(pivot)

        zPosition = 40
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been used") }

    var damage: Double { type.baseDamage * pow(1.5, Double(tier)) }
    var range: CGFloat { type.baseRange * (1 + 0.1 * CGFloat(tier)) }
    var fireInterval: TimeInterval { type.baseInterval * pow(0.93, Double(tier)) }
    var upgradeCost: Int { Int(Double(type.cost) * 0.85 * Double(tier + 1)) }
    var sellValue: Int { Int(Double(invested) * 0.7) }
    var canUpgrade: Bool { tier < Tower.maxTier }

    func upgrade() {
        guard canUpgrade else { return }
        invested += upgradeCost
        tier += 1
        addTierPip()
        run(.sequence([.scale(to: 1.25, duration: 0.1), .scale(to: 1.0, duration: 0.12)]))
    }

    private func addTierPip() {
        let pip = SKShapeNode(circleOfRadius: 2.2)
        pip.fillColor = type.color
        pip.strokeColor = .clear
        pip.glowWidth = 2
        let offset = CGFloat(tierPips.count - 1) * 7
        pip.position = CGPoint(x: offset, y: -16)
        tierPips.append(pip)
        addChild(pip)
        for (i, p) in tierPips.enumerated() {
            p.position.x = (CGFloat(i) - CGFloat(tierPips.count - 1) / 2) * 7
        }
    }

    func aim(at point: CGPoint) {
        let delta = point - position
        barrel.parent?.zRotation = atan2(delta.y, delta.x) - .pi / 2
    }
}
