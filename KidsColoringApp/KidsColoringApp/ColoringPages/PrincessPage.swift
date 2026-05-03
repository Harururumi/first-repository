import SwiftUI

// Canvas coordinate space: 400 x 500
extension ColoringPage {
    static let princess = ColoringPage(
        id: "princess_aurora",
        nameKo: "귀여운 공주",
        nameEn: "Sweet Princess",
        regions: [
            // Background / sky
            ColorRegion(
                id: "princess_bg",
                name: "하늘",
                segments: [
                    .move(0, 0), .line(400, 0), .line(400, 500), .line(0, 500), .close
                ],
                drawingOrder: 0
            ),
            // Dress bottom (skirt)
            ColorRegion(
                id: "princess_skirt",
                name: "드레스 치마",
                segments: [
                    .move(80, 300),
                    .curve(60, 340, 40, 400, 30, 470),
                    .line(370, 470),
                    .curve(360, 400, 340, 340, 320, 300),
                    .curve(280, 280, 200, 270, 200, 270),
                    .curve(200, 270, 120, 280, 80, 300),
                    .close
                ],
                drawingOrder: 2
            ),
            // Dress top (bodice)
            ColorRegion(
                id: "princess_bodice",
                name: "드레스 상단",
                segments: [
                    .move(130, 200),
                    .curve(120, 220, 100, 260, 95, 300),
                    .curve(130, 290, 200, 285, 200, 285),
                    .curve(200, 285, 270, 290, 305, 300),
                    .curve(300, 260, 280, 220, 270, 200),
                    .curve(240, 185, 200, 180, 200, 180),
                    .curve(200, 180, 160, 185, 130, 200),
                    .close
                ],
                drawingOrder: 3
            ),
            // Face / skin
            ColorRegion(
                id: "princess_face",
                name: "얼굴",
                segments: [
                    .move(200, 80),
                    .curve(155, 80, 135, 110, 140, 145),
                    .curve(145, 175, 170, 195, 200, 195),
                    .curve(230, 195, 255, 175, 260, 145),
                    .curve(265, 110, 245, 80, 200, 80),
                    .close
                ],
                drawingOrder: 4
            ),
            // Hair
            ColorRegion(
                id: "princess_hair",
                name: "머리카락",
                segments: [
                    .move(200, 60),
                    .curve(155, 55, 125, 75, 125, 110),
                    .curve(125, 125, 130, 140, 140, 150),
                    .curve(145, 110, 165, 88, 200, 85),
                    .curve(235, 88, 255, 110, 260, 150),
                    .curve(270, 140, 275, 125, 275, 110),
                    .curve(275, 75, 245, 55, 200, 60),
                    .close
                ],
                drawingOrder: 5
            ),
            // Crown
            ColorRegion(
                id: "princess_crown",
                name: "왕관",
                segments: [
                    .move(160, 68),
                    .line(165, 45),
                    .line(175, 60),
                    .line(200, 42),
                    .line(225, 60),
                    .line(235, 45),
                    .line(240, 68),
                    .curve(220, 65, 180, 65, 160, 68),
                    .close
                ],
                drawingOrder: 6
            ),
            // Wand
            ColorRegion(
                id: "princess_wand",
                name: "마법봉",
                segments: [
                    .move(295, 165),
                    .curve(302, 158, 314, 158, 321, 165),
                    .curve(328, 172, 328, 184, 321, 191),
                    .curve(314, 198, 302, 198, 295, 191),
                    .curve(288, 184, 288, 172, 295, 165),
                    .close,
                    .move(306, 191),
                    .line(310, 300),
                    .line(314, 300),
                    .line(318, 191),
                    .close
                ],
                drawingOrder: 7
            ),
            // Ground
            ColorRegion(
                id: "princess_ground",
                name: "바닥",
                segments: [
                    .move(0, 440),
                    .curve(100, 430, 300, 430, 400, 440),
                    .line(400, 500),
                    .line(0, 500),
                    .close
                ],
                drawingOrder: 1
            )
        ],
        outlinePathData: [],
        canvasSize: CGSize(width: 400, height: 500),
        difficulty: 1
    )
}
