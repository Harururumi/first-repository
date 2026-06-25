---
name: wiki-ingest
description: 00-Inbox/의 미분류 항목(Telegram/Notion/YouTube 등에서 수집된 원본)을 읽고 분류해 적절한 Vault 위치로 이동시킨다. "/wiki-ingest" 또는 "Inbox 처리해줘" 요청 시 사용.
context: fork
model: sonnet
allowed-tools: Read, Grep, Glob, Write, Edit, Bash(node scripts/wiki-index.js:*)
---

# wiki-ingest

## 동작

1. `00-Inbox/`의 모든 미처리 파일을 나열한다 (이미 처리된 항목은 frontmatter `status: processed`로 표시되어 있으므로 제외)
2. 각 항목을 `inbox-processor` Subagent에 위임해 분류 결과(병합 가능 여부 포함)를 받는다
3. 분류 결과에 따라 `10-Notes/` 또는 `30-Resources/<카테고리>/`로 이동시키고 frontmatter에 `status: processed`, `processed-at`을 기록한다
4. article/video 타입이 2개 이상 겹치는 제목이 발견되면 `concept-merger` Subagent를 호출해 concept 승격을 맡긴다 (이 Skill이 직접 승격하지 않음)
5. 마지막으로 `node scripts/wiki-index.js --incremental`을 실행해 인덱스를 갱신한다

## 하지 않는 일

- concept 승격 로직을 직접 구현하지 않는다 (concept-merger 책임)
- `.wiki-index.json`을 직접 수정하지 않는다 (wiki-index.js 스크립트만 수정 가능 — SHIELD 규칙)
