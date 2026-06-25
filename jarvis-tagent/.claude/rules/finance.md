---
paths:
  - "40-Stocks/**"
  - "scripts/stock-sources/**"
---

# Finance / 주식 영역 규칙

- `40-Stocks/`는 라이브 데이터 전용이며 Claude가 직접 Edit/Write 하지 않는다 — 항상 `scripts/sync-stocks.js` 또는 `scripts/stock-sources/index.js --write`를 통해서만 기록된다
- `stock-advise` Skill의 출력(`40-Stocks/Advisory/<ticker>-<date>.md`)은 매수/매도 "추천"이며 투자자문이 아니다 — 모든 리포트 말미에 디스클레이머를 포함해야 한다
- `stock-analyst` Subagent는 대화 중 실시간 응답만 하며 Vault에 어떤 것도 기록하지 않는다 (Write/Edit 도구 없음)
- API 키가 없는 소스는 자동으로 skip하고, 있는 소스만 병합한다 — 키 누락을 에러로 취급하지 않는다
- `.env`의 키 값은 절대 읽거나 출력하지 않는다 — 스크립트가 `process.env`로 직접 읽는다
