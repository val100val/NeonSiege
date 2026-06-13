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
         theGauntlet, parallax, reactorRing, vortexRun, finalProtocol,
         theSwitchback, diamondField, theHive, mirrorMaze, pinwheel,
         catacombs, twinVortex, theCrucible, labyrinthOfEchoes, omegaCitadel]
    }

    static func level(id: Int) -> LevelDef { all[max(0, min(all.count - 1, id - 1))] }

    // MARK: - Waves
    //
    // Levels are large, real mazes now, so enemies travel far - we lean the
    // difficulty into denser packs and steeper HP so the back half stays tense.

    private static func makeWaves(count: Int, levelId: Int) -> [Wave] {
        var waves: [Wave] = []
        for i in 1...count {
            let d = Double(levelId) * 0.55 + Double(i) * 0.4
            var entries: [WaveEntry] = []
            if i % 5 == 0 {
                entries.append(WaveEntry(type: .boss, count: max(1, Int(d / 3.4)), interval: 2.2))
                entries.append(WaveEntry(type: .drone, count: 7 + i, interval: 0.65))
            } else {
                entries.append(WaveEntry(type: .drone, count: 6 + Int(d * 2.2), interval: 0.85))
                if i >= 2 { entries.append(WaveEntry(type: .sprinter, count: 3 + Int(d * 1.1), interval: 0.5)) }
                if i >= 3 { entries.append(WaveEntry(type: .swarm, count: 5 + Int(d * 1.7), interval: 0.28)) }
                if i >= 4 { entries.append(WaveEntry(type: .tank, count: 1 + Int(d * 0.7), interval: 1.5)) }
                if i >= 6 { entries.append(WaveEntry(type: .phantom, count: 1 + Int(d * 0.6), interval: 1.1)) }
            }
            waves.append(Wave(entries: entries))
        }
        return waves
    }

    /// Waves for levels 11+: denser mixes, Juggernauts every 5th wave,
    /// a Colossus every 10th, and OMEGA PRIME closing out the campaign.
    private static func makeEpicWaves(count: Int, levelId: Int, finale: Bool = false) -> [Wave] {
        var waves: [Wave] = []
        for i in 1...count {
            let d = Double(levelId) * 0.6 + Double(i) * 0.45
            var entries: [WaveEntry] = []
            if finale && i == count {
                entries.append(WaveEntry(type: .omega, count: 1, interval: 1))
                entries.append(WaveEntry(type: .colossus, count: 2, interval: 4))
                entries.append(WaveEntry(type: .juggernaut, count: 3, interval: 3))
                entries.append(WaveEntry(type: .swarm, count: 18, interval: 0.22))
            } else if i % 10 == 0 {
                entries.append(WaveEntry(type: .colossus, count: max(1, Int(d / 9)), interval: 3.3))
                entries.append(WaveEntry(type: .sprinter, count: 7 + Int(d), interval: 0.42))
            } else if i % 5 == 0 {
                entries.append(WaveEntry(type: .juggernaut, count: max(1, Int(d / 5.5)), interval: 2.6))
                entries.append(WaveEntry(type: .drone, count: 9 + i, interval: 0.55))
            } else {
                entries.append(WaveEntry(type: .drone, count: 7 + Int(d * 2.4), interval: 0.75))
                entries.append(WaveEntry(type: .sprinter, count: 4 + Int(d * 1.2), interval: 0.45))
                if i >= 2 { entries.append(WaveEntry(type: .swarm, count: 7 + Int(d * 1.8), interval: 0.26)) }
                if i >= 3 { entries.append(WaveEntry(type: .tank, count: 2 + Int(d * 0.8), interval: 1.3)) }
                if i >= 4 { entries.append(WaveEntry(type: .phantom, count: 1 + Int(d * 0.7), interval: 1.0)) }
                if i >= 7 { entries.append(WaveEntry(type: .boss, count: 1 + Int(d / 7), interval: 2.0)) }
            }
            waves.append(Wave(entries: entries))
        }
        return waves
    }

    static func hpScale(wave: Int, levelId: Int) -> Double {
        1 + 0.18 * Double(wave - 1) + 0.14 * Double(levelId - 1)
    }

    // MARK: - Levels
    //
    // Geometry is generated and BFS-validated by tools/build_levels.py - every
    // level guarantees a winding spawn->core path plus buildable pockets for
    // tower-mazing. Do not hand-edit wall coordinates; regenerate instead.

private static let bootCamp = LevelDef(
        id: 1,
        name: "Boot Camp",
        subtitle: "Shape the maze. Hold the line.",
        cols: 26, rows: 14,
        walls: [Cell(c: 8, r: 4), Cell(c: 9, r: 4), Cell(c: 10, r: 4), Cell(c: 11, r: 4), Cell(c: 12, r: 4), Cell(c: 13, r: 4), Cell(c: 14, r: 4), Cell(c: 15, r: 4), Cell(c: 16, r: 4), Cell(c: 17, r: 4), Cell(c: 18, r: 4), Cell(c: 19, r: 4), Cell(c: 20, r: 4), Cell(c: 21, r: 4), Cell(c: 22, r: 4), Cell(c: 23, r: 4), Cell(c: 24, r: 4), Cell(c: 25, r: 4), Cell(c: 0, r: 8), Cell(c: 1, r: 8), Cell(c: 2, r: 8), Cell(c: 3, r: 8), Cell(c: 4, r: 8), Cell(c: 5, r: 8), Cell(c: 6, r: 8), Cell(c: 7, r: 8), Cell(c: 8, r: 8), Cell(c: 9, r: 8), Cell(c: 10, r: 8), Cell(c: 11, r: 8), Cell(c: 12, r: 8), Cell(c: 13, r: 8), Cell(c: 14, r: 8), Cell(c: 15, r: 8), Cell(c: 16, r: 8), Cell(c: 17, r: 8)],
        spawns: [Cell(c: 0, r: 6)],
        core: Cell(c: 25, r: 6),
        portalPairs: [],
        startCredits: 200,
        shards: 10,
        waves: makeWaves(count: 8, levelId: 1)
    );
    private static let twinStreams = LevelDef(
        id: 2,
        name: "Twin Streams",
        subtitle: "Two fronts. One core.",
        cols: 28, rows: 14,
        walls: [Cell(c: 13, r: 0), Cell(c: 13, r: 1), Cell(c: 13, r: 2), Cell(c: 13, r: 3), Cell(c: 13, r: 4), Cell(c: 18, r: 4), Cell(c: 19, r: 4), Cell(c: 20, r: 4), Cell(c: 21, r: 4), Cell(c: 22, r: 4), Cell(c: 23, r: 4), Cell(c: 24, r: 4), Cell(c: 13, r: 5), Cell(c: 4, r: 6), Cell(c: 5, r: 6), Cell(c: 6, r: 6), Cell(c: 7, r: 6), Cell(c: 8, r: 6), Cell(c: 9, r: 6), Cell(c: 4, r: 7), Cell(c: 5, r: 7), Cell(c: 6, r: 7), Cell(c: 7, r: 7), Cell(c: 8, r: 7), Cell(c: 9, r: 7), Cell(c: 13, r: 8), Cell(c: 13, r: 9), Cell(c: 18, r: 9), Cell(c: 19, r: 9), Cell(c: 20, r: 9), Cell(c: 21, r: 9), Cell(c: 22, r: 9), Cell(c: 23, r: 9), Cell(c: 24, r: 9), Cell(c: 13, r: 10), Cell(c: 13, r: 11), Cell(c: 13, r: 12), Cell(c: 13, r: 13)],
        spawns: [Cell(c: 0, r: 13), Cell(c: 0, r: 0)],
        core: Cell(c: 27, r: 6),
        portalPairs: [],
        startCredits: 240,
        shards: 8,
        waves: makeWaves(count: 10, levelId: 2)
    );
    private static let theSpiral = LevelDef(
        id: 3,
        name: "The Spiral",
        subtitle: "The long way in.",
        cols: 26, rows: 16,
        walls: [Cell(c: 2, r: 2), Cell(c: 3, r: 2), Cell(c: 4, r: 2), Cell(c: 5, r: 2), Cell(c: 6, r: 2), Cell(c: 7, r: 2), Cell(c: 8, r: 2), Cell(c: 9, r: 2), Cell(c: 10, r: 2), Cell(c: 11, r: 2), Cell(c: 12, r: 2), Cell(c: 13, r: 2), Cell(c: 14, r: 2), Cell(c: 15, r: 2), Cell(c: 16, r: 2), Cell(c: 17, r: 2), Cell(c: 18, r: 2), Cell(c: 19, r: 2), Cell(c: 20, r: 2), Cell(c: 21, r: 2), Cell(c: 22, r: 2), Cell(c: 23, r: 2), Cell(c: 2, r: 3), Cell(c: 23, r: 3), Cell(c: 2, r: 4), Cell(c: 5, r: 4), Cell(c: 6, r: 4), Cell(c: 7, r: 4), Cell(c: 8, r: 4), Cell(c: 9, r: 4), Cell(c: 10, r: 4), Cell(c: 11, r: 4), Cell(c: 12, r: 4), Cell(c: 13, r: 4), Cell(c: 14, r: 4), Cell(c: 15, r: 4), Cell(c: 16, r: 4), Cell(c: 17, r: 4), Cell(c: 18, r: 4), Cell(c: 19, r: 4), Cell(c: 20, r: 4), Cell(c: 23, r: 4), Cell(c: 2, r: 5), Cell(c: 5, r: 5), Cell(c: 20, r: 5), Cell(c: 23, r: 5), Cell(c: 2, r: 6), Cell(c: 5, r: 6), Cell(c: 9, r: 6), Cell(c: 10, r: 6), Cell(c: 11, r: 6), Cell(c: 12, r: 6), Cell(c: 13, r: 6), Cell(c: 14, r: 6), Cell(c: 15, r: 6), Cell(c: 16, r: 6), Cell(c: 17, r: 6), Cell(c: 20, r: 6), Cell(c: 5, r: 7), Cell(c: 17, r: 7), Cell(c: 20, r: 7), Cell(c: 2, r: 8), Cell(c: 5, r: 8), Cell(c: 17, r: 8), Cell(c: 20, r: 8), Cell(c: 2, r: 9), Cell(c: 5, r: 9), Cell(c: 8, r: 9), Cell(c: 9, r: 9), Cell(c: 10, r: 9), Cell(c: 11, r: 9), Cell(c: 12, r: 9), Cell(c: 13, r: 9), Cell(c: 14, r: 9), Cell(c: 15, r: 9), Cell(c: 16, r: 9), Cell(c: 17, r: 9), Cell(c: 20, r: 9), Cell(c: 23, r: 9), Cell(c: 2, r: 10), Cell(c: 5, r: 10), Cell(c: 20, r: 10), Cell(c: 23, r: 10), Cell(c: 2, r: 11), Cell(c: 5, r: 11), Cell(c: 6, r: 11), Cell(c: 7, r: 11), Cell(c: 8, r: 11), Cell(c: 9, r: 11), Cell(c: 10, r: 11), Cell(c: 11, r: 11), Cell(c: 15, r: 11), Cell(c: 16, r: 11), Cell(c: 17, r: 11), Cell(c: 18, r: 11), Cell(c: 19, r: 11), Cell(c: 20, r: 11), Cell(c: 23, r: 11), Cell(c: 2, r: 12), Cell(c: 23, r: 12), Cell(c: 2, r: 13), Cell(c: 3, r: 13), Cell(c: 4, r: 13), Cell(c: 5, r: 13), Cell(c: 6, r: 13), Cell(c: 7, r: 13), Cell(c: 8, r: 13), Cell(c: 9, r: 13), Cell(c: 10, r: 13), Cell(c: 11, r: 13), Cell(c: 12, r: 13), Cell(c: 13, r: 13), Cell(c: 14, r: 13), Cell(c: 15, r: 13), Cell(c: 16, r: 13), Cell(c: 17, r: 13), Cell(c: 18, r: 13), Cell(c: 19, r: 13), Cell(c: 20, r: 13), Cell(c: 21, r: 13), Cell(c: 22, r: 13), Cell(c: 23, r: 13)],
        spawns: [Cell(c: 0, r: 7)],
        core: Cell(c: 13, r: 7),
        portalPairs: [],
        startCredits: 280,
        shards: 8,
        waves: makeWaves(count: 10, levelId: 3)
    );
    private static let crossfire = LevelDef(
        id: 4,
        name: "Crossfire",
        subtitle: "Surrounded on all sides.",
        cols: 26, rows: 16,
        walls: [Cell(c: 2, r: 2), Cell(c: 3, r: 2), Cell(c: 4, r: 2), Cell(c: 5, r: 2), Cell(c: 6, r: 2), Cell(c: 7, r: 2), Cell(c: 8, r: 2), Cell(c: 9, r: 2), Cell(c: 10, r: 2), Cell(c: 11, r: 2), Cell(c: 12, r: 2), Cell(c: 13, r: 2), Cell(c: 14, r: 2), Cell(c: 15, r: 2), Cell(c: 16, r: 2), Cell(c: 17, r: 2), Cell(c: 18, r: 2), Cell(c: 19, r: 2), Cell(c: 20, r: 2), Cell(c: 21, r: 2), Cell(c: 22, r: 2), Cell(c: 23, r: 2), Cell(c: 2, r: 3), Cell(c: 23, r: 3), Cell(c: 2, r: 4), Cell(c: 5, r: 4), Cell(c: 6, r: 4), Cell(c: 7, r: 4), Cell(c: 8, r: 4), Cell(c: 9, r: 4), Cell(c: 10, r: 4), Cell(c: 11, r: 4), Cell(c: 12, r: 4), Cell(c: 13, r: 4), Cell(c: 14, r: 4), Cell(c: 15, r: 4), Cell(c: 16, r: 4), Cell(c: 17, r: 4), Cell(c: 18, r: 4), Cell(c: 19, r: 4), Cell(c: 20, r: 4), Cell(c: 23, r: 4), Cell(c: 2, r: 5), Cell(c: 5, r: 5), Cell(c: 20, r: 5), Cell(c: 23, r: 5), Cell(c: 2, r: 6), Cell(c: 5, r: 6), Cell(c: 9, r: 6), Cell(c: 10, r: 6), Cell(c: 11, r: 6), Cell(c: 12, r: 6), Cell(c: 13, r: 6), Cell(c: 14, r: 6), Cell(c: 15, r: 6), Cell(c: 16, r: 6), Cell(c: 17, r: 6), Cell(c: 20, r: 6), Cell(c: 2, r: 7), Cell(c: 5, r: 7), Cell(c: 17, r: 7), Cell(c: 20, r: 7), Cell(c: 2, r: 8), Cell(c: 5, r: 8), Cell(c: 17, r: 8), Cell(c: 20, r: 8), Cell(c: 2, r: 9), Cell(c: 5, r: 9), Cell(c: 8, r: 9), Cell(c: 9, r: 9), Cell(c: 10, r: 9), Cell(c: 11, r: 9), Cell(c: 12, r: 9), Cell(c: 13, r: 9), Cell(c: 14, r: 9), Cell(c: 15, r: 9), Cell(c: 16, r: 9), Cell(c: 17, r: 9), Cell(c: 20, r: 9), Cell(c: 23, r: 9), Cell(c: 2, r: 10), Cell(c: 5, r: 10), Cell(c: 20, r: 10), Cell(c: 23, r: 10), Cell(c: 2, r: 11), Cell(c: 5, r: 11), Cell(c: 6, r: 11), Cell(c: 7, r: 11), Cell(c: 8, r: 11), Cell(c: 9, r: 11), Cell(c: 10, r: 11), Cell(c: 11, r: 11), Cell(c: 15, r: 11), Cell(c: 16, r: 11), Cell(c: 17, r: 11), Cell(c: 18, r: 11), Cell(c: 19, r: 11), Cell(c: 20, r: 11), Cell(c: 23, r: 11), Cell(c: 2, r: 12), Cell(c: 23, r: 12), Cell(c: 2, r: 13), Cell(c: 3, r: 13), Cell(c: 4, r: 13), Cell(c: 5, r: 13), Cell(c: 6, r: 13), Cell(c: 7, r: 13), Cell(c: 8, r: 13), Cell(c: 9, r: 13), Cell(c: 10, r: 13), Cell(c: 11, r: 13), Cell(c: 12, r: 13), Cell(c: 13, r: 13), Cell(c: 14, r: 13), Cell(c: 15, r: 13), Cell(c: 16, r: 13), Cell(c: 17, r: 13), Cell(c: 18, r: 13), Cell(c: 19, r: 13), Cell(c: 20, r: 13), Cell(c: 21, r: 13), Cell(c: 22, r: 13), Cell(c: 23, r: 13)],
        spawns: [Cell(c: 0, r: 15), Cell(c: 25, r: 15), Cell(c: 0, r: 0), Cell(c: 25, r: 0)],
        core: Cell(c: 13, r: 7),
        portalPairs: [],
        startCredits: 300,
        shards: 8,
        waves: makeWaves(count: 12, levelId: 4)
    );
    private static let glitchGate = LevelDef(
        id: 5,
        name: "Glitch Gate",
        subtitle: "Reality is optional here.",
        cols: 28, rows: 15,
        walls: [Cell(c: 2, r: 3), Cell(c: 3, r: 3), Cell(c: 4, r: 3), Cell(c: 5, r: 3), Cell(c: 6, r: 3), Cell(c: 7, r: 3), Cell(c: 8, r: 3), Cell(c: 9, r: 3), Cell(c: 10, r: 3), Cell(c: 11, r: 3), Cell(c: 12, r: 3), Cell(c: 13, r: 3), Cell(c: 14, r: 3), Cell(c: 15, r: 3), Cell(c: 16, r: 3), Cell(c: 17, r: 3), Cell(c: 18, r: 3), Cell(c: 19, r: 3), Cell(c: 20, r: 3), Cell(c: 21, r: 3), Cell(c: 22, r: 3), Cell(c: 23, r: 3), Cell(c: 24, r: 3), Cell(c: 25, r: 3), Cell(c: 26, r: 3), Cell(c: 27, r: 3), Cell(c: 0, r: 6), Cell(c: 1, r: 6), Cell(c: 2, r: 6), Cell(c: 3, r: 6), Cell(c: 4, r: 6), Cell(c: 5, r: 6), Cell(c: 6, r: 6), Cell(c: 7, r: 6), Cell(c: 8, r: 6), Cell(c: 9, r: 6), Cell(c: 10, r: 6), Cell(c: 11, r: 6), Cell(c: 12, r: 6), Cell(c: 13, r: 6), Cell(c: 14, r: 6), Cell(c: 15, r: 6), Cell(c: 16, r: 6), Cell(c: 17, r: 6), Cell(c: 18, r: 6), Cell(c: 19, r: 6), Cell(c: 20, r: 6), Cell(c: 21, r: 6), Cell(c: 22, r: 6), Cell(c: 23, r: 6), Cell(c: 24, r: 6), Cell(c: 25, r: 6), Cell(c: 2, r: 8), Cell(c: 3, r: 8), Cell(c: 4, r: 8), Cell(c: 5, r: 8), Cell(c: 6, r: 8), Cell(c: 7, r: 8), Cell(c: 8, r: 8), Cell(c: 9, r: 8), Cell(c: 10, r: 8), Cell(c: 11, r: 8), Cell(c: 12, r: 8), Cell(c: 13, r: 8), Cell(c: 14, r: 8), Cell(c: 15, r: 8), Cell(c: 16, r: 8), Cell(c: 17, r: 8), Cell(c: 18, r: 8), Cell(c: 19, r: 8), Cell(c: 20, r: 8), Cell(c: 21, r: 8), Cell(c: 22, r: 8), Cell(c: 23, r: 8), Cell(c: 24, r: 8), Cell(c: 25, r: 8), Cell(c: 26, r: 8), Cell(c: 27, r: 8), Cell(c: 0, r: 11), Cell(c: 1, r: 11), Cell(c: 2, r: 11), Cell(c: 3, r: 11), Cell(c: 4, r: 11), Cell(c: 5, r: 11), Cell(c: 6, r: 11), Cell(c: 7, r: 11), Cell(c: 8, r: 11), Cell(c: 9, r: 11), Cell(c: 10, r: 11), Cell(c: 11, r: 11), Cell(c: 12, r: 11), Cell(c: 13, r: 11), Cell(c: 14, r: 11), Cell(c: 15, r: 11), Cell(c: 16, r: 11), Cell(c: 17, r: 11), Cell(c: 18, r: 11), Cell(c: 19, r: 11), Cell(c: 20, r: 11), Cell(c: 21, r: 11), Cell(c: 22, r: 11), Cell(c: 23, r: 11), Cell(c: 24, r: 11), Cell(c: 25, r: 11)],
        spawns: [Cell(c: 0, r: 12), Cell(c: 0, r: 2)],
        core: Cell(c: 27, r: 7),
        portalPairs: [(Cell(c: 4, r: 12), Cell(c: 23, r: 2)), (Cell(c: 4, r: 2), Cell(c: 23, r: 12))],
        startCredits: 320,
        shards: 8,
        waves: makeWaves(count: 12, levelId: 5)
    );
    private static let theGauntlet = LevelDef(
        id: 6,
        name: "The Gauntlet",
        subtitle: "Six gates. No mercy.",
        cols: 30, rows: 15,
        walls: [Cell(c: 2, r: 2), Cell(c: 3, r: 2), Cell(c: 4, r: 2), Cell(c: 5, r: 2), Cell(c: 6, r: 2), Cell(c: 7, r: 2), Cell(c: 8, r: 2), Cell(c: 9, r: 2), Cell(c: 10, r: 2), Cell(c: 11, r: 2), Cell(c: 12, r: 2), Cell(c: 13, r: 2), Cell(c: 14, r: 2), Cell(c: 15, r: 2), Cell(c: 16, r: 2), Cell(c: 17, r: 2), Cell(c: 18, r: 2), Cell(c: 19, r: 2), Cell(c: 20, r: 2), Cell(c: 21, r: 2), Cell(c: 22, r: 2), Cell(c: 23, r: 2), Cell(c: 24, r: 2), Cell(c: 25, r: 2), Cell(c: 26, r: 2), Cell(c: 27, r: 2), Cell(c: 28, r: 2), Cell(c: 29, r: 2), Cell(c: 0, r: 4), Cell(c: 1, r: 4), Cell(c: 2, r: 4), Cell(c: 3, r: 4), Cell(c: 4, r: 4), Cell(c: 5, r: 4), Cell(c: 6, r: 4), Cell(c: 7, r: 4), Cell(c: 8, r: 4), Cell(c: 9, r: 4), Cell(c: 10, r: 4), Cell(c: 11, r: 4), Cell(c: 12, r: 4), Cell(c: 13, r: 4), Cell(c: 14, r: 4), Cell(c: 15, r: 4), Cell(c: 16, r: 4), Cell(c: 17, r: 4), Cell(c: 18, r: 4), Cell(c: 19, r: 4), Cell(c: 20, r: 4), Cell(c: 21, r: 4), Cell(c: 22, r: 4), Cell(c: 23, r: 4), Cell(c: 24, r: 4), Cell(c: 25, r: 4), Cell(c: 26, r: 4), Cell(c: 27, r: 4), Cell(c: 2, r: 6), Cell(c: 3, r: 6), Cell(c: 4, r: 6), Cell(c: 5, r: 6), Cell(c: 6, r: 6), Cell(c: 7, r: 6), Cell(c: 8, r: 6), Cell(c: 9, r: 6), Cell(c: 10, r: 6), Cell(c: 11, r: 6), Cell(c: 12, r: 6), Cell(c: 13, r: 6), Cell(c: 14, r: 6), Cell(c: 15, r: 6), Cell(c: 16, r: 6), Cell(c: 17, r: 6), Cell(c: 18, r: 6), Cell(c: 19, r: 6), Cell(c: 20, r: 6), Cell(c: 21, r: 6), Cell(c: 22, r: 6), Cell(c: 23, r: 6), Cell(c: 24, r: 6), Cell(c: 25, r: 6), Cell(c: 26, r: 6), Cell(c: 27, r: 6), Cell(c: 28, r: 6), Cell(c: 29, r: 6), Cell(c: 0, r: 8), Cell(c: 1, r: 8), Cell(c: 2, r: 8), Cell(c: 3, r: 8), Cell(c: 4, r: 8), Cell(c: 5, r: 8), Cell(c: 6, r: 8), Cell(c: 7, r: 8), Cell(c: 8, r: 8), Cell(c: 9, r: 8), Cell(c: 10, r: 8), Cell(c: 11, r: 8), Cell(c: 12, r: 8), Cell(c: 13, r: 8), Cell(c: 14, r: 8), Cell(c: 15, r: 8), Cell(c: 16, r: 8), Cell(c: 17, r: 8), Cell(c: 18, r: 8), Cell(c: 19, r: 8), Cell(c: 20, r: 8), Cell(c: 21, r: 8), Cell(c: 22, r: 8), Cell(c: 23, r: 8), Cell(c: 24, r: 8), Cell(c: 25, r: 8), Cell(c: 26, r: 8), Cell(c: 27, r: 8), Cell(c: 2, r: 10), Cell(c: 3, r: 10), Cell(c: 4, r: 10), Cell(c: 5, r: 10), Cell(c: 6, r: 10), Cell(c: 7, r: 10), Cell(c: 8, r: 10), Cell(c: 9, r: 10), Cell(c: 10, r: 10), Cell(c: 11, r: 10), Cell(c: 12, r: 10), Cell(c: 13, r: 10), Cell(c: 14, r: 10), Cell(c: 15, r: 10), Cell(c: 16, r: 10), Cell(c: 17, r: 10), Cell(c: 18, r: 10), Cell(c: 19, r: 10), Cell(c: 20, r: 10), Cell(c: 21, r: 10), Cell(c: 22, r: 10), Cell(c: 23, r: 10), Cell(c: 24, r: 10), Cell(c: 25, r: 10), Cell(c: 26, r: 10), Cell(c: 27, r: 10), Cell(c: 28, r: 10), Cell(c: 29, r: 10), Cell(c: 0, r: 12), Cell(c: 1, r: 12), Cell(c: 2, r: 12), Cell(c: 3, r: 12), Cell(c: 4, r: 12), Cell(c: 5, r: 12), Cell(c: 6, r: 12), Cell(c: 7, r: 12), Cell(c: 8, r: 12), Cell(c: 9, r: 12), Cell(c: 10, r: 12), Cell(c: 11, r: 12), Cell(c: 12, r: 12), Cell(c: 13, r: 12), Cell(c: 14, r: 12), Cell(c: 15, r: 12), Cell(c: 16, r: 12), Cell(c: 17, r: 12), Cell(c: 18, r: 12), Cell(c: 19, r: 12), Cell(c: 20, r: 12), Cell(c: 21, r: 12), Cell(c: 22, r: 12), Cell(c: 23, r: 12), Cell(c: 24, r: 12), Cell(c: 25, r: 12), Cell(c: 26, r: 12), Cell(c: 27, r: 12)],
        spawns: [Cell(c: 0, r: 13)],
        core: Cell(c: 29, r: 1),
        portalPairs: [],
        startCredits: 320,
        shards: 8,
        waves: makeWaves(count: 12, levelId: 6)
    );
    private static let parallax = LevelDef(
        id: 7,
        name: "Parallax",
        subtitle: "Up, down, repeat.",
        cols: 28, rows: 16,
        walls: [Cell(c: 8, r: 0), Cell(c: 16, r: 0), Cell(c: 24, r: 0), Cell(c: 8, r: 1), Cell(c: 16, r: 1), Cell(c: 24, r: 1), Cell(c: 4, r: 2), Cell(c: 8, r: 2), Cell(c: 12, r: 2), Cell(c: 16, r: 2), Cell(c: 20, r: 2), Cell(c: 24, r: 2), Cell(c: 4, r: 3), Cell(c: 8, r: 3), Cell(c: 12, r: 3), Cell(c: 16, r: 3), Cell(c: 20, r: 3), Cell(c: 24, r: 3), Cell(c: 4, r: 4), Cell(c: 8, r: 4), Cell(c: 12, r: 4), Cell(c: 16, r: 4), Cell(c: 20, r: 4), Cell(c: 24, r: 4), Cell(c: 4, r: 5), Cell(c: 8, r: 5), Cell(c: 12, r: 5), Cell(c: 16, r: 5), Cell(c: 20, r: 5), Cell(c: 24, r: 5), Cell(c: 4, r: 6), Cell(c: 8, r: 6), Cell(c: 12, r: 6), Cell(c: 16, r: 6), Cell(c: 20, r: 6), Cell(c: 24, r: 6), Cell(c: 4, r: 7), Cell(c: 8, r: 7), Cell(c: 12, r: 7), Cell(c: 16, r: 7), Cell(c: 20, r: 7), Cell(c: 24, r: 7), Cell(c: 4, r: 8), Cell(c: 8, r: 8), Cell(c: 12, r: 8), Cell(c: 16, r: 8), Cell(c: 20, r: 8), Cell(c: 24, r: 8), Cell(c: 4, r: 9), Cell(c: 8, r: 9), Cell(c: 12, r: 9), Cell(c: 16, r: 9), Cell(c: 20, r: 9), Cell(c: 24, r: 9), Cell(c: 4, r: 10), Cell(c: 8, r: 10), Cell(c: 12, r: 10), Cell(c: 16, r: 10), Cell(c: 20, r: 10), Cell(c: 24, r: 10), Cell(c: 4, r: 11), Cell(c: 8, r: 11), Cell(c: 12, r: 11), Cell(c: 16, r: 11), Cell(c: 20, r: 11), Cell(c: 24, r: 11), Cell(c: 4, r: 12), Cell(c: 8, r: 12), Cell(c: 12, r: 12), Cell(c: 16, r: 12), Cell(c: 20, r: 12), Cell(c: 24, r: 12), Cell(c: 4, r: 13), Cell(c: 8, r: 13), Cell(c: 12, r: 13), Cell(c: 16, r: 13), Cell(c: 20, r: 13), Cell(c: 24, r: 13), Cell(c: 4, r: 14), Cell(c: 12, r: 14), Cell(c: 20, r: 14), Cell(c: 4, r: 15), Cell(c: 12, r: 15), Cell(c: 20, r: 15)],
        spawns: [Cell(c: 1, r: 15)],
        core: Cell(c: 26, r: 0),
        portalPairs: [],
        startCredits: 340,
        shards: 8,
        waves: makeWaves(count: 12, levelId: 7)
    );
    private static let reactorRing = LevelDef(
        id: 8,
        name: "Reactor Ring",
        subtitle: "Breach every ring.",
        cols: 28, rows: 16,
        walls: [Cell(c: 2, r: 2), Cell(c: 3, r: 2), Cell(c: 4, r: 2), Cell(c: 5, r: 2), Cell(c: 6, r: 2), Cell(c: 7, r: 2), Cell(c: 8, r: 2), Cell(c: 9, r: 2), Cell(c: 10, r: 2), Cell(c: 11, r: 2), Cell(c: 12, r: 2), Cell(c: 13, r: 2), Cell(c: 14, r: 2), Cell(c: 15, r: 2), Cell(c: 16, r: 2), Cell(c: 17, r: 2), Cell(c: 18, r: 2), Cell(c: 19, r: 2), Cell(c: 20, r: 2), Cell(c: 21, r: 2), Cell(c: 22, r: 2), Cell(c: 23, r: 2), Cell(c: 24, r: 2), Cell(c: 25, r: 2), Cell(c: 2, r: 3), Cell(c: 25, r: 3), Cell(c: 2, r: 4), Cell(c: 5, r: 4), Cell(c: 6, r: 4), Cell(c: 7, r: 4), Cell(c: 8, r: 4), Cell(c: 9, r: 4), Cell(c: 10, r: 4), Cell(c: 11, r: 4), Cell(c: 12, r: 4), Cell(c: 13, r: 4), Cell(c: 14, r: 4), Cell(c: 15, r: 4), Cell(c: 16, r: 4), Cell(c: 17, r: 4), Cell(c: 18, r: 4), Cell(c: 19, r: 4), Cell(c: 20, r: 4), Cell(c: 21, r: 4), Cell(c: 22, r: 4), Cell(c: 25, r: 4), Cell(c: 2, r: 5), Cell(c: 5, r: 5), Cell(c: 22, r: 5), Cell(c: 25, r: 5), Cell(c: 2, r: 6), Cell(c: 5, r: 6), Cell(c: 9, r: 6), Cell(c: 10, r: 6), Cell(c: 11, r: 6), Cell(c: 12, r: 6), Cell(c: 13, r: 6), Cell(c: 14, r: 6), Cell(c: 15, r: 6), Cell(c: 16, r: 6), Cell(c: 17, r: 6), Cell(c: 18, r: 6), Cell(c: 19, r: 6), Cell(c: 22, r: 6), Cell(c: 2, r: 7), Cell(c: 5, r: 7), Cell(c: 19, r: 7), Cell(c: 22, r: 7), Cell(c: 2, r: 8), Cell(c: 5, r: 8), Cell(c: 19, r: 8), Cell(c: 22, r: 8), Cell(c: 2, r: 9), Cell(c: 5, r: 9), Cell(c: 8, r: 9), Cell(c: 9, r: 9), Cell(c: 10, r: 9), Cell(c: 11, r: 9), Cell(c: 12, r: 9), Cell(c: 13, r: 9), Cell(c: 14, r: 9), Cell(c: 15, r: 9), Cell(c: 16, r: 9), Cell(c: 17, r: 9), Cell(c: 18, r: 9), Cell(c: 19, r: 9), Cell(c: 22, r: 9), Cell(c: 25, r: 9), Cell(c: 2, r: 10), Cell(c: 5, r: 10), Cell(c: 22, r: 10), Cell(c: 25, r: 10), Cell(c: 2, r: 11), Cell(c: 5, r: 11), Cell(c: 6, r: 11), Cell(c: 7, r: 11), Cell(c: 8, r: 11), Cell(c: 9, r: 11), Cell(c: 10, r: 11), Cell(c: 11, r: 11), Cell(c: 12, r: 11), Cell(c: 16, r: 11), Cell(c: 17, r: 11), Cell(c: 18, r: 11), Cell(c: 19, r: 11), Cell(c: 20, r: 11), Cell(c: 21, r: 11), Cell(c: 22, r: 11), Cell(c: 25, r: 11), Cell(c: 2, r: 12), Cell(c: 25, r: 12), Cell(c: 2, r: 13), Cell(c: 3, r: 13), Cell(c: 4, r: 13), Cell(c: 5, r: 13), Cell(c: 6, r: 13), Cell(c: 7, r: 13), Cell(c: 8, r: 13), Cell(c: 9, r: 13), Cell(c: 10, r: 13), Cell(c: 11, r: 13), Cell(c: 12, r: 13), Cell(c: 13, r: 13), Cell(c: 14, r: 13), Cell(c: 15, r: 13), Cell(c: 16, r: 13), Cell(c: 17, r: 13), Cell(c: 18, r: 13), Cell(c: 19, r: 13), Cell(c: 20, r: 13), Cell(c: 21, r: 13), Cell(c: 22, r: 13), Cell(c: 23, r: 13), Cell(c: 24, r: 13), Cell(c: 25, r: 13)],
        spawns: [Cell(c: 0, r: 15), Cell(c: 27, r: 15), Cell(c: 0, r: 0), Cell(c: 27, r: 0)],
        core: Cell(c: 14, r: 7),
        portalPairs: [],
        startCredits: 360,
        shards: 8,
        waves: makeWaves(count: 13, levelId: 8)
    );
    private static let vortexRun = LevelDef(
        id: 9,
        name: "Vortex Run",
        subtitle: "The lanes betray you.",
        cols: 28, rows: 16,
        walls: [Cell(c: 3, r: 2), Cell(c: 4, r: 2), Cell(c: 5, r: 2), Cell(c: 6, r: 2), Cell(c: 7, r: 2), Cell(c: 8, r: 2), Cell(c: 9, r: 2), Cell(c: 10, r: 2), Cell(c: 11, r: 2), Cell(c: 12, r: 2), Cell(c: 13, r: 2), Cell(c: 14, r: 2), Cell(c: 15, r: 2), Cell(c: 16, r: 2), Cell(c: 17, r: 2), Cell(c: 18, r: 2), Cell(c: 19, r: 2), Cell(c: 20, r: 2), Cell(c: 21, r: 2), Cell(c: 22, r: 2), Cell(c: 23, r: 2), Cell(c: 24, r: 2), Cell(c: 25, r: 2), Cell(c: 2, r: 3), Cell(c: 25, r: 3), Cell(c: 2, r: 4), Cell(c: 5, r: 4), Cell(c: 6, r: 4), Cell(c: 7, r: 4), Cell(c: 8, r: 4), Cell(c: 9, r: 4), Cell(c: 10, r: 4), Cell(c: 11, r: 4), Cell(c: 12, r: 4), Cell(c: 13, r: 4), Cell(c: 14, r: 4), Cell(c: 15, r: 4), Cell(c: 16, r: 4), Cell(c: 17, r: 4), Cell(c: 18, r: 4), Cell(c: 19, r: 4), Cell(c: 20, r: 4), Cell(c: 21, r: 4), Cell(c: 22, r: 4), Cell(c: 25, r: 4), Cell(c: 2, r: 5), Cell(c: 5, r: 5), Cell(c: 22, r: 5), Cell(c: 25, r: 5), Cell(c: 2, r: 6), Cell(c: 5, r: 6), Cell(c: 9, r: 6), Cell(c: 10, r: 6), Cell(c: 11, r: 6), Cell(c: 12, r: 6), Cell(c: 13, r: 6), Cell(c: 14, r: 6), Cell(c: 15, r: 6), Cell(c: 16, r: 6), Cell(c: 17, r: 6), Cell(c: 18, r: 6), Cell(c: 19, r: 6), Cell(c: 22, r: 6), Cell(c: 2, r: 7), Cell(c: 5, r: 7), Cell(c: 19, r: 7), Cell(c: 22, r: 7), Cell(c: 2, r: 8), Cell(c: 5, r: 8), Cell(c: 19, r: 8), Cell(c: 22, r: 8), Cell(c: 2, r: 9), Cell(c: 5, r: 9), Cell(c: 8, r: 9), Cell(c: 9, r: 9), Cell(c: 10, r: 9), Cell(c: 11, r: 9), Cell(c: 12, r: 9), Cell(c: 13, r: 9), Cell(c: 14, r: 9), Cell(c: 15, r: 9), Cell(c: 16, r: 9), Cell(c: 17, r: 9), Cell(c: 18, r: 9), Cell(c: 19, r: 9), Cell(c: 22, r: 9), Cell(c: 25, r: 9), Cell(c: 2, r: 10), Cell(c: 5, r: 10), Cell(c: 22, r: 10), Cell(c: 25, r: 10), Cell(c: 2, r: 11), Cell(c: 5, r: 11), Cell(c: 6, r: 11), Cell(c: 7, r: 11), Cell(c: 8, r: 11), Cell(c: 9, r: 11), Cell(c: 10, r: 11), Cell(c: 11, r: 11), Cell(c: 12, r: 11), Cell(c: 16, r: 11), Cell(c: 17, r: 11), Cell(c: 18, r: 11), Cell(c: 19, r: 11), Cell(c: 20, r: 11), Cell(c: 21, r: 11), Cell(c: 22, r: 11), Cell(c: 25, r: 11), Cell(c: 2, r: 12), Cell(c: 25, r: 12), Cell(c: 3, r: 13), Cell(c: 4, r: 13), Cell(c: 5, r: 13), Cell(c: 6, r: 13), Cell(c: 7, r: 13), Cell(c: 8, r: 13), Cell(c: 9, r: 13), Cell(c: 10, r: 13), Cell(c: 11, r: 13), Cell(c: 12, r: 13), Cell(c: 13, r: 13), Cell(c: 14, r: 13), Cell(c: 15, r: 13), Cell(c: 16, r: 13), Cell(c: 17, r: 13), Cell(c: 18, r: 13), Cell(c: 19, r: 13), Cell(c: 20, r: 13), Cell(c: 21, r: 13), Cell(c: 22, r: 13), Cell(c: 23, r: 13), Cell(c: 24, r: 13), Cell(c: 25, r: 13)],
        spawns: [Cell(c: 0, r: 13), Cell(c: 0, r: 2)],
        core: Cell(c: 14, r: 7),
        portalPairs: [(Cell(c: 1, r: 13), Cell(c: 1, r: 2))],
        startCredits: 360,
        shards: 8,
        waves: makeWaves(count: 14, levelId: 9)
    );
    private static let finalProtocol = LevelDef(
        id: 10,
        name: "Final Protocol",
        subtitle: "Everything. All at once.",
        cols: 30, rows: 16,
        walls: [Cell(c: 8, r: 0), Cell(c: 15, r: 0), Cell(c: 22, r: 0), Cell(c: 8, r: 1), Cell(c: 15, r: 1), Cell(c: 22, r: 1), Cell(c: 4, r: 2), Cell(c: 8, r: 2), Cell(c: 11, r: 2), Cell(c: 15, r: 2), Cell(c: 19, r: 2), Cell(c: 22, r: 2), Cell(c: 26, r: 2), Cell(c: 4, r: 3), Cell(c: 8, r: 3), Cell(c: 11, r: 3), Cell(c: 15, r: 3), Cell(c: 19, r: 3), Cell(c: 22, r: 3), Cell(c: 26, r: 3), Cell(c: 4, r: 4), Cell(c: 8, r: 4), Cell(c: 11, r: 4), Cell(c: 15, r: 4), Cell(c: 19, r: 4), Cell(c: 22, r: 4), Cell(c: 26, r: 4), Cell(c: 4, r: 5), Cell(c: 8, r: 5), Cell(c: 11, r: 5), Cell(c: 15, r: 5), Cell(c: 19, r: 5), Cell(c: 22, r: 5), Cell(c: 26, r: 5), Cell(c: 4, r: 6), Cell(c: 8, r: 6), Cell(c: 11, r: 6), Cell(c: 15, r: 6), Cell(c: 19, r: 6), Cell(c: 22, r: 6), Cell(c: 26, r: 6), Cell(c: 4, r: 7), Cell(c: 8, r: 7), Cell(c: 11, r: 7), Cell(c: 15, r: 7), Cell(c: 19, r: 7), Cell(c: 22, r: 7), Cell(c: 26, r: 7), Cell(c: 4, r: 8), Cell(c: 8, r: 8), Cell(c: 11, r: 8), Cell(c: 15, r: 8), Cell(c: 19, r: 8), Cell(c: 22, r: 8), Cell(c: 26, r: 8), Cell(c: 4, r: 9), Cell(c: 8, r: 9), Cell(c: 11, r: 9), Cell(c: 15, r: 9), Cell(c: 19, r: 9), Cell(c: 22, r: 9), Cell(c: 26, r: 9), Cell(c: 4, r: 10), Cell(c: 8, r: 10), Cell(c: 11, r: 10), Cell(c: 15, r: 10), Cell(c: 19, r: 10), Cell(c: 22, r: 10), Cell(c: 26, r: 10), Cell(c: 4, r: 11), Cell(c: 8, r: 11), Cell(c: 11, r: 11), Cell(c: 15, r: 11), Cell(c: 19, r: 11), Cell(c: 22, r: 11), Cell(c: 26, r: 11), Cell(c: 4, r: 12), Cell(c: 8, r: 12), Cell(c: 11, r: 12), Cell(c: 15, r: 12), Cell(c: 19, r: 12), Cell(c: 22, r: 12), Cell(c: 26, r: 12), Cell(c: 4, r: 13), Cell(c: 8, r: 13), Cell(c: 11, r: 13), Cell(c: 15, r: 13), Cell(c: 19, r: 13), Cell(c: 22, r: 13), Cell(c: 26, r: 13), Cell(c: 4, r: 14), Cell(c: 11, r: 14), Cell(c: 19, r: 14), Cell(c: 26, r: 14), Cell(c: 4, r: 15), Cell(c: 11, r: 15), Cell(c: 19, r: 15), Cell(c: 26, r: 15)],
        spawns: [Cell(c: 1, r: 15), Cell(c: 1, r: 0)],
        core: Cell(c: 28, r: 7),
        portalPairs: [(Cell(c: 3, r: 15), Cell(c: 3, r: 0))],
        startCredits: 400,
        shards: 8,
        waves: makeWaves(count: 15, levelId: 10)
    );
    private static let theSwitchback = LevelDef(
        id: 11,
        name: "The Switchback",
        subtitle: "Eight gates. Zero shortcuts.",
        cols: 32, rows: 16,
        walls: [Cell(c: 7, r: 0), Cell(c: 14, r: 0), Cell(c: 21, r: 0), Cell(c: 28, r: 0), Cell(c: 7, r: 1), Cell(c: 14, r: 1), Cell(c: 21, r: 1), Cell(c: 28, r: 1), Cell(c: 4, r: 2), Cell(c: 7, r: 2), Cell(c: 11, r: 2), Cell(c: 14, r: 2), Cell(c: 18, r: 2), Cell(c: 21, r: 2), Cell(c: 25, r: 2), Cell(c: 28, r: 2), Cell(c: 4, r: 3), Cell(c: 7, r: 3), Cell(c: 11, r: 3), Cell(c: 14, r: 3), Cell(c: 18, r: 3), Cell(c: 21, r: 3), Cell(c: 25, r: 3), Cell(c: 28, r: 3), Cell(c: 4, r: 4), Cell(c: 7, r: 4), Cell(c: 11, r: 4), Cell(c: 14, r: 4), Cell(c: 18, r: 4), Cell(c: 21, r: 4), Cell(c: 25, r: 4), Cell(c: 28, r: 4), Cell(c: 4, r: 5), Cell(c: 7, r: 5), Cell(c: 11, r: 5), Cell(c: 14, r: 5), Cell(c: 18, r: 5), Cell(c: 21, r: 5), Cell(c: 25, r: 5), Cell(c: 28, r: 5), Cell(c: 4, r: 6), Cell(c: 7, r: 6), Cell(c: 11, r: 6), Cell(c: 14, r: 6), Cell(c: 18, r: 6), Cell(c: 21, r: 6), Cell(c: 25, r: 6), Cell(c: 28, r: 6), Cell(c: 4, r: 7), Cell(c: 7, r: 7), Cell(c: 11, r: 7), Cell(c: 14, r: 7), Cell(c: 18, r: 7), Cell(c: 21, r: 7), Cell(c: 25, r: 7), Cell(c: 28, r: 7), Cell(c: 4, r: 8), Cell(c: 7, r: 8), Cell(c: 11, r: 8), Cell(c: 14, r: 8), Cell(c: 18, r: 8), Cell(c: 21, r: 8), Cell(c: 25, r: 8), Cell(c: 28, r: 8), Cell(c: 4, r: 9), Cell(c: 7, r: 9), Cell(c: 11, r: 9), Cell(c: 14, r: 9), Cell(c: 18, r: 9), Cell(c: 21, r: 9), Cell(c: 25, r: 9), Cell(c: 28, r: 9), Cell(c: 4, r: 10), Cell(c: 7, r: 10), Cell(c: 11, r: 10), Cell(c: 14, r: 10), Cell(c: 18, r: 10), Cell(c: 21, r: 10), Cell(c: 25, r: 10), Cell(c: 28, r: 10), Cell(c: 4, r: 11), Cell(c: 7, r: 11), Cell(c: 11, r: 11), Cell(c: 14, r: 11), Cell(c: 18, r: 11), Cell(c: 21, r: 11), Cell(c: 25, r: 11), Cell(c: 28, r: 11), Cell(c: 4, r: 12), Cell(c: 7, r: 12), Cell(c: 11, r: 12), Cell(c: 14, r: 12), Cell(c: 18, r: 12), Cell(c: 21, r: 12), Cell(c: 25, r: 12), Cell(c: 28, r: 12), Cell(c: 4, r: 13), Cell(c: 7, r: 13), Cell(c: 11, r: 13), Cell(c: 14, r: 13), Cell(c: 18, r: 13), Cell(c: 21, r: 13), Cell(c: 25, r: 13), Cell(c: 28, r: 13), Cell(c: 4, r: 14), Cell(c: 11, r: 14), Cell(c: 18, r: 14), Cell(c: 25, r: 14), Cell(c: 4, r: 15), Cell(c: 11, r: 15), Cell(c: 18, r: 15), Cell(c: 25, r: 15)],
        spawns: [Cell(c: 1, r: 15)],
        core: Cell(c: 30, r: 0),
        portalPairs: [],
        startCredits: 440,
        shards: 8,
        waves: makeEpicWaves(count: 13, levelId: 11)
    );
    private static let diamondField = LevelDef(
        id: 12,
        name: "Diamond Field",
        subtitle: "Cut by crystal.",
        cols: 30, rows: 16,
        walls: [Cell(c: 2, r: 4), Cell(c: 8, r: 4), Cell(c: 14, r: 4), Cell(c: 20, r: 4), Cell(c: 26, r: 4), Cell(c: 1, r: 5), Cell(c: 2, r: 5), Cell(c: 3, r: 5), Cell(c: 7, r: 5), Cell(c: 8, r: 5), Cell(c: 9, r: 5), Cell(c: 13, r: 5), Cell(c: 14, r: 5), Cell(c: 15, r: 5), Cell(c: 19, r: 5), Cell(c: 20, r: 5), Cell(c: 21, r: 5), Cell(c: 25, r: 5), Cell(c: 26, r: 5), Cell(c: 27, r: 5), Cell(c: 2, r: 6), Cell(c: 8, r: 6), Cell(c: 14, r: 6), Cell(c: 20, r: 6), Cell(c: 26, r: 6), Cell(c: 5, r: 8), Cell(c: 11, r: 8), Cell(c: 17, r: 8), Cell(c: 23, r: 8), Cell(c: 4, r: 9), Cell(c: 5, r: 9), Cell(c: 6, r: 9), Cell(c: 10, r: 9), Cell(c: 11, r: 9), Cell(c: 12, r: 9), Cell(c: 16, r: 9), Cell(c: 17, r: 9), Cell(c: 18, r: 9), Cell(c: 22, r: 9), Cell(c: 23, r: 9), Cell(c: 24, r: 9), Cell(c: 5, r: 10), Cell(c: 11, r: 10), Cell(c: 17, r: 10), Cell(c: 23, r: 10), Cell(c: 2, r: 12), Cell(c: 8, r: 12), Cell(c: 14, r: 12), Cell(c: 20, r: 12), Cell(c: 26, r: 12), Cell(c: 1, r: 13), Cell(c: 2, r: 13), Cell(c: 3, r: 13), Cell(c: 7, r: 13), Cell(c: 8, r: 13), Cell(c: 9, r: 13), Cell(c: 13, r: 13), Cell(c: 14, r: 13), Cell(c: 15, r: 13), Cell(c: 19, r: 13), Cell(c: 20, r: 13), Cell(c: 21, r: 13), Cell(c: 25, r: 13), Cell(c: 26, r: 13), Cell(c: 27, r: 13), Cell(c: 8, r: 14), Cell(c: 14, r: 14), Cell(c: 20, r: 14), Cell(c: 26, r: 14)],
        spawns: [Cell(c: 0, r: 14), Cell(c: 0, r: 1)],
        core: Cell(c: 29, r: 7),
        portalPairs: [],
        startCredits: 460,
        shards: 8,
        waves: makeEpicWaves(count: 13, levelId: 12)
    );
    private static let theHive = LevelDef(
        id: 13,
        name: "The Hive",
        subtitle: "They pour from three mouths.",
        cols: 30, rows: 16,
        walls: [Cell(c: 7, r: 0), Cell(c: 14, r: 0), Cell(c: 28, r: 0), Cell(c: 7, r: 1), Cell(c: 14, r: 1), Cell(c: 14, r: 2), Cell(c: 21, r: 2), Cell(c: 21, r: 3), Cell(c: 28, r: 3), Cell(c: 7, r: 4), Cell(c: 21, r: 4), Cell(c: 28, r: 4), Cell(c: 0, r: 5), Cell(c: 1, r: 5), Cell(c: 2, r: 5), Cell(c: 3, r: 5), Cell(c: 4, r: 5), Cell(c: 7, r: 5), Cell(c: 8, r: 5), Cell(c: 11, r: 5), Cell(c: 12, r: 5), Cell(c: 13, r: 5), Cell(c: 14, r: 5), Cell(c: 15, r: 5), Cell(c: 16, r: 5), Cell(c: 17, r: 5), Cell(c: 18, r: 5), Cell(c: 21, r: 5), Cell(c: 22, r: 5), Cell(c: 25, r: 5), Cell(c: 26, r: 5), Cell(c: 27, r: 5), Cell(c: 28, r: 5), Cell(c: 7, r: 6), Cell(c: 28, r: 6), Cell(c: 7, r: 7), Cell(c: 14, r: 7), Cell(c: 14, r: 8), Cell(c: 21, r: 8), Cell(c: 14, r: 9), Cell(c: 21, r: 9), Cell(c: 28, r: 9), Cell(c: 0, r: 10), Cell(c: 1, r: 10), Cell(c: 2, r: 10), Cell(c: 3, r: 10), Cell(c: 4, r: 10), Cell(c: 5, r: 10), Cell(c: 8, r: 10), Cell(c: 9, r: 10), Cell(c: 12, r: 10), Cell(c: 13, r: 10), Cell(c: 14, r: 10), Cell(c: 15, r: 10), Cell(c: 16, r: 10), Cell(c: 17, r: 10), Cell(c: 18, r: 10), Cell(c: 19, r: 10), Cell(c: 21, r: 10), Cell(c: 22, r: 10), Cell(c: 23, r: 10), Cell(c: 26, r: 10), Cell(c: 27, r: 10), Cell(c: 28, r: 10), Cell(c: 21, r: 11), Cell(c: 28, r: 11), Cell(c: 7, r: 12), Cell(c: 28, r: 12), Cell(c: 7, r: 13), Cell(c: 14, r: 13), Cell(c: 7, r: 14), Cell(c: 14, r: 14), Cell(c: 21, r: 14), Cell(c: 7, r: 15), Cell(c: 14, r: 15), Cell(c: 21, r: 15), Cell(c: 28, r: 15)],
        spawns: [Cell(c: 0, r: 14), Cell(c: 0, r: 7), Cell(c: 0, r: 1)],
        core: Cell(c: 29, r: 7),
        portalPairs: [],
        startCredits: 480,
        shards: 8,
        waves: makeEpicWaves(count: 13, levelId: 13)
    );
    private static let mirrorMaze = LevelDef(
        id: 14,
        name: "Mirror Maze",
        subtitle: "Left is right. Right is wrong.",
        cols: 30, rows: 16,
        walls: [Cell(c: 3, r: 2), Cell(c: 4, r: 2), Cell(c: 5, r: 2), Cell(c: 6, r: 2), Cell(c: 7, r: 2), Cell(c: 8, r: 2), Cell(c: 9, r: 2), Cell(c: 10, r: 2), Cell(c: 11, r: 2), Cell(c: 12, r: 2), Cell(c: 13, r: 2), Cell(c: 14, r: 2), Cell(c: 15, r: 2), Cell(c: 16, r: 2), Cell(c: 17, r: 2), Cell(c: 18, r: 2), Cell(c: 19, r: 2), Cell(c: 20, r: 2), Cell(c: 21, r: 2), Cell(c: 22, r: 2), Cell(c: 23, r: 2), Cell(c: 24, r: 2), Cell(c: 25, r: 2), Cell(c: 26, r: 2), Cell(c: 27, r: 2), Cell(c: 2, r: 4), Cell(c: 3, r: 4), Cell(c: 4, r: 4), Cell(c: 5, r: 4), Cell(c: 6, r: 4), Cell(c: 7, r: 4), Cell(c: 8, r: 4), Cell(c: 9, r: 4), Cell(c: 10, r: 4), Cell(c: 11, r: 4), Cell(c: 12, r: 4), Cell(c: 13, r: 4), Cell(c: 14, r: 4), Cell(c: 15, r: 4), Cell(c: 16, r: 4), Cell(c: 17, r: 4), Cell(c: 18, r: 4), Cell(c: 19, r: 4), Cell(c: 20, r: 4), Cell(c: 21, r: 4), Cell(c: 22, r: 4), Cell(c: 23, r: 4), Cell(c: 24, r: 4), Cell(c: 25, r: 4), Cell(c: 26, r: 4), Cell(c: 27, r: 4), Cell(c: 28, r: 4), Cell(c: 29, r: 4), Cell(c: 0, r: 6), Cell(c: 1, r: 6), Cell(c: 2, r: 6), Cell(c: 3, r: 6), Cell(c: 4, r: 6), Cell(c: 5, r: 6), Cell(c: 6, r: 6), Cell(c: 7, r: 6), Cell(c: 8, r: 6), Cell(c: 9, r: 6), Cell(c: 10, r: 6), Cell(c: 11, r: 6), Cell(c: 12, r: 6), Cell(c: 13, r: 6), Cell(c: 14, r: 6), Cell(c: 15, r: 6), Cell(c: 16, r: 6), Cell(c: 17, r: 6), Cell(c: 18, r: 6), Cell(c: 19, r: 6), Cell(c: 20, r: 6), Cell(c: 21, r: 6), Cell(c: 22, r: 6), Cell(c: 23, r: 6), Cell(c: 24, r: 6), Cell(c: 25, r: 6), Cell(c: 26, r: 6), Cell(c: 27, r: 6), Cell(c: 2, r: 9), Cell(c: 3, r: 9), Cell(c: 4, r: 9), Cell(c: 5, r: 9), Cell(c: 6, r: 9), Cell(c: 7, r: 9), Cell(c: 8, r: 9), Cell(c: 9, r: 9), Cell(c: 10, r: 9), Cell(c: 11, r: 9), Cell(c: 12, r: 9), Cell(c: 13, r: 9), Cell(c: 14, r: 9), Cell(c: 15, r: 9), Cell(c: 16, r: 9), Cell(c: 17, r: 9), Cell(c: 18, r: 9), Cell(c: 19, r: 9), Cell(c: 20, r: 9), Cell(c: 21, r: 9), Cell(c: 22, r: 9), Cell(c: 23, r: 9), Cell(c: 24, r: 9), Cell(c: 25, r: 9), Cell(c: 26, r: 9), Cell(c: 27, r: 9), Cell(c: 28, r: 9), Cell(c: 29, r: 9), Cell(c: 0, r: 11), Cell(c: 1, r: 11), Cell(c: 2, r: 11), Cell(c: 3, r: 11), Cell(c: 4, r: 11), Cell(c: 5, r: 11), Cell(c: 6, r: 11), Cell(c: 7, r: 11), Cell(c: 8, r: 11), Cell(c: 9, r: 11), Cell(c: 10, r: 11), Cell(c: 11, r: 11), Cell(c: 12, r: 11), Cell(c: 13, r: 11), Cell(c: 14, r: 11), Cell(c: 15, r: 11), Cell(c: 16, r: 11), Cell(c: 17, r: 11), Cell(c: 18, r: 11), Cell(c: 19, r: 11), Cell(c: 20, r: 11), Cell(c: 21, r: 11), Cell(c: 22, r: 11), Cell(c: 23, r: 11), Cell(c: 24, r: 11), Cell(c: 25, r: 11), Cell(c: 26, r: 11), Cell(c: 27, r: 11), Cell(c: 2, r: 13), Cell(c: 3, r: 13), Cell(c: 4, r: 13), Cell(c: 5, r: 13), Cell(c: 6, r: 13), Cell(c: 7, r: 13), Cell(c: 8, r: 13), Cell(c: 9, r: 13), Cell(c: 10, r: 13), Cell(c: 11, r: 13), Cell(c: 12, r: 13), Cell(c: 13, r: 13), Cell(c: 14, r: 13), Cell(c: 15, r: 13), Cell(c: 16, r: 13), Cell(c: 17, r: 13), Cell(c: 18, r: 13), Cell(c: 19, r: 13), Cell(c: 20, r: 13), Cell(c: 21, r: 13), Cell(c: 22, r: 13), Cell(c: 23, r: 13), Cell(c: 24, r: 13), Cell(c: 25, r: 13), Cell(c: 26, r: 13)],
        spawns: [Cell(c: 0, r: 2)],
        core: Cell(c: 29, r: 13),
        portalPairs: [],
        startCredits: 500,
        shards: 8,
        waves: makeEpicWaves(count: 14, levelId: 14)
    );
    private static let pinwheel = LevelDef(
        id: 15,
        name: "Pinwheel",
        subtitle: "The whole map spins against you.",
        cols: 30, rows: 16,
        walls: [Cell(c: 2, r: 2), Cell(c: 3, r: 2), Cell(c: 4, r: 2), Cell(c: 5, r: 2), Cell(c: 6, r: 2), Cell(c: 7, r: 2), Cell(c: 8, r: 2), Cell(c: 9, r: 2), Cell(c: 10, r: 2), Cell(c: 11, r: 2), Cell(c: 12, r: 2), Cell(c: 13, r: 2), Cell(c: 14, r: 2), Cell(c: 15, r: 2), Cell(c: 16, r: 2), Cell(c: 17, r: 2), Cell(c: 18, r: 2), Cell(c: 19, r: 2), Cell(c: 20, r: 2), Cell(c: 21, r: 2), Cell(c: 22, r: 2), Cell(c: 23, r: 2), Cell(c: 24, r: 2), Cell(c: 25, r: 2), Cell(c: 26, r: 2), Cell(c: 27, r: 2), Cell(c: 2, r: 3), Cell(c: 27, r: 3), Cell(c: 2, r: 4), Cell(c: 5, r: 4), Cell(c: 6, r: 4), Cell(c: 7, r: 4), Cell(c: 8, r: 4), Cell(c: 9, r: 4), Cell(c: 10, r: 4), Cell(c: 11, r: 4), Cell(c: 12, r: 4), Cell(c: 13, r: 4), Cell(c: 14, r: 4), Cell(c: 15, r: 4), Cell(c: 16, r: 4), Cell(c: 17, r: 4), Cell(c: 18, r: 4), Cell(c: 19, r: 4), Cell(c: 20, r: 4), Cell(c: 21, r: 4), Cell(c: 22, r: 4), Cell(c: 23, r: 4), Cell(c: 24, r: 4), Cell(c: 27, r: 4), Cell(c: 2, r: 5), Cell(c: 5, r: 5), Cell(c: 24, r: 5), Cell(c: 27, r: 5), Cell(c: 2, r: 6), Cell(c: 5, r: 6), Cell(c: 9, r: 6), Cell(c: 10, r: 6), Cell(c: 11, r: 6), Cell(c: 12, r: 6), Cell(c: 13, r: 6), Cell(c: 14, r: 6), Cell(c: 15, r: 6), Cell(c: 16, r: 6), Cell(c: 17, r: 6), Cell(c: 18, r: 6), Cell(c: 19, r: 6), Cell(c: 20, r: 6), Cell(c: 21, r: 6), Cell(c: 24, r: 6), Cell(c: 2, r: 7), Cell(c: 5, r: 7), Cell(c: 21, r: 7), Cell(c: 24, r: 7), Cell(c: 27, r: 7), Cell(c: 28, r: 7), Cell(c: 29, r: 7), Cell(c: 2, r: 8), Cell(c: 5, r: 8), Cell(c: 21, r: 8), Cell(c: 24, r: 8), Cell(c: 2, r: 9), Cell(c: 5, r: 9), Cell(c: 8, r: 9), Cell(c: 9, r: 9), Cell(c: 10, r: 9), Cell(c: 11, r: 9), Cell(c: 12, r: 9), Cell(c: 13, r: 9), Cell(c: 14, r: 9), Cell(c: 15, r: 9), Cell(c: 16, r: 9), Cell(c: 17, r: 9), Cell(c: 18, r: 9), Cell(c: 19, r: 9), Cell(c: 20, r: 9), Cell(c: 21, r: 9), Cell(c: 24, r: 9), Cell(c: 27, r: 9), Cell(c: 2, r: 10), Cell(c: 5, r: 10), Cell(c: 24, r: 10), Cell(c: 27, r: 10), Cell(c: 2, r: 11), Cell(c: 5, r: 11), Cell(c: 6, r: 11), Cell(c: 7, r: 11), Cell(c: 8, r: 11), Cell(c: 9, r: 11), Cell(c: 10, r: 11), Cell(c: 11, r: 11), Cell(c: 12, r: 11), Cell(c: 13, r: 11), Cell(c: 17, r: 11), Cell(c: 18, r: 11), Cell(c: 19, r: 11), Cell(c: 20, r: 11), Cell(c: 21, r: 11), Cell(c: 22, r: 11), Cell(c: 23, r: 11), Cell(c: 24, r: 11), Cell(c: 27, r: 11), Cell(c: 2, r: 12), Cell(c: 27, r: 12), Cell(c: 2, r: 13), Cell(c: 3, r: 13), Cell(c: 4, r: 13), Cell(c: 5, r: 13), Cell(c: 6, r: 13), Cell(c: 7, r: 13), Cell(c: 8, r: 13), Cell(c: 9, r: 13), Cell(c: 10, r: 13), Cell(c: 11, r: 13), Cell(c: 12, r: 13), Cell(c: 13, r: 13), Cell(c: 14, r: 13), Cell(c: 15, r: 13), Cell(c: 16, r: 13), Cell(c: 17, r: 13), Cell(c: 18, r: 13), Cell(c: 19, r: 13), Cell(c: 20, r: 13), Cell(c: 21, r: 13), Cell(c: 22, r: 13), Cell(c: 23, r: 13), Cell(c: 24, r: 13), Cell(c: 25, r: 13), Cell(c: 26, r: 13), Cell(c: 27, r: 13), Cell(c: 15, r: 14), Cell(c: 15, r: 15)],
        spawns: [Cell(c: 0, r: 15), Cell(c: 29, r: 15), Cell(c: 0, r: 0), Cell(c: 29, r: 0)],
        core: Cell(c: 15, r: 7),
        portalPairs: [],
        startCredits: 520,
        shards: 8,
        waves: makeEpicWaves(count: 14, levelId: 15)
    );
    private static let catacombs = LevelDef(
        id: 16,
        name: "Catacombs",
        subtitle: "Narrow doors. Heavy traffic.",
        cols: 32, rows: 16,
        walls: [Cell(c: 2, r: 2), Cell(c: 3, r: 2), Cell(c: 4, r: 2), Cell(c: 5, r: 2), Cell(c: 6, r: 2), Cell(c: 7, r: 2), Cell(c: 8, r: 2), Cell(c: 9, r: 2), Cell(c: 10, r: 2), Cell(c: 11, r: 2), Cell(c: 12, r: 2), Cell(c: 13, r: 2), Cell(c: 14, r: 2), Cell(c: 15, r: 2), Cell(c: 16, r: 2), Cell(c: 17, r: 2), Cell(c: 18, r: 2), Cell(c: 19, r: 2), Cell(c: 20, r: 2), Cell(c: 21, r: 2), Cell(c: 22, r: 2), Cell(c: 23, r: 2), Cell(c: 24, r: 2), Cell(c: 25, r: 2), Cell(c: 26, r: 2), Cell(c: 27, r: 2), Cell(c: 28, r: 2), Cell(c: 29, r: 2), Cell(c: 30, r: 2), Cell(c: 31, r: 2), Cell(c: 0, r: 4), Cell(c: 1, r: 4), Cell(c: 2, r: 4), Cell(c: 3, r: 4), Cell(c: 4, r: 4), Cell(c: 5, r: 4), Cell(c: 6, r: 4), Cell(c: 7, r: 4), Cell(c: 8, r: 4), Cell(c: 9, r: 4), Cell(c: 10, r: 4), Cell(c: 11, r: 4), Cell(c: 12, r: 4), Cell(c: 13, r: 4), Cell(c: 14, r: 4), Cell(c: 15, r: 4), Cell(c: 16, r: 4), Cell(c: 17, r: 4), Cell(c: 18, r: 4), Cell(c: 19, r: 4), Cell(c: 20, r: 4), Cell(c: 21, r: 4), Cell(c: 22, r: 4), Cell(c: 23, r: 4), Cell(c: 24, r: 4), Cell(c: 25, r: 4), Cell(c: 26, r: 4), Cell(c: 27, r: 4), Cell(c: 28, r: 4), Cell(c: 29, r: 4), Cell(c: 2, r: 6), Cell(c: 3, r: 6), Cell(c: 4, r: 6), Cell(c: 5, r: 6), Cell(c: 6, r: 6), Cell(c: 7, r: 6), Cell(c: 8, r: 6), Cell(c: 9, r: 6), Cell(c: 10, r: 6), Cell(c: 11, r: 6), Cell(c: 12, r: 6), Cell(c: 13, r: 6), Cell(c: 14, r: 6), Cell(c: 15, r: 6), Cell(c: 16, r: 6), Cell(c: 17, r: 6), Cell(c: 18, r: 6), Cell(c: 19, r: 6), Cell(c: 20, r: 6), Cell(c: 21, r: 6), Cell(c: 22, r: 6), Cell(c: 23, r: 6), Cell(c: 24, r: 6), Cell(c: 25, r: 6), Cell(c: 26, r: 6), Cell(c: 27, r: 6), Cell(c: 28, r: 6), Cell(c: 29, r: 6), Cell(c: 30, r: 6), Cell(c: 31, r: 6), Cell(c: 0, r: 9), Cell(c: 1, r: 9), Cell(c: 2, r: 9), Cell(c: 3, r: 9), Cell(c: 4, r: 9), Cell(c: 5, r: 9), Cell(c: 6, r: 9), Cell(c: 7, r: 9), Cell(c: 8, r: 9), Cell(c: 9, r: 9), Cell(c: 10, r: 9), Cell(c: 11, r: 9), Cell(c: 12, r: 9), Cell(c: 13, r: 9), Cell(c: 14, r: 9), Cell(c: 15, r: 9), Cell(c: 16, r: 9), Cell(c: 17, r: 9), Cell(c: 18, r: 9), Cell(c: 19, r: 9), Cell(c: 20, r: 9), Cell(c: 21, r: 9), Cell(c: 22, r: 9), Cell(c: 23, r: 9), Cell(c: 24, r: 9), Cell(c: 25, r: 9), Cell(c: 26, r: 9), Cell(c: 27, r: 9), Cell(c: 28, r: 9), Cell(c: 29, r: 9), Cell(c: 2, r: 11), Cell(c: 3, r: 11), Cell(c: 4, r: 11), Cell(c: 5, r: 11), Cell(c: 6, r: 11), Cell(c: 7, r: 11), Cell(c: 8, r: 11), Cell(c: 9, r: 11), Cell(c: 10, r: 11), Cell(c: 11, r: 11), Cell(c: 12, r: 11), Cell(c: 13, r: 11), Cell(c: 14, r: 11), Cell(c: 15, r: 11), Cell(c: 16, r: 11), Cell(c: 17, r: 11), Cell(c: 18, r: 11), Cell(c: 19, r: 11), Cell(c: 20, r: 11), Cell(c: 21, r: 11), Cell(c: 22, r: 11), Cell(c: 23, r: 11), Cell(c: 24, r: 11), Cell(c: 25, r: 11), Cell(c: 26, r: 11), Cell(c: 27, r: 11), Cell(c: 28, r: 11), Cell(c: 29, r: 11), Cell(c: 30, r: 11), Cell(c: 31, r: 11), Cell(c: 0, r: 13), Cell(c: 1, r: 13), Cell(c: 2, r: 13), Cell(c: 3, r: 13), Cell(c: 4, r: 13), Cell(c: 5, r: 13), Cell(c: 6, r: 13), Cell(c: 7, r: 13), Cell(c: 8, r: 13), Cell(c: 9, r: 13), Cell(c: 10, r: 13), Cell(c: 11, r: 13), Cell(c: 12, r: 13), Cell(c: 13, r: 13), Cell(c: 14, r: 13), Cell(c: 15, r: 13), Cell(c: 16, r: 13), Cell(c: 17, r: 13), Cell(c: 18, r: 13), Cell(c: 19, r: 13), Cell(c: 20, r: 13), Cell(c: 21, r: 13), Cell(c: 22, r: 13), Cell(c: 23, r: 13), Cell(c: 24, r: 13), Cell(c: 25, r: 13), Cell(c: 26, r: 13), Cell(c: 27, r: 13), Cell(c: 28, r: 13), Cell(c: 29, r: 13)],
        spawns: [Cell(c: 0, r: 14)],
        core: Cell(c: 31, r: 1),
        portalPairs: [],
        startCredits: 540,
        shards: 8,
        waves: makeEpicWaves(count: 14, levelId: 16)
    );
    private static let twinVortex = LevelDef(
        id: 17,
        name: "Twin Vortex",
        subtitle: "Two storms, one eye.",
        cols: 32, rows: 16,
        walls: [Cell(c: 2, r: 2), Cell(c: 3, r: 2), Cell(c: 4, r: 2), Cell(c: 5, r: 2), Cell(c: 6, r: 2), Cell(c: 7, r: 2), Cell(c: 8, r: 2), Cell(c: 9, r: 2), Cell(c: 10, r: 2), Cell(c: 11, r: 2), Cell(c: 12, r: 2), Cell(c: 13, r: 2), Cell(c: 18, r: 2), Cell(c: 19, r: 2), Cell(c: 20, r: 2), Cell(c: 21, r: 2), Cell(c: 22, r: 2), Cell(c: 23, r: 2), Cell(c: 24, r: 2), Cell(c: 25, r: 2), Cell(c: 26, r: 2), Cell(c: 27, r: 2), Cell(c: 28, r: 2), Cell(c: 29, r: 2), Cell(c: 2, r: 3), Cell(c: 13, r: 3), Cell(c: 18, r: 3), Cell(c: 29, r: 3), Cell(c: 2, r: 4), Cell(c: 13, r: 4), Cell(c: 18, r: 4), Cell(c: 29, r: 4), Cell(c: 2, r: 5), Cell(c: 6, r: 5), Cell(c: 7, r: 5), Cell(c: 8, r: 5), Cell(c: 9, r: 5), Cell(c: 13, r: 5), Cell(c: 18, r: 5), Cell(c: 22, r: 5), Cell(c: 23, r: 5), Cell(c: 24, r: 5), Cell(c: 25, r: 5), Cell(c: 29, r: 5), Cell(c: 2, r: 6), Cell(c: 6, r: 6), Cell(c: 9, r: 6), Cell(c: 13, r: 6), Cell(c: 18, r: 6), Cell(c: 22, r: 6), Cell(c: 25, r: 6), Cell(c: 29, r: 6), Cell(c: 2, r: 7), Cell(c: 9, r: 7), Cell(c: 22, r: 7), Cell(c: 2, r: 8), Cell(c: 9, r: 8), Cell(c: 22, r: 8), Cell(c: 29, r: 8), Cell(c: 2, r: 9), Cell(c: 6, r: 9), Cell(c: 9, r: 9), Cell(c: 13, r: 9), Cell(c: 18, r: 9), Cell(c: 22, r: 9), Cell(c: 25, r: 9), Cell(c: 29, r: 9), Cell(c: 2, r: 10), Cell(c: 6, r: 10), Cell(c: 7, r: 10), Cell(c: 8, r: 10), Cell(c: 9, r: 10), Cell(c: 13, r: 10), Cell(c: 18, r: 10), Cell(c: 22, r: 10), Cell(c: 23, r: 10), Cell(c: 24, r: 10), Cell(c: 25, r: 10), Cell(c: 29, r: 10), Cell(c: 2, r: 11), Cell(c: 13, r: 11), Cell(c: 18, r: 11), Cell(c: 29, r: 11), Cell(c: 2, r: 12), Cell(c: 13, r: 12), Cell(c: 18, r: 12), Cell(c: 29, r: 12), Cell(c: 2, r: 13), Cell(c: 3, r: 13), Cell(c: 4, r: 13), Cell(c: 5, r: 13), Cell(c: 6, r: 13), Cell(c: 7, r: 13), Cell(c: 8, r: 13), Cell(c: 9, r: 13), Cell(c: 10, r: 13), Cell(c: 11, r: 13), Cell(c: 12, r: 13), Cell(c: 13, r: 13), Cell(c: 18, r: 13), Cell(c: 19, r: 13), Cell(c: 20, r: 13), Cell(c: 21, r: 13), Cell(c: 22, r: 13), Cell(c: 23, r: 13), Cell(c: 24, r: 13), Cell(c: 25, r: 13), Cell(c: 26, r: 13), Cell(c: 27, r: 13), Cell(c: 28, r: 13), Cell(c: 29, r: 13)],
        spawns: [Cell(c: 0, r: 15), Cell(c: 0, r: 0)],
        core: Cell(c: 31, r: 7),
        portalPairs: [(Cell(c: 8, r: 7), Cell(c: 23, r: 7))],
        startCredits: 560,
        shards: 8,
        waves: makeEpicWaves(count: 15, levelId: 17)
    );
    private static let theCrucible = LevelDef(
        id: 18,
        name: "The Crucible",
        subtitle: "Forge your last stand.",
        cols: 30, rows: 16,
        walls: [Cell(c: 2, r: 2), Cell(c: 3, r: 2), Cell(c: 4, r: 2), Cell(c: 5, r: 2), Cell(c: 6, r: 2), Cell(c: 7, r: 2), Cell(c: 8, r: 2), Cell(c: 9, r: 2), Cell(c: 10, r: 2), Cell(c: 11, r: 2), Cell(c: 12, r: 2), Cell(c: 13, r: 2), Cell(c: 14, r: 2), Cell(c: 15, r: 2), Cell(c: 16, r: 2), Cell(c: 17, r: 2), Cell(c: 18, r: 2), Cell(c: 19, r: 2), Cell(c: 20, r: 2), Cell(c: 21, r: 2), Cell(c: 22, r: 2), Cell(c: 23, r: 2), Cell(c: 24, r: 2), Cell(c: 25, r: 2), Cell(c: 26, r: 2), Cell(c: 27, r: 2), Cell(c: 2, r: 3), Cell(c: 27, r: 3), Cell(c: 2, r: 4), Cell(c: 5, r: 4), Cell(c: 6, r: 4), Cell(c: 7, r: 4), Cell(c: 8, r: 4), Cell(c: 9, r: 4), Cell(c: 10, r: 4), Cell(c: 11, r: 4), Cell(c: 12, r: 4), Cell(c: 13, r: 4), Cell(c: 14, r: 4), Cell(c: 15, r: 4), Cell(c: 16, r: 4), Cell(c: 17, r: 4), Cell(c: 18, r: 4), Cell(c: 19, r: 4), Cell(c: 20, r: 4), Cell(c: 21, r: 4), Cell(c: 22, r: 4), Cell(c: 23, r: 4), Cell(c: 24, r: 4), Cell(c: 27, r: 4), Cell(c: 2, r: 5), Cell(c: 5, r: 5), Cell(c: 13, r: 5), Cell(c: 14, r: 5), Cell(c: 16, r: 5), Cell(c: 17, r: 5), Cell(c: 24, r: 5), Cell(c: 27, r: 5), Cell(c: 2, r: 6), Cell(c: 5, r: 6), Cell(c: 9, r: 6), Cell(c: 10, r: 6), Cell(c: 11, r: 6), Cell(c: 12, r: 6), Cell(c: 13, r: 6), Cell(c: 14, r: 6), Cell(c: 15, r: 6), Cell(c: 16, r: 6), Cell(c: 17, r: 6), Cell(c: 18, r: 6), Cell(c: 19, r: 6), Cell(c: 20, r: 6), Cell(c: 21, r: 6), Cell(c: 24, r: 6), Cell(c: 2, r: 7), Cell(c: 5, r: 7), Cell(c: 13, r: 7), Cell(c: 17, r: 7), Cell(c: 21, r: 7), Cell(c: 24, r: 7), Cell(c: 2, r: 8), Cell(c: 5, r: 8), Cell(c: 13, r: 8), Cell(c: 17, r: 8), Cell(c: 21, r: 8), Cell(c: 24, r: 8), Cell(c: 2, r: 9), Cell(c: 5, r: 9), Cell(c: 8, r: 9), Cell(c: 9, r: 9), Cell(c: 10, r: 9), Cell(c: 11, r: 9), Cell(c: 12, r: 9), Cell(c: 13, r: 9), Cell(c: 14, r: 9), Cell(c: 16, r: 9), Cell(c: 17, r: 9), Cell(c: 18, r: 9), Cell(c: 19, r: 9), Cell(c: 20, r: 9), Cell(c: 21, r: 9), Cell(c: 24, r: 9), Cell(c: 27, r: 9), Cell(c: 2, r: 10), Cell(c: 5, r: 10), Cell(c: 24, r: 10), Cell(c: 27, r: 10), Cell(c: 2, r: 11), Cell(c: 5, r: 11), Cell(c: 6, r: 11), Cell(c: 7, r: 11), Cell(c: 8, r: 11), Cell(c: 9, r: 11), Cell(c: 10, r: 11), Cell(c: 11, r: 11), Cell(c: 12, r: 11), Cell(c: 13, r: 11), Cell(c: 17, r: 11), Cell(c: 18, r: 11), Cell(c: 19, r: 11), Cell(c: 20, r: 11), Cell(c: 21, r: 11), Cell(c: 22, r: 11), Cell(c: 23, r: 11), Cell(c: 24, r: 11), Cell(c: 27, r: 11), Cell(c: 2, r: 12), Cell(c: 27, r: 12), Cell(c: 2, r: 13), Cell(c: 3, r: 13), Cell(c: 4, r: 13), Cell(c: 5, r: 13), Cell(c: 6, r: 13), Cell(c: 7, r: 13), Cell(c: 8, r: 13), Cell(c: 9, r: 13), Cell(c: 10, r: 13), Cell(c: 11, r: 13), Cell(c: 12, r: 13), Cell(c: 13, r: 13), Cell(c: 14, r: 13), Cell(c: 15, r: 13), Cell(c: 16, r: 13), Cell(c: 17, r: 13), Cell(c: 18, r: 13), Cell(c: 19, r: 13), Cell(c: 20, r: 13), Cell(c: 21, r: 13), Cell(c: 22, r: 13), Cell(c: 23, r: 13), Cell(c: 24, r: 13), Cell(c: 25, r: 13), Cell(c: 26, r: 13), Cell(c: 27, r: 13)],
        spawns: [Cell(c: 0, r: 15), Cell(c: 29, r: 15), Cell(c: 0, r: 0), Cell(c: 29, r: 0)],
        core: Cell(c: 15, r: 7),
        portalPairs: [(Cell(c: 15, r: 15), Cell(c: 15, r: 0))],
        startCredits: 600,
        shards: 8,
        waves: makeEpicWaves(count: 15, levelId: 18)
    );
    private static let labyrinthOfEchoes = LevelDef(
        id: 19,
        name: "Labyrinth of Echoes",
        subtitle: "Every step repeats.",
        cols: 32, rows: 17,
        walls: [Cell(c: 0, r: 2), Cell(c: 1, r: 2), Cell(c: 2, r: 2), Cell(c: 3, r: 2), Cell(c: 4, r: 2), Cell(c: 5, r: 2), Cell(c: 6, r: 2), Cell(c: 7, r: 2), Cell(c: 8, r: 2), Cell(c: 9, r: 2), Cell(c: 10, r: 2), Cell(c: 11, r: 2), Cell(c: 12, r: 2), Cell(c: 13, r: 2), Cell(c: 14, r: 2), Cell(c: 15, r: 2), Cell(c: 16, r: 2), Cell(c: 17, r: 2), Cell(c: 18, r: 2), Cell(c: 19, r: 2), Cell(c: 20, r: 2), Cell(c: 21, r: 2), Cell(c: 22, r: 2), Cell(c: 23, r: 2), Cell(c: 24, r: 2), Cell(c: 25, r: 2), Cell(c: 26, r: 2), Cell(c: 27, r: 2), Cell(c: 28, r: 2), Cell(c: 29, r: 2), Cell(c: 2, r: 4), Cell(c: 3, r: 4), Cell(c: 4, r: 4), Cell(c: 5, r: 4), Cell(c: 6, r: 4), Cell(c: 7, r: 4), Cell(c: 8, r: 4), Cell(c: 9, r: 4), Cell(c: 10, r: 4), Cell(c: 11, r: 4), Cell(c: 12, r: 4), Cell(c: 13, r: 4), Cell(c: 14, r: 4), Cell(c: 15, r: 4), Cell(c: 16, r: 4), Cell(c: 17, r: 4), Cell(c: 18, r: 4), Cell(c: 19, r: 4), Cell(c: 20, r: 4), Cell(c: 21, r: 4), Cell(c: 22, r: 4), Cell(c: 23, r: 4), Cell(c: 24, r: 4), Cell(c: 25, r: 4), Cell(c: 26, r: 4), Cell(c: 27, r: 4), Cell(c: 28, r: 4), Cell(c: 29, r: 4), Cell(c: 30, r: 4), Cell(c: 31, r: 4), Cell(c: 0, r: 6), Cell(c: 1, r: 6), Cell(c: 2, r: 6), Cell(c: 3, r: 6), Cell(c: 4, r: 6), Cell(c: 5, r: 6), Cell(c: 6, r: 6), Cell(c: 7, r: 6), Cell(c: 8, r: 6), Cell(c: 9, r: 6), Cell(c: 10, r: 6), Cell(c: 11, r: 6), Cell(c: 12, r: 6), Cell(c: 13, r: 6), Cell(c: 14, r: 6), Cell(c: 15, r: 6), Cell(c: 16, r: 6), Cell(c: 17, r: 6), Cell(c: 18, r: 6), Cell(c: 19, r: 6), Cell(c: 20, r: 6), Cell(c: 21, r: 6), Cell(c: 22, r: 6), Cell(c: 23, r: 6), Cell(c: 24, r: 6), Cell(c: 25, r: 6), Cell(c: 26, r: 6), Cell(c: 27, r: 6), Cell(c: 28, r: 6), Cell(c: 29, r: 6), Cell(c: 2, r: 8), Cell(c: 3, r: 8), Cell(c: 4, r: 8), Cell(c: 5, r: 8), Cell(c: 6, r: 8), Cell(c: 7, r: 8), Cell(c: 8, r: 8), Cell(c: 9, r: 8), Cell(c: 10, r: 8), Cell(c: 11, r: 8), Cell(c: 12, r: 8), Cell(c: 13, r: 8), Cell(c: 14, r: 8), Cell(c: 15, r: 8), Cell(c: 16, r: 8), Cell(c: 17, r: 8), Cell(c: 18, r: 8), Cell(c: 19, r: 8), Cell(c: 20, r: 8), Cell(c: 21, r: 8), Cell(c: 22, r: 8), Cell(c: 23, r: 8), Cell(c: 24, r: 8), Cell(c: 25, r: 8), Cell(c: 26, r: 8), Cell(c: 27, r: 8), Cell(c: 28, r: 8), Cell(c: 29, r: 8), Cell(c: 30, r: 8), Cell(c: 31, r: 8), Cell(c: 0, r: 10), Cell(c: 1, r: 10), Cell(c: 2, r: 10), Cell(c: 3, r: 10), Cell(c: 4, r: 10), Cell(c: 5, r: 10), Cell(c: 6, r: 10), Cell(c: 7, r: 10), Cell(c: 8, r: 10), Cell(c: 9, r: 10), Cell(c: 10, r: 10), Cell(c: 11, r: 10), Cell(c: 12, r: 10), Cell(c: 13, r: 10), Cell(c: 14, r: 10), Cell(c: 15, r: 10), Cell(c: 16, r: 10), Cell(c: 17, r: 10), Cell(c: 18, r: 10), Cell(c: 19, r: 10), Cell(c: 20, r: 10), Cell(c: 21, r: 10), Cell(c: 22, r: 10), Cell(c: 23, r: 10), Cell(c: 24, r: 10), Cell(c: 25, r: 10), Cell(c: 26, r: 10), Cell(c: 27, r: 10), Cell(c: 28, r: 10), Cell(c: 29, r: 10), Cell(c: 2, r: 12), Cell(c: 3, r: 12), Cell(c: 4, r: 12), Cell(c: 5, r: 12), Cell(c: 6, r: 12), Cell(c: 7, r: 12), Cell(c: 8, r: 12), Cell(c: 9, r: 12), Cell(c: 10, r: 12), Cell(c: 11, r: 12), Cell(c: 12, r: 12), Cell(c: 13, r: 12), Cell(c: 14, r: 12), Cell(c: 15, r: 12), Cell(c: 16, r: 12), Cell(c: 17, r: 12), Cell(c: 18, r: 12), Cell(c: 19, r: 12), Cell(c: 20, r: 12), Cell(c: 21, r: 12), Cell(c: 22, r: 12), Cell(c: 23, r: 12), Cell(c: 24, r: 12), Cell(c: 25, r: 12), Cell(c: 26, r: 12), Cell(c: 27, r: 12), Cell(c: 28, r: 12), Cell(c: 29, r: 12), Cell(c: 30, r: 12), Cell(c: 31, r: 12), Cell(c: 0, r: 14), Cell(c: 1, r: 14), Cell(c: 2, r: 14), Cell(c: 3, r: 14), Cell(c: 4, r: 14), Cell(c: 5, r: 14), Cell(c: 6, r: 14), Cell(c: 7, r: 14), Cell(c: 8, r: 14), Cell(c: 9, r: 14), Cell(c: 10, r: 14), Cell(c: 11, r: 14), Cell(c: 12, r: 14), Cell(c: 13, r: 14), Cell(c: 14, r: 14), Cell(c: 15, r: 14), Cell(c: 16, r: 14), Cell(c: 17, r: 14), Cell(c: 18, r: 14), Cell(c: 19, r: 14), Cell(c: 20, r: 14), Cell(c: 21, r: 14), Cell(c: 22, r: 14), Cell(c: 23, r: 14), Cell(c: 24, r: 14), Cell(c: 25, r: 14), Cell(c: 26, r: 14), Cell(c: 27, r: 14), Cell(c: 28, r: 14), Cell(c: 29, r: 14)],
        spawns: [Cell(c: 0, r: 15)],
        core: Cell(c: 31, r: 1),
        portalPairs: [],
        startCredits: 640,
        shards: 8,
        waves: makeEpicWaves(count: 15, levelId: 19)
    );
    private static let omegaCitadel = LevelDef(
        id: 20,
        name: "Omega Citadel",
        subtitle: "OMEGA PRIME awaits.",
        cols: 32, rows: 17,
        walls: [Cell(c: 2, r: 2), Cell(c: 3, r: 2), Cell(c: 4, r: 2), Cell(c: 5, r: 2), Cell(c: 6, r: 2), Cell(c: 7, r: 2), Cell(c: 8, r: 2), Cell(c: 9, r: 2), Cell(c: 10, r: 2), Cell(c: 11, r: 2), Cell(c: 12, r: 2), Cell(c: 13, r: 2), Cell(c: 14, r: 2), Cell(c: 15, r: 2), Cell(c: 16, r: 2), Cell(c: 17, r: 2), Cell(c: 18, r: 2), Cell(c: 19, r: 2), Cell(c: 20, r: 2), Cell(c: 21, r: 2), Cell(c: 22, r: 2), Cell(c: 23, r: 2), Cell(c: 24, r: 2), Cell(c: 25, r: 2), Cell(c: 26, r: 2), Cell(c: 27, r: 2), Cell(c: 28, r: 2), Cell(c: 29, r: 2), Cell(c: 2, r: 3), Cell(c: 29, r: 3), Cell(c: 2, r: 4), Cell(c: 5, r: 4), Cell(c: 6, r: 4), Cell(c: 7, r: 4), Cell(c: 8, r: 4), Cell(c: 9, r: 4), Cell(c: 10, r: 4), Cell(c: 11, r: 4), Cell(c: 12, r: 4), Cell(c: 13, r: 4), Cell(c: 14, r: 4), Cell(c: 15, r: 4), Cell(c: 16, r: 4), Cell(c: 17, r: 4), Cell(c: 18, r: 4), Cell(c: 19, r: 4), Cell(c: 20, r: 4), Cell(c: 21, r: 4), Cell(c: 22, r: 4), Cell(c: 23, r: 4), Cell(c: 24, r: 4), Cell(c: 25, r: 4), Cell(c: 26, r: 4), Cell(c: 29, r: 4), Cell(c: 2, r: 5), Cell(c: 5, r: 5), Cell(c: 26, r: 5), Cell(c: 29, r: 5), Cell(c: 2, r: 6), Cell(c: 5, r: 6), Cell(c: 8, r: 6), Cell(c: 9, r: 6), Cell(c: 10, r: 6), Cell(c: 11, r: 6), Cell(c: 12, r: 6), Cell(c: 13, r: 6), Cell(c: 14, r: 6), Cell(c: 15, r: 6), Cell(c: 16, r: 6), Cell(c: 17, r: 6), Cell(c: 18, r: 6), Cell(c: 19, r: 6), Cell(c: 20, r: 6), Cell(c: 21, r: 6), Cell(c: 22, r: 6), Cell(c: 23, r: 6), Cell(c: 26, r: 6), Cell(c: 29, r: 6), Cell(c: 2, r: 7), Cell(c: 5, r: 7), Cell(c: 23, r: 7), Cell(c: 26, r: 7), Cell(c: 2, r: 8), Cell(c: 5, r: 8), Cell(c: 23, r: 8), Cell(c: 26, r: 8), Cell(c: 2, r: 9), Cell(c: 5, r: 9), Cell(c: 23, r: 9), Cell(c: 26, r: 9), Cell(c: 2, r: 10), Cell(c: 5, r: 10), Cell(c: 8, r: 10), Cell(c: 9, r: 10), Cell(c: 10, r: 10), Cell(c: 11, r: 10), Cell(c: 12, r: 10), Cell(c: 13, r: 10), Cell(c: 14, r: 10), Cell(c: 15, r: 10), Cell(c: 16, r: 10), Cell(c: 17, r: 10), Cell(c: 18, r: 10), Cell(c: 19, r: 10), Cell(c: 20, r: 10), Cell(c: 21, r: 10), Cell(c: 22, r: 10), Cell(c: 23, r: 10), Cell(c: 26, r: 10), Cell(c: 29, r: 10), Cell(c: 2, r: 11), Cell(c: 5, r: 11), Cell(c: 26, r: 11), Cell(c: 29, r: 11), Cell(c: 2, r: 12), Cell(c: 5, r: 12), Cell(c: 6, r: 12), Cell(c: 7, r: 12), Cell(c: 8, r: 12), Cell(c: 9, r: 12), Cell(c: 10, r: 12), Cell(c: 11, r: 12), Cell(c: 12, r: 12), Cell(c: 13, r: 12), Cell(c: 14, r: 12), Cell(c: 18, r: 12), Cell(c: 19, r: 12), Cell(c: 20, r: 12), Cell(c: 21, r: 12), Cell(c: 22, r: 12), Cell(c: 23, r: 12), Cell(c: 24, r: 12), Cell(c: 25, r: 12), Cell(c: 26, r: 12), Cell(c: 29, r: 12), Cell(c: 2, r: 13), Cell(c: 29, r: 13), Cell(c: 2, r: 14), Cell(c: 3, r: 14), Cell(c: 4, r: 14), Cell(c: 5, r: 14), Cell(c: 6, r: 14), Cell(c: 7, r: 14), Cell(c: 8, r: 14), Cell(c: 9, r: 14), Cell(c: 10, r: 14), Cell(c: 11, r: 14), Cell(c: 12, r: 14), Cell(c: 13, r: 14), Cell(c: 14, r: 14), Cell(c: 15, r: 14), Cell(c: 16, r: 14), Cell(c: 17, r: 14), Cell(c: 18, r: 14), Cell(c: 19, r: 14), Cell(c: 20, r: 14), Cell(c: 21, r: 14), Cell(c: 22, r: 14), Cell(c: 23, r: 14), Cell(c: 24, r: 14), Cell(c: 25, r: 14), Cell(c: 26, r: 14), Cell(c: 27, r: 14), Cell(c: 28, r: 14), Cell(c: 29, r: 14)],
        spawns: [Cell(c: 0, r: 16), Cell(c: 31, r: 16), Cell(c: 0, r: 0), Cell(c: 31, r: 0)],
        core: Cell(c: 16, r: 8),
        portalPairs: [(Cell(c: 1, r: 15), Cell(c: 1, r: 1))],
        startCredits: 760,
        shards: 8,
        waves: makeEpicWaves(count: 16, levelId: 20, finale: true)
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
