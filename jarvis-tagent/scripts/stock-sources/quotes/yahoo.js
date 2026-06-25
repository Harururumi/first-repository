'use strict';
// Yahoo Finance — US 시세 (공개 차트 API). 키 불필요.
const { fetchJson } = require('../lib/http');

async function fetch(ticker) {
  const url = `https://query1.finance.yahoo.com/v8/finance/chart/${encodeURIComponent(ticker)}`;
  const data = await fetchJson(url);
  return data?.chart?.result?.[0];
}

module.exports = { name: 'yahoo', isEnabled: () => true, fetch };
