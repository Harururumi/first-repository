'use strict';
// Polymarket Gamma API — 예측시장 odds. 키 불필요.
const { fetchJson } = require('../lib/http');

async function fetch(ticker) {
  const url = `https://gamma-api.polymarket.com/events?search=${encodeURIComponent(ticker)}&closed=false`;
  return fetchJson(url);
}

module.exports = { name: 'polymarket', isEnabled: () => true, fetch };
