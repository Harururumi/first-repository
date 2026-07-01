# JARVIS v2 — 자가성장 엔진 + 범용 확장 요구사항

> 이 문서는 `JARVIS_REQUIREMENTS.md`(REQ-1~9)의 **후속 v2 계획**입니다.
> REQ-10~18을 정의하며, Iron Man의 JARVIS 수준(물리세계 제어 제외)에 가깝게
> "지속 학습/성장 + 범용화"를 목표로 합니다.

---

## 0. 새 세션(Personal-Agent) 이식 지침 — 먼저 읽을 것

이 저장소(`first-repository`)의 `jarvis-tagent/`는 원래 사용자의 실제 T-agent 프로젝트
(`Personal-Agent`)로 옮기기 위한 템플릿이다. 새 세션이 `Personal-Agent` + `first-repository`
두 저장소를 모두 스코프에 두고 시작되면 다음 순서로 진행한다:

1. **이식**: `first-repository/jarvis-tagent/`의 산출물(CLAUDE.md · 99-Meta/SOUL.md · `.claude/`
   [settings.json, rules, hooks, skills, agents] · scripts/stock-sources/ · 테스트 · 두 요구사항 문서)을
   `Personal-Agent` 루트 구조에 맞게 이식한다.
   - **기존 파일 덮어쓰기 금지** — 이미 있는 `CLAUDE.md`/`scripts`/`.claude`가 있으면 diff 병합.
   - **SHIELD 준수**: `40-Stocks/` 직접 편집 금지, `.env`·`.wiki-index.json` 미접근.
   - `JARVIS_REQUIREMENTS.md`의 "원본↔구현 reconciliation 표"대로 settings.json/vault-guard 조정
     (`uv run`, Advisory 예외 제거, 99-Attachments 추가, VAULT_PATH).
2. **v2 구축**: 이 문서(REQ-10~18)의 계획대로 이어서 구현. repo에서 테스트 가능한 것부터,
   Mac 전용(LoRA/DSPy/launchd/MCP 상시연결)은 템플릿+러너로.

---

## 1. 사용자 확정 결정 (v2 범위)

- **가중치 학습**: Claude 본체는 API라 온라인 가중치 학습 **불가**. 로컬 `qwen3` 대상
  **오프라인 LoRA 파인튜닝까지 실제로 구현**(야간/주간 배치, MLX-LM).
- **자기개선 자율성**: **위험도 기반** — 저위험 자동 / 고위험 Telegram 게이트.
- **확장 도메인**: 사실상 전부 — 범용 웹검색, 개인생산성(Gmail/Calendar/Drive),
  연구/논문(arXiv), 기술트렌드·커뮤니티·거시경제, 주식 확장(TipRanks 등),
  **AI 교육·영어 교육** 포함.

## 2. 왜 온라인 가중치 학습이 아니라 4축 성장인가

Claude 본체는 호스팅 API라 가중치 접근 불가 + 온라인(매턴) 업데이트는 catastrophic
forgetting/안전 회귀 위험. 따라서 "지속 성장"을 4축으로 근사하고, *진짜 weight learning*은
로컬 모델 배치 파인튜닝으로만 한정:
1. 기억 성장(Vault/SOUL) · 2. 스킬 성장(라이브러리) · 3. 하네스/프롬프트 성장(eval 기반 자동최적화)
· 4. 로컬 qwen3 오프라인 LoRA(야간/주간 — 유일한 가중치 학습).

## 3. 방법론 매핑 (세 기법이 어디 사는가)

| 기법 | 정의 | 구현 위치 |
|---|---|---|
| Loop engineering | sense→plan→act→**reflect** 반복 + 자율 주기 루프 | 태스크별 reflection + REQ-17-3 야간 자기개선 루프 + `/loop` |
| AI-DLC | 능력을 spec→build→**eval**→canary→promote→monitor로 관리 | REQ-17-2 골든셋/회귀, 17-5 스킬 버전·카나리, 17-6 모델 승격 게이트 |
| Harness engineering | 모델이 아닌 **스캐폴딩**(컨텍스트·검색·라우팅·가드레일)을 최적화 대상으로 | REQ-16 오케스트레이션 + REQ-17-4 프롬프트/하네스 자동최적화 |

---

## 4. 신규 REQ 그룹

### REQ-10. 범용 웹 검색 & 리서치
- `web-research` Skill + `web-researcher` Subagent(읽기전용). 도구: 내장 `WebSearch`/`WebFetch`
  + Tavily/Brave Search MCP, JS-heavy 사이트는 Playwright(MCP/사전설치 Chromium).
- 출력: 출처 인용 필수, 신뢰도 라벨, 모순 ⚠️. Vault 저장은 `synthesize` 경유.

### REQ-11. 멀티 도메인 소스 프레임워크 (stock-sources 일반화)
- `scripts/stock-sources/` → `scripts/sources/<domain>/<category>/<connector>.js`로 일반화.
  기존 `lib/{http,aggregate}.js`(Promise.allSettled·키없으면 skip·정규화) **재사용**.
- 도메인: `finance/`(기존+**TipRanks**·Polygon·FMP·AlphaVantage·Tiingo) · `web/`(Tavily/Brave)
  · `research/`(arXiv·Semantic Scholar·Papers with Code) · `tech/`(GitHub trending·HN·Reddit·Product Hunt)
  · `macro/`(FRED·ECOS·World Bank) · `personal/`(Gmail·Calendar·Drive MCP 래퍼) · `education/`(REQ-18)
- 집계기 `sources/index.js --domain <d> --query <q> [--write <path>]`.

### REQ-12. 선제적 행동 엔진 (proactive)
- launchd 모니터 + Telegram push. 트리거 규칙 `.claude/triggers/*.yaml`
  (보유종목 ±%·신규 공시·캘린더 임박·중요 메일·Inbox 적체). 알림=저위험(자동)/자동매매·외부발송=고위험(게이트).

### REQ-13. 멀티모달 인지
- `vision-analyze` Skill: 차트/스크린샷/문서 이미지 → Claude vision. 문서 텍스트는 macOS Vision/Tesseract OCR 보조. PDF는 Read(pages).

### REQ-14. 시뮬레이션 & 예측
- `simulate` Skill + `scripts/sim/`(Python 사이드카): 백테스트·몬테카를로·예측시장 칼리브레이션.
  결과는 스크립트로만 `40-Stocks/Advisory/` 또는 `20-Projects/`에 기록. "예측·자문 아님" 디스클레이머.

### REQ-15. 신원/접근 제어 + 감사 (자율성 안전벨트)
- `.claude/policy.yaml`: 행동을 **risk tier**로 분류.
  - 저위험(자동): 프롬프트 미세조정(범위 내)·인덱스 갱신·텔레메트리·eval 실행·초안 생성·읽기 조회
  - 고위험(게이트): 새 스킬 승격·도구/권한 부여·외부 발송·거래·LoRA 기본 승격·Vault 대량 삭제·`.env`
- 신원: Telegram chat_id 화이트리스트 + (옵션)음성 화자확인. 모든 자율 변경은 감사 원장(git 백업)·롤백 가능.

### REQ-16. 오케스트레이션 확장 (Harness)
- `orchestrator` Subagent: 복합 요청→태스크 그래프 분해→적합 Subagent 병렬 팬아웃→병합.
  컨텍스트 예산·검색 라우팅을 측정·튜닝(REQ-17-4 입력).

### REQ-17. ★ 자가성장 엔진 (핵심)
| 하위 | 내용 | tier |
|---|---|---|
| 17-1 텔레메트리 원장 | 세션의 성공/👎/에러/지연/도구실패 → `99-Meta/telemetry.jsonl` (PostToolUse/Stop Hook) | 자동 |
| 17-2 Eval 골든셋 (AI-DLC) | `evals/<capability>/*.yaml` 골든 케이스 + `node --test`/promptfoo 회귀 | 자동 |
| 17-3 야간 자기개선 루프 (Loop) | launchd `com.jarvis.growth` → 텔레메트리→eval→개선안→저위험 자동/고위험 staging+Telegram | 혼합 |
| 17-4 프롬프트/하네스 자동최적화 (Harness) | DSPy(파이썬)로 CLAUDE.md·스킬·라우팅 프롬프트를 eval 점수 기준 최적화, 저위험만 자동 머지 | 혼합 |
| 17-5 스킬 진화 | harvester v2(실제 반복 해결책→스킬 초안) + 버전/카나리/롤백. 승격은 고위험 게이트 | 게이트 |
| 17-6 로컬 LoRA 파인튜닝 | qwen3 대상. 데이터 큐레이션→MLX-LM LoRA→eval→**기본 승격은 게이트** | 게이트 |
| 17-7 성장 원장 | `99-Meta/Growth-Ledger.md`에 무엇·왜·언제 + 롤백 포인터 | 자동 |

### REQ-18. 교육 도메인 (AI 교육 · 영어 교육)
- `tutor-ai` / `tutor-english` Skill: 커리큘럼·간격반복(`30-Resources/Edu/`)·진척 추적·출제/채점.
  영어는 사전/문법 API(LanguageTool 등). 학습 기록은 텔레메트리에 합류→성장 루프가 난이도 자동 조절.

---

## 5. Phase 로드맵 (기존 0~6 이후)

| Phase | 목표 | 완료 기준 |
|---|---|---|
| 7 | 범용 검색 + 소스 일반화 (REQ-10,11) | `/web-research`, `sources --domain` 작동, 기존 stock 테스트 회귀 통과 |
| 8 | 선제 행동 + 신원/감사 (REQ-12,15) | 트리거→Telegram push, policy risk tier 적용, 감사 원장 |
| 9 | 멀티모달 + 시뮬레이션 (REQ-13,14) | 차트 이미지 해석, 백테스트 리포트 |
| 10 | 오케스트레이션 (REQ-16) | orchestrator 복합요청 분해·병렬 실행 |
| 11 | 자가성장 골격 (REQ-17-1·2·3·7) | 텔레메트리·골든셋 회귀·야간 루프 1회·성장 원장 |
| 12 | 하네스/스킬 진화 (REQ-17-4·5) | DSPy 최적화 1회·스킬 카나리·롤백 |
| 13 | 로컬 LoRA (REQ-17-6) | qwen3 LoRA→eval→게이트 승격 파이프라인 |
| 14 | 교육 도메인 (REQ-18) | AI/영어 튜터 + 간격반복 + 진척 추적 |

---

## 6. 필요 스킬 / 툴 / 플러그인 (Shopping List)

**Claude Code 내장**: WebSearch, WebFetch, Skills, Subagents, Hooks, `/loop`(야간 자율 루프),
Plan mode, Task 도구(오케스트레이션).

**MCP 서버**
- Gmail / Google Calendar / Google Drive (개인생산성)
- Playwright(브라우저, 사전설치 Chromium) — TipRanks/investing.com 등 JS 사이트
- Tavily 또는 Brave Search — 범용 웹검색
- (옵션) 벡터스토어 MCP(chroma/qdrant) — 장기 검색 강화

**외부 API/데이터**
- 주식: TipRanks·Polygon·FMP·AlphaVantage·Tiingo · 연구: arXiv·Semantic Scholar·Papers with Code
- 기술: GitHub API·HN Algolia·Reddit·Product Hunt · 거시: FRED·ECOS·World Bank
- 검색: Tavily/Brave/SerpAPI · 영어교육: LanguageTool/사전 API

**로컬 ML/평가 스택 (Python 사이드카 — 커넥터/오케스트레이션은 Node 유지)**
- Ollama(qwen3 서빙) · **MLX-LM**(Apple Silicon LoRA; Unsloth/axolotl은 CUDA 대안)
- promptfoo(JS eval 회귀) · DSPy(파이썬 프롬프트 자동최적화)
- (옵션) Langfuse/Phoenix 트레이싱 — 없으면 자체 JSONL 원장 + `node --test`

**멀티모달**: Claude vision(내장) · macOS Vision/Tesseract OCR
**시뮬레이션**: Python pandas/numpy, (옵션) vectorbt/backtrader

> 아키텍처: 데이터 커넥터·오케스트레이션·훅은 **Node**, 파인튜닝/DSPy/백테스트는
> **Python 사이드카**(`scripts/ml/`, `scripts/sim/`). 파일/CLI로 통신해 SHIELD(.env는 스크립트만) 유지.

---

## 7. SHIELD / 안전 추가
- `policy.yaml` risk tier가 자율 행동의 단일 관문. 고위험은 예외 없이 Telegram 게이트.
- LoRA 로컬 모델은 eval 골든셋 통과 + 사람 승인 전까지 **기본 모델 승격 금지**.
- 모든 자율 변경은 git 커밋 + 성장 원장 기록 → 1-커맨드 롤백.
- 외부 발송·거래·.env·40-Stocks 직접쓰기는 항상 고위험.
- 교육/금융 산출물에 "정보 제공·자문 아님" 디스클레이머.

## 8. 검증 방법
- repo 세션: 신규 Skill/Agent/스크립트 템플릿 + `scripts/sources/`·`evals/` **mock 단위테스트**,
  무키 소스(arXiv/HN/GitHub/Polymarket 등) 통합테스트(네트워크 차단 시 skip), 기존 stock 테스트 회귀.
  DSPy/LoRA/launchd/MCP 상시연결은 **맥에서만** — 템플릿+러너 제공.
- 맥: MCP(Gmail/Cal/Drive/Tavily/Playwright) 연결, `.env` 키, Ollama+MLX 설치,
  Phase 7~14 검증 순차 실행, 야간 루프 launchd 등록 후 1주 관찰.

## 9. 미해결/리스크
- LoRA 데이터 품질(라벨·누수)·평가 회귀 비용 — 골든셋 빈약하면 성장이 퇴행 가능.
- 개인 데이터(MCP 메일/드라이브) 접근 범위 — 최소권한·감사 필수.
- 다수 유료 API 비용 — 키 없으면 자동 skip 구조라 점진 도입.

---

## 10. 진행 상태 (이 문서 작성 시점)
- REQ-1~9: `first-repository/jarvis-tagent/`에 템플릿 구현 완료(단위테스트 14 통과).
- REQ-10~18: **계획 확정, 구현 착수 전.** 새 Personal-Agent 세션에서 위 이식 → Phase 7~14 순으로 구축.
