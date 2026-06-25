#!/usr/bin/env python3
"""SessionStart hook — briefs Claude with SOUL.md + recent Vault activity."""
import json
import os
import sys

VAULT_ROOT = os.environ.get("CLAUDE_PROJECT_DIR", os.getcwd())
SOUL_PATH = os.path.join(VAULT_ROOT, "99-Meta", "SOUL.md")
INBOX_DIR = os.path.join(VAULT_ROOT, "00-Inbox")


def read_soul():
    try:
        with open(SOUL_PATH, "r", encoding="utf-8") as f:
            return f.read()
    except FileNotFoundError:
        return ""


def count_inbox():
    try:
        return len([f for f in os.listdir(INBOX_DIR) if not f.startswith(".")])
    except FileNotFoundError:
        return 0


def main():
    soul = read_soul()
    inbox_count = count_inbox()

    briefing_lines = ["# Jarvis 세션 브리핑"]
    if soul:
        briefing_lines.append(soul)
    briefing_lines.append(f"\n00-Inbox/ 미처리 항목: {inbox_count}개")
    if inbox_count > 0:
        briefing_lines.append("필요하면 `/wiki-ingest`로 처리하거나 inbox-processor Subagent를 호출하세요.")

    output = {
        "hookSpecificOutput": {
            "hookEventName": "SessionStart",
            "additionalContext": "\n".join(briefing_lines),
        }
    }
    print(json.dumps(output))


if __name__ == "__main__":
    main()
    sys.exit(0)
