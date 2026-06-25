'use strict';
const test = require('node:test');
const assert = require('node:assert/strict');

function mockFetchOnce(t, { json, text, status = 200 } = {}) {
  t.mock.method(globalThis, 'fetch', async () => ({
    ok: status >= 200 && status < 300,
    status,
    statusText: 'OK',
    json: async () => json,
    text: async () => text,
  }));
}

test('quotes/yahoo parses chart result', async (t) => {
  const yahoo = require('../quotes/yahoo');
  mockFetchOnce(t, { json: { chart: { result: [{ meta: { regularMarketPrice: 123.45 } }] } } });
  const data = await yahoo.fetch('AAPL');
  assert.equal(data.meta.regularMarketPrice, 123.45);
  assert.equal(yahoo.isEnabled(), true);
});

test('quotes/naver returns first datas entry', async (t) => {
  const naver = require('../quotes/naver');
  mockFetchOnce(t, { json: { datas: [{ symbolCode: '005930', closePrice: '70000' }] } });
  const data = await naver.fetch('005930');
  assert.equal(data.symbolCode, '005930');
});

test('filings/secEdgar returns hits array', async (t) => {
  const secEdgar = require('../filings/secEdgar');
  mockFetchOnce(t, { json: { hits: { hits: [{ _id: '1' }] } } });
  const data = await secEdgar.fetch('AAPL');
  assert.deepEqual(data, [{ _id: '1' }]);
});

test('news/rss parses RSS XML items and filters by ticker', async (t) => {
  const rss = require('../news/rss');
  const xml = `<rss><channel>
    <item><title><![CDATA[Samsung surges]]></title><link>https://example.com/1</link></item>
    <item><title>Unrelated story</title><link>https://example.com/2</link></item>
  </channel></rss>`;
  mockFetchOnce(t, { text: xml });
  const items = await rss.fetch('Samsung');
  assert.equal(items.length, 1);
  assert.equal(items[0].title, 'Samsung surges');
});

test('sentiment/reddit maps children to normalized shape', async (t) => {
  const reddit = require('../sentiment/reddit');
  mockFetchOnce(t, {
    json: {
      data: {
        children: [
          { data: { title: 'AAPL to the moon', score: 10, permalink: '/r/stocks/abc' } },
        ],
      },
    },
  });
  const data = await reddit.fetch('AAPL');
  assert.equal(data.length, 1);
  assert.equal(data[0].title, 'AAPL to the moon');
  assert.equal(data[0].url, 'https://www.reddit.com/r/stocks/abc');
});

test('predictionMarkets/polymarket has no key requirement', () => {
  const polymarket = require('../predictionMarkets/polymarket');
  assert.equal(polymarket.isEnabled(), true);
});

test('key-gated connectors report disabled when env vars are absent', () => {
  const originalEnv = { ...process.env };
  for (const key of [
    'KIS_APP_KEY',
    'KIS_APP_SECRET',
    'KIS_ACCOUNT_NO',
    'ALPACA_API_KEY',
    'ALPACA_API_SECRET',
    'OPENDART_API_KEY',
    'FINNHUB_API_KEY',
    'KALSHI_API_KEY',
    'ECOS_API_KEY',
    'FRED_API_KEY',
  ]) {
    delete process.env[key];
  }

  const kis = require('../quotes/kis');
  const alpaca = require('../quotes/alpaca');
  const openDart = require('../filings/openDart');
  const finnhub = require('../news/finnhub');
  const kalshi = require('../predictionMarkets/kalshi');
  const ecos = require('../macro/ecos');
  const fred = require('../macro/fred');

  assert.equal(kis.isEnabled(), false);
  assert.equal(alpaca.isEnabled(), false);
  assert.equal(openDart.isEnabled(), false);
  assert.equal(finnhub.isEnabled(), false);
  assert.equal(kalshi.isEnabled(), false);
  assert.equal(ecos.isEnabled(), false);
  assert.equal(fred.isEnabled(), false);

  process.env = originalEnv;
});

test('key-gated connectors report enabled when required env vars are present', () => {
  process.env.FINNHUB_API_KEY = 'test-key';
  const finnhub = require('../news/finnhub');
  assert.equal(finnhub.isEnabled(), true);
  delete process.env.FINNHUB_API_KEY;
});
