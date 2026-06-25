'use strict';
// 한국은행 ECOS — 매크로 지표 (기준금리 등). API 키 필요.
const { fetchJson } = require('../lib/http');

async function fetch(_ticker, opts = {}) {
  const statCode = opts.statCode || '722Y001'; // 한국은행 기준금리
  const url = `https://ecos.bok.or.kr/api/StatisticSearch/${process.env.ECOS_API_KEY}/json/kr/1/10/${statCode}`;
  return fetchJson(url);
}

module.exports = {
  name: 'ecos',
  isEnabled: () => Boolean(process.env.ECOS_API_KEY),
  fetch,
};
