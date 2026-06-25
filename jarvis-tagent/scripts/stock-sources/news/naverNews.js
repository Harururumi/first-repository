'use strict';
// 네이버 증권 뉴스 — KR 종목 뉴스 (JSON API, 스크래핑). 키 불필요.
const { fetchJson } = require('../lib/http');

async function fetch(ticker) {
  const url = `https://m.stock.naver.com/api/news/stock/${encodeURIComponent(ticker)}?pageSize=20`;
  return fetchJson(url, { headers: { Referer: 'https://m.stock.naver.com/' } });
}

module.exports = { name: 'naverNews', isEnabled: () => true, fetch };
