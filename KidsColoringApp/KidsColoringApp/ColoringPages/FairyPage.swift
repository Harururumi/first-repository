import SwiftUI

// Canvas coordinate space: 400 x 500
extension ColoringPage {
    static let fairy = ColoringPage(
        id: "fairy_lumina",
        nameKo: "반짝이 요정",
        nameEn: "Sparkle Fairy",
        regions: [
            // Background
            ColorRegion(
                id: "fairy_bg",
                name: "하늘",
                segments: [
                    .move(0, 0), .line(400, 0), .line(400, 500), .line(0, 500), .close
                ],
                drawingOrder: 0
            ),
            // Ground with flowers
            ColorRegion(
                id: "fairy_ground",
                name: "풀밭",
                segments: [
                    .move(0, 430), .curve(100, 415, 300, 415, 400, 430),
                    .line(400, 500), .line(0, 500), .close
                ],
                drawingOrder: 1
            ),
            // Left wing
            ColorRegion(
                id: "fairy_wing_left",
                name: "왼쪽 날개",
                segments: [
                    .move(175, 210),
                    .curve(140, 190, 80, 160, 60, 200),
                    .curve(45, 235, 80, 280, 130, 270),
                    .curve(155, 265, 170, 245, 175, 230),
                    .close
                ],
                drawingOrder: 2
            ),
            // Right wing
            ColorRegion(
                id: "fairy_wing_right",
                name: "오른쪽 날개",
                segments: [
                    .move(225, 210),
                    .curve(260, 190, 320, 160, 340, 200),
                    .curve(355, 235, 320, 280, 270, 270),
                    .curve(245, 265, 230, 245, 225, 230),
                    .close
                ],
                drawingOrder: 2
            ),
            // Dress
            ColorRegion(
                id: "fairy_dress",
                name: "드레스",
                segments: [
                    .move(155, 215),
                    .curve(140, 250, 135, 310, 120, 380),
                    .curve(150, 390, 200, 385, 200, 385),
                    .curve(200, 385, 250, 390, 280, 380),
                    .curve(265, 310, 260, 250, 245, 215),
                    .curve(225, 200, 200, 196, 200, 196),
                    .curve(200, 196, 175, 200, 155, 215),
                    .close
                ],
                drawingOrder: 3
            ),
            // Face
            ColorRegion(
                id: "fairy_face",
                name: "얼굴",
                segments: [
                    .move(200, 85),
                    .curve(160, 85, 140, 112, 145, 147),
                    .curve(150, 177, 174, 197, 200, 197),
                    .curve(226, 197, 250, 177, 255, 147),
                    .curve(260, 112, 240, 85, 200, 85),
                    .close
                ],
                drawingOrder: 4
            ),
            // Hair (flowing)
            ColorRegion(
                id: "fairy_hair",
                name: "머리카락",
                segments: [
                    .move(200, 65),
                    .curve(155, 60, 122, 82, 127, 120),
                    .curve(130, 137, 138, 150, 147, 157),
                    .curve(150, 115, 170, 92, 200, 88),
                    .curve(230, 92, 250, 115, 253, 157),
                    .curve(262, 150, 270, 137, 273, 120),
                    .curve(278, 82, 245, 60, 200, 65),
                    .close
                ],
                drawingOrder: 5
            ),
            // Flower wand
            ColorRegion(
                id: "fairy_wand",
                name: "꽃 지팡이",
                segments: [
                    // Flower petals
                    .move(308, 168),
                    .curve(310, 148, 322, 140, 328, 152),
                    .curve(334, 164, 326, 178, 320, 178),
                    .curve(326, 182, 334, 196, 328, 208),
                    .curve(322, 220, 310, 212, 308, 192),
                    .curve(304, 212, 292, 220, 286, 208),
                    .curve(280, 196, 288, 182, 294, 178),
                    .curve(288, 178, 280, 164, 286, 152),
                    .curve(292, 140, 304, 148, 308, 168),
                    .close,
                    // Stem
                    .move(306, 190),
                    .line(310, 370),
                    .line(314, 370),
                    .line(318, 190),
                    .close
                ],
                drawingOrder: 6
            )
        ],
        outlinePathData: [],
        canvasSize: CGSize(width: 400, height: 500),
        difficulty: 1
    )
}
