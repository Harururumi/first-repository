'use strict';
// Hacker News Algolia Search API — 기술 커뮤니티 언급. 키 불필요.
const { fetchJson } = require('../lib/http');

async function fetch(ticker) {
  const url = `https://hn.algolia.com/api/v1/search?query=${encodeURIComponent(ticker)}&tags=story`;
  const data = await fetchJson(url);
  return (data?.hits ?? []).map((h) => ({
    title: h.title,
    points: h.points,
    url: h.url,
    createdAt: h.created_at,
  }));
}

module.exports = { name: 'hackernews', isEnabled: () => true, fetch };
