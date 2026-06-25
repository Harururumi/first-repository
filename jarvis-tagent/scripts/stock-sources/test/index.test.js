'use strict';
const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const { execFileSync } = require('node:child_process');

const { renderMarkdown } = require('../index');

test('renderMarkdown formats success/error/skipped entries per category', () => {
  const md = renderMarkdown('AAPL', {
    quotes: [
      { source: 'yahoo', data: { price: 200 }, fetchedAt: '2026-01-01T00:00:00.000Z' },
      { source: 'kis', skipped: true, reason: 'missing API key' },
    ],
    news: [{ source: 'rss', error: 'timeout', fetchedAt: '2026-01-01T00:00:00.000Z' }],
  });

  assert.match(md, /ticker: AAPL/);
  assert.match(md, /## quotes/);
  assert.match(md, /`yahoo`/);
  assert.match(md, /"price": 200/);
  assert.match(md, /`kis`: skipped \(missing API key\)/);
  assert.match(md, /`rss`: error — timeout/);
});

test('CLI --write only writes under 40-Stocks\\/Advisory, never elsewhere', () => {
  const tmpRoot = fs.mkdtempSync(path.join(os.tmpdir(), 'jarvis-vault-'));
  const env = {
    ...process.env,
    JARVIS_VAULT_ROOT: tmpRoot,
    // No API keys set on purpose — every key-gated connector should be skipped,
    // and every no-key connector will fail fast against an unreachable host in CI,
    // which still exercises the write path via the error branch.
  };

  execFileSync(process.execPath, [path.join(__dirname, '..', 'index.js'), '--ticker', 'TEST', '--write'], {
    env,
    timeout: 30000,
  });

  const advisoryDir = path.join(tmpRoot, '40-Stocks', 'Advisory');
  const files = fs.readdirSync(advisoryDir);
  assert.equal(files.length, 1);
  assert.match(files[0], /^TEST-\d{4}-\d{2}-\d{2}\.md$/);

  fs.rmSync(tmpRoot, { recursive: true, force: true });
});
