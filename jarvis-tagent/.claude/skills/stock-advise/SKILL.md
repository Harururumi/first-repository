---
name: stock-advise
description: 종목명/티커(또는 "포트폴리오 전체 점검")를 입력받아 시세/공시/뉴스/커뮤니티 감성/예측시장/매크로 지표를 다중 소스에서 모아 매수/매도/보유 추천 리포트를 40-Stocks/Advisory/에 영구 기록한다. "/stock-advise <종목>" 요청 시 사용. 대화 중 1회성 질문은 이 Skill이 아니라 stock-analyst Subagent가 처리한다.
context: fork
model: sonnet
allowed-tools: Read, Bash(node scripts/stock-sources/index.js:*)
---

# stock-advise

## 동작

1. `node scripts/stock-sources/index.js --ticker <종목/티커> --write`를 실행한다
   - 스크립트가 quotes/filings/news/sentiment/predictionMarkets/macro 카테고리별 소스를 `Promise.allSettled`로 병렬 조회하고 정규화한다
   - API 키가 없는 소스는 자동 skip — 에러로 취급하지 않는다
   - `--write` 플래그가 있으면 스크립트가 직접 `40-Stocks/Advisory/<ticker>-<date>.md`에 원본 데이터를 기록한다 (Claude는 절대 이 경로에 직접 Edit/Write 하지 않음 — SHIELD 규칙)
2. 스크립트가 기록한 `40-Stocks/Advisory/<ticker>-<date>.md`를 Read로 읽는다
3. 읽은 데이터를 근거로 다음을 종합해 같은 파일 하단에 "## 분석" 섹션을 추가 요청하는 대신, 새로 받은 분석 텍스트를 사용자에게 직접 응답으로 전달한다 (Vault 파일에 분석 텍스트를 추가로 쓰려면 다시 `index.js --append-analysis`를 통해서만 — 직접 Edit 금지):
   - 매수/매도/보유 중 하나의 추천
   - 확신도(낮음/중간/높음)와 그 근거 (어떤 소스가 일치/상충하는지)
   - 리스크 요인
4. 응답 말미에 항상 다음 디스클레이머를 포함한다: "이 분석은 정보 제공 목적이며 투자자문이 아닙니다. 투자 결정과 책임은 본인에게 있습니다."

## 데이터 소스 (scripts/stock-sources/ 참조)

| 카테고리 | 소스 |
|---|---|
| 시세 | KIS Open API, KRX, 네이버/다음 증권, Alpaca, Yahoo Finance, investing.com |
| 공시 | OpenDART(KR), SEC EDGAR(US) |
| 뉴스 | 네이버뉴스, RSS(한국경제/매일경제), Finnhub, investing.com, MarketWatch, Seeking Alpha |
| 커뮤니티 감성 | Reddit, Stocktwits, Hacker News, 네이버/다음 종목토론방 |
| 예측시장 | Polymarket, Kalshi |
| 매크로 | 한국은행 ECOS, FRED |

## 하지 않는 일

- `40-Stocks/`에 직접 Edit/Write 하지 않는다 — 기록은 항상 `scripts/stock-sources/index.js`를 거친다 (SHIELD 규칙)
- `.env`의 API 키 값을 읽거나 출력하지 않는다 — 스크립트가 `process.env`로 직접 읽는다
- 확신도가 낮을 때 단정적으로 표현하지 않는다
