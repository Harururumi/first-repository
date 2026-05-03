import SwiftUI

struct ColoringPage: Identifiable, Hashable {
    let id: String
    let nameKo: String
    let nameEn: String
    let regions: [ColorRegion]
    let outlinePathData: [PathSegment]
    let canvasSize: CGSize
    let difficulty: Int

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: ColoringPage, rhs: ColoringPage) -> Bool { lhs.id == rhs.id }

    var displayName: String { nameKo }
}

struct ColorRegion: Identifiable, Hashable {
    let id: String
    let name: String
    let segments: [PathSegment]
    let drawingOrder: Int

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: ColorRegion, rhs: ColorRegion) -> Bool { lhs.id == rhs.id }

    func makePath(in canvasSize: CGSize, renderSize: CGSize) -> Path {
        let scaleX = renderSize.width / canvasSize.width
        let scaleY = renderSize.height / canvasSize.height
        return buildPath(from: segments, scaleX: scaleX, scaleY: scaleY)
    }
}

enum PathSegment {
    case move(CGFloat, CGFloat)
    case line(CGFloat, CGFloat)
    case curve(CGFloat, CGFloat, CGFloat, CGFloat, CGFloat, CGFloat)
    case quadCurve(CGFloat, CGFloat, CGFloat, CGFloat)
    case close
}

func buildPath(from segments: [PathSegment], scaleX: CGFloat, scaleY: CGFloat) -> Path {
    var path = Path()
    for segment in segments {
        switch segment {
        case .move(let x, let y):
            path.move(to: CGPoint(x: x * scaleX, y: y * scaleY))
        case .line(let x, let y):
            path.addLine(to: CGPoint(x: x * scaleX, y: y * scaleY))
        case .curve(let c1x, let c1y, let c2x, let c2y, let ex, let ey):
            path.addCurve(
                to: CGPoint(x: ex * scaleX, y: ey * scaleY),
                control1: CGPoint(x: c1x * scaleX, y: c1y * scaleY),
                control2: CGPoint(x: c2x * scaleX, y: c2y * scaleY)
            )
        case .quadCurve(let cx, let cy, let ex, let ey):
            path.addQuadCurve(
                to: CGPoint(x: ex * scaleX, y: ey * scaleY),
                control: CGPoint(x: cx * scaleX, y: cy * scaleY)
            )
        case .close:
            path.closeSubpath()
        }
    }
    return path
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
