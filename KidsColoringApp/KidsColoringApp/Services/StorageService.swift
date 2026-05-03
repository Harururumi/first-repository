import UIKit

class StorageService {
    static let shared = StorageService()

    private let artworksDir: URL
    private let metadataURL: URL

    private init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        artworksDir = docs.appendingPathComponent("Artworks", isDirectory: true)
        metadataURL = docs.appendingPathComponent("artworks_metadata.json")
        try? FileManager.default.createDirectory(at: artworksDir, withIntermediateDirectories: true)
    }

    @discardableResult
    func save(image: UIImage, for page: ColoringPage) -> SavedArtwork? {
        let filename = "\(page.id)_\(Int(Date().timeIntervalSince1970)).png"
        let fileURL = artworksDir.appendingPathComponent(filename)

        guard let data = image.pngData() else { return nil }
        try? data.write(to: fileURL)

        let artwork = SavedArtwork(
            id: UUID(),
            pageId: page.id,
            characterNameKo: page.nameKo,
            characterNameEn: page.nameEn,
            createdAt: Date(),
            imagePath: "Artworks/\(filename)"
        )

        var artworks = loadArtworks()
        artworks.append(artwork)
        saveMetadata(artworks)
        return artwork
    }

    func loadArtworks() -> [SavedArtwork] {
        guard let data = try? Data(contentsOf: metadataURL),
              let list = try? JSONDecoder().decode([SavedArtwork].self, from: data)
        else { return [] }
        return list.sorted { $0.createdAt > $1.createdAt }
    }

    func loadImage(for artwork: SavedArtwork) -> UIImage? {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = docs.appendingPathComponent(artwork.imagePath)
        return UIImage(contentsOfFile: url.path)
    }

    func delete(_ artwork: SavedArtwork) {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = docs.appendingPathComponent(artwork.imagePath)
        try? FileManager.default.removeItem(at: url)

        var artworks = loadArtworks()
        artworks.removeAll { $0.id == artwork.id }
        saveMetadata(artworks)
    }

    func hasArtwork(for pageId: String) -> Bool {
        loadArtworks().contains { $0.pageId == pageId }
    }

    private func saveMetadata(_ artworks: [SavedArtwork]) {
        guard let data = try? JSONEncoder().encode(artworks) else { return }
        try? data.write(to: metadataURL)
    }
}
