# 주요 설계 결정 기록

## 2026-05-03

### PencilKit undo 직접 관리
- **결정:** PencilKit의 built-in UndoManager를 쓰지 않고, `strokes.prefix(n)`으로 직접 관리
- **이유:** 구획 채우기 undo와 통합이 안 됨. 하나의 `undoStack`으로 두 방식을 통합하기 위해

### NavigationStack 미사용
- **결정:** `AppState.currentScreen` enum 기반 커스텀 네비게이션
- **이유:** 40개월 아이 대상 키오스크 앱 — 스와이프 백 방지, 전환 완전 통제

### 구획 Path 방식 (SVG 미사용)
- **결정:** Swift `PathSegment` enum으로 직접 정의 (SVG 파싱 없음)
- **이유:** 외부 SVG 파서 의존성 없이 순수 SwiftUI로 렌더링, 빌드 단순화

### 디즈니 IP 미사용
- **결정:** 완전 오리지널 캐릭터 (공주/왕자/요정/악당/용)
- **이유:** App Store 심사 통과, 저작권 리스크 제거
