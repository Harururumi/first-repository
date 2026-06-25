#!/usr/bin/env node
'use strict';
/**
 * Multi-source stock data aggregator.
 *
 * Usage:
 *   node index.js --ticker <symbol> [--write] [--no-write]
 *
 * --write writes the normalized result to 40-Stocks/Advisory/<ticker>-<date>.md
 * (the only code path allowed to touch 40-Stocks/ — Claude must never Edit/Write there directly).
 * Without --write, prints JSON to stdout only (used by the stock-analyst Subagent for
 * read-only, non-persisted lookups).
 */
const fs = require('fs');
const path = require('path');

const { runCategory } = require('./lib/aggregate');

const quotes = [
  require('./quotes/kis'),
  require('./quotes/alpaca'),
  require('./quotes/krx'),
  require('./quotes/naver'),
  require('./quotes/daum'),
  require('./quotes/investingCom'),
  require('./quotes/yahoo'),
];
const filings = [require('./filings/openDart'), require('./filings/secEdgar')];
const news = [
  require('./news/naverNews'),
  require('./news/rss'),
  require('./news/finnhub'),
  require('./news/investingComNews'),
  require('./news/marketWatch'),
  require('./news/seekingAlpha'),
];
const sentiment = [
  require('./sentiment/reddit'),
  require('./sentiment/stocktwits'),
  require('./sentiment/hackernews'),
  require('./sentiment/naverDiscussion'),
  require('./sentiment/daumDiscussion'),
];
const predictionMarkets = [
  require('./predictionMarkets/polymarket'),
  require('./predictionMarkets/kalshi'),
];
const macro = [require('./macro/ecos'), require('./macro/fred')];

const CATEGORIES = { quotes, filings, news, sentiment, predictionMarkets, macro };

function parseArgs(argv) {
  const args = { write: false, ticker: null };
  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    if (arg === '--ticker') args.ticker = argv[++i];
    else if (arg === '--write') args.write = true;
    else if (arg === '--no-write') args.write = false;
  }
  return args;
}

async function aggregate(ticker) {
  const entries = await Promise.all(
    Object.entries(CATEGORIES).map(async ([category, connectors]) => [
      category,
      await runCategory(connectors, ticker),
    ]),
  );
  return Object.fromEntries(entries);
}

function findVaultRoot() {
  // Allows tests (and non-standard deployments) to point 40-Stocks/Advisory/ elsewhere.
  if (process.env.JARVIS_VAULT_ROOT) return process.env.JARVIS_VAULT_ROOT;
  // jarvis-tagent/scripts/stock-sources/index.js -> jarvis-tagent/ is the vault root
  return path.resolve(__dirname, '..', '..');
}

function renderMarkdown(ticker, result) {
  const date = new Date().toISOString().slice(0, 10);
  const lines = [
    `---`,
    `type: stock-advisory`,
    `ticker: ${ticker}`,
    `generated-at: ${new Date().toISOString()}`,
    `---`,
    ``,
    `# ${ticker} — 다중 소스 원본 데이터 (${date})`,
    ``,
    `> 이 파일은 \`scripts/stock-sources/index.js --write\`가 생성했습니다. 직접 편집하지 마세요.`,
    ``,
  ];

  for (const [category, results] of Object.entries(result)) {
    lines.push(`## ${category}`, '');
    for (const r of results) {
      if (r.skipped) {
        lines.push(`- \`${r.source}\`: skipped (${r.reason})`);
      } else if (r.error) {
        lines.push(`- \`${r.source}\`: error — ${r.error}`);
      } else {
        lines.push(`- \`${r.source}\` (${r.fetchedAt}):`, '', '```json', JSON.stringify(r.data, null, 2), '```');
      }
    }
    lines.push('');
  }

  return lines.join('\n');
}

async function main() {
  const { ticker, write } = parseArgs(process.argv.slice(2));
  if (!ticker) {
    console.error('Usage: node index.js --ticker <symbol> [--write]');
    process.exit(1);
  }

  const result = await aggregate(ticker);

  if (write) {
    const vaultRoot = findVaultRoot();
    const advisoryDir = path.join(vaultRoot, '40-Stocks', 'Advisory');
    fs.mkdirSync(advisoryDir, { recursive: true });
    const date = new Date().toISOString().slice(0, 10);
    const filePath = path.join(advisoryDir, `${ticker}-${date}.md`);
    fs.writeFileSync(filePath, renderMarkdown(ticker, result), 'utf-8');
    console.log(JSON.stringify({ written: filePath }));
  } else {
    console.log(JSON.stringify(result, null, 2));
  }
}

if (require.main === module) {
  main().catch((err) => {
    console.error(err);
    process.exit(1);
  });
}

module.exports = { aggregate, renderMarkdown, CATEGORIES };
