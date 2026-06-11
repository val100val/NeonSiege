import Foundation

struct WaveEntry {
    let type: EnemyType
    let count: Int
    let interval: TimeInterval
}

struct Wave {
    let entries: [WaveEntry]
}

struct LevelDef {
    let id: Int
    let name: String
    let subtitle: String
    let cols: Int
    let rows: Int
    let walls: Set<Cell>
    let spawns: [Cell]
    let core: Cell
    let portalPairs: [(Cell, Cell)]
    let startCredits: Int
    let shards: Int
    let waves: [Wave]
}

enum LevelLibrary {
    static var all: [LevelDef] {
        [bootCamp, twinStreams, theSpiral, crossfire, glitchGate,
         theGauntlet, parallax, reactorRing, vortexRun, finalProtocol]
    }

    static func level(id: Int) -> LevelDef { all[max(0, min(all.count - 1, id - 1))] }

    // MARK: - Wall helpers

    private static func hline(r: Int, c1: Int, c2: Int) -> Set<Cell> {
        Set((min(c1, c2)...max(c1, c2)).map { Cell(c: $0, r: r) })
    }

    private static func vline(c: Int, r1: Int, r2: Int) -> Set<Cell> {
        Set((min(r1, r2)...max(r1, r2)).map { Cell(c: c, r: $0) })
    }

    // MARK: - Waves

    private static func makeWaves(count: Int, levelId: Int) -> [Wave] {
        var waves: [Wave] = []
        for i in 1...count {
            let d = Double(levelId) * 0.5 + Double(i) * 0.35
            var entries: [WaveEntry] = []
            if i % 5 == 0 {
                entries.append(WaveEntry(type: .boss, count: max(1, Int(d / 4)), interval: 2.4))
                entries.append(WaveEntry(type: .drone, count: 6 + i, interval: 0.7))
            } else {
                entries.append(WaveEntry(type: .drone, count: 5 + Int(d * 2), interval: 0.9))
                if i >= 2 { entries.append(WaveEntry(type: .sprinter, count: 2 + Int(d), interval: 0.55)) }
                if i >= 3 { entries.append(WaveEntry(type: .swarm, count: 4 + Int(d * 1.5), interval: 0.3)) }
                if i >= 4 { entries.append(WaveEntry(type: .tank, count: 1 + Int(d * 0.6), interval: 1.6)) }
                if i >= 6 { entries.append(WaveEntry(type: .phantom, count: 1 + Int(d * 0.5), interval: 1.2)) }
            }
            waves.append(Wave(entries: entries))
        }
        return waves
    }

    static func hpScale(wave: Int, levelId: Int) -> Double {
        1 + 0.16 * Double(wave - 1) + 0.12 * Double(levelId - 1)
    }

    // MARK: - Levels

    /// Open field. Classic maze-building: the path is yours to shape.
    private static let bootCamp = LevelDef(
        id: 1,
        name: "Boot Camp",
        subtitle: "Shape the maze. Hold the line.",
        cols: 16, rows: 9,
        walls: [],
        spawns: [Cell(c: 0, r: 4)],
        core: Cell(c: 15, r: 4),
        portalPairs: [],
        startCredits: 180,
        shards: 10,
        waves: makeWaves(count: 8, levelId: 1)
    )

    /// Two spawn gates in opposite corners converge on a central core.
    private static let twinStreams = LevelDef(
        id: 2,
        name: "Twin Streams",
        subtitle: "Two fronts. One core.",
        cols: 18, rows: 9,
        walls: hline(r: 2, c1: 5, c2: 7)
            .union(hline(r: 6, c1: 10, c2: 12))
            .union(vline(c: 4, r1: 6, r2: 7))
            .union(vline(c: 13, r1: 1, r2: 2)),
        spawns: [Cell(c: 0, r: 0), Cell(c: 17, r: 8)],
        core: Cell(c: 9, r: 4),
        portalPairs: [],
        startCredits: 220,
        shards: 8,
        waves: makeWaves(count: 10, levelId: 2)
    )

    /// A long pre-built spiral lane winding into the core.
    private static let theSpiral = LevelDef(
        id: 3,
        name: "The Spiral",
        subtitle: "The long way down.",
        cols: 18, rows: 9,
        walls: vline(c: 3, r1: 1, r2: 7)
            .union(hline(r: 1, c1: 3, c2: 13))
            .union(vline(c: 13, r1: 1, r2: 7))
            .union(hline(r: 7, c1: 5, c2: 13))
            .union(vline(c: 5, r1: 3, r2: 7))
            .union(hline(r: 3, c1: 5, c2: 11))
            .union(vline(c: 11, r1: 3, r2: 5)),
        spawns: [Cell(c: 0, r: 4)],
        core: Cell(c: 9, r: 4),
        portalPairs: [],
        startCredits: 240,
        shards: 8,
        waves: makeWaves(count: 10, levelId: 3)
    )

    /// Four spawn gates, one in each corner. Defend every direction.
    private static let crossfire = LevelDef(
        id: 4,
        name: "Crossfire",
        subtitle: "Surrounded on all sides.",
        cols: 18, rows: 9,
        walls: hline(r: 4, c1: 4, c2: 6)
            .union(hline(r: 4, c1: 11, c2: 13))
            .union(vline(c: 9, r1: 1, r2: 2))
            .union(vline(c: 9, r1: 6, r2: 7)),
        spawns: [Cell(c: 0, r: 0), Cell(c: 17, r: 0), Cell(c: 0, r: 8), Cell(c: 17, r: 8)],
        core: Cell(c: 9, r: 4),
        portalPairs: [],
        startCredits: 260,
        shards: 8,
        waves: makeWaves(count: 12, levelId: 4)
    )

    /// Glitch portals teleport invaders across the map. Watch both exits.
    private static let glitchGate = LevelDef(
        id: 5,
        name: "Glitch Gate",
        subtitle: "Reality is optional here.",
        cols: 18, rows: 9,
        walls: vline(c: 8, r1: 0, r2: 3)
            .union(vline(c: 8, r1: 5, r2: 8)),
        spawns: [Cell(c: 0, r: 1), Cell(c: 0, r: 7)],
        core: Cell(c: 16, r: 4),
        portalPairs: [
            (Cell(c: 5, r: 1), Cell(c: 12, r: 7)),
            (Cell(c: 5, r: 7), Cell(c: 12, r: 1)),
        ],
        startCredits: 280,
        shards: 8,
        waves: makeWaves(count: 12, levelId: 5)
    )

    /// Three wall ribs force a long serpentine march. Punish every turn.
    private static let theGauntlet = LevelDef(
        id: 6,
        name: "The Gauntlet",
        subtitle: "Three gates. No mercy.",
        cols: 18, rows: 9,
        walls: vline(c: 4, r1: 2, r2: 8)
            .union(vline(c: 9, r1: 0, r2: 6))
            .union(vline(c: 14, r1: 2, r2: 8)),
        spawns: [Cell(c: 0, r: 4)],
        core: Cell(c: 17, r: 4),
        portalPairs: [],
        startCredits: 280,
        shards: 8,
        waves: makeWaves(count: 12, levelId: 6)
    )

    /// A wall splits the map into two parallel lanes. Split your budget too.
    private static let parallax = LevelDef(
        id: 7,
        name: "Parallax",
        subtitle: "Two lanes. One budget.",
        cols: 18, rows: 9,
        walls: hline(r: 4, c1: 2, c2: 15),
        spawns: [Cell(c: 0, r: 0), Cell(c: 0, r: 8)],
        core: Cell(c: 17, r: 4),
        portalPairs: [],
        startCredits: 300,
        shards: 8,
        waves: makeWaves(count: 12, levelId: 7)
    )

    /// The core sits inside a walled ring with only two breach points.
    private static let reactorRing = LevelDef(
        id: 8,
        name: "Reactor Ring",
        subtitle: "Two breaches. Four armies.",
        cols: 18, rows: 9,
        walls: hline(r: 2, c1: 6, c2: 12)
            .union(hline(r: 6, c1: 6, c2: 12))
            .union(vline(c: 6, r1: 3, r2: 3))
            .union(vline(c: 6, r1: 5, r2: 5))
            .union(vline(c: 12, r1: 3, r2: 3))
            .union(vline(c: 12, r1: 5, r2: 5)),
        spawns: [Cell(c: 0, r: 0), Cell(c: 17, r: 0), Cell(c: 0, r: 8), Cell(c: 17, r: 8)],
        core: Cell(c: 9, r: 4),
        portalPairs: [],
        startCredits: 320,
        shards: 8,
        waves: makeWaves(count: 13, levelId: 8)
    )

    /// A portal shortcut pierces the central wall. Guard the exit — or exploit it.
    private static let vortexRun = LevelDef(
        id: 9,
        name: "Vortex Run",
        subtitle: "The shortcut is a trap.",
        cols: 18, rows: 9,
        walls: vline(c: 9, r1: 1, r2: 7),
        spawns: [Cell(c: 0, r: 2), Cell(c: 0, r: 6)],
        core: Cell(c: 17, r: 4),
        portalPairs: [
            (Cell(c: 4, r: 4), Cell(c: 13, r: 4)),
        ],
        startCredits: 320,
        shards: 8,
        waves: makeWaves(count: 14, levelId: 9)
    )

    /// The finale: three spawn gates, a glitch portal, and 15 brutal waves.
    private static let finalProtocol = LevelDef(
        id: 10,
        name: "Final Protocol",
        subtitle: "Everything. All at once.",
        cols: 18, rows: 9,
        walls: hline(r: 2, c1: 3, c2: 5)
            .union(hline(r: 6, c1: 3, c2: 5))
            .union(vline(c: 12, r1: 3, r2: 5)),
        spawns: [Cell(c: 0, r: 0), Cell(c: 0, r: 8), Cell(c: 9, r: 0)],
        core: Cell(c: 17, r: 4),
        portalPairs: [
            (Cell(c: 2, r: 4), Cell(c: 14, r: 8)),
        ],
        startCredits: 360,
        shards: 8,
        waves: makeWaves(count: 15, levelId: 10)
    )
}

enum Progress {
    private static let unlockedKey = "ns_unlocked"

    static var unlockedLevel: Int {
        max(1, UserDefaults.standard.integer(forKey: unlockedKey) == 0 ? 1 : UserDefaults.standard.integer(forKey: unlockedKey))
    }

    static func unlock(level: Int) {
        if level > unlockedLevel {
            UserDefaults.standard.set(level, forKey: unlockedKey)
        }
    }

    static func stars(for levelId: Int) -> Int {
        UserDefaults.standard.integer(forKey: "ns_stars_\(levelId)")
    }

    static func setStars(_ stars: Int, for levelId: Int) {
        if stars > Progress.stars(for: levelId) {
            UserDefaults.standard.set(stars, forKey: "ns_stars_\(levelId)")
        }
    }
}
