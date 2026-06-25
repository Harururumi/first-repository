---
name: wiki-lint
description: Vault 전체(또는 지정 경로)의 노트가 frontmatter 스키마, 링크 무결성, 중복 제목 규칙을 지키는지 검사하고 위반 목록을 보고한다. "/wiki-lint" 요청 시 사용.
context: fork
model: haiku
allowed-tools: Read, Grep, Glob
---

# wiki-lint

## 동작

1. `10-Notes/`, `30-Resources/`, `20-Projects/`의 모든 `.md` 파일을 스캔한다
2. 각 파일의 frontmatter에 필수 필드(`type`, `created`, `tags`)가 있는지 확인한다
3. `[[wiki-link]]` 형식의 내부 링크가 실제 존재하는 파일을 가리키는지 검사한다 (깨진 링크 목록 생성)
4. 같은 제목을 가진 파일이 승격 규칙(2개 이상 겹치면 concept) 없이 방치되어 있는지 확인한다
5. 위반 사항을 카테고리별로 정리해 보고만 한다 — 자동 수정하지 않는다

## 하지 않는 일

- 파일을 직접 수정하지 않는다 (읽기 전용 — Write/Edit 도구 없음)
- 발견한 문제의 수정은 사람 또는 별도 후속 작업으로 넘긴다
