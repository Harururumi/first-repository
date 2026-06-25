'use strict';
// 다음 증권 토론방 — KR 커뮤니티 감성 (JSON API, 스크래핑). 키 불필요.
const { fetchJson } = require('../lib/http');

async function fetch(ticker) {
  const code = ticker.startsWith('A') ? ticker : `A${ticker}`;
  const url = `https://finance.daum.net/api/discuss/A${encodeURIComponent(code.replace(/^A/, ''))}?page=1&perPage=20`;
  return fetchJson(url, { headers: { Referer: 'https://finance.daum.net/' } });
}

module.exports = { name: 'daumDiscussion', isEnabled: () => true, fetch };
