#!/usr/bin/env bash
# Stop hook — incrementally rebuilds the wiki index after a session ends.
# Delegates to wiki-index.js; never writes .wiki-index.json directly from this hook itself.

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
INDEX_SCRIPT="$PROJECT_DIR/scripts/wiki-index.js"

if [ -f "$INDEX_SCRIPT" ]; then
  node "$INDEX_SCRIPT" --incremental || echo "wiki-index.js incremental update failed (non-fatal)" >&2
fi

exit 0
