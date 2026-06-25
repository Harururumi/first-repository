#!/usr/bin/env bash
# PostToolUse hook — notifies when 00-Inbox/ changes (e.g. via Telegram sync writes).

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

case "$file_path" in
  */00-Inbox/*)
    echo "{\"hookSpecificOutput\":{\"hookEventName\":\"PostToolUse\",\"additionalContext\":\"00-Inbox/ 변경 감지: $file_path — inbox-processor Subagent로 분류를 고려하세요.\"}}"
    ;;
esac

exit 0
