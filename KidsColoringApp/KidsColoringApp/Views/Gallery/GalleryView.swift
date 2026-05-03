import SwiftUI

struct GalleryView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var vm = GalleryViewModel()

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#C5E8FF"), Color(hex: "#E8D5FF")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button {
                        SoundService.shared.play(.pageSelect)
                        appState.navigate(to: .home)
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 22, weight: .heavy))
                            .foregroundColor(.white)
                            .frame(width: 52, height: 52)
                            .background(Color(hex: "#FF6B6B"))
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                    }

                    Spacer()

                    VStack(spacing: 2) {
                        Text("내 작품")
                            .font(.system(size: 28, weight: .heavy, design: .rounded))
                            .foregroundColor(Color(hex: "#5B2D8E"))
                        Text("My Creations")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(Color(hex: "#5B2D8E").opacity(0.7))
                    }

                    Spacer()

                    Color.clear.frame(width: 52, height: 52)
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 20)

                if vm.artworks.isEmpty {
                    EmptyGalleryView()
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(vm.artworks) { artwork in
                                ArtworkCardView(artwork: artwork, vm: vm)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .onAppear { vm.loadArtworks() }
    }
}

struct ArtworkCardView: View {
    let artwork: SavedArtwork
    @ObservedObject var vm: GalleryViewModel
    @State private var image: UIImage?
    @State private var showDeleteConfirm = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 6) {
                Group {
                    if let img = image {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                    } else {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.2))
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                            )
                    }
                }
                .frame(height: 110)
                .clipShape(RoundedRectangle(cornerRadius: 10))

                Text(artwork.characterNameKo)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#333333"))

                Text(formattedDate(artwork.createdAt))
                    .font(.system(size: 10, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
            }
            .padding(10)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)

            // Delete button
            Button {
                showDeleteConfirm = true
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(Color(hex: "#FF3B30"))
                    .background(Color.white.clipShape(Circle()))
            }
            .offset(x: 6, y: -6)
        }
        .onAppear {
            image = vm.image(for: artwork)
        }
        .alert("삭제하시겠어요?", isPresented: $showDeleteConfirm) {
            Button("삭제", role: .destructive) { vm.delete(artwork) }
            Button("취소", role: .cancel) {}
        } message: {
            Text("이 작품은 복구할 수 없어요.")
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일"
        return formatter.string(from: date)
    }
}

struct EmptyGalleryView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("🎨")
                .font(.system(size: 80))

            Text("아직 작품이 없어요!")
                .font(.system(size: 24, weight: .heavy, design: .rounded))
                .foregroundColor(Color(hex: "#5B2D8E"))

            Text("색칠을 완성하고 저장해보세요!")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)
            Spacer()
        }
    }
}
