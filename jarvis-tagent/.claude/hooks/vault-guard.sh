#!/usr/bin/env bash
# PreToolUse hook — blocks Edit/Write/MultiEdit on SHIELD-protected paths.
# Exit 2 + stderr message blocks the tool call and shows the reason to Claude.

set -euo pipefail

input="$(cat)"

file_path="$(echo "$input" | python3 -c '
import json, sys
try:
    data = json.load(sys.stdin)
except Exception:
    sys.exit(0)
ti = data.get("tool_input", {})
path = ti.get("file_path") or ti.get("path") or ""
print(path)
')"

if [ -z "$file_path" ]; then
  exit 0
fi

case "$file_path" in
  */40-Stocks/*)
    if [[ "$file_path" != */40-Stocks/Advisory/* ]]; then
      echo "BLOCKED: 40-Stocks/ 직접 편집 금지 (라이브 데이터 전용). scripts/sync-stocks.js 또는 scripts/stock-sources/index.js --write 를 사용하세요." >&2
      exit 2
    fi
    ;;
  */.env|*/.env.*)
    echo "BLOCKED: .env 파일 읽기/수정 금지." >&2
    exit 2
    ;;
  */.wiki-index.json)
    echo "BLOCKED: .wiki-index.json 직접 수정 금지 (wiki-index.js만 수정 가능)." >&2
    exit 2
    ;;
esac

exit 0
