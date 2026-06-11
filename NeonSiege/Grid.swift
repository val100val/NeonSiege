import Foundation

struct Cell: Hashable {
    let c: Int
    let r: Int
}

/// Grid model with BFS flow fields. Enemies route around towers (maze-building),
/// so the fields are recomputed whenever a tower is placed or sold.
final class Grid {
    let cols: Int
    let rows: Int
    let walls: Set<Cell>
    let core: Cell
    let spawns: [Cell]
    let portals: [Cell: Cell] // bidirectional pairs, both directions present
    private(set) var towers: Set<Cell> = []

    private(set) var distToCore: [Int] = []
    private(set) var distToSpawn: [Int] = []

    init(cols: Int, rows: Int, walls: Set<Cell>, core: Cell, spawns: [Cell], portalPairs: [(Cell, Cell)]) {
        self.cols = cols
        self.rows = rows
        self.walls = walls
        self.core = core
        self.spawns = spawns
        var pairs: [Cell: Cell] = [:]
        for (a, b) in portalPairs {
            pairs[a] = b
            pairs[b] = a
        }
        self.portals = pairs
        recompute()
    }

    func inBounds(_ cell: Cell) -> Bool {
        cell.c >= 0 && cell.c < cols && cell.r >= 0 && cell.r < rows
    }

    func isBlocked(_ cell: Cell) -> Bool {
        walls.contains(cell) || towers.contains(cell)
    }

    func index(_ cell: Cell) -> Int { cell.r * cols + cell.c }

    func neighbors(_ cell: Cell) -> [Cell] {
        var result: [Cell] = []
        for (dc, dr) in [(1, 0), (-1, 0), (0, 1), (0, -1)] {
            let n = Cell(c: cell.c + dc, r: cell.r + dr)
            if inBounds(n) && !isBlocked(n) { result.append(n) }
        }
        if let twin = portals[cell], !isBlocked(twin) { result.append(twin) }
        return result
    }

    private func bfs(from sources: [Cell]) -> [Int] {
        var dist = Array(repeating: Int.max, count: cols * rows)
        var queue: [Cell] = []
        for s in sources where inBounds(s) && !isBlocked(s) {
            dist[index(s)] = 0
            queue.append(s)
        }
        var head = 0
        while head < queue.count {
            let cur = queue[head]
            head += 1
            let d = dist[index(cur)]
            for n in neighbors(cur) where dist[index(n)] > d + 1 {
                dist[index(n)] = d + 1
                queue.append(n)
            }
        }
        return dist
    }

    func recompute() {
        distToCore = bfs(from: [core])
        distToSpawn = bfs(from: spawns)
    }

    /// Next step along the flow field. Returns nil when no path exists.
    func nextCell(from cell: Cell, towardCore: Bool) -> Cell? {
        guard inBounds(cell) else { return nil }
        let dist = towardCore ? distToCore : distToSpawn
        var best: Cell? = nil
        var bestD = dist[index(cell)]
        for n in neighbors(cell) {
            let d = dist[index(n)]
            if d < bestD {
                bestD = d
                best = n
            }
        }
        return best
    }

    func distanceToCore(from cell: Cell) -> Int {
        guard inBounds(cell) else { return Int.max }
        return distToCore[index(cell)]
    }

    func distanceToSpawn(from cell: Cell) -> Int {
        guard inBounds(cell) else { return Int.max }
        return distToSpawn[index(cell)]
    }

    /// True if a tower at `cell` would not cut off any spawn or any occupied enemy cell.
    func canPlaceTower(at cell: Cell, occupied: [Cell]) -> Bool {
        guard inBounds(cell), !isBlocked(cell), cell != core,
              !spawns.contains(cell), portals[cell] == nil else { return false }
        if occupied.contains(cell) { return false }
        towers.insert(cell)
        let dist = bfs(from: [core])
        var ok = true
        for s in spawns where dist[index(s)] == Int.max { ok = false }
        for o in occupied where inBounds(o) && !isBlocked(o) && dist[index(o)] == Int.max { ok = false }
        towers.remove(cell)
        return ok
    }

    func placeTower(at cell: Cell) {
        towers.insert(cell)
        recompute()
    }

    func removeTower(at cell: Cell) {
        towers.remove(cell)
        recompute()
    }
}
