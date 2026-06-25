#!/usr/bin/env python3
"""Stop hook — detects repeated complex solution patterns across session logs
and drops draft skill candidates into .claude/skills/staging/ for human review.

Promotion to a real Skill is never automatic — a human approves via the
Telegram "스킬검토" [승인][수정][거절] flow (handled outside this hook).
"""
import json
import os
import sys
from collections import Counter
from datetime import datetime, timezone

PROJECT_DIR = os.environ.get("CLAUDE_PROJECT_DIR", os.getcwd())
LOG_PATH = os.path.join(PROJECT_DIR, "99-Meta", "Log.md")
STAGING_DIR = os.path.join(PROJECT_DIR, ".claude", "skills", "staging")
PATTERN_THRESHOLD = 3


def load_recent_patterns():
    """Read transcript_path from stdin payload; count repeated tool-call signatures."""
    try:
        payload = json.load(sys.stdin)
    except Exception:
        return Counter()

    transcript_path = payload.get("transcript_path")
    if not transcript_path or not os.path.exists(transcript_path):
        return Counter()

    signatures = Counter()
    try:
        with open(transcript_path, "r", encoding="utf-8") as f:
            for line in f:
                try:
                    entry = json.loads(line)
                except Exception:
                    continue
                tool_name = entry.get("tool_name") or entry.get("name")
                if tool_name:
                    signatures[tool_name] += 1
    except Exception:
        pass
    return signatures


def write_candidate(signature, count):
    os.makedirs(STAGING_DIR, exist_ok=True)
    slug = signature.lower().replace(" ", "-")
    ts = datetime.now(timezone.utc).strftime("%Y%m%d-%H%M%S")
    candidate_path = os.path.join(STAGING_DIR, f"{slug}-{ts}.md")
    content = (
        f"# Skill 후보: {signature}\n\n"
        f"- 감지 횟수: {count}회 (임계값 {PATTERN_THRESHOLD})\n"
        f"- 생성 시각: {ts}\n"
        f"- 상태: 검토 대기 (Telegram '스킬검토'에서 [승인][수정][거절])\n\n"
        "## 제안 SKILL.md 초안\n\n"
        "<!-- 사람이 검토 후 채워서 .claude/skills/로 승격 -->\n"
    )
    with open(candidate_path, "w", encoding="utf-8") as f:
        f.write(content)
    return candidate_path


def main():
    signatures = load_recent_patterns()
    for signature, count in signatures.items():
        if count >= PATTERN_THRESHOLD:
            write_candidate(signature, count)
    sys.exit(0)


if __name__ == "__main__":
    main()
