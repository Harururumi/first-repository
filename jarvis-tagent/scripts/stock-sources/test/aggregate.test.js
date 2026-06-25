'use strict';
const test = require('node:test');
const assert = require('node:assert/strict');

const { runCategory } = require('../lib/aggregate');

function makeConnector({ name, enabled = true, value, error }) {
  return {
    name,
    isEnabled: () => enabled,
    fetch: async () => {
      if (error) throw error;
      return value;
    },
  };
}

test('runCategory returns fulfilled results with source/data/fetchedAt', async () => {
  const connectors = [makeConnector({ name: 'a', value: { price: 100 } })];
  const results = await runCategory(connectors, 'TEST');
  assert.equal(results.length, 1);
  assert.equal(results[0].source, 'a');
  assert.deepEqual(results[0].data, { price: 100 });
  assert.ok(results[0].fetchedAt);
});

test('runCategory captures errors without throwing (Promise.allSettled semantics)', async () => {
  const connectors = [
    makeConnector({ name: 'good', value: { ok: true } }),
    makeConnector({ name: 'bad', error: new Error('boom') }),
  ];
  const results = await runCategory(connectors, 'TEST');
  const bad = results.find((r) => r.source === 'bad');
  const good = results.find((r) => r.source === 'good');
  assert.equal(bad.error, 'boom');
  assert.deepEqual(good.data, { ok: true });
});

test('runCategory skips disabled connectors instead of calling fetch', async () => {
  let called = false;
  const connectors = [
    {
      name: 'needs-key',
      isEnabled: () => false,
      fetch: async () => {
        called = true;
        return {};
      },
    },
  ];
  const results = await runCategory(connectors, 'TEST');
  assert.equal(called, false);
  assert.equal(results[0].skipped, true);
  assert.equal(results[0].source, 'needs-key');
});

test('runCategory treats isEnabled() throwing as disabled (missing key safety)', async () => {
  const connectors = [
    {
      name: 'throws',
      isEnabled: () => {
        throw new Error('no env');
      },
      fetch: async () => ({}),
    },
  ];
  const results = await runCategory(connectors, 'TEST');
  assert.equal(results[0].skipped, true);
});
