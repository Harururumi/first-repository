import Foundation

struct SavedArtwork: Identifiable, Codable {
    let id: UUID
    let pageId: String
    let characterNameKo: String
    let characterNameEn: String
    let createdAt: Date
    let imagePath: String
}
