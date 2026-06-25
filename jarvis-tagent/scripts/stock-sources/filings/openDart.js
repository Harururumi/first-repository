'use strict';
// OpenDART (금융감독원 전자공시) — KR 공시. API 키 필요.
const { fetchJson } = require('../lib/http');

async function fetch(ticker) {
  const url = new URL('https://opendart.fss.or.kr/api/list.json');
  url.searchParams.set('crtfc_key', process.env.OPENDART_API_KEY);
  url.searchParams.set('corp_code', ticker);
  url.searchParams.set('page_count', '20');
  const data = await fetchJson(url.toString());
  return data?.list ?? data;
}

module.exports = {
  name: 'openDart',
  isEnabled: () => Boolean(process.env.OPENDART_API_KEY),
  fetch,
};
