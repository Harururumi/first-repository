import SwiftUI

class GalleryViewModel: ObservableObject {
    @Published var artworks: [SavedArtwork] = []

    func loadArtworks() {
        artworks = StorageService.shared.loadArtworks()
    }

    func delete(_ artwork: SavedArtwork) {
        StorageService.shared.delete(artwork)
        artworks.removeAll { $0.id == artwork.id }
    }

    func image(for artwork: SavedArtwork) -> UIImage? {
        StorageService.shared.loadImage(for: artwork)
    }
}
