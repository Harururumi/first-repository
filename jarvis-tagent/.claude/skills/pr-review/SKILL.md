---
name: pr-review
description: T-agent 코드(scripts/, .claude/)에 대한 변경사항(diff/PR)을 검토해 SHIELD 규칙 위반, 버그, 컨벤션 불일치를 보고한다. "/pr-review" 요청 시 또는 git diff가 있을 때 사용.
context: fork
model: sonnet
allowed-tools: Read, Grep, Glob, Bash(git diff:*), Bash(git log:*), Bash(git status:*)
---

# pr-review

## 동작

1. `git diff`로 변경된 파일을 확인한다 (코드 탐색이 더 필요하면 `codebase-explorer` Subagent에 위임)
2. 변경 사항이 SHIELD 규칙(40-Stocks 직접 쓰기, .env 접근, .wiki-index.json 직접 수정, AI 호출 Promise.all 병렬화, Obsidian 역방향 덮어쓰기)을 위반하는지 우선 검사한다
3. 일반적인 버그/네이밍/에러 처리 누락을 점검한다
4. 결과를 차단(blocking) 항목과 제안(suggestion) 항목으로 나눠 보고한다 — 파일을 직접 수정하지 않는다

## 하지 않는 일

- 코드를 직접 수정하지 않는다 (읽기 전용 + git 조회만)
- Vault 노트 내용은 검토 대상으로 다루지 않는다
