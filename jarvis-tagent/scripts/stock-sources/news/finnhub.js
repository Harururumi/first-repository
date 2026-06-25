'use strict';
// Finnhub News API — 종목별 뉴스. API 키 필요.
const { fetchJson } = require('../lib/http');

async function fetch(ticker) {
  const to = new Date().toISOString().slice(0, 10);
  const from = new Date(Date.now() - 7 * 86400000).toISOString().slice(0, 10);
  const url = `https://finnhub.io/api/v1/company-news?symbol=${encodeURIComponent(ticker)}&from=${from}&to=${to}&token=${process.env.FINNHUB_API_KEY}`;
  return fetchJson(url);
}

module.exports = {
  name: 'finnhub',
  isEnabled: () => Boolean(process.env.FINNHUB_API_KEY),
  fetch,
};
