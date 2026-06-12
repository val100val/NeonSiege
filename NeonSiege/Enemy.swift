import SpriteKit

enum EnemyType: CaseIterable {
    case drone, sprinter, swarm, tank, phantom, boss, juggernaut, colossus, omega

    var baseHP: Double {
        switch self {
        case .drone: return 26
        case .sprinter: return 16
        case .swarm: return 10
        case .tank: return 130
        case .phantom: return 48
        case .boss: return 650
        case .juggernaut: return 1500
        case .colossus: return 2800
        case .omega: return 6000
        }
    }

    var isBoss: Bool {
        switch self {
        case .boss, .juggernaut, .colossus, .omega: return true
        default: return false
        }
    }

    /// Speed in cells per second.
    var speed: CGFloat {
        switch self {
        case .drone: return 1.6
        case .sprinter: return 2.9
        case .swarm: return 2.2
        case .tank: return 0.9
        case .phantom: return 1.8
        case .boss: return 0.7
        case .juggernaut: return 0.55
        case .colossus: return 0.5
        case .omega: return 0.42
        }
    }

    var reward: Int {
        switch self {
        case .drone: return 8
        case .sprinter: return 10
        case .swarm: return 4
        case .tank: return 28
        case .phantom: return 22
        case .boss: return 120
        case .juggernaut: return 260
        case .colossus: return 420
        case .omega: return 1000
        }
    }

    var radius: CGFloat {
        switch self {
        case .drone: return 9
        case .sprinter: return 7
        case .swarm: return 5.5
        case .tank: return 12
        case .phantom: return 9
        case .boss: return 16
        case .juggernaut: return 19
        case .colossus: return 22
        case .omega: return 26
        }
    }

    var color: SKColor {
        switch self {
        case .drone: return Theme.amber
        case .sprinter: return Theme.lime
        case .swarm: return SKColor(white: 0.92, alpha: 1)
        case .tank: return Theme.red
        case .phantom: return Theme.violet
        case .boss: return Theme.magenta
        case .juggernaut: return Theme.red
        case .colossus: return Theme.amber
        case .omega: return SKColor(red: 1.0, green: 0.25, blue: 0.25, alpha: 1)
        }
    }

    var displayName: String {
        switch self {
        case .drone: return "Drone"
        case .sprinter: return "Sprinter"
        case .swarm: return "Swarmling"
        case .tank: return "Bulwark"
        case .phantom: return "Phantom"
        case .boss: return "Overload"
        case .juggernaut: return "Juggernaut"
        case .colossus: return "Colossus"
        case .omega: return "OMEGA PRIME"
        }
    }
}

enum EnemyState {
    case advancing   // moving toward the core
    case retreating  // carrying a stolen shard back to a spawn gate
}

final class Enemy: SKNode {
    let type: EnemyType
    var hp: Double
    let maxHP: Double
    var state: EnemyState = .advancing
    var carryingShard = false
    var currentCell: Cell
    var targetCell: Cell?
    var slowFactor: CGFloat = 1
    var slowUntil: TimeInterval = 0
    var cloaked = false
    private var cloakClock: TimeInterval = 0
    private var clock: TimeInterval = 0
    private let body: SKShapeNode
    private let hpBarBack: SKShapeNode
    private let hpBarFill: SKShapeNode
    private var shardIcon: SKShapeNode?

    init(type: EnemyType, hpScale: Double, cell: Cell) {
        self.type = type
        self.maxHP = type.baseHP * hpScale
        self.hp = maxHP
        self.currentCell = cell

        body = SKShapeNode(circleOfRadius: type.radius)
        body.strokeColor = type.color
        body.lineWidth = 2
        body.glowWidth = 4
        body.fillColor = type.color.withAlphaComponent(0.35)

        let barWidth = type.radius * 2.4
        hpBarBack = SKShapeNode(rectOf: CGSize(width: barWidth, height: 3.5), cornerRadius: 1.5)
        hpBarBack.fillColor = SKColor(white: 0.1, alpha: 0.85)
        hpBarBack.strokeColor = .clear
        hpBarBack.position = CGPoint(x: 0, y: type.radius + 7)

        hpBarFill = SKShapeNode(rectOf: CGSize(width: barWidth, height: 3.5), cornerRadius: 1.5)
        hpBarFill.fillColor = Theme.lime
        hpBarFill.strokeColor = .clear
        hpBarFill.position = CGPoint(x: 0, y: type.radius + 7)

        super.init()
        addChild(body)
        addChild(hpBarBack)
        addChild(hpBarFill)
        zPosition = 50

        if type.isBoss {
            let ring = SKShapeNode(circleOfRadius: type.radius + 5)
            ring.strokeColor = type.color.withAlphaComponent(0.6)
            ring.lineWidth = 1.5
            ring.fillColor = .clear
            addChild(ring)
            ring.run(.repeatForever(.rotate(byAngle: .pi * 2, duration: 3)))
        }
        if type == .omega {
            let outerRing = SKShapeNode(circleOfRadius: type.radius + 11)
            outerRing.strokeColor = SKColor.white.withAlphaComponent(0.5)
            outerRing.lineWidth = 1
            outerRing.glowWidth = 6
            outerRing.fillColor = .clear
            addChild(outerRing)
            outerRing.run(.repeatForever(.rotate(byAngle: -.pi * 2, duration: 2)))
        }
        let pulse = SKAction.sequence([
            .scale(to: 1.08, duration: 0.45),
            .scale(to: 1.0, duration: 0.45),
        ])
        body.run(.repeatForever(pulse))
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been used") }

    var isDead: Bool { hp <= 0 }

    func applyDamage(_ amount: Double) {
        hp -= amount
        let ratio = max(0, CGFloat(hp / maxHP))
        hpBarFill.xScale = ratio
        hpBarFill.position.x = -hpBarBack.frame.width * (1 - ratio) / 2
        if ratio < 0.35 { hpBarFill.fillColor = Theme.red }
        else if ratio < 0.7 { hpBarFill.fillColor = Theme.amber }
    }

    func applySlow(factor: CGFloat, duration: TimeInterval, now: TimeInterval) {
        // OMEGA PRIME shrugs off most of the chill.
        slowFactor = type == .omega ? max(factor, 0.85) : factor
        slowUntil = now + duration
        body.strokeColor = Theme.ice
    }

    func startCarryingShard() {
        carryingShard = true
        state = .retreating
        targetCell = nil
        let icon = SKShapeNode(path: hexagonPath(radius: 5))
        icon.strokeColor = Theme.cyan
        icon.fillColor = Theme.cyan.withAlphaComponent(0.6)
        icon.glowWidth = 5
        icon.position = CGPoint(x: 0, y: -type.radius - 8)
        addChild(icon)
        shardIcon = icon
    }

    /// Advances the enemy. Returns events for the scene to handle.
    func update(dt: TimeInterval, grid: Grid, cellSize: CGFloat, cellCenter: (Cell) -> CGPoint, now: TimeInterval) -> EnemyEvent {
        clock += dt
        if slowUntil > 0 && now > slowUntil {
            slowFactor = 1
            slowUntil = 0
            body.strokeColor = type.color
        }
        if type == .phantom {
            cloakClock += dt
            let cycle = cloakClock.truncatingRemainder(dividingBy: 4.4)
            let shouldCloak = cycle > 3.0
            if shouldCloak != cloaked {
                cloaked = shouldCloak
                run(.fadeAlpha(to: cloaked ? 0.25 : 1.0, duration: 0.25))
            }
        }

        if targetCell == nil {
            switch state {
            case .advancing:
                if currentCell == grid.core { return .reachedCore }
                targetCell = grid.nextCell(from: currentCell, towardCore: true)
            case .retreating:
                if grid.distanceToSpawn(from: currentCell) == 0 { return .escaped }
                targetCell = grid.nextCell(from: currentCell, towardCore: false)
            }
            if targetCell == nil { return .none } // temporarily walled in; wait
        }

        guard let target = targetCell else { return .none }

        // Portal hop: target is not 4-adjacent to the current cell.
        if abs(target.c - currentCell.c) + abs(target.r - currentCell.r) > 1 {
            currentCell = target
            targetCell = nil
            position = cellCenter(target)
            run(.sequence([.fadeAlpha(to: 0.05, duration: 0.05), .fadeAlpha(to: cloaked ? 0.25 : 1.0, duration: 0.2)]))
            return .teleported
        }

        let destination = cellCenter(target)
        let speedBoost: CGFloat = carryingShard ? 1.2 : 1.0
        let step = type.speed * cellSize * slowFactor * speedBoost * CGFloat(dt)
        let delta = destination - position
        if delta.length <= step {
            position = destination
            currentCell = target
            targetCell = nil
        } else {
            position = position + delta.normalized * step
        }
        return .none
    }
}

enum EnemyEvent {
    case none
    case reachedCore
    case escaped
    case teleported
}
