'use strict';
// 한국거래소(KRX) 정보데이터시스템 — KR 시세. 키 불필요(공개 데이터).
const { fetchJson } = require('../lib/http');

const BASE_URL = 'http://data.krx.co.kr/comm/bldAttendant/getJsonData.cmd';

async function fetch(ticker) {
  const body = new URLSearchParams({
    bld: 'dbms/MDC/STAT/standard/MDCSTAT01501',
    isuCd: ticker,
  });
  return fetchJson(BASE_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body,
  });
}

module.exports = { name: 'krx', isEnabled: () => true, fetch };
