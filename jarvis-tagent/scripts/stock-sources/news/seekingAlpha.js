'use strict';
// Seeking Alpha RSS — US 종목 분석/뉴스. 키 불필요.
const { fetchText } = require('../lib/http');

async function fetch(ticker) {
  const url = `https://seekingalpha.com/api/sa/combined/${encodeURIComponent(ticker)}.xml`;
  const xml = await fetchText(url);
  const items = [...xml.matchAll(/<item>([\s\S]*?)<\/item>/g)];
  return items.map((m) => {
    const title = (m[1].match(/<title>([\s\S]*?)<\/title>/) || [])[1] || '';
    return title.replace(/<!\[CDATA\[|\]\]>/g, '').trim();
  });
}

module.exports = { name: 'seekingAlpha', isEnabled: () => true, fetch };
