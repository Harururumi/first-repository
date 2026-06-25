---
name: standup
description: 지난 24시간(또는 지정 기간)의 Vault 변경, Inbox 처리 현황, 진행 중인 20-Projects/ 항목을 모아 일일/주간 스탠드업 요약을 생성한다. "/standup" 요청 시 또는 SessionStart 브리핑 보강용으로 사용.
context: fork
model: haiku
allowed-tools: Read, Grep, Glob
---

# standup

## 동작

1. `99-Meta/Log.md`와 각 파일의 수정 시각을 확인해 지정 기간 내 변경 사항을 모은다
2. `00-Inbox/` 미처리 항목 수, `20-Projects/`의 활성 프로젝트 상태를 요약한다
3. 보유 종목 관련 변경이 있으면(`40-Stocks/` 수정 이력) 짧게 언급하되, 상세 분석은 `stock-analyst` Subagent나 `/stock-advise`로 안내한다
4. 짧은 불릿 형식으로 출력한다 (Vault에 저장하지 않음 — 1회성 요약)

## 하지 않는 일

- Vault 파일을 생성/수정하지 않는다
