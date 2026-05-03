# 새 캐릭터 추가 템플릿

## 캐릭터 정보
- **ID:** `[영문_소문자]`
- **한국어 이름:** `[이름]`
- **영어 이름:** `[Name]`
- **난이도:** 1~3
- **컨셉:** [공주/왕자/요정/용/악당 등]

## 구현 순서

1. `ColoringPages/[이름]Page.swift` 생성
2. `ColoringPage` extension 작성
   - canvasSize: `CGSize(width: 400, height: 500)` 고정
   - 각 구획: `ColorRegion(id:, name:, segments:, drawingOrder:)`
   - 배경(order:0) → 바닥(order:1) → 몸(order:2~3) → 얼굴(order:4+)
3. `DragonPage.swift` 맨 아래 `all` 배열에 추가
4. `HomeView.swift`의 `cardColors` 순환으로 자동 반영

## Path 좌표 규칙
- 캔버스: 0~400(X), 0~500(Y) 기준
- 상대 좌표 → `scaleX/scaleY`로 렌더 크기에 자동 맞춤
- 닫힌 경로 필수: 마지막에 `.close`
