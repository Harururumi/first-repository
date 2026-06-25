---
name: query
description: 자연어 질문을 받아 Vault(.wiki-index.json + 노트 본문)를 검색해 답을 생성한다. "/query <질문>" 요청 시 사용. 단순 검색은 직접 수행하고, 깊은 탐색이 필요하면 wiki-researcher Subagent에 위임한다.
context: fork
model: sonnet
allowed-tools: Read, Grep, Glob
---

# query

## 동작

1. `.wiki-index.json`을 읽어 질문과 관련된 후보 노트/concept를 찾는다
2. 후보가 적고 명확하면 직접 읽고 답한다
3. 후보가 모호하거나 깊은 맥락 조사가 필요하면 `wiki-researcher` Subagent를 호출해 초안을 받아 종합한다
4. 답변에는 근거가 된 노트 경로를 함께 표시한다

## 하지 않는 일

- Vault 파일을 수정하지 않는다 (읽기 전용)
- 코드(`scripts/`, `.claude/`) 탐색은 하지 않는다 — 그건 `codebase-explorer` Subagent 책임이며, 코드 관련 질문이면 그쪽으로 위임한다
