'use strict';
// 다음 증권 — KR 시세 (JSON API, 스크래핑). 키 불필요.
const { fetchJson } = require('../lib/http');

async function fetch(ticker) {
  const code = ticker.startsWith('A') ? ticker : `A${ticker}`;
  const url = `https://finance.daum.net/api/quotes/${encodeURIComponent(code)}`;
  return fetchJson(url, { headers: { Referer: 'https://finance.daum.net/' } });
}

module.exports = { name: 'daum', isEnabled: () => true, fetch };
