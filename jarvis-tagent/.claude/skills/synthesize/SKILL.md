---
name: synthesize
description: 여러 노트/concept에 흩어진 정보를 모아 하나의 종합 노트(요약/비교/타임라인 등)로 정리해 30-Resources/ 또는 10-Notes/에 새 파일로 생성한다. "/synthesize <주제>" 요청 시 사용.
context: fork
model: sonnet
allowed-tools: Read, Grep, Glob, Write
---

# synthesize

## 동작

1. 주제와 관련된 노트를 `wiki-researcher` Subagent를 통해 광범위하게 수집한다
2. 수집된 내용을 모순/시간순/카테고리별로 정리해 종합 노트 초안을 만든다
3. 출처(원본 노트 경로)를 모두 인용으로 남긴다
4. 결과를 `10-Notes/` 또는 `30-Resources/<카테고리>/`에 새 파일로 저장한다 (기존 노트를 덮어쓰지 않고 새 파일 생성)

## 하지 않는 일

- 기존 원본 노트를 수정하지 않는다 — 항상 새 종합 노트를 만든다
- `40-Stocks/`나 `.wiki-index.json`은 다루지 않는다
