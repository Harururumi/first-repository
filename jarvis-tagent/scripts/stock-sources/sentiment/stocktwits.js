'use strict';
// Stocktwits — 종목별 커뮤니티 감성. 키 불필요(공개 스트림).
const { fetchJson } = require('../lib/http');

async function fetch(ticker) {
  const url = `https://api.stocktwits.com/api/2/streams/symbol/${encodeURIComponent(ticker)}.json`;
  const data = await fetchJson(url);
  return (data?.messages ?? []).map((m) => ({
    body: m.body,
    sentiment: m.entities?.sentiment?.basic ?? null,
    createdAt: m.created_at,
  }));
}

module.exports = { name: 'stocktwits', isEnabled: () => true, fetch };
