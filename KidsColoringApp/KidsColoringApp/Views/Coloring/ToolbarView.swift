import SwiftUI
import PencilKit

struct ToolbarView: View {
    @ObservedObject var vm: ColoringViewModel
    let page: ColoringPage
    @State private var showSaveConfirm = false

    var body: some View {
        HStack(spacing: 12) {
            // Brush tool
            ToolButton(
                icon: "paintbrush.pointed.fill",
                label: "붓",
                color: Color(hex: "#007AFF"),
                isSelected: {
                    if case .brush(_) = vm.activeTool { return true }
                    return false
                }()
            ) {
                vm.activeTool = .brush(lineWidth: 20)
                SoundService.shared.play(.colorSplash)
            }

            // Bucket fill tool
            ToolButton(
                icon: "drop.fill",
                label: "채우기",
                color: Color(hex: "#34C759"),
                isSelected: vm.activeTool == .bucket
            ) {
                vm.activeTool = .bucket
                SoundService.shared.play(.colorSplash)
            }

            // Eraser
            ToolButton(
                icon: "eraser.fill",
                label: "지우개",
                color: Color(hex: "#8E8E93"),
                isSelected: {
                    if case .eraser = vm.activeTool { return true }
                    return false
                }()
            ) {
                vm.activeTool = .eraser
                SoundService.shared.play(.colorSplash)
            }

            Spacer()

            // Save button
            Button {
                let image = ArtworkRenderer.render(
                    page: page,
                    regionColors: vm.regionColors,
                    pkDrawing: vm.pkDrawing
                )
                _ = StorageService.shared.save(image: image, for: page)
                showSaveConfirm = true
                SoundService.shared.play(.celebration)
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 18, weight: .bold))
                    Text("저장")
                        .font(.system(size: 15, weight: .heavy, design: .rounded))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 18)
                .padding(.vertical, 14)
                .background(Color(hex: "#FF2D55"))
                .clipShape(Capsule())
                .shadow(color: Color(hex: "#FF2D55").opacity(0.4), radius: 6, x: 0, y: 3)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .overlay(
            Group {
                if showSaveConfirm {
                    SaveConfirmBanner()
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation { showSaveConfirm = false }
                            }
                        }
                }
            }
            , alignment: .top
        )
    }
}

struct ToolButton: View {
    let icon: String
    let label: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(isSelected ? .white : color)
                    .frame(width: 54, height: 54)
                    .background(isSelected ? color : color.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: isSelected ? color.opacity(0.4) : .clear, radius: 4, x: 0, y: 2)
                Text(label)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(color)
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }
}

struct SaveConfirmBanner: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
            Text("저장되었어요! 💾")
                .font(.system(size: 15, weight: .bold, design: .rounded))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color(hex: "#34C759"))
        .clipShape(Capsule())
        .shadow(radius: 8)
    }
}
