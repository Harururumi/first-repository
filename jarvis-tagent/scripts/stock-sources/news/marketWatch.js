'use strict';
// MarketWatch RSS — US 시장 뉴스. 키 불필요.
const { fetchText } = require('../lib/http');

async function fetch() {
  const xml = await fetchText('https://feeds.content.dowjones.io/public/rss/mw_topstories');
  const items = [...xml.matchAll(/<item>([\s\S]*?)<\/item>/g)];
  return items.map((m) => {
    const title = (m[1].match(/<title>([\s\S]*?)<\/title>/) || [])[1] || '';
    return title.replace(/<!\[CDATA\[|\]\]>/g, '').trim();
  });
}

module.exports = { name: 'marketWatch', isEnabled: () => true, fetch };
