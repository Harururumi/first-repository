---
paths:
  - "30-Resources/AI-Dev/**"
  - "scripts/**"
  - ".claude/**"
---

# AI-Dev / 코드 영역 규칙

- 이 경로의 파일을 다룰 때는 `codebase-explorer` Subagent를 우선 사용한다 (Vault 노트 분석과 분리)
- `scripts/stock-sources/` 내 커넥터를 수정할 때는 해당 사이트의 스크래핑 정책(robots.txt/ToS)을 존중하고, 캐싱 없이 과도한 빈도로 호출하는 코드를 추가하지 않는다
- 새 connector 파일은 항상 `<category>/<name>.js` 단위로 독립시켜, 한 사이트의 구조 변경이 다른 커넥터에 영향을 주지 않게 한다
