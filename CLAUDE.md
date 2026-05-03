# 마법의 색칠나라 - Claude 프로젝트 컨텍스트

> 이 파일은 Claude Code가 세션 시작 시 자동으로 읽는 프로젝트 정의 파일입니다.
> 매번 설명하지 않아도 됩니다.

---

## 프로젝트 개요

**앱 이름:** 마법의 색칠나라 (Magic Coloring Kingdom)
**플랫폼:** iOS (iPhone, SwiftUI, iOS 16+)
**대상 사용자:** 40개월(~3.5세) 유아
**언어:** 한국어 + 영어 (이중 언어)
**번들 ID:** com.kidsapp.coloringworld
**개발 브랜치:** `claude/kids-coloring-app-5aSeU`

---

## 기술 스택

- **UI:** SwiftUI (MVVM 패턴)
- **드로잉:** PencilKit (자유 브러시)
- **색칠 구획:** SwiftUI Canvas + Path (벡터 기반)
- **사운드:** AVFoundation + AudioToolbox
- **저장:** FileManager (PNG) + UserDefaults (메타데이터)
- **최소 iOS:** 16.0

---

## 현재 구조

```
KidsColoringApp/
├── KidsColoringApp.xcodeproj/
└── KidsColoringApp/
    ├── App/                    # 앱 진입점, AppState, 네비게이션
    ├── Models/                 # ColoringPage, DrawingState, SavedArtwork
    ├── ViewModels/             # ColoringViewModel, GalleryViewModel
    ├── Views/
    │   ├── Splash/             # 인트로 애니메이션
    │   ├── Home/               # 캐릭터 선택 그리드
    │   ├── Coloring/           # 메인 색칠 화면 (핵심)
    │   └── Gallery/            # 저장 작품 갤러리
    ├── Services/               # StorageService, SoundService, ArtworkRenderer
    └── ColoringPages/          # 5개 캐릭터 Path 정의
```

---

## 5개 캐릭터 (오리지널, 저작권 없음)

| ID | 한국어 | 영어 | 난이도 | 구획 수 |
|----|--------|------|--------|---------|
| `princess_aurora` | 귀여운 공주 | Sweet Princess | ★ | 8 |
| `prince_stellan` | 용감한 왕자 | Brave Prince | ★★ | 10 |
| `villain_thornwick` | 재미있는 악당 | Funny Villain | ★★ | 7 |
| `fairy_lumina` | 반짝이 요정 | Sparkle Fairy | ★ | 8 |
| `dragon_ember` | 귀여운 용 | Cute Dragon | ★★★ | 10 |

---

## 핵심 설계 결정 (변경 시 주의)

### 색칠 방식
- **구획 채우기:** `buildPath(from:scaleX:scaleY:)` 함수로 Path 생성 → `Canvas`에서 fill
- **자유 브러시:** `PKCanvasView` (UIViewRepresentable) - 손가락 드로잉 지원
- **레이어 순서:** 구획 fill → PencilKit 브러시 → 아웃라인(항상 맨 위)

### Undo 스택
- `ColoringViewModel.undoStack: [UndoAction]` (최대 30개)
- `UndoAction`: `.regionFilled(id, previousColor)` 또는 `.pkStrokeAdded(count)`
- PencilKit undo는 자체 UndoManager 사용 안 함 (strokes.prefix로 직접 관리)

### 저장
- `FileManager` → `Documents/Artworks/{pageId}_{timestamp}.png`
- 메타데이터: `Documents/artworks_metadata.json` (Codable JSON)
- `ArtworkRenderer.render()` → UIGraphicsImageRenderer로 레이어 합성

### 네비게이션
- `AppState.currentScreen: AppScreen` enum으로 상태 기반 전환
- NavigationStack 미사용 (키오스크 방식)

---

## UI/UX 원칙 (절대 변경 금지)

- 모든 탭 타겟: **최소 52pt** (40개월 유아 기준)
- 색상: 밝고 선명한 파스텔/원색 계열
- 텍스트: `.rounded` 디자인 폰트
- 방향 고정: **세로(Portrait)만** 지원
- 항상 **라이트 모드** 강제

---

## 코딩 컨벤션

- Swift 5.9, SwiftUI, async 없이 동기 패턴
- 주석: 최소화 (명확한 이름으로 대체)
- 새 캐릭터 추가: `ColoringPages/` 에 파일 추가 + `DragonPage.swift`의 `all` 배열에 포함
- 색상은 `Color(hex:)` 익스텐션 사용 (`ColoringPage.swift`에 정의됨)

---

## 다음 할 일 (MVP 이후)

- [ ] 색깔 이름 음성 안내 (`AVSpeechSynthesizer`)
- [ ] 완성도 100% 시 사진 앱 저장 (`UIImageWriteToSavedPhotosAlbum`)
- [ ] 배경 BGM 루프 (저작권 없는 .caf 음원)
- [ ] 스티커 붙이기 기능
- [ ] 캐릭터 추가 (5개 → 10개)
- [ ] iPad 지원 (가로 레이아웃 추가)

---

## 자주 쓰는 명령

```bash
# 브랜치 확인
git status

# 변경사항 커밋
git add -A && git commit -m "..." && git push
```

---

*마지막 업데이트: 2026-05-03*
