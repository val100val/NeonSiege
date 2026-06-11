import SpriteKit
#if canImport(UIKit)
import UIKit
#endif

enum Theme {
    static let background = SKColor(red: 0.04, green: 0.05, blue: 0.10, alpha: 1)
    static let gridLine = SKColor(red: 0.13, green: 0.17, blue: 0.28, alpha: 1)
    static let panel = SKColor(red: 0.07, green: 0.09, blue: 0.17, alpha: 0.94)
    static let cyan = SKColor(red: 0.00, green: 0.92, blue: 1.00, alpha: 1)
    static let magenta = SKColor(red: 1.00, green: 0.25, blue: 0.75, alpha: 1)
    static let lime = SKColor(red: 0.55, green: 1.00, blue: 0.35, alpha: 1)
    static let amber = SKColor(red: 1.00, green: 0.72, blue: 0.20, alpha: 1)
    static let violet = SKColor(red: 0.62, green: 0.45, blue: 1.00, alpha: 1)
    static let ice = SKColor(red: 0.55, green: 0.80, blue: 1.00, alpha: 1)
    static let red = SKColor(red: 1.00, green: 0.30, blue: 0.30, alpha: 1)
    static let dim = SKColor(white: 0.62, alpha: 1)

    static let titleFont = "AvenirNext-Heavy"
    static let boldFont = "AvenirNext-Bold"
    static let font = "AvenirNext-Medium"
}

/// Platform default scale mode: edge-to-edge on iPhone, letterboxed fixed canvas on Mac.
#if os(iOS)
let platformScaleMode: SKSceneScaleMode = .resizeFill
#else
let platformScaleMode: SKSceneScaleMode = .aspectFit
#endif

enum Haptics {
    #if os(iOS)
    static func tap() { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
    static func heavy() { UIImpactFeedbackGenerator(style: .heavy).impactOccurred() }
    static func success() { UINotificationFeedbackGenerator().notificationOccurred(.success) }
    static func error() { UINotificationFeedbackGenerator().notificationOccurred(.error) }
    #else
    // No haptics on macOS — keep call sites identical across platforms.
    static func tap() {}
    static func heavy() {}
    static func success() {}
    static func error() {}
    #endif
}

func makeLabel(_ text: String, size: CGFloat, color: SKColor = .white, font: String = Theme.boldFont) -> SKLabelNode {
    let label = SKLabelNode(fontNamed: font)
    label.text = text
    label.fontSize = size
    label.fontColor = color
    label.verticalAlignmentMode = .center
    return label
}

func neonCircle(radius: CGFloat, color: SKColor, glow: CGFloat = 6, fillAlpha: CGFloat = 0.25) -> SKShapeNode {
    let node = SKShapeNode(circleOfRadius: radius)
    node.strokeColor = color
    node.lineWidth = 2
    node.glowWidth = glow
    node.fillColor = color.withAlphaComponent(fillAlpha)
    return node
}

func neonRect(size: CGSize, corner: CGFloat = 8, color: SKColor, glow: CGFloat = 4, fillAlpha: CGFloat = 0.16) -> SKShapeNode {
    let node = SKShapeNode(rectOf: size, cornerRadius: corner)
    node.strokeColor = color
    node.lineWidth = 2
    node.glowWidth = glow
    node.fillColor = color.withAlphaComponent(fillAlpha)
    return node
}

func hexagonPath(radius: CGFloat) -> CGPath {
    let path = CGMutablePath()
    for i in 0..<6 {
        let angle = CGFloat(i) * .pi / 3 + .pi / 6
        let point = CGPoint(x: cos(angle) * radius, y: sin(angle) * radius)
        if i == 0 { path.move(to: point) } else { path.addLine(to: point) }
    }
    path.closeSubpath()
    return path
}

extension CGPoint {
    static func + (a: CGPoint, b: CGPoint) -> CGPoint { CGPoint(x: a.x + b.x, y: a.y + b.y) }
    static func - (a: CGPoint, b: CGPoint) -> CGPoint { CGPoint(x: a.x - b.x, y: a.y - b.y) }
    static func * (a: CGPoint, s: CGFloat) -> CGPoint { CGPoint(x: a.x * s, y: a.y * s) }
    var length: CGFloat { sqrt(x * x + y * y) }
    var normalized: CGPoint {
        let len = length
        return len > 0 ? CGPoint(x: x / len, y: y / len) : .zero
    }
    func distance(to other: CGPoint) -> CGFloat { (self - other).length }
}
