import SwiftUI

// Canvas coordinate space: 400 x 500
extension ColoringPage {
    static let prince = ColoringPage(
        id: "prince_stellan",
        nameKo: "용감한 왕자",
        nameEn: "Brave Prince",
        regions: [
            // Background
            ColorRegion(
                id: "prince_bg",
                name: "하늘",
                segments: [
                    .move(0, 0), .line(400, 0), .line(400, 500), .line(0, 500), .close
                ],
                drawingOrder: 0
            ),
            // Ground
            ColorRegion(
                id: "prince_ground",
                name: "바닥",
                segments: [
                    .move(0, 440), .curve(100, 430, 300, 430, 400, 440),
                    .line(400, 500), .line(0, 500), .close
                ],
                drawingOrder: 1
            ),
            // Boots
            ColorRegion(
                id: "prince_boots",
                name: "장화",
                segments: [
                    .move(145, 390), .line(145, 440), .line(185, 440),
                    .line(185, 390), .close,
                    .move(215, 390), .line(215, 440), .line(255, 440),
                    .line(255, 390), .close
                ],
                drawingOrder: 2
            ),
            // Pants / legs
            ColorRegion(
                id: "prince_pants",
                name: "바지",
                segments: [
                    .move(140, 290), .line(140, 400), .line(195, 400),
                    .line(200, 330), .line(205, 400), .line(260, 400),
                    .line(260, 290), .close
                ],
                drawingOrder: 3
            ),
            // Tunic / armor body
            ColorRegion(
                id: "prince_tunic",
                name: "갑옷",
                segments: [
                    .move(135, 200),
                    .curve(125, 230, 125, 270, 130, 300),
                    .line(270, 300),
                    .curve(275, 270, 275, 230, 265, 200),
                    .curve(240, 185, 200, 180, 200, 180),
                    .curve(200, 180, 160, 185, 135, 200),
                    .close
                ],
                drawingOrder: 4
            ),
            // Cape
            ColorRegion(
                id: "prince_cape",
                name: "망토",
                segments: [
                    .move(135, 200),
                    .curve(115, 230, 105, 280, 100, 350),
                    .curve(120, 360, 140, 350, 145, 330),
                    .line(150, 290),
                    .curve(145, 260, 140, 230, 140, 210),
                    .close
                ],
                drawingOrder: 2
            ),
            // Face
            ColorRegion(
                id: "prince_face",
                name: "얼굴",
                segments: [
                    .move(200, 82),
                    .curve(158, 82, 138, 112, 143, 148),
                    .curve(148, 178, 172, 198, 200, 198),
                    .curve(228, 198, 252, 178, 257, 148),
                    .curve(262, 112, 242, 82, 200, 82),
                    .close
                ],
                drawingOrder: 5
            ),
            // Hair
            ColorRegion(
                id: "prince_hair",
                name: "머리카락",
                segments: [
                    .move(200, 62),
                    .curve(158, 57, 128, 80, 130, 115),
                    .curve(132, 130, 138, 145, 145, 152),
                    .curve(148, 112, 168, 90, 200, 87),
                    .curve(232, 90, 252, 112, 255, 152),
                    .curve(262, 145, 268, 130, 270, 115),
                    .curve(272, 80, 242, 57, 200, 62),
                    .close
                ],
                drawingOrder: 6
            ),
            // Crown / helmet
            ColorRegion(
                id: "prince_crown",
                name: "왕관",
                segments: [
                    .move(163, 70),
                    .line(168, 48),
                    .line(178, 63),
                    .line(200, 45),
                    .line(222, 63),
                    .line(232, 48),
                    .line(237, 70),
                    .curve(218, 67, 182, 67, 163, 70),
                    .close
                ],
                drawingOrder: 7
            ),
            // Sword
            ColorRegion(
                id: "prince_sword",
                name: "검",
                segments: [
                    .move(270, 200),
                    .line(278, 192),
                    .line(340, 130),
                    .line(348, 138),
                    .line(286, 208),
                    .close,
                    // Guard
                    .move(265, 215),
                    .line(295, 185),
                    .line(302, 192),
                    .line(272, 222),
                    .close
                ],
                drawingOrder: 8
            )
        ],
        outlinePathData: [],
        canvasSize: CGSize(width: 400, height: 500),
        difficulty: 2
    )
}
