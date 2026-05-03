import UIKit
import PencilKit
import SwiftUI

class ArtworkRenderer {
    static func render(
        page: ColoringPage,
        regionColors: [String: Color],
        pkDrawing: PKDrawing,
        outputSize: CGSize = CGSize(width: 800, height: 1000)
    ) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: outputSize)
        return renderer.image { ctx in
            let cgCtx = ctx.cgContext
            let scaleX = outputSize.width / page.canvasSize.width
            let scaleY = outputSize.height / page.canvasSize.height

            // White background
            UIColor.white.setFill()
            cgCtx.fill(CGRect(origin: .zero, size: outputSize))

            // Draw filled regions sorted by drawing order
            for region in page.regions.sorted(by: { $0.drawingOrder < $1.drawingOrder }) {
                if let color = regionColors[region.id] {
                    let path = buildPath(from: region.segments, scaleX: scaleX, scaleY: scaleY)
                    UIColor(color).setFill()
                    UIBezierPath(cgPath: path.cgPath).fill()
                }
            }

            // Draw PencilKit strokes
            let pkImage = pkDrawing.image(
                from: CGRect(origin: .zero, size: page.canvasSize),
                scale: scaleX
            )
            pkImage.draw(in: CGRect(origin: .zero, size: outputSize))

            // Draw character outlines on top
            for region in page.regions.sorted(by: { $0.drawingOrder < $1.drawingOrder }) {
                let path = buildPath(from: region.segments, scaleX: scaleX, scaleY: scaleY)
                UIColor.black.setStroke()
                let bezier = UIBezierPath(cgPath: path.cgPath)
                bezier.lineWidth = 3.0
                bezier.lineJoinStyle = .round
                bezier.lineCapStyle = .round
                bezier.stroke()
            }
        }
    }
}
