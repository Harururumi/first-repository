'use strict';

/**
 * Runs all enabled connectors in a category via Promise.allSettled and
 * normalizes results to { source, data, fetchedAt } or { source, error, fetchedAt }.
 * Connectors without required API keys are skipped (not treated as errors).
 */
async function runCategory(connectors, ticker, opts = {}) {
  const enabled = connectors.filter((c) => {
    try {
      return c.isEnabled();
    } catch {
      return false;
    }
  });
  const skipped = connectors
    .filter((c) => !enabled.includes(c))
    .map((c) => ({ source: c.name, skipped: true, reason: 'missing API key' }));

  const settled = await Promise.allSettled(enabled.map((c) => c.fetch(ticker, opts)));

  const results = settled.map((result, i) => {
    const source = enabled[i].name;
    const fetchedAt = new Date().toISOString();
    if (result.status === 'fulfilled') {
      return { source, data: result.value, fetchedAt };
    }
    return { source, error: result.reason?.message || String(result.reason), fetchedAt };
  });

  return [...results, ...skipped];
}

module.exports = { runCategory };
