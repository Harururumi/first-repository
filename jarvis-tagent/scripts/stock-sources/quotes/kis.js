'use strict';
// 한국투자증권 (KIS) Open API — KR 시세. API 키 필요.
const { fetchJson } = require('../lib/http');

const BASE_URL = 'https://openapi.koreainvestment.com:9443';

let cachedToken = null;
let tokenExpiresAt = 0;

async function getAccessToken() {
  if (cachedToken && Date.now() < tokenExpiresAt) return cachedToken;
  const res = await fetchJson(`${BASE_URL}/oauth2/tokenP`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      grant_type: 'client_credentials',
      appkey: process.env.KIS_APP_KEY,
      appsecret: process.env.KIS_APP_SECRET,
    }),
  });
  cachedToken = res.access_token;
  tokenExpiresAt = Date.now() + (Number(res.expires_in || 86400) - 60) * 1000;
  return cachedToken;
}

async function fetch(ticker) {
  const token = await getAccessToken();
  const url = `${BASE_URL}/uapi/domestic-stock/v1/quotations/inquire-price?fid_cond_mrkt_div_code=J&fid_input_iscd=${encodeURIComponent(ticker)}`;
  const data = await fetchJson(url, {
    headers: {
      authorization: `Bearer ${token}`,
      appkey: process.env.KIS_APP_KEY,
      appsecret: process.env.KIS_APP_SECRET,
      tr_id: 'FHKST01010100',
    },
  });
  return data.output;
}

module.exports = {
  name: 'kis',
  isEnabled: () =>
    Boolean(process.env.KIS_APP_KEY && process.env.KIS_APP_SECRET && process.env.KIS_ACCOUNT_NO),
  fetch,
};
