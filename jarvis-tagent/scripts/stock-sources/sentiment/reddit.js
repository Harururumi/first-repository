'use strict';
// Reddit 공개 검색 JSON — 커뮤니티 감성. 키 불필요.
const { fetchJson } = require('../lib/http');

async function fetch(ticker) {
  const url = `https://www.reddit.com/r/stocks/search.json?q=${encodeURIComponent(ticker)}&sort=new&limit=20&restrict_sr=1`;
  const data = await fetchJson(url);
  return (data?.data?.children ?? []).map((c) => ({
    title: c.data.title,
    score: c.data.score,
    url: `https://www.reddit.com${c.data.permalink}`,
  }));
}

module.exports = { name: 'reddit', isEnabled: () => true, fetch };
