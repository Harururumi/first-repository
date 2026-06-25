'use strict';
// FRED (Federal Reserve Economic Data) — 매크로 지표. API 키 필요.
const { fetchJson } = require('../lib/http');

async function fetch(_ticker, opts = {}) {
  const seriesId = opts.seriesId || 'FEDFUNDS'; // 미 연준 기준금리
  const url = `https://api.stlouisfed.org/fred/series/observations?series_id=${seriesId}&api_key=${process.env.FRED_API_KEY}&file_type=json&limit=10&sort_order=desc`;
  return fetchJson(url);
}

module.exports = {
  name: 'fred',
  isEnabled: () => Boolean(process.env.FRED_API_KEY),
  fetch,
};
