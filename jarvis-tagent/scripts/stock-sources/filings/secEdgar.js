'use strict';
// SEC EDGAR Full-Text Search — US 공시. 키 불필요.
const { fetchJson } = require('../lib/http');

async function fetch(ticker) {
  const url = `https://efts.sec.gov/LATEST/search-index?q=${encodeURIComponent(ticker)}&forms=10-K,10-Q,8-K`;
  const data = await fetchJson(url, { headers: { 'User-Agent': 'JarvisStockAdvise research@example.com' } });
  return data?.hits?.hits ?? data;
}

module.exports = { name: 'secEdgar', isEnabled: () => true, fetch };
