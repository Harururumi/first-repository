---
paths:
  - "00-Inbox/**"
---

# Inbox 규칙

- `00-Inbox/`의 항목 분류는 `inbox-processor` Subagent가 담당한다 (제목 겹침 기반 병합 가능 여부 판단까지 포함)
- concept 페이지로의 **승격 결정**은 `inbox-processor`가 하지 않는다 — `inbox-processor`가 분류를 끝낸 뒤 `concept-merger` Subagent가 article/video 2개 이상 겹치는지 확인해 승격한다
- 승격 시 모순되는 내용이 발견되면 ⚠️ 표기로 남기고 임의로 삭제/병합하지 않는다
