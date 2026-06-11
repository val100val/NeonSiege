import SpriteKit

final class GameScene: SKScene {
    private let level: LevelDef
    private var grid: Grid!
    private var cellSize: CGFloat = 0
    private var gridOrigin: CGPoint = .zero

    private let boardLayer = SKNode()
    private let entityLayer = SKNode()
    private let uiLayer = SKNode()
    private var hud: HUD!

    private var enemies: [Enemy] = []
    private var towers: [Tower] = []
    private var towerByCell: [Cell: Tower] = [:]

    private var credits = 0 { didSet { hud.setCredits(credits) } }
    private var shards = 0 { didSet { hud.setShards(shards) } }
    private var waveIndex = 0
    private var pendingSpawns: [(time: TimeInterval, type: EnemyType, cell: Cell)] = []
    private var waveClock: TimeInterval = 0
    private var betweenWaves = true
    private var countdown: TimeInterval = 5
    private var spawnCounter = 0

    private var lastUpdate: TimeInterval = 0
    private var simTime: TimeInterval = 0
    private var gameSpeed: CGFloat = 1
    private var gamePaused = false
    private var gameEnded = false
    private var planning = true

    private var selectedBuild: TowerType? = .pulse
    private var popup: SKNode?
    private var popupTower: Tower?
    private var pauseOverlay: SKNode?

    init(level: LevelDef, size: CGSize) {
        self.level = level
        super.init(size: size)
        scaleMode = platformScaleMode
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been used") }

    override func didMove(to view: SKView) {
        backgroundColor = Theme.background
        grid = Grid(cols: level.cols, rows: level.rows, walls: level.walls,
                    core: level.core, spawns: level.spawns, portalPairs: level.portalPairs)

        let usableWidth = size.width - 100
        let usableHeight = size.height - 44 - 62 - 48
        cellSize = min(usableWidth / CGFloat(level.cols), usableHeight / CGFloat(level.rows))
        let boardWidth = cellSize * CGFloat(level.cols)
        let boardHeight = cellSize * CGFloat(level.rows)
        gridOrigin = CGPoint(x: (size.width - boardWidth) / 2,
                             y: 68 + (usableHeight - boardHeight) / 2)

        addChild(boardLayer)
        addChild(entityLayer)
        addChild(uiLayer)

        hud = HUD(size: size)
        uiLayer.addChild(hud)

        drawBoard()

        credits = level.startCredits
        shards = level.shards
        hud.setWave(current: 1, total: level.waves.count)
        hud.setSelected(selectedBuild)
        hud.setSpeed(1)
        betweenWaves = true
        planning = true
        countdown = 5
        showLevelIntro()
    }

    /// Planning phase intro: level name + subtitle so the player can study
    /// the layout and pre-build before calling the first wave.
    private func showLevelIntro() {
        let intro = SKNode()
        intro.zPosition = 150

        let name = makeLabel(level.name.uppercased(), size: 30, color: Theme.cyan, font: Theme.titleFont)
        name.position = CGPoint(x: size.width / 2, y: size.height / 2 + 34)
        intro.addChild(name)

        let sub = makeLabel(level.subtitle.uppercased(), size: 14, color: Theme.magenta)
        sub.position = CGPoint(x: size.width / 2, y: size.height / 2 + 8)
        intro.addChild(sub)

        let hint = makeLabel("STUDY THE MAP - BUILD YOUR MAZE - LAUNCH WHEN READY", size: 11, color: Theme.dim)
        hint.position = CGPoint(x: size.width / 2, y: size.height / 2 - 18)
        intro.addChild(hint)

        uiLayer.addChild(intro)
        intro.run(.sequence([
            .wait(forDuration: 3.2),
            .fadeOut(withDuration: 0.8),
            .removeFromParent(),
        ]))
    }

    // MARK: - Board drawing

    private func cellCenter(_ cell: Cell) -> CGPoint {
        CGPoint(x: gridOrigin.x + (CGFloat(cell.c) + 0.5) * cellSize,
                y: gridOrigin.y + (CGFloat(cell.r) + 0.5) * cellSize)
    }

    private func cellAt(_ point: CGPoint) -> Cell? {
        let c = Int(floor((point.x - gridOrigin.x) / cellSize))
        let r = Int(floor((point.y - gridOrigin.y) / cellSize))
        let cell = Cell(c: c, r: r)
        return grid.inBounds(cell) ? cell : nil
    }

    private func drawBoard() {
        let path = CGMutablePath()
        for c in 0...level.cols {
            path.move(to: CGPoint(x: gridOrigin.x + CGFloat(c) * cellSize, y: gridOrigin.y))
            path.addLine(to: CGPoint(x: gridOrigin.x + CGFloat(c) * cellSize, y: gridOrigin.y + CGFloat(level.rows) * cellSize))
        }
        for r in 0...level.rows {
            path.move(to: CGPoint(x: gridOrigin.x, y: gridOrigin.y + CGFloat(r) * cellSize))
            path.addLine(to: CGPoint(x: gridOrigin.x + CGFloat(level.cols) * cellSize, y: gridOrigin.y + CGFloat(r) * cellSize))
        }
        let lines = SKShapeNode(path: path)
        lines.strokeColor = Theme.gridLine
        lines.lineWidth = 1
        lines.alpha = 0.6
        boardLayer.addChild(lines)

        for wall in level.walls {
            let block = SKShapeNode(rectOf: CGSize(width: cellSize - 4, height: cellSize - 4), cornerRadius: 4)
            block.fillColor = SKColor(red: 0.10, green: 0.13, blue: 0.24, alpha: 1)
            block.strokeColor = Theme.violet.withAlphaComponent(0.35)
            block.lineWidth = 1.5
            block.position = cellCenter(wall)
            boardLayer.addChild(block)
        }

        let core = SKShapeNode(path: hexagonPath(radius: cellSize * 0.42))
        core.strokeColor = Theme.cyan
        core.lineWidth = 3
        core.glowWidth = 10
        core.fillColor = Theme.cyan.withAlphaComponent(0.3)
        core.position = cellCenter(level.core)
        core.zPosition = 30
        core.name = "core_node"
        boardLayer.addChild(core)
        core.run(.repeatForever(.sequence([
            .scale(to: 1.12, duration: 0.8),
            .scale(to: 1.0, duration: 0.8),
        ])))

        for spawn in level.spawns {
            let gate = neonRect(size: CGSize(width: cellSize - 6, height: cellSize - 6), corner: 6,
                                color: Theme.magenta, glow: 6, fillAlpha: 0.25)
            gate.position = cellCenter(spawn)
            gate.zPosition = 30
            boardLayer.addChild(gate)
            let glyph = makeLabel("IN", size: cellSize * 0.3, color: Theme.magenta)
            glyph.position = gate.position
            glyph.zPosition = 31
            boardLayer.addChild(glyph)
        }

        var portalLabel = "A"
        var seen = Set<Cell>()
        for (a, b) in level.portalPairs {
            if seen.contains(a) { continue }
            seen.insert(a)
            seen.insert(b)
            for cell in [a, b] {
                let ring = SKShapeNode(circleOfRadius: cellSize * 0.36)
                ring.strokeColor = Theme.violet
                ring.lineWidth = 2.5
                ring.glowWidth = 7
                ring.fillColor = Theme.violet.withAlphaComponent(0.18)
                ring.position = cellCenter(cell)
                ring.zPosition = 30
                boardLayer.addChild(ring)
                ring.run(.repeatForever(.rotate(byAngle: .pi * 2, duration: 2.5)))
                let inner = SKShapeNode(circleOfRadius: cellSize * 0.18)
                inner.strokeColor = Theme.violet.withAlphaComponent(0.7)
                inner.lineWidth = 1.5
                inner.fillColor = .clear
                inner.position = ring.position
                inner.zPosition = 31
                boardLayer.addChild(inner)
                let label = makeLabel(portalLabel, size: cellSize * 0.26, color: Theme.violet)
                label.position = CGPoint(x: ring.position.x, y: ring.position.y)
                label.zPosition = 32
                boardLayer.addChild(label)
            }
            portalLabel = String(UnicodeScalar(portalLabel.unicodeScalars.first!.value + 1)!)
        }
    }

    // MARK: - Waves

    private func startNextWave() {
        waveIndex += 1
        betweenWaves = false
        hud.setCountdown(nil)
        hud.setWave(current: waveIndex, total: level.waves.count)
        waveClock = 0
        pendingSpawns = []
        let wave = level.waves[waveIndex - 1]
        for (entryIdx, entry) in wave.entries.enumerated() {
            let base = 0.5 + Double(entryIdx) * 1.2
            for k in 0..<entry.count {
                let cell = level.spawns[spawnCounter % level.spawns.count]
                spawnCounter += 1
                pendingSpawns.append((time: base + Double(k) * entry.interval, type: entry.type, cell: cell))
            }
        }
        pendingSpawns.sort { $0.time < $1.time }
        Effects.floatText("WAVE \(waveIndex)", at: CGPoint(x: size.width / 2, y: size.height / 2 + 40), color: Theme.magenta, size: 26, in: uiLayer)
        Sound.shared.play(.wave, on: self)
        Haptics.heavy()
    }

    private func spawnEnemy(type: EnemyType, at cell: Cell) {
        let enemy = Enemy(type: type, hpScale: LevelLibrary.hpScale(wave: waveIndex, levelId: level.id), cell: cell)
        enemy.position = cellCenter(cell)
        entityLayer.addChild(enemy)
        enemies.append(enemy)
        Effects.ring(at: enemy.position, radius: cellSize * 0.5, color: Theme.magenta, in: entityLayer)
    }

    // MARK: - Update loop

    override func update(_ currentTime: TimeInterval) {
        if lastUpdate == 0 { lastUpdate = currentTime }
        let rawDt = min(currentTime - lastUpdate, 1.0 / 30.0)
        lastUpdate = currentTime
        if gamePaused || gameEnded { return }
        let dt = rawDt * Double(gameSpeed)
        simTime += dt

        if betweenWaves {
            if planning {
                // Planning phase: no timer. Build freely, launch when ready.
                hud.setCountdown("BUILD NOW  -  TAP HERE TO LAUNCH WAVE 1")
                return
            }
            countdown -= dt
            if waveIndex < level.waves.count {
                hud.setCountdown("NEXT WAVE IN \(max(0, Int(ceil(countdown))))s  -  TAP TO CALL (+$15)")
            }
            if countdown <= 0 {
                startNextWave()
            }
            return
        }

        // Spawning
        waveClock += dt
        while let next = pendingSpawns.first, next.time <= waveClock {
            pendingSpawns.removeFirst()
            spawnEnemy(type: next.type, at: next.cell)
        }

        // Enemies
        var removed: [Enemy] = []
        for enemy in enemies {
            let event = enemy.update(dt: dt, grid: grid, cellSize: cellSize,
                                     cellCenter: { [weak self] in self?.cellCenter($0) ?? .zero }, now: simTime)
            switch event {
            case .reachedCore:
                shards -= 1
                Effects.ring(at: cellCenter(level.core), radius: cellSize, color: Theme.red, in: entityLayer)
                Effects.floatText("-1 CORE", at: cellCenter(level.core), color: Theme.red, size: 15, in: entityLayer)
                Sound.shared.play(.stolen, on: self)
                Haptics.error()
                if shards <= 0 {
                    removed.append(enemy)
                    endGame(victory: false)
                } else {
                    enemy.startCarryingShard()
                }
            case .escaped:
                removed.append(enemy)
            case .teleported:
                Effects.ring(at: enemy.position, radius: cellSize * 0.5, color: Theme.violet, in: entityLayer)
                Sound.shared.play(.teleport, on: self)
            case .none:
                break
            }
        }
        if gameEnded { cleanupRemoved(removed); return }

        // Towers
        for tower in towers {
            tower.cooldown -= dt
            if tower.cooldown > 0 { continue }
            guard let target = pickTarget(for: tower) else { continue }
            tower.cooldown = tower.fireInterval
            tower.aim(at: target.position)
            fire(tower: tower, at: target)
        }

        // Deaths
        for enemy in enemies where enemy.isDead && !removed.contains(where: { $0 === enemy }) {
            removed.append(enemy)
            handleKill(enemy)
        }
        cleanupRemoved(removed)

        // Wave complete?
        if !gameEnded && pendingSpawns.isEmpty && enemies.isEmpty && !betweenWaves {
            let bonus = 20 + 4 * waveIndex
            credits += bonus
            Effects.floatText("WAVE CLEAR +$\(bonus)", at: CGPoint(x: size.width / 2, y: size.height / 2 + 40), color: Theme.lime, size: 20, in: uiLayer)
            if waveIndex >= level.waves.count {
                endGame(victory: true)
            } else {
                betweenWaves = true
                countdown = 6
            }
        }
    }

    private func cleanupRemoved(_ removed: [Enemy]) {
        guard !removed.isEmpty else { return }
        enemies.removeAll { e in removed.contains(where: { $0 === e }) }
        for e in removed { e.removeFromParent() }
    }

    private func handleKill(_ enemy: Enemy) {
        credits += enemy.type.reward
        Effects.burst(at: enemy.position, color: enemy.type.color, count: enemy.type == .boss ? 18 : 8, in: entityLayer)
        Effects.floatText("+$\(enemy.type.reward)", at: enemy.position, color: Theme.amber, in: entityLayer)
        if enemy.carryingShard {
            Effects.shardReturn(from: enemy.position, to: cellCenter(level.core), in: entityLayer) { [weak self] in
                guard let self = self, !self.gameEnded else { return }
                self.shards += 1
                Effects.floatText("CORE RESCUED", at: self.cellCenter(self.level.core), color: Theme.cyan, size: 14, in: self.entityLayer)
                Sound.shared.play(.rescued, on: self)
            }
        }
        Sound.shared.play(.die, on: self)
        Haptics.tap()
    }

    // MARK: - Targeting & firing

    private func pickTarget(for tower: Tower) -> Enemy? {
        let rangePoints = tower.range * cellSize
        var best: Enemy?
        var bestScore = Double.greatestFiniteMagnitude
        for enemy in enemies where !enemy.cloaked && !enemy.isDead {
            let distance = tower.position.distance(to: enemy.position)
            if distance > rangePoints { continue }
            var score = Double(grid.distanceToCore(from: enemy.currentCell) == Int.max
                ? 9999 : grid.distanceToCore(from: enemy.currentCell))
            if enemy.carryingShard { score -= 10000 } // prioritize shard carriers
            if score < bestScore {
                bestScore = score
                best = enemy
            }
        }
        return best
    }

    private func fire(tower: Tower, at target: Enemy) {
        switch tower.type {
        case .pulse:
            Effects.beam(from: tower.position, to: target.position, color: Theme.cyan, in: entityLayer)
            target.applyDamage(tower.damage)
            Sound.shared.play(.pulse, on: self)
        case .cryo:
            Effects.beam(from: tower.position, to: target.position, color: Theme.ice, width: 3.5, in: entityLayer)
            target.applyDamage(tower.damage)
            target.applySlow(factor: 0.5, duration: 1.8, now: simTime)
            Sound.shared.play(.cryo, on: self)
        case .arc:
            Sound.shared.play(.arc, on: self)
            var chain: [Enemy] = [target]
            var damage = tower.damage
            var from = tower.position
            for _ in 0..<3 {
                guard let current = chain.last else { break }
                Effects.beam(from: from, to: current.position, color: Theme.magenta, in: entityLayer)
                current.applyDamage(damage)
                from = current.position
                damage *= 0.7
                let next = enemies.first { candidate in
                    !candidate.cloaked && !candidate.isDead &&
                    !chain.contains(where: { $0 === candidate }) &&
                    candidate.position.distance(to: current.position) < cellSize * 1.8
                }
                if let next = next { chain.append(next) } else { break }
            }
        case .rail:
            Sound.shared.play(.rail, on: self)
            let direction = (target.position - tower.position).normalized
            let endPoint = tower.position + direction * (tower.range * cellSize)
            Effects.beam(from: tower.position, to: endPoint, color: Theme.amber, width: 4, in: entityLayer)
            for enemy in enemies where !enemy.cloaked && !enemy.isDead {
                if distancePointToSegment(enemy.position, a: tower.position, b: endPoint) < 14 {
                    enemy.applyDamage(tower.damage)
                }
            }
        }
    }

    private func distancePointToSegment(_ p: CGPoint, a: CGPoint, b: CGPoint) -> CGFloat {
        let ab = b - a
        let lengthSquared = ab.x * ab.x + ab.y * ab.y
        if lengthSquared == 0 { return p.distance(to: a) }
        let t = max(0, min(1, ((p.x - a.x) * ab.x + (p.y - a.y) * ab.y) / lengthSquared))
        let projection = CGPoint(x: a.x + ab.x * t, y: a.y + ab.y * t)
        return p.distance(to: projection)
    }

    // MARK: - Input handling

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
        if event.keyCode == 53 { // Esc
            if popup != nil { dismissPopup() } else { _ = handleAction("pause") }
            return
        }
        switch event.charactersIgnoringModifiers?.lowercased() {
        case "1": _ = handleAction("build_pulse")
        case "2": _ = handleAction("build_cryo")
        case "3": _ = handleAction("build_arc")
        case "4": _ = handleAction("build_rail")
        case "f": _ = handleAction("speed")
        case "w": _ = handleAction("callwave")
        case " ", "p": _ = handleAction("pause")
        default: break
        }
    }
    #endif

    private func handleTap(at point: CGPoint) {
        if let name = actionName(at: point), handleAction(name) { return }
        if gamePaused || gameEnded { return }

        guard let cell = cellAt(point) else {
            dismissPopup()
            return
        }
        if let tower = towerByCell[cell] {
            showPopup(for: tower)
            return
        }
        dismissPopup()
        attemptPlacement(at: cell)
    }

    private func actionName(at point: CGPoint) -> String? {
        var node: SKNode? = atPoint(point)
        while let current = node {
            if let name = current.name, !name.isEmpty { return name }
            node = current.parent
        }
        return nil
    }

    private func handleAction(_ name: String) -> Bool {
        switch name {
        case "build_pulse": selectBuild(.pulse); return true
        case "build_cryo": selectBuild(.cryo); return true
        case "build_arc": selectBuild(.arc); return true
        case "build_rail": selectBuild(.rail); return true
        case "speed":
            gameSpeed = gameSpeed == 1 ? 2 : 1
            hud.setSpeed(Int(gameSpeed))
            Sound.shared.play(.tap, on: self)
            Haptics.tap()
            return true
        case "pause":
            togglePause()
            return true
        case "callwave":
            if planning && !gameEnded {
                planning = false
                startNextWave()
            } else if betweenWaves && !gameEnded && waveIndex < level.waves.count {
                credits += 15
                startNextWave()
            }
            return true
        case "popup_upgrade":
            if let tower = popupTower, tower.canUpgrade, credits >= tower.upgradeCost {
                credits -= tower.upgradeCost
                tower.upgrade()
                Sound.shared.play(.upgrade, on: self)
                Haptics.success()
                dismissPopup()
                showPopup(for: tower)
            } else {
                Sound.shared.play(.blocked, on: self)
                Haptics.error()
            }
            return true
        case "popup_sell":
            if let tower = popupTower { sell(tower) }
            return true
        case "popup_close":
            dismissPopup()
            return true
        case "overlay_resume":
            togglePause()
            return true
        case "overlay_sound":
            Sound.shared.toggle()
            Sound.shared.play(.tap, on: self)
            if gamePaused { showPauseOverlay() }
            return true
        case "overlay_retry":
            view?.presentScene(GameScene(level: level, size: size), transition: .fade(withDuration: 0.4))
            return true
        case "overlay_menu":
            view?.presentScene(MenuScene(size: size), transition: .fade(withDuration: 0.4))
            return true
        case "overlay_next":
            let nextLevel = LevelLibrary.level(id: level.id + 1)
            view?.presentScene(GameScene(level: nextLevel, size: size), transition: .fade(withDuration: 0.4))
            return true
        case "core_node":
            return false
        default:
            return false
        }
    }

    private func selectBuild(_ type: TowerType) {
        selectedBuild = type
        hud.setSelected(type)
        Sound.shared.play(.tap, on: self)
        Haptics.tap()
    }

    private func attemptPlacement(at cell: Cell) {
        guard let type = selectedBuild else { return }
        if credits < type.cost {
            Effects.floatText("NEED $\(type.cost)", at: cellCenter(cell), color: Theme.red, in: entityLayer)
            Sound.shared.play(.blocked, on: self)
            Haptics.error()
            return
        }
        var occupied: [Cell] = []
        for enemy in enemies {
            occupied.append(enemy.currentCell)
            if let target = enemy.targetCell { occupied.append(target) }
        }
        guard grid.canPlaceTower(at: cell, occupied: occupied) else {
            Effects.floatText("BLOCKED", at: cellCenter(cell), color: Theme.red, in: entityLayer)
            Sound.shared.play(.blocked, on: self)
            Haptics.error()
            return
        }
        credits -= type.cost
        grid.placeTower(at: cell)
        let tower = Tower(type: type, cell: cell, cellSize: cellSize)
        tower.position = cellCenter(cell)
        entityLayer.addChild(tower)
        towers.append(tower)
        towerByCell[cell] = tower
        retargetEnemies()
        Effects.ring(at: tower.position, radius: cellSize * 0.6, color: type.color, in: entityLayer)
        Sound.shared.play(.place, on: self)
        Haptics.tap()
    }

    private func sell(_ tower: Tower) {
        credits += tower.sellValue
        grid.removeTower(at: tower.cell)
        towerByCell[tower.cell] = nil
        towers.removeAll { $0 === tower }
        Effects.burst(at: tower.position, color: tower.type.color, in: entityLayer)
        Effects.floatText("+$\(tower.sellValue)", at: tower.position, color: Theme.amber, in: entityLayer)
        tower.removeFromParent()
        retargetEnemies()
        dismissPopup()
        Sound.shared.play(.sell, on: self)
        Haptics.tap()
    }

    private func retargetEnemies() {
        for enemy in enemies { enemy.targetCell = nil }
    }

    // MARK: - Tower popup

    private func showPopup(for tower: Tower) {
        dismissPopup()
        popupTower = tower
        let container = SKNode()
        container.zPosition = 120

        let panel = neonRect(size: CGSize(width: 190, height: 96), corner: 10, color: tower.type.color, glow: 4, fillAlpha: 0.92)
        panel.fillColor = Theme.panel
        container.addChild(panel)

        let title = makeLabel("\(tower.type.name)  Lv\(tower.tier + 1)", size: 14, color: tower.type.color)
        title.position = CGPoint(x: 0, y: 30)
        container.addChild(title)

        let upgradeButton = neonRect(size: CGSize(width: 160, height: 26), corner: 6, color: Theme.lime, glow: 2, fillAlpha: 0.15)
        upgradeButton.position = CGPoint(x: 0, y: 2)
        upgradeButton.name = "popup_upgrade"
        container.addChild(upgradeButton)
        let upgradeText = tower.canUpgrade ? "UPGRADE  $\(tower.upgradeCost)" : "MAX LEVEL"
        let upgradeLabel = makeLabel(upgradeText, size: 12, color: tower.canUpgrade ? Theme.lime : Theme.dim)
        upgradeLabel.name = "popup_upgrade"
        upgradeLabel.position = upgradeButton.position
        container.addChild(upgradeLabel)

        let sellButton = neonRect(size: CGSize(width: 160, height: 26), corner: 6, color: Theme.red, glow: 2, fillAlpha: 0.12)
        sellButton.position = CGPoint(x: 0, y: -28)
        sellButton.name = "popup_sell"
        container.addChild(sellButton)
        let sellLabel = makeLabel("SELL  +$\(tower.sellValue)", size: 12, color: Theme.red)
        sellLabel.name = "popup_sell"
        sellLabel.position = sellButton.position
        container.addChild(sellLabel)

        var x = tower.position.x
        x = max(110, min(size.width - 110, x))
        var y = tower.position.y + 80
        if y > size.height - 110 { y = tower.position.y - 80 }
        container.position = CGPoint(x: x, y: y)
        uiLayer.addChild(container)
        popup = container

        // Range indicator
        let rangeRing = SKShapeNode(circleOfRadius: tower.range * cellSize)
        rangeRing.strokeColor = tower.type.color.withAlphaComponent(0.5)
        rangeRing.lineWidth = 1.5
        rangeRing.fillColor = tower.type.color.withAlphaComponent(0.06)
        rangeRing.position = tower.position
        rangeRing.zPosition = 35
        rangeRing.name = "popup_range"
        entityLayer.addChild(rangeRing)
    }

    private func dismissPopup() {
        popup?.removeFromParent()
        popup = nil
        popupTower = nil
        entityLayer.childNode(withName: "popup_range")?.removeFromParent()
    }

    // MARK: - Pause & game end

    private func togglePause() {
        if gameEnded { return }
        gamePaused.toggle()
        Sound.shared.play(.tap, on: self)
        Haptics.tap()
        if gamePaused {
            showPauseOverlay()
        } else {
            pauseOverlay?.removeFromParent()
            pauseOverlay = nil
        }
    }

    private func showPauseOverlay() {
        pauseOverlay?.removeFromParent()
        let soundText = Sound.shared.isEnabled ? "SOUND: ON" : "SOUND: OFF"
        // Compact side panel + light dim so the level stays visible while paused.
        let overlay = makeOverlay(title: "PAUSED", titleColor: Theme.cyan, buttons: [
            ("RESUME", "overlay_resume", Theme.lime),
            (soundText, "overlay_sound", Theme.cyan),
            ("RESTART", "overlay_retry", Theme.amber),
            ("MENU", "overlay_menu", Theme.dim),
        ], dimAlpha: 0.18, panelWidth: 220,
           center: CGPoint(x: size.width - 130, y: size.height / 2))
        uiLayer.addChild(overlay)
        pauseOverlay = overlay
    }

    private func endGame(victory: Bool) {
        guard !gameEnded else { return }
        gameEnded = true
        dismissPopup()
        hud.setCountdown(nil)

        if victory {
            let ratio = Double(shards) / Double(level.shards)
            let stars = ratio >= 0.8 ? 3 : (ratio >= 0.4 ? 2 : 1)
            Progress.setStars(stars, for: level.id)
            Progress.unlock(level: level.id + 1)
            let starsText = String(repeating: "* ", count: stars).trimmingCharacters(in: .whitespaces)
            var buttons: [(String, String, SKColor)] = []
            if level.id < LevelLibrary.all.count {
                buttons.append(("NEXT LEVEL", "overlay_next", Theme.lime))
            }
            buttons.append(("REPLAY", "overlay_retry", Theme.amber))
            buttons.append(("MENU", "overlay_menu", Theme.dim))
            let overlay = makeOverlay(title: "SECTOR SECURED", subtitle: starsText, titleColor: Theme.lime, buttons: buttons)
            uiLayer.addChild(overlay)
            Sound.shared.play(.win, on: self)
            Haptics.success()
        } else {
            let overlay = makeOverlay(title: "CORES LOST", titleColor: Theme.red, buttons: [
                ("RETRY", "overlay_retry", Theme.lime),
                ("MENU", "overlay_menu", Theme.dim),
            ])
            uiLayer.addChild(overlay)
            Sound.shared.play(.lose, on: self)
            Haptics.error()
        }
    }

    private func makeOverlay(title: String, subtitle: String? = nil, titleColor: SKColor,
                             buttons: [(String, String, SKColor)],
                             dimAlpha: CGFloat = 0.66, panelWidth: CGFloat = 320,
                             center: CGPoint? = nil) -> SKNode {
        let overlay = SKNode()
        overlay.zPosition = 200
        let mid = center ?? CGPoint(x: size.width / 2, y: size.height / 2)

        let dimmer = SKShapeNode(rectOf: CGSize(width: size.width * 2, height: size.height * 2))
        dimmer.fillColor = SKColor(white: 0, alpha: dimAlpha)
        dimmer.strokeColor = .clear
        dimmer.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlay.addChild(dimmer)

        let panelHeight = CGFloat(150 + buttons.count * 44)
        let panel = neonRect(size: CGSize(width: panelWidth, height: panelHeight), corner: 14, color: titleColor, glow: 6, fillAlpha: 1)
        panel.fillColor = Theme.panel
        panel.position = mid
        overlay.addChild(panel)

        let titleLabel = makeLabel(title, size: 26, color: titleColor, font: Theme.titleFont)
        titleLabel.position = CGPoint(x: mid.x, y: mid.y + panelHeight / 2 - 44)
        overlay.addChild(titleLabel)

        var y = mid.y + panelHeight / 2 - 84
        if let subtitle = subtitle {
            let subtitleLabel = makeLabel(subtitle, size: 24, color: Theme.amber)
            subtitleLabel.position = CGPoint(x: mid.x, y: y)
            overlay.addChild(subtitleLabel)
            y -= 46
        }

        for (text, action, color) in buttons {
            let button = neonRect(size: CGSize(width: panelWidth - 50, height: 36), corner: 8, color: color, glow: 3, fillAlpha: 0.14)
            button.position = CGPoint(x: mid.x, y: y)
            button.name = action
            overlay.addChild(button)
            let label = makeLabel(text, size: 15, color: color)
            label.name = action
            label.position = button.position
            overlay.addChild(label)
            y -= 44
        }
        return overlay
    }
}
