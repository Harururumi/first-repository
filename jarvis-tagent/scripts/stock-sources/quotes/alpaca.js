'use strict';
// Alpaca Market Data API — US 시세. API 키 필요.
const { fetchJson } = require('../lib/http');

async function fetch(ticker) {
  const url = `https://data.alpaca.markets/v2/stocks/${encodeURIComponent(ticker)}/quotes/latest`;
  const data = await fetchJson(url, {
    headers: {
      'APCA-API-KEY-ID': process.env.ALPACA_API_KEY,
      'APCA-API-SECRET-KEY': process.env.ALPACA_API_SECRET,
    },
  });
  return data.quote;
}

module.exports = {
  name: 'alpaca',
  isEnabled: () => Boolean(process.env.ALPACA_API_KEY && process.env.ALPACA_API_SECRET),
  fetch,
};
