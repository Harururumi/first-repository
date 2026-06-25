'use strict';
// investing.com — 글로벌 보조 시세 (HTML 스크래핑, best-effort). 키 불필요.
// 구조 변경에 취약하므로 단독 모듈로 격리되어 있다 — 실패 시 이 커넥터만 skip된다.
const { fetchText } = require('../lib/http');

async function fetch(ticker) {
  const url = `https://www.investing.com/equities/${encodeURIComponent(ticker)}`;
  const html = await fetchText(url);
  const match = html.match(/data-test="instrument-price-last">([^<]+)</);
  if (!match) {
    throw new Error('investing.com price element not found (page structure may have changed)');
  }
  return { ticker, lastPrice: match[1].trim() };
}

module.exports = { name: 'investingCom', isEnabled: () => true, fetch };
