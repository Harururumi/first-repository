# JARVIS — System Requirements & Implementation Plan (통합 업데이트판)

> T-agent + LLM Wiki + Claude Code + Hermes Concepts + Voice + **주식 다중 소스 분석**
> 원본 작성일: 2026-06-29 / 통합 갱신: 2026-06-29
>
> 이 문서는 원본 `JARVIS_REQUIREMENTS.md`(= `JARVIS_REQUIREMENTS_1.md`, 두 파일 동일)에
> 이번 세션에서 추가 설계·구현한 주식 분석 항목(REQ-4-8, REQ-5-5, REQ-9)과
> **현재 구현 상태**, **원본 ↔ 구현 reconciliation**을 합친 단일 소스입니다.
> 실제 산출물은 이 repo의 `jarvis-tagent/` 디렉토리에 템플릿으로 존재하며,
> 사용자의 맥 T-agent 프로젝트 루트로 복사해 사용합니다.

---

## 전체 아키텍처

```
┌──────────────────────────────────────────────────────────────────┐
│                      INPUT LAYER (입력)                          │
│  [맥 터미널]  Claude Code CLI (타이핑)                            │
│  [맥 음성]    Wake word "Hey Jarvis" → whisper.cpp (로컬 STT)    │
│  [iPhone]     Telegram 앱 (채팅)                                 │
│  [iPhone]     Siri Shortcut → 받아쓰기 → Telegram 봇            │
└───────────────────────────┬──────────────────────────────────────┘
                            │
┌───────────────────────────▼──────────────────────────────────────┐
│                   BRAIN LAYER (두뇌) = Claude Code               │
│    CLAUDE.md ── Jarvis SOUL + T-agent 구조 전체 인지             │
│    Rules ─────  볼트 폴더별 규칙 (ai-dev / finance / inbox)       │
│    Skills ────  wiki-ingest / query / synthesize / standup /     │
│                 wiki-lint / wiki-reindex / pr-review /           │
│                 ★ stock-advise                                   │
│    Hooks ─────  SessionStart 브리핑 / Vault 보호 / 스킬 수확     │
│    Subagents ─  wiki-researcher / inbox-processor /              │
│                 concept-merger / codebase-explorer /             │
│                 ★ stock-analyst                                  │
└───────────────────────────┬──────────────────────────────────────┘
                            │
┌───────────────────────────▼──────────────────────────────────────┐
│                   MEMORY LAYER (장기 메모리) = Obsidian Vault    │
│    00-Inbox / 10-Notes / 20-Projects / 30-Resources              │
│    40-Stocks (라이브 데이터, 직접 편집 금지)                     │
│      └─ ★ Advisory/  (stock-advise 리포트, 스크립트로만 기록)    │
│    LLM Wiki 파이프라인 (RAW→INGEST→WIKI→QUERY→LINT)             │
│    wiki-index.json (시맨틱 임베딩, nomic-embed-text)             │
│    99-Meta/Log.md / Index.md / SOUL.md                          │
│    ★ scripts/stock-sources/  (다중 소스 데이터 레이어, REQ-9)    │
└───────────────────────────┬──────────────────────────────────────┘
                            │
┌───────────────────────────▼──────────────────────────────────────┐
│                   OUTPUT LAYER (출력)                            │
│  터미널 텍스트 / Telegram 텍스트·음성(ogg) /                     │
│  맥 TTS (say -v Yuna / ElevenLabs) / iPhone Siri 읽어주기        │
└──────────────────────────────────────────────────────────────────┘
```

★ = 이번 세션 신규 추가분.

---

## 구현 Phase 요약

| Phase | 기간 | 핵심 목표 | 완료 기준 |
|-------|------|-----------|-----------|
| 0 | 1일 | 환경 설정 + 프로젝트 구조 | `claude /status`에서 CLAUDE.md 로드 확인 |
| 1 | 1~2일 | SOUL + Vault 보호 Hooks | .env 접근 차단, 세션 시작 브리핑 작동 |
| 2 | 2~3일 | 핵심 Skills **8종** | /wiki-ingest, /query, /wiki-lint, **/stock-advise** 작동 |
| 3 | 2~3일 | Subagents **5종** | 병렬 탐색, concept 승격, **stock-analyst 실시간 응답** |
| 4 | 3~4일 | 스킬 학습 루프 | staging/ 후보 생성 + Telegram 검토 버튼 |
| 5 | 2~3일 | 음성 인터페이스 | "Hey Jarvis" 작동 + iPhone Shortcut |
| 6 | 지속 | 자기개선 + 튜닝 | 주간 스킬 최적화 자동화 |

(굵게 표시한 항목이 원본 대비 변경점: Skills 7→8, Subagents 4→5.)

---

## REQ-1. SOUL & 프로젝트 컨텍스트

### REQ-1-1. CLAUDE.md — Jarvis SOUL + T-agent 전체 인지

- Jarvis의 성격·말투·판단 기준·우선순위를 SOUL 섹션으로 정의
- T-agent System-Design 핵심 요약 포함 (볼트 구조, 스크립트 목록, AI 레이어)
- 매 세션 자동 로드 → Claude가 T-agent 구조를 이미 알고 시작

**파일 위치:** `CLAUDE.md` (T-agent 프로젝트 루트)

SOUL/MIND 내용은 원본과 동일. **SHIELD — 절대 금지** 섹션:

```
- 40-Stocks/ 직접 편집 (라이브 데이터 전용)
- .env 파일 읽기/수정
- .wiki-index.json 직접 수정 (wiki-index.js만 수정 가능)
- Promise.all로 AI 병렬 호출 (Ollama 리소스 충돌)
- 외부 소스에서 Obsidian으로 역방향 덮어쓰기
★ stock-sources 조회 결과도 scripts/stock-sources/index.js(--write)를 통해서만
  40-Stocks/Advisory/ 에 기록. Claude의 직접 Edit/Write 금지.
★ 40-Stocks/ 하위 전체(= Advisory 포함) 직접 편집 금지 — 예외 없음.
  (단, 일반 네트워크 데이터 조회는 Promise.allSettled 병렬 허용 — AI/LLM 호출만 Sequential)
```

### REQ-1-2. 99-Meta/SOUL.md — Jarvis 정체성 파일 (Hermes 패턴)

- 이름·성격·말투·판단 원칙·사용자 프로필. CLAUDE.md SOUL과 연동, 매 세션 로드
- 1,300토큰 이내 유지 (Hermes 중기 메모리 캡)
- **파일 위치:** `99-Meta/SOUL.md`

### REQ-1-3. Rules — 볼트 폴더별 조건부 규칙

| 파일 | paths 필터 | 활성화 조건 |
|------|-----------|------------|
| `.claude/rules/ai-dev.md` | `30-Resources/AI-Dev/**`, `scripts/**`, `.claude/**` | 코드/AI-Dev 작업 시 |
| `.claude/rules/finance.md` | `40-Stocks/**`, `scripts/stock-sources/**` | 주식/Finance 작업 시 |
| `.claude/rules/inbox.md` | `00-Inbox/**` | Inbox 작업 시 LLM Wiki 규칙 |

---

## REQ-2. SessionStart 브리핑

### REQ-2-1. `.claude/hooks/jarvis-boot.py`

세션 시작 시 자동 실행, `additionalContext`로 다음 주입:
Inbox 파일 수(≥10 🟡), Daily Brief 갱신 시각, wiki-index 나이(>24h ⚠️),
최근 7일 신규 노트 수, 처리 대기 concept 후보 수, SOUL.md 내용.

(구현 상태: 현재 템플릿은 SOUL.md 로드 + Inbox 카운트만 구현 — index 나이/주간 신규/concept 후보는 보강 권고. 아래 구현 상태 표 참조.)

---

## REQ-3. Vault 보호 Hooks

### REQ-3-1. `.claude/hooks/vault-guard.sh` (PreToolUse)

차단 대상: `40-Stocks/`(Advisory 포함), `.env`, `.wiki-index.json`, `99-Attachments/`.
일치 시 `exit 2` + stderr 메시지로 도구 호출 차단.
- matcher: `Edit|Write|MultiEdit` (원본은 `Edit|Write|Read` + Bash 위험명령 가드 — reconciliation 표 참조)

### REQ-3-2. `.claude/hooks/inbox-trigger.sh` (PostToolUse)

`00-Inbox/`에 Write/Edit 발생 시 `/wiki-ingest` 권장 알림.

### REQ-3-3. `.claude/hooks/update-index.sh` (Stop)

세션 종료 시 `node scripts/wiki-index.js --incremental` 증분 갱신.

### `.claude/settings.json`

SessionStart(jarvis-boot) / PreToolUse(vault-guard) / PostToolUse(inbox-trigger) /
Stop(update-index + skill-harvester) 등록. stock 관련 신규 Hook 없음 — Skill/Subagent만 추가.

---

## REQ-4. Skills (`.claude/skills/<이름>/SKILL.md`)

원본 7종 + 신규 1종 = **8종**.

| # | 이름 | 목적 | model | 비고 |
|---|------|------|-------|------|
| 4-1 | wiki-ingest | Inbox raw → 기존 노트 병합·갱신 (이동 아닌 병합) | sonnet | concept 승격은 concept-merger에 위임 |
| 4-2 | wiki-lint | 볼트 건강검사(고아/방치/빈 노트/모순) | haiku | 읽기 전용 |
| 4-3 | wiki-reindex | `99-Meta/Index.md` 풀 재생성 | haiku | wiki-reindex.js 호출 |
| 4-4 | query | 볼트 하이브리드 검색 + AI 합성 | sonnet | 깊은 탐색은 wiki-researcher 위임 |
| 4-5 | synthesize | 관련 노트 수집 → concept 노트 신규 생성 | sonnet | sources frontmatter 기록 |
| 4-6 | standup | git 로그 기반 스탠드업 | haiku | Keep/Problem/Try |
| 4-7 | pr-review | 변경/PR 리뷰 (SHIELD 위반 우선 점검) | sonnet | 읽기+git only |
| **4-8** | **stock-advise ★** | **종목 다중 소스 분석 → Advisory 리포트** | **sonnet** | **아래 상세** |

### ★ REQ-4-8. stock-advise

- 위치: `.claude/skills/stock-advise/SKILL.md`
- 동작:
  1. `node scripts/stock-sources/index.js --ticker <종목> --write` 실행
     → 스크립트가 카테고리별 소스를 `Promise.allSettled`로 병렬 조회·정규화하고,
       **스크립트가 직접** `40-Stocks/Advisory/<ticker>-<date>.md`에 원본 데이터 기록
       (Claude는 이 경로에 직접 Edit/Write 하지 않음 — SHIELD)
  2. Claude는 그 리포트를 Read로 읽고 → 매수/매도/보유 추천 + 확신도(낮음/중간/높음) + 리스크
  3. 응답 말미 디스클레이머 필수: "이 분석은 정보 제공 목적이며 투자자문이 아닙니다."
- frontmatter: `context: fork`, `model: sonnet`,
  `allowed-tools: Read, Bash(node scripts/stock-sources/index.js:*)`
- 키 없는 소스 자동 skip. `.env`는 스크립트가 `process.env`로만 접근(Claude/Skill은 .env 미접근).

---

## REQ-5. Subagents (`.claude/agents/<이름>.md`)

원본 4종 + 신규 1종 = **5종**. 이름이 비슷한 것은 "대상(노트/코드)"·"단계(분류/승격)"로 경계를 가른다.

### 업무 분할 표 (책임 경계 명확화)

| Subagent | 트리거 키워드 | tools | model/effort/maxTurns | 책임 범위 | 하지 않는 일 (경계) |
|---|---|---|---|---|---|
| wiki-researcher | 연구/분석/탐색 | Read Grep Glob | sonnet/high/30 | 10-Notes·30-Resources 심층 탐색 → concept 초안 반환 | Vault 쓰기X(Write/Edit 없음), 코드 안봄 |
| inbox-processor | 처리/ingest | Read Grep Glob Write Edit | haiku/medium/40 | 00-Inbox 일괄 분류(병합 가능 여부 판단) | concept **승격 결정**X (concept-merger 책임) |
| concept-merger | 승격/병합/merge | Read Grep Glob Write Edit | sonnet/high/25 | article/video 2개+ 겹치면 concept 승격 + sources 갱신 + 모순 ⚠️ | 신규 Inbox **분류**X (inbox-processor 선행 후 동작) |
| codebase-explorer | 탐색/어디에/find/where is | Read Grep Glob | haiku/medium/40 | scripts·.claude **코드** 탐색(심볼/의존성/위치), thoroughness 지원 | Obsidian 노트 **내용** 분석X (wiki-researcher 책임), 수정X |
| **stock-analyst ★** | 주식/매수/매도/포트폴리오 | Read Grep Glob Bash | sonnet/high | scripts/stock-sources 호출 → **대화 한정 실시간** 매수/매도 의견 | 40-Stocks 쓰기X(Write/Edit 없음), **영구 리포트 저장**X (stock-advise 책임) |

겹치는 요청(예: "AI 노트 찾으면서 관련 코드도")은 두 Subagent를 **병렬 동시 호출**해 합치는 것을 기본 패턴으로 한다 (Phase 3 "병렬 팬아웃" 검증이 이를 확인).

### ★ REQ-5-5. stock-analyst

- 위치: `.claude/agents/stock-analyst.md`
- 대화 중 즉흥 질문("오늘 삼성전자 사야해?")에 `scripts/stock-sources/`를 `--no-write`(읽기 전용)로 호출 → 즉답
- `tools: Read Grep Glob Bash` (Write/Edit 없음 → 40-Stocks 원천 차단), `model: sonnet`, `effort: high`
- Bash는 `node scripts/stock-sources/...` 실행에만 사용. Vault에 아무것도 영구 저장하지 않음 → 영구 리포트 필요 시 `/stock-advise` 안내. `.env` 키 값 미출력.

---

## REQ-6. 스킬 학습 루프 (Hermes 개념의 Claude Code화)

- **6-1** `.claude/hooks/skill-harvester.py` (Stop Hook): 반복 패턴 감지 → `.claude/skills/staging/<이름>.md` 후보 저장 (자동 승격 없음, 사람 게이트)
- **6-2** Telegram `스킬검토` 커맨드(sync-telegram.js): staging 목록 + [승인][수정][거절] 인라인 버튼 → 승인 시 `skills/`로 이동
- **6-3** 주간 스킬 자기개선(launchd 월요일): 실행 로그 평가 → `staging/<이름>-v2.md` 제안

(구현 상태: harvester는 tool_name 빈도 기반 stub로 staging 후보까지만 생성. Telegram 연동·자동 승격·주간 최적화는 맥의 sync-telegram.js/launchd 작업.)

---

## REQ-7. 음성 인터페이스 (⏳ 맥 전용 — 이 세션에서 실행/테스트 불가)

- **7-1** 맥 Wake Word `jarvis-listener.py`: Porcupine "Hey Jarvis" → SOX 녹음(침묵 2초) → whisper.cpp STT → 길이 라우팅(30자↓ Telegram / 30자↑ Claude Code CLI) → macOS `say -v Yuna` TTS. launchd `com.jarvis.listener` 상시.
  - 필요: `brew install whisper-cpp sox`, `pip install pvporcupine`
  - TTS 우선순위: ElevenLabs API → `say -v Yuna` 무료 fallback
- **7-2** iPhone Siri Shortcut: 받아쓰기 → `🎙️ [음성]` 접두사 + Telegram sendMessage POST → 3초 대기 → getUpdates → Siri가 응답 읽기
- **7-3** sync-telegram.js 음성 분기: `🎙️` 접두사 감지 → `textToSpeech`(ElevenLabs→say fallback) → `sendVoice`

---

## REQ-8. 자기개선 메모리 시스템

- **8-1** 3단계 메모리: 단기(세션 컨텍스트) / 중기(`99-Meta/SOUL.md` ≤1300토큰, 주간) / 장기(Vault 전체, 자동 수집). SessionStart Hook이 중기 메모리 주입.
- **8-2** 피드백 루프: Telegram 응답에 [👍][👎] → 👎 시 사유 질문 → `SOUL.md` 누적 → 월간 리포트

---

## ★ REQ-9. scripts/stock-sources — 주식 다중 소스 데이터 레이어 (신규)

stock-advise Skill과 stock-analyst Subagent가 공통으로 호출하는 데이터 레이어.

### 디렉토리

```
scripts/stock-sources/
├── index.js                 # CLI(--ticker/--write/--no-write) + 카테고리 병렬 조회 + 정규화 + Advisory 기록
├── lib/{http.js,aggregate.js}
├── quotes/      kis.js alpaca.js krx.js naver.js daum.js investingCom.js yahoo.js
├── filings/     openDart.js secEdgar.js
├── news/        naverNews.js rss.js finnhub.js investingComNews.js marketWatch.js seekingAlpha.js
├── sentiment/   reddit.js stocktwits.js hackernews.js naverDiscussion.js daumDiscussion.js
├── predictionMarkets/  polymarket.js kalshi.js
├── macro/       ecos.js fred.js
└── test/        aggregate / connectors / index / integration .test.js
```

### 소스 / 인증

| 카테고리 | 소스 | 인증 |
|---|---|---|
| 시세 KR | 한국투자증권 KIS, 한국거래소 KRX, 네이버, 다음 | KIS만 키 |
| 시세 US | Alpaca, Yahoo Finance | Alpaca만 키 |
| 시세 글로벌 | investing.com | 불필요(스크래핑) |
| 공시 | OpenDART(KR, 키), SEC EDGAR(US, 불필요) | |
| 뉴스 | 네이버뉴스 / 한국경제·매일경제 RSS / investing.com / MarketWatch / Seeking Alpha (불필요), Finnhub (키) | |
| 커뮤니티 감성 | Reddit / Stocktwits / Hacker News / 네이버·다음 종목토론방 (전부 불필요) | |
| 예측시장 | Polymarket Gamma (불필요), Kalshi (키) | |
| 매크로 | 한국은행 ECOS (키), FRED (키) | |

### 집계 규칙

- 카테고리별 `runCategory()`가 활성 커넥터를 `Promise.allSettled`로 병렬 조회
- 정규화 출력: `{source, data, fetchedAt}` | `{source, error, fetchedAt}` | `{source, skipped, reason}`
- API 키 없는 커넥터(`isEnabled()===false`)는 **skip**(에러 아님). `isEnabled()` 예외도 skip 처리
- `index.js --write`만 `40-Stocks/Advisory/<ticker>-<date>.md` 기록 (이 경로만 40-Stocks 쓰기 허용 코드 경로)
- `--no-write`는 stdout JSON만 (stock-analyst의 비영구 조회용)
- 스크래핑 소스(네이버/다음/investing.com/MarketWatch/Seeking Alpha)는 개인 사용·적정 빈도·캐싱 전제,
  커넥터를 `<category>/<name>.js` 단위로 격리 → 사이트 구조 변경 시 해당 모듈만 깨짐
- `.env` 키는 각 커넥터가 `process.env`로 직접 읽음 (Claude/Skill 프롬프트는 .env 미접근)

### 테스트

- 단위(`aggregate/connectors/index .test.js`): `t.mock.method(globalThis,'fetch')`로 mock — 정규화·skip·에러·--write 경로. **현재 14개 통과**
- 통합(`integration.test.js`): 무키 소스(SEC EDGAR/Yahoo/HN/Polymarket 등) 실호출, 네트워크 차단 시 `t.skip` (이 원격 세션에선 정책상 전부 skip → 맥에서 실 신호 확인)
- 실행: `npm test` / `npm run test:integration`

---

## 구현 상태 매핑 (이 repo `jarvis-tagent/`)

| REQ | 상태 | 비고 |
|---|---|---|
| 1-1 / 1-2 / 1-3 | ✅ 템플릿 | SHIELD에 stock 1줄 포함 |
| 2-1 jarvis-boot.py | ✅(간소화) 🔧 | SOUL 로드+Inbox 카운트만 — index 나이/주간 신규/concept 후보 보강 권고 |
| 3-1 vault-guard.sh | ✅ 🔧 | 현재 Advisory 예외 허용 → SHIELD와 상충, **예외 제거 권고** |
| 3-2 / 3-3 | ✅ 템플릿 | |
| settings.json | ✅ 🔧 | python3/matcher 차이 (reconciliation 표) |
| 4-1~4-7 Skills | ✅ 템플릿 | |
| 4-8 stock-advise ★ | ✅ 템플릿 | |
| 5-1~5-4 Subagents | ✅ 템플릿 | |
| 5-5 stock-analyst ★ | ✅ 템플릿 | |
| 6 스킬 학습(harvester) | ✅(초안) 🔧 | tool_name 빈도 stub, Telegram 알림·자동 승격 미연동 |
| 7 음성 / launchd / Telegram 분기 | ⏳ 맥 전용 | 이 세션 실행·테스트 불가 |
| 8 메모리 / 피드백 | ⏳ 부분 | SOUL.md 틀만, 👍👎 루프는 sync-telegram.js 필요 |
| 9 stock-sources ★ | ✅ 구현+테스트 | 단위 14 통과, 통합은 맥에서 |

---

## 원본 ↔ 구현 reconciliation (맥 적용 시 조정)

| 항목 | 원본 스펙 | 현재 구현 템플릿 | 권고 |
|---|---|---|---|
| py 훅 실행 | `uv run` | `python3` | 맥에 uv 있으면 `uv run`(의존성 격리) |
| PreToolUse matcher | `Edit\|Write\|Read` (+ Bash 위험명령 가드) | `Edit\|Write\|MultiEdit` | Read 차단·Bash 가드 추가 검토 |
| 차단 경로 | 40-Stocks / .env / .wiki-index.json / 99-Attachments | + Advisory 예외 허용 | 99-Attachments 추가, **Advisory 예외 제거**(SHIELD 일치) |
| PostToolUse | `if: Write(00-Inbox/*)` | matcher + 스크립트 내부 필터 | 동작 동일, 원본 `if` 방식으로 통일 가능 |
| VAULT 경로 | `VAULT_PATH` env | `CLAUDE_PROJECT_DIR` | 맥 `.env`에 `VAULT_PATH` 설정 후 통일 |

> 참고: vault-guard의 Advisory 예외를 제거해도 stock-advise는 정상 동작한다 —
> 리포트는 Claude의 Edit/Write가 아니라 `index.js`의 Node `fs.writeFileSync`가 기록하므로
> PreToolUse Hook(도구 호출 가로채기) 대상이 아니다. 예외는 오히려 SHIELD 우회 통로가 되므로 닫는 게 안전.

---

## 비용 구조

| 컴포넌트 | 방식 | 월 비용 |
|---------|------|--------|
| Claude Code (Max 구독, 메인 두뇌) | 구독 | $100 |
| Gemini 2.0 Flash (무료 티어, 1,500 req/day) | 무료 | $0 |
| Ollama qwen3:14b (fallback) / whisper.cpp(STT) / Porcupine(wake) / macOS say(TTS) | 로컬·무료 | $0 |
| ElevenLabs (선택, 고품질 TTS) | API | $5 |
| 주식 데이터 소스(무키 소스 다수) | 무료/스크래핑 | $0 (유료 API 키는 사용자 선택) |

---

## launchd 전체 스케줄 (기존 + 추가)

| 에이전트 | 시간 | 스크립트 | 상태 |
|---------|------|---------|------|
| notion-sync / youtube-sync / telegram-cmd / telegram-sync / stocks-sync / dart-monitor / wiki-index / weekly-report / notion-vision | (원본 유지) | 기존 스크립트 | ✅ 기존 |
| `com.jarvis.listener` | 상시(KeepAlive) | jarvis-listener.py | 🆕 Phase 5 |
| `com.jarvis.skill-optimizer` | 매주 월 11:00 | skill-optimizer.py | 🆕 Phase 6 |

(주식 조회는 대화/Skill 트리거 기반이므로 별도 launchd 불필요. 정기 리포트가 필요하면
`com.jarvis.stock-advise`를 추가해 `index.js --ticker <보유종목> --write`를 일 1회 돌릴 수 있음.)

---

## 검증 방법

**이 repo 세션:** 템플릿 작성 완료 + `scripts/stock-sources` 단위 14개 통과. 이 문서 커밋·푸시.

**사용자 맥(직접):**
1. `jarvis-tagent/` 내용을 실제 T-agent 루트로 복사(기존 파일은 diff 병합)
2. reconciliation 표대로 `settings.json`·`vault-guard.sh` 조정 (`uv run`, Advisory 예외 제거, 99-Attachments 추가, VAULT_PATH)
3. Phase 0~6 검증 커맨드: `/status` `/doctor` `/hooks` `/wiki-ingest` `/query` `/wiki-lint` `/standup` `/stock-advise <종목>`, 병렬 팬아웃, stock-analyst 즉답
4. `.env`에 필요한 키 입력(KIS/Alpaca/OpenDART/Finnhub/Kalshi/ECOS/FRED — 없으면 자동 skip)
5. 음성 스택(whisper.cpp/Porcupine/SOX/launchd/Siri Shortcut) 설치·연결
6. Telegram `스킬검토`·👍👎 피드백 연동(sync-telegram.js)
