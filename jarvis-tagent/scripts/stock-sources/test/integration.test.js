'use strict';
/**
 * Best-effort integration tests against real no-auth-required sources.
 *
 * These hit live third-party endpoints, so they:
 *  - skip (not fail) when the current network policy blocks outbound requests
 *    (this happens inside the sandboxed Claude Code remote session itself)
 *  - skip (not fail) on transient upstream errors (rate limiting, scraping
 *    target HTML changes) so CI doesn't flake on things outside our control
 *
 * Run on a machine with normal internet access (e.g. the user's Mac) to get
 * real pass/fail signal for each connector.
 */
const test = require('node:test');
const assert = require('node:assert/strict');

async function tryFetch(name, fn, t) {
  try {
    return await fn();
  } catch (err) {
    t.diagnostic(`${name} skipped: ${err.message}`);
    t.skip(`network unavailable or upstream error: ${err.message}`);
    return undefined;
  }
}

test('quotes/yahoo live fetch returns a chart result', async (t) => {
  const yahoo = require('../quotes/yahoo');
  const data = await tryFetch('yahoo', () => yahoo.fetch('AAPL'), t);
  if (data === undefined) return;
  assert.ok(data.meta);
});

test('filings/secEdgar live fetch returns search hits', async (t) => {
  const secEdgar = require('../filings/secEdgar');
  const data = await tryFetch('secEdgar', () => secEdgar.fetch('Apple'), t);
  if (data === undefined) return;
  assert.ok(Array.isArray(data));
});

test('sentiment/hackernews live fetch returns story hits', async (t) => {
  const hackernews = require('../sentiment/hackernews');
  const data = await tryFetch('hackernews', () => hackernews.fetch('Tesla'), t);
  if (data === undefined) return;
  assert.ok(Array.isArray(data));
});

test('predictionMarkets/polymarket live fetch returns events payload', async (t) => {
  const polymarket = require('../predictionMarkets/polymarket');
  const data = await tryFetch('polymarket', () => polymarket.fetch('election'), t);
  if (data === undefined) return;
  assert.ok(data !== null);
});
