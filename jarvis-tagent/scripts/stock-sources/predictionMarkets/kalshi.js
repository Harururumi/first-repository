'use strict';
// Kalshi — 예측시장 odds. API 키 필요.
const { fetchJson } = require('../lib/http');

async function fetch(ticker) {
  const url = `https://trading-api.kalshi.com/trade-api/v2/markets?series_ticker=${encodeURIComponent(ticker)}`;
  return fetchJson(url, {
    headers: { Authorization: `Bearer ${process.env.KALSHI_API_KEY}` },
  });
}

module.exports = {
  name: 'kalshi',
  isEnabled: () => Boolean(process.env.KALSHI_API_KEY),
  fetch,
};
