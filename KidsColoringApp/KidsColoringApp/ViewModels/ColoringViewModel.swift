import SwiftUI
import PencilKit

class ColoringViewModel: ObservableObject {
    let page: ColoringPage

    @Published var regionColors: [String: Color] = [:]
    @Published var pkDrawing: PKDrawing = PKDrawing()
    @Published var selectedColor: Color = .red
    @Published var activeTool: ColoringTool = .brush(lineWidth: 20)
    @Published var showCelebration: Bool = false
    @Published var completionPercent: Double = 0

    private var undoStack: [UndoAction] = []
    private let maxUndoDepth = 30

    init(page: ColoringPage) {
        self.page = page
    }

    // MARK: - Region Fill

    func tapAt(_ point: CGPoint, renderSize: CGSize) {
        guard case .bucket = activeTool else { return }

        let scaleX = renderSize.width / page.canvasSize.width
        let scaleY = renderSize.height / page.canvasSize.height
        let normalizedPoint = CGPoint(x: point.x / scaleX, y: point.y / scaleY)

        // Find topmost region under tap
        let hit = page.regions
            .sorted { $0.drawingOrder > $1.drawingOrder }
            .first { region in
                let path = buildPath(from: region.segments, scaleX: 1, scaleY: 1)
                return path.contains(normalizedPoint)
            }

        if let region = hit {
            let previous = regionColors[region.id]
            pushUndo(.regionFilled(regionId: region.id, previousColor: previous))
            regionColors[region.id] = selectedColor
            SoundService.shared.play(.colorSplash)
            updateCompletion()
        }
    }

    // MARK: - Undo

    func undo() {
        guard let action = undoStack.popLast() else { return }
        switch action {
        case .regionFilled(let regionId, let previousColor):
            if let prev = previousColor {
                regionColors[regionId] = prev
            } else {
                regionColors.removeValue(forKey: regionId)
            }
            updateCompletion()
        case .pkStrokeAdded(let previousCount):
            let trimmed = Array(pkDrawing.strokes.prefix(previousCount))
            pkDrawing = PKDrawing(strokes: trimmed)
        }
        SoundService.shared.play(.undo)
    }

    func onBrushStrokeAdded(previousCount: Int) {
        pushUndo(.pkStrokeAdded(previousStrokeCount: previousCount))
        SoundService.shared.play(.colorSplash)
    }

    // MARK: - Save

    func saveArtwork(renderView: @escaping () -> UIImage?) -> SavedArtwork? {
        guard let image = renderView() else { return nil }
        let artwork = StorageService.shared.save(image: image, for: page)
        return artwork
    }

    // MARK: - Completion

    private func updateCompletion() {
        let total = page.regions.filter { $0.id != page.regions.first?.id }.count
        let colored = regionColors.count
        let percent = total > 0 ? Double(colored) / Double(total) : 0
        completionPercent = min(percent, 1.0)

        if completionPercent >= 0.8 && !showCelebration {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation { self.showCelebration = true }
                SoundService.shared.play(.celebration)
            }
        }
    }

    // MARK: - Private

    private func pushUndo(_ action: UndoAction) {
        undoStack.append(action)
        if undoStack.count > maxUndoDepth {
            undoStack.removeFirst()
        }
    }

    var canUndo: Bool { !undoStack.isEmpty }
}
