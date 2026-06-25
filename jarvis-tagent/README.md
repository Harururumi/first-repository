# jarvis-tagent — T-agent용 Jarvis 템플릿

이 디렉토리는 사용자의 Mac에 있는 실제 T-agent(Obsidian Vault) 프로젝트 루트로 복사해 넣을 템플릿입니다.
이 원격 Claude Code 세션은 그 Mac 파일시스템에 접근할 수 없으므로, 결과물을 이 repo 안에 만들어 두었습니다.

## 사용 방법 (사용자가 본인 Mac에서 직접)

1. 이 디렉토리(`jarvis-tagent/`)의 내용을 T-agent 프로젝트 루트에 복사
   (기존 `CLAUDE.md`/`.claude/`가 있다면 병합 — 덮어쓰지 말고 diff 확인)
2. `scripts/stock-sources/`에서 `npm test` 실행 — 키 없이도 14개 단위 테스트 통과 확인
3. `npm run test:integration`으로 실제 외부 사이트 호출 검증 (이 원격 세션에서는 네트워크 정책상 전부 skip됨 — Mac에서는 실제 응답 확인 가능)
4. 필요한 API 키를 `.env`에 직접 입력 (`KIS_APP_KEY/SECRET/ACCOUNT_NO`, `ALPACA_API_KEY/SECRET`, `OPENDART_API_KEY`, `FINNHUB_API_KEY`, `KALSHI_API_KEY`, `ECOS_API_KEY`, `FRED_API_KEY`) — 키가 없는 소스는 자동 skip
5. `claude /status`, `/doctor`, `/hooks`로 Hook/Skill/Subagent 로드 확인
6. `/stock-advise <종목명>`으로 `40-Stocks/Advisory/`에 리포트 생성 확인
7. 대화 중 "오늘 삼성전자 사야해?" 같은 질문으로 `stock-analyst` Subagent 자동 호출 확인
8. Phase 4(스킬 학습 루프)·5(음성 인터페이스: whisper.cpp/Porcupine/launchd/Siri Shortcut)는 이 세션이 테스트할 수 없는 Mac 전용 작업입니다.

## 디렉토리 개요

- `CLAUDE.md` — SOUL/MIND/SHIELD 정의
- `99-Meta/SOUL.md` — 중기 기억(정체성/최근 결정)
- `.claude/settings.json` — Hook 등록
- `.claude/hooks/` — SessionStart/PreToolUse/PostToolUse/Stop Hook 스크립트
- `.claude/rules/` — 경로별 조건 규칙 (ai-dev, finance, inbox)
- `.claude/skills/` — 7개 기본 Skill + `stock-advise`
- `.claude/agents/` — 5개 Subagent (역할 분담은 각 파일의 frontmatter description 참조)
- `scripts/stock-sources/` — 주식 다중 소스 데이터 레이어 (`index.js` + 카테고리별 커넥터 + 테스트)
