'use strict';
// 한국경제/매일경제 RSS — KR 경제 뉴스. 키 불필요.
const { fetchText } = require('../lib/http');

const FEEDS = {
  hankyung: 'https://www.hankyung.com/feed/economy',
  mk: 'https://www.mk.co.kr/rss/30100041/',
};

function parseRssItems(xml) {
  const items = [...xml.matchAll(/<item>([\s\S]*?)<\/item>/g)];
  return items.map((m) => {
    const block = m[1];
    const title = (block.match(/<title>([\s\S]*?)<\/title>/) || [])[1] || '';
    const link = (block.match(/<link>([\s\S]*?)<\/link>/) || [])[1] || '';
    return { title: title.replace(/<!\[CDATA\[|\]\]>/g, '').trim(), link: link.trim() };
  });
}

async function fetch(ticker, opts = {}) {
  const feedKey = opts.feed || 'hankyung';
  const xml = await fetchText(FEEDS[feedKey]);
  return parseRssItems(xml).filter((item) => !ticker || item.title.includes(ticker));
}

module.exports = { name: 'rss', isEnabled: () => true, fetch };
