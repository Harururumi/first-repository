'use strict';

const DEFAULT_TIMEOUT_MS = 8000;
const USER_AGENT =
  'Mozilla/5.0 (compatible; JarvisStockAdvise/1.0; personal-use research bot)';

async function fetchWithTimeout(url, options = {}) {
  const { timeoutMs = DEFAULT_TIMEOUT_MS, headers = {}, ...rest } = options;
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), timeoutMs);
  try {
    const res = await fetch(url, {
      ...rest,
      headers: { 'User-Agent': USER_AGENT, ...headers },
      signal: controller.signal,
    });
    if (!res.ok) {
      throw new Error(`HTTP ${res.status} ${res.statusText} for ${url}`);
    }
    return res;
  } finally {
    clearTimeout(timer);
  }
}

async function fetchJson(url, options = {}) {
  const res = await fetchWithTimeout(url, options);
  return res.json();
}

async function fetchText(url, options = {}) {
  const res = await fetchWithTimeout(url, options);
  return res.text();
}

module.exports = { fetchWithTimeout, fetchJson, fetchText, USER_AGENT };
