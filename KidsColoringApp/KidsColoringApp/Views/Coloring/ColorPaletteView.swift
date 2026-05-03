import SwiftUI

struct ColorPaletteView: View {
    @Binding var selectedColor: Color
    @Binding var activeTool: ColoringTool

    static let palette: [Color] = [
        Color(hex: "#FF3B30"), Color(hex: "#FF9500"), Color(hex: "#FFCC00"), Color(hex: "#34C759"),
        Color(hex: "#007AFF"), Color(hex: "#AF52DE"), Color(hex: "#FF2D55"), Color(hex: "#FF6B9D"),
        Color(hex: "#5AC8FA"), Color(hex: "#4CD964"), Color(hex: "#8B4513"), Color(hex: "#FFDAB9"),
        Color.white,           Color(hex: "#AAAAAA"), Color(hex: "#555555"), Color.black
    ]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(Array(Self.palette.enumerated()), id: \.offset) { _, color in
                    colorSwatch(color)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
        )
    }

    private func colorSwatch(_ color: Color) -> some View {
        let isSelected: Bool = {
            if case .bucket = activeTool {
                return UIColor(selectedColor).isApproximatelyEqual(to: UIColor(color))
            }
            if case .brush(_) = activeTool {
                return UIColor(selectedColor).isApproximatelyEqual(to: UIColor(color))
            }
            return false
        }()

        return Button {
            selectedColor = color
            if case .eraser = activeTool {
                activeTool = .brush(lineWidth: 20)
            }
            SoundService.shared.play(.colorSplash)
        } label: {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: isSelected ? 3 : 0)
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.black.opacity(0.15), lineWidth: 1)
                    )

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundColor(color == .white ? .black : .white)
                }
            }
            .shadow(color: isSelected ? color.opacity(0.6) : .clear, radius: 6, x: 0, y: 2)
            .scaleEffect(isSelected ? 1.15 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}

extension UIColor {
    func isApproximatelyEqual(to other: UIColor, tolerance: CGFloat = 0.02) -> Bool {
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        other.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        return abs(r1-r2) < tolerance && abs(g1-g2) < tolerance && abs(b1-b2) < tolerance
    }
}
