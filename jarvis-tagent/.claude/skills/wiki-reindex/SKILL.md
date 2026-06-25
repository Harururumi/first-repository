---
name: wiki-reindex
description: Vault 전체를 처음부터 다시 스캔해 .wiki-index.json을 완전히 재생성한다 (update-index.sh의 incremental 갱신과 달리 풀 리빌드). "/wiki-reindex" 또는 인덱스가 깨졌을 때 사용.
context: fork
model: haiku
allowed-tools: Read, Glob, Bash(node scripts/wiki-reindex.js:*)
---

# wiki-reindex

## 동작

1. `node scripts/wiki-reindex.js --full`을 실행해 Vault 전체를 재스캔하고 `.wiki-index.json`을 재생성한다
2. 실행 전후 파일 개수를 비교해 큰 폭으로 줄어들면(데이터 손실 의심) 경고하고 덮어쓰기 전에 확인을 받는다
3. 완료 후 인덱싱된 노트/리소스/concept 개수를 요약 보고한다

## 하지 않는 일

- `.wiki-index.json`을 Claude가 직접 Write/Edit 하지 않는다 — 항상 `wiki-reindex.js` 스크립트를 통해서만 갱신한다 (SHIELD 규칙)
