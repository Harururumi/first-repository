import SwiftUI
import PencilKit

struct ColoringView: View {
    let page: ColoringPage
    @EnvironmentObject var appState: AppState
    @StateObject private var vm: ColoringViewModel
    @State private var canvasSize: CGSize = .zero

    init(page: ColoringPage) {
        self.page = page
        _vm = StateObject(wrappedValue: ColoringViewModel(page: page))
    }

    var body: some View {
        ZStack {
            Color(hex: "#FFFEF5").ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar
                topBar

                // Canvas area
                GeometryReader { geo in
                    let size = canvasAspectFitSize(in: geo.size)
                    ZStack {
                        // Region fill layer
                        RegionColoringLayer(vm: vm, renderSize: size)

                        // PencilKit brush layer
                        if case .brush(let width) = vm.activeTool {
                            ColoringCanvasView(vm: vm, lineWidth: width)
                                .allowsHitTesting(vm.activeTool != .bucket)
                        } else if case .eraser = vm.activeTool {
                            ColoringCanvasView(vm: vm, lineWidth: 20, isEraser: true)
                                .allowsHitTesting(true)
                        }

                        // Outline layer on top
                        OutlineLayer(page: page, renderSize: size)
                            .allowsHitTesting(false)

                        // Bucket fill tap gesture
                        if case .bucket = vm.activeTool {
                            Color.clear
                                .contentShape(Rectangle())
                                .gesture(
                                    DragGesture(minimumDistance: 0)
                                        .onEnded { value in
                                            vm.tapAt(value.location, renderSize: size)
                                        }
                                )
                        }
                    }
                    .frame(width: size.width, height: size.height)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 4)
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
                    .onAppear { canvasSize = size }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)

                // Progress bar
                progressBar

                // Color palette
                ColorPaletteView(selectedColor: $vm.selectedColor, activeTool: $vm.activeTool)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 4)

                // Toolbar
                ToolbarView(vm: vm, page: page)
                    .padding(.bottom, 8)
            }

            // Celebration overlay
            if vm.showCelebration {
                CelebrationView(isShowing: $vm.showCelebration) {
                    // Save on celebration
                    let image = ArtworkRenderer.render(
                        page: page,
                        regionColors: vm.regionColors,
                        pkDrawing: vm.pkDrawing
                    )
                    _ = StorageService.shared.save(image: image, for: page)
                }
            }
        }
        .navigationBarHidden(true)
    }

    private var topBar: some View {
        HStack {
            Button {
                SoundService.shared.play(.pageSelect)
                appState.navigate(to: .home)
            } label: {
                Image(systemName: "house.fill")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 52, height: 52)
                    .background(Color(hex: "#FF6B6B"))
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
            }

            Spacer()

            VStack(spacing: 0) {
                Text(page.nameKo)
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                    .foregroundColor(Color(hex: "#5B2D8E"))
                Text(page.nameEn)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Undo button
            Button {
                vm.undo()
            } label: {
                Image(systemName: "arrow.uturn.backward")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 52, height: 52)
                    .background(vm.canUndo ? Color(hex: "#9B59B6") : Color.gray.opacity(0.5))
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
            }
            .disabled(!vm.canUndo)
        }
        .padding(.horizontal, 20)
        .padding(.top, 56)
        .padding(.bottom, 8)
    }

    private var progressBar: some View {
        HStack(spacing: 8) {
            Text("색칠 완성도")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 10)
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "#FF6B6B"), Color(hex: "#FFD700")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * vm.completionPercent, height: 10)
                        .animation(.spring(), value: vm.completionPercent)
                }
            }
            .frame(height: 10)
            Text("\(Int(vm.completionPercent * 100))%")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "#FF6B6B"))
                .frame(width: 35, alignment: .trailing)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 4)
    }

    private func canvasAspectFitSize(in containerSize: CGSize) -> CGSize {
        let aspectRatio = page.canvasSize.width / page.canvasSize.height
        let containerAspect = containerSize.width / containerSize.height
        if aspectRatio > containerAspect {
            let width = containerSize.width
            return CGSize(width: width, height: width / aspectRatio)
        } else {
            let height = containerSize.height
            return CGSize(width: height * aspectRatio, height: height)
        }
    }
}

// MARK: - Region coloring layer

struct RegionColoringLayer: View {
    @ObservedObject var vm: ColoringViewModel
    let renderSize: CGSize

    var body: some View {
        Canvas { context, size in
            let scaleX = size.width / vm.page.canvasSize.width
            let scaleY = size.height / vm.page.canvasSize.height

            for region in vm.page.regions.sorted(by: { $0.drawingOrder < $1.drawingOrder }) {
                if let color = vm.regionColors[region.id] {
                    let path = buildPath(from: region.segments, scaleX: scaleX, scaleY: scaleY)
                    context.fill(path, with: .color(color))
                }
            }
        }
        .frame(width: renderSize.width, height: renderSize.height)
    }
}

// MARK: - Outline layer

struct OutlineLayer: View {
    let page: ColoringPage
    let renderSize: CGSize

    var body: some View {
        Canvas { context, size in
            let scaleX = size.width / page.canvasSize.width
            let scaleY = size.height / page.canvasSize.height

            for region in page.regions.sorted(by: { $0.drawingOrder < $1.drawingOrder }) {
                let path = buildPath(from: region.segments, scaleX: scaleX, scaleY: scaleY)
                context.stroke(path, with: .color(.black),
                               style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
            }
        }
        .frame(width: renderSize.width, height: renderSize.height)
    }
}

// MARK: - PencilKit canvas

struct ColoringCanvasView: UIViewRepresentable {
    @ObservedObject var vm: ColoringViewModel
    let lineWidth: CGFloat
    var isEraser: Bool = false

    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.backgroundColor = .clear
        canvas.isOpaque = false
        canvas.drawingPolicy = .anyInput
        canvas.delegate = context.coordinator
        updateTool(canvas)
        return canvas
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        updateTool(uiView)
        if uiView.drawing != vm.pkDrawing {
            uiView.drawing = vm.pkDrawing
        }
    }

    private func updateTool(_ canvas: PKCanvasView) {
        if isEraser {
            canvas.tool = PKEraserTool(.bitmap, width: lineWidth)
        } else {
            canvas.tool = PKInkingTool(
                .pen,
                color: UIColor(vm.selectedColor),
                width: lineWidth
            )
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(vm: vm) }

    class Coordinator: NSObject, PKCanvasViewDelegate {
        let vm: ColoringViewModel
        init(vm: ColoringViewModel) { self.vm = vm }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            let previousCount = vm.pkDrawing.strokes.count
            if canvasView.drawing.strokes.count > previousCount {
                vm.onBrushStrokeAdded(previousCount: previousCount)
                vm.pkDrawing = canvasView.drawing
            } else {
                vm.pkDrawing = canvasView.drawing
            }
        }
    }
}
