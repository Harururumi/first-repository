# 새 기능 추가 템플릿

## 기능 이름
[기능 이름]

## 목적
[이 기능이 왜 필요한가]

## 구현 위치
- View: `Views/[화면]/[파일].swift`
- ViewModel: `ViewModels/[파일].swift`
- Service: `Services/[파일].swift` (필요시)

## 체크리스트
- [ ] 40개월 유아 UX 원칙 준수 (탭 52pt+)
- [ ] 한국어/영어 이중 표시
- [ ] 사운드 피드백 (`SoundService.shared.play(...)`)
- [ ] 저장/불러오기 필요 시 `StorageService` 활용
- [ ] `CLAUDE.md`의 "다음 할 일" 업데이트
