import SwiftUI

// Canvas coordinate space: 400 x 500
extension ColoringPage {
    static let dragon = ColoringPage(
        id: "dragon_ember",
        nameKo: "귀여운 용",
        nameEn: "Cute Dragon",
        regions: [
            // Background
            ColorRegion(
                id: "dragon_bg",
                name: "하늘",
                segments: [
                    .move(0, 0), .line(400, 0), .line(400, 500), .line(0, 500), .close
                ],
                drawingOrder: 0
            ),
            // Ground
            ColorRegion(
                id: "dragon_ground",
                name: "바닥",
                segments: [
                    .move(0, 420), .curve(100, 405, 300, 405, 400, 420),
                    .line(400, 500), .line(0, 500), .close
                ],
                drawingOrder: 1
            ),
            // Body (big round body)
            ColorRegion(
                id: "dragon_body",
                name: "몸통",
                segments: [
                    .move(200, 220),
                    .curve(140, 220, 100, 265, 100, 320),
                    .curve(100, 390, 145, 420, 200, 420),
                    .curve(255, 420, 300, 390, 300, 320),
                    .curve(300, 265, 260, 220, 200, 220),
                    .close
                ],
                drawingOrder: 2
            ),
            // Belly (lighter color)
            ColorRegion(
                id: "dragon_belly",
                name: "배",
                segments: [
                    .move(200, 260),
                    .curve(175, 260, 155, 285, 155, 320),
                    .curve(155, 365, 175, 390, 200, 390),
                    .curve(225, 390, 245, 365, 245, 320),
                    .curve(245, 285, 225, 260, 200, 260),
                    .close
                ],
                drawingOrder: 3
            ),
            // Left wing
            ColorRegion(
                id: "dragon_wing_left",
                name: "왼쪽 날개",
                segments: [
                    .move(110, 250),
                    .curve(80, 225, 40, 190, 50, 240),
                    .curve(55, 270, 80, 300, 105, 300),
                    .close
                ],
                drawingOrder: 2
            ),
            // Right wing
            ColorRegion(
                id: "dragon_wing_right",
                name: "오른쪽 날개",
                segments: [
                    .move(290, 250),
                    .curve(320, 225, 360, 190, 350, 240),
                    .curve(345, 270, 320, 300, 295, 300),
                    .close
                ],
                drawingOrder: 2
            ),
            // Head
            ColorRegion(
                id: "dragon_head",
                name: "머리",
                segments: [
                    .move(200, 105),
                    .curve(155, 105, 130, 132, 133, 165),
                    .curve(136, 200, 165, 225, 200, 225),
                    .curve(235, 225, 264, 200, 267, 165),
                    .curve(270, 132, 245, 105, 200, 105),
                    .close
                ],
                drawingOrder: 4
            ),
            // Horns
            ColorRegion(
                id: "dragon_horns",
                name: "뿔",
                segments: [
                    .move(170, 112),
                    .line(155, 78),
                    .line(175, 100),
                    .close,
                    .move(230, 112),
                    .line(245, 78),
                    .line(225, 100),
                    .close
                ],
                drawingOrder: 5
            ),
            // Eyes area (white)
            ColorRegion(
                id: "dragon_eyes",
                name: "눈",
                segments: [
                    // Left eye
                    .move(175, 148),
                    .curve(168, 140, 160, 142, 160, 152),
                    .curve(160, 162, 168, 168, 178, 164),
                    .curve(186, 160, 185, 148, 175, 148),
                    .close,
                    // Right eye
                    .move(225, 148),
                    .curve(232, 140, 240, 142, 240, 152),
                    .curve(240, 162, 232, 168, 222, 164),
                    .curve(214, 160, 215, 148, 225, 148),
                    .close
                ],
                drawingOrder: 6
            ),
            // Tail
            ColorRegion(
                id: "dragon_tail",
                name: "꼬리",
                segments: [
                    .move(285, 360),
                    .curve(310, 370, 350, 360, 360, 340),
                    .curve(370, 318, 355, 298, 335, 305),
                    .curve(320, 310, 310, 330, 305, 345),
                    .close
                ],
                drawingOrder: 2
            )
        ],
        outlinePathData: [],
        canvasSize: CGSize(width: 400, height: 500),
        difficulty: 3
    )
}

// All pages collection
extension ColoringPage {
    static let all: [ColoringPage] = [princess, prince, fairy, villain, dragon]
}
