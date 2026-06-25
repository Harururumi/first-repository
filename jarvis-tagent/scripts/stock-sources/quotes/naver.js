'use strict';
// 네이버 증권 — KR 시세 (JSON polling API, 스크래핑). 키 불필요.
const { fetchJson } = require('../lib/http');

async function fetch(ticker) {
  const url = `https://polling.finance.naver.com/api/realtime/domestic/stock/${encodeURIComponent(ticker)}`;
  const data = await fetchJson(url, { headers: { Referer: 'https://finance.naver.com/' } });
  return data?.datas?.[0] ?? data;
}

module.exports = { name: 'naver', isEnabled: () => true, fetch };
