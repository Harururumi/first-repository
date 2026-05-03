import SwiftUI

// Canvas coordinate space: 400 x 500
extension ColoringPage {
    static let villain = ColoringPage(
        id: "villain_thornwick",
        nameKo: "재미있는 악당",
        nameEn: "Funny Villain",
        regions: [
            // Background (dark/purple night sky)
            ColorRegion(
                id: "villain_bg",
                name: "밤하늘",
                segments: [
                    .move(0, 0), .line(400, 0), .line(400, 500), .line(0, 500), .close
                ],
                drawingOrder: 0
            ),
            // Ground
            ColorRegion(
                id: "villain_ground",
                name: "바닥",
                segments: [
                    .move(0, 440), .curve(100, 430, 300, 430, 400, 440),
                    .line(400, 500), .line(0, 500), .close
                ],
                drawingOrder: 1
            ),
            // Robe / body
            ColorRegion(
                id: "villain_robe",
                name: "로브",
                segments: [
                    .move(100, 220),
                    .curve(80, 280, 70, 360, 60, 440),
                    .line(340, 440),
                    .curve(330, 360, 320, 280, 300, 220),
                    .curve(270, 200, 200, 195, 200, 195),
                    .curve(200, 195, 130, 200, 100, 220),
                    .close
                ],
                drawingOrder: 2
            ),
            // Face
            ColorRegion(
                id: "villain_face",
                name: "얼굴",
                segments: [
                    .move(200, 88),
                    .curve(158, 88, 138, 118, 143, 152),
                    .curve(148, 182, 172, 202, 200, 202),
                    .curve(228, 202, 252, 182, 257, 152),
                    .curve(262, 118, 242, 88, 200, 88),
                    .close
                ],
                drawingOrder: 4
            ),
            // Hair (wild)
            ColorRegion(
                id: "villain_hair",
                name: "머리카락",
                segments: [
                    .move(200, 68),
                    .curve(145, 60, 110, 85, 118, 130),
                    .curve(122, 145, 130, 158, 140, 162),
                    .curve(138, 118, 158, 92, 200, 88),
                    .curve(242, 92, 262, 118, 260, 162),
                    .curve(270, 158, 278, 145, 282, 130),
                    .curve(290, 85, 255, 60, 200, 68),
                    .close
                ],
                drawingOrder: 5
            ),
            // Hat
            ColorRegion(
                id: "villain_hat",
                name: "모자",
                segments: [
                    // Brim
                    .move(140, 75),
                    .curve(150, 70, 165, 68, 200, 68),
                    .curve(235, 68, 250, 70, 260, 75),
                    .curve(245, 80, 215, 82, 215, 82),
                    // Hat tower
                    .line(225, 25),
                    .line(175, 25),
                    .line(185, 82),
                    .curve(185, 82, 155, 80, 140, 75),
                    .close
                ],
                drawingOrder: 6
            ),
            // Staff / wand
            ColorRegion(
                id: "villain_staff",
                name: "지팡이",
                segments: [
                    .move(290, 210),
                    .line(294, 210),
                    .line(320, 410),
                    .line(316, 410),
                    .close,
                    // Orb on top
                    .move(292, 195),
                    .curve(285, 188, 285, 178, 292, 171),
                    .curve(299, 164, 309, 164, 316, 171),
                    .curve(323, 178, 323, 188, 316, 195),
                    .curve(309, 202, 299, 202, 292, 195),
                    .close
                ],
                drawingOrder: 7
            )
        ],
        outlinePathData: [],
        canvasSize: CGSize(width: 400, height: 500),
        difficulty: 2
    )
}
