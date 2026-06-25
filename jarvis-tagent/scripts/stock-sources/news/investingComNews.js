'use strict';
// investing.com 뉴스 — 글로벌 보조 뉴스 (HTML 스크래핑, best-effort). 키 불필요.
const { fetchText } = require('../lib/http');

async function fetch(ticker) {
  const url = `https://www.investing.com/equities/${encodeURIComponent(ticker)}-news`;
  const html = await fetchText(url);
  const titles = [...html.matchAll(/<a[^>]+data-test="article-title-link"[^>]*>([^<]+)</g)].map(
    (m) => m[1].trim(),
  );
  return titles;
}

module.exports = { name: 'investingComNews', isEnabled: () => true, fetch };
