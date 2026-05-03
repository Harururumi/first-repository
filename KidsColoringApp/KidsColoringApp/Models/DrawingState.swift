import SwiftUI
import PencilKit

struct DrawingState {
    var regionColors: [String: Color]
    var pkDrawing: PKDrawing
}

enum UndoAction {
    case regionFilled(regionId: String, previousColor: Color?)
    case pkStrokeAdded(previousStrokeCount: Int)
}

enum ColoringTool: Equatable {
    case brush(lineWidth: CGFloat)
    case bucket
    case eraser
}
