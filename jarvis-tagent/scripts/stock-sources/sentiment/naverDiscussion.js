'use strict';
// 네이버 증권 종목토론방 — KR 커뮤니티 감성 (HTML 스크래핑). 키 불필요.
const { fetchText } = require('../lib/http');

async function fetch(ticker) {
  const url = `https://finance.naver.com/item/board.naver?code=${encodeURIComponent(ticker)}`;
  const html = await fetchText(url);
  const titles = [...html.matchAll(/<td class="title">\s*<a[^>]*title="([^"]+)"/g)].map(
    (m) => m[1],
  );
  return titles;
}

module.exports = { name: 'naverDiscussion', isEnabled: () => true, fetch };
