import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    private let columns = [GridItem(.flexible(), spacing: 20), GridItem(.flexible(), spacing: 20)]
    private let pages = ColoringPage.all
    private let cardColors: [Color] = [
        Color(hex: "#FFB3BA"),
        Color(hex: "#FFDFBA"),
        Color(hex: "#FFFFBA"),
        Color(hex: "#BAFFC9"),
        Color(hex: "#BAE1FF")
    ]

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color(hex: "#E8D5FF"), Color(hex: "#C5E8FF")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("무엇을 색칠할까요?")
                            .font(.system(size: 28, weight: .heavy, design: .rounded))
                            .foregroundColor(Color(hex: "#5B2D8E"))

                        Text("What shall we color?")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(Color(hex: "#5B2D8E").opacity(0.7))
                    }

                    Spacer()

                    Button {
                        SoundService.shared.play(.pageSelect)
                        appState.navigate(to: .gallery)
                    } label: {
                        VStack(spacing: 2) {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 22, weight: .bold))
                            Text("내 작품")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(width: 64, height: 64)
                        .background(Color(hex: "#FF6B9D"))
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
                .padding(.bottom, 20)

                // Character grid
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                            CharacterCardView(
                                page: page,
                                cardColor: cardColors[index % cardColors.count]
                            )
                            .onTapGesture {
                                SoundService.shared.play(.pageSelect)
                                appState.navigate(to: .coloring(page))
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

struct CharacterCardView: View {
    let page: ColoringPage
    let cardColor: Color
    @State private var isPressed = false
    @State private var hasArtwork = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 12) {
                // Character preview (drawn programmatically)
                CharacterPreviewView(page: page)
                    .frame(height: 150)
                    .background(Color.white.opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                // Name labels
                VStack(spacing: 2) {
                    Text(page.nameKo)
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                        .foregroundColor(Color(hex: "#333333"))

                    Text(page.nameEn)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                }

                // Difficulty stars
                HStack(spacing: 3) {
                    ForEach(0..<3) { i in
                        Image(systemName: i < page.difficulty ? "star.fill" : "star")
                            .font(.system(size: 12))
                            .foregroundColor(i < page.difficulty ? .orange : .gray.opacity(0.4))
                    }
                }
            }
            .padding(14)
            .background(cardColor)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)

            // "완성!" badge if artwork exists
            if hasArtwork {
                Text("완성! ⭐")
                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color(hex: "#FF6B6B"))
                    .clipShape(Capsule())
                    .offset(x: -8, y: 8)
            }
        }
        .onAppear {
            hasArtwork = StorageService.shared.hasArtwork(for: page.id)
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

struct CharacterPreviewView: View {
    let page: ColoringPage
    private let previewColors: [String: Color] = [
        "princess_bg": Color(hex: "#87CEEB"),
        "princess_skirt": Color(hex: "#FFB6C1"),
        "princess_bodice": Color(hex: "#FF69B4"),
        "princess_face": Color(hex: "#FFDAB9"),
        "princess_hair": Color(hex: "#DAA520"),
        "princess_crown": Color(hex: "#FFD700"),
        "princess_wand": Color(hex: "#C0C0C0"),
        "princess_ground": Color(hex: "#90EE90"),
        "prince_bg": Color(hex: "#87CEEB"),
        "prince_ground": Color(hex: "#90EE90"),
        "prince_boots": Color(hex: "#8B4513"),
        "prince_pants": Color(hex: "#4169E1"),
        "prince_tunic": Color(hex: "#1E90FF"),
        "prince_cape": Color(hex: "#DC143C"),
        "prince_face": Color(hex: "#FFDAB9"),
        "prince_hair": Color(hex: "#DAA520"),
        "prince_crown": Color(hex: "#FFD700"),
        "prince_sword": Color(hex: "#C0C0C0"),
        "villain_bg": Color(hex: "#483D8B"),
        "villain_ground": Color(hex: "#556B2F"),
        "villain_robe": Color(hex: "#4B0082"),
        "villain_face": Color(hex: "#FFDAB9"),
        "villain_hair": Color(hex: "#2F2F2F"),
        "villain_hat": Color(hex: "#2F2F2F"),
        "villain_staff": Color(hex: "#8B6914"),
        "fairy_bg": Color(hex: "#FFE4E1"),
        "fairy_ground": Color(hex: "#90EE90"),
        "fairy_wing_left": Color(hex: "#E0FFFF").opacity(0.8),
        "fairy_wing_right": Color(hex: "#E0FFFF").opacity(0.8),
        "fairy_dress": Color(hex: "#98FB98"),
        "fairy_face": Color(hex: "#FFDAB9"),
        "fairy_hair": Color(hex: "#FFD700"),
        "fairy_wand": Color(hex: "#FF69B4"),
        "dragon_bg": Color(hex: "#87CEEB"),
        "dragon_ground": Color(hex: "#90EE90"),
        "dragon_body": Color(hex: "#FF8C00"),
        "dragon_belly": Color(hex: "#FFD700"),
        "dragon_wing_left": Color(hex: "#FF4500"),
        "dragon_wing_right": Color(hex: "#FF4500"),
        "dragon_head": Color(hex: "#FF8C00"),
        "dragon_horns": Color(hex: "#8B0000"),
        "dragon_eyes": Color.white,
        "dragon_tail": Color(hex: "#FF6347")
    ]

    var body: some View {
        GeometryReader { geo in
            Canvas { context, size in
                let scaleX = size.width / page.canvasSize.width
                let scaleY = size.height / page.canvasSize.height

                for region in page.regions.sorted(by: { $0.drawingOrder < $1.drawingOrder }) {
                    let path = buildPath(from: region.segments, scaleX: scaleX, scaleY: scaleY)
                    if let color = previewColors[region.id] {
                        context.fill(path, with: .color(color))
                    }
                    // Draw outline
                    context.stroke(path, with: .color(.black), lineWidth: 1.5)
                }
            }
        }
    }
}
