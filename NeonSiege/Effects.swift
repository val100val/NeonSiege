import SpriteKit

/// Lightweight programmatic VFX — no asset files needed.
enum Effects {
    static func beam(from: CGPoint, to: CGPoint, color: SKColor, width: CGFloat = 2.5, in parent: SKNode) {
        let path = CGMutablePath()
        path.move(to: from)
        path.addLine(to: to)
        let line = SKShapeNode(path: path)
        line.strokeColor = color
        line.lineWidth = width
        line.glowWidth = 4
        line.zPosition = 60
        parent.addChild(line)
        line.run(.sequence([.fadeOut(withDuration: 0.14), .removeFromParent()]))
    }

    static func burst(at point: CGPoint, color: SKColor, count: Int = 8, in parent: SKNode) {
        for _ in 0..<count {
            let dot = SKShapeNode(circleOfRadius: CGFloat.random(in: 1.5...3))
            dot.fillColor = color
            dot.strokeColor = .clear
            dot.glowWidth = 3
            dot.position = point
            dot.zPosition = 65
            parent.addChild(dot)
            let angle = CGFloat.random(in: 0...(2 * .pi))
            let distance = CGFloat.random(in: 12...34)
            let target = CGPoint(x: point.x + cos(angle) * distance, y: point.y + sin(angle) * distance)
            dot.run(.sequence([
                .group([.move(to: target, duration: 0.3), .fadeOut(withDuration: 0.3)]),
                .removeFromParent(),
            ]))
        }
    }

    static func ring(at point: CGPoint, radius: CGFloat, color: SKColor, in parent: SKNode) {
        let ring = SKShapeNode(circleOfRadius: radius)
        ring.strokeColor = color
        ring.lineWidth = 2
        ring.glowWidth = 4
        ring.fillColor = .clear
        ring.position = point
        ring.zPosition = 60
        ring.setScale(0.2)
        parent.addChild(ring)
        ring.run(.sequence([
            .group([.scale(to: 1.0, duration: 0.25), .fadeOut(withDuration: 0.25)]),
            .removeFromParent(),
        ]))
    }

    static func floatText(_ text: String, at point: CGPoint, color: SKColor, size: CGFloat = 13, in parent: SKNode) {
        let label = makeLabel(text, size: size, color: color)
        label.position = point
        label.zPosition = 70
        parent.addChild(label)
        label.run(.sequence([
            .group([.moveBy(x: 0, y: 22, duration: 0.7), .fadeOut(withDuration: 0.7)]),
            .removeFromParent(),
        ]))
    }

    static func shardReturn(from: CGPoint, to: CGPoint, in parent: SKNode, completion: @escaping () -> Void) {
        let shard = SKShapeNode(path: hexagonPath(radius: 6))
        shard.strokeColor = Theme.cyan
        shard.fillColor = Theme.cyan.withAlphaComponent(0.6)
        shard.glowWidth = 6
        shard.position = from
        shard.zPosition = 80
        parent.addChild(shard)
        shard.run(.sequence([
            .move(to: to, duration: 0.5),
            .run(completion),
            .removeFromParent(),
        ]))
    }
}
