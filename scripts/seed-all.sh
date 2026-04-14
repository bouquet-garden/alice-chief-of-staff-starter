#!/usr/bin/env bash
# seed-all.sh — Orchestrate all seed scripts for Alice backtest pipeline
# Usage: seed-all.sh [--days N]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Defaults
DAYS=30

# Parse flags
while [[ $# -gt 0 ]]; do
  case "$1" in
    --days)
      DAYS="$2"
      shift 2
      ;;
    *)
      echo "Unknown flag: $1" >&2
      echo "Usage: $0 [--days N]" >&2
      exit 1
      ;;
  esac
done

CACHE_DIR="${WORKSPACE_ROOT}/workspace/cache"
SEED_LOG="${CACHE_DIR}/seed-log.json"
TODAY=$(date +%Y-%m-%d)
START_TS=$(date +%s)

mkdir -p "${CACHE_DIR}"

echo ""
echo "============================================"
echo "  Alice Seed Pipeline"
echo "  Date  : ${TODAY}"
echo "  Period: last ${DAYS} days"
echo "============================================"
echo ""

# Track results
EMAIL_STATUS="skipped"
EMAIL_COUNT=0
SLACK_STATUS="skipped"
SLACK_COUNT=0
TRANSCRIPT_STATUS="skipped"
TRANSCRIPT_COUNT=0

# --- Email ---
echo "[ 1/3 ] Running seed-from-email..."
if bash "${SCRIPT_DIR}/seed-from-email.sh" --days "${DAYS}"; then
  EMAIL_STATUS="success"
  EMAIL_FILE="${CACHE_DIR}/raw/email/email-${TODAY}.json"
  if [[ -f "${EMAIL_FILE}" ]]; then
    EMAIL_COUNT=$(python3 -c "import json; d=json.load(open('${EMAIL_FILE}')); print(d.get('thread_count',0))" 2>/dev/null || echo 0)
  fi
else
  EMAIL_STATUS="failed"
fi
echo ""

# --- Slack ---
echo "[ 2/3 ] Running seed-from-slack..."
if bash "${SCRIPT_DIR}/seed-from-slack.sh" --days "${DAYS}"; then
  SLACK_STATUS="success"
  SLACK_FILE="${CACHE_DIR}/raw/slack/slack-${TODAY}.json"
  if [[ -f "${SLACK_FILE}" ]]; then
    SLACK_COUNT=$(python3 -c "import json; d=json.load(open('${SLACK_FILE}')); print(d.get('signal_count',0))" 2>/dev/null || echo 0)
  fi
else
  SLACK_STATUS="failed"
fi
echo ""

# --- Transcripts ---
echo "[ 3/3 ] Running seed-from-transcripts..."
if bash "${SCRIPT_DIR}/seed-from-transcripts.sh"; then
  TRANSCRIPT_STATUS="success"
  TRANSCRIPT_FILE="${CACHE_DIR}/entities/transcripts-${TODAY}.json"
  if [[ -f "${TRANSCRIPT_FILE}" ]]; then
    TRANSCRIPT_COUNT=$(python3 -c "import json; d=json.load(open('${TRANSCRIPT_FILE}')); print(d.get('entity_count',0))" 2>/dev/null || echo 0)
  fi
else
  TRANSCRIPT_STATUS="failed"
fi
echo ""

END_TS=$(date +%s)
ELAPSED=$((END_TS - START_TS))

# Print summary
echo "============================================"
echo "  Seed Summary"
echo "============================================"
printf "  %-20s %s (%s items)\n" "Email:" "${EMAIL_STATUS}" "${EMAIL_COUNT}"
printf "  %-20s %s (%s items)\n" "Slack:" "${SLACK_STATUS}" "${SLACK_COUNT}"
printf "  %-20s %s (%s entities)\n" "Transcripts:" "${TRANSCRIPT_STATUS}" "${TRANSCRIPT_COUNT}"
TOTAL_ITEMS=$((EMAIL_COUNT + SLACK_COUNT + TRANSCRIPT_COUNT))
echo "  ---"
printf "  %-20s %s\n" "Total items seeded:" "${TOTAL_ITEMS}"
printf "  %-20s %ss\n" "Elapsed:" "${ELAPSED}"
echo "============================================"
echo ""

# Write seed log
python3 - "${SEED_LOG}" "${TODAY}" "${DAYS}" "${ELAPSED}" \
  "${EMAIL_STATUS}" "${EMAIL_COUNT}" \
  "${SLACK_STATUS}" "${SLACK_COUNT}" \
  "${TRANSCRIPT_STATUS}" "${TRANSCRIPT_COUNT}" \
  "${TOTAL_ITEMS}" <<'PYEOF'
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

seed_log_path = sys.argv[1]
today = sys.argv[2]
days = int(sys.argv[3])
elapsed = int(sys.argv[4])
email_status = sys.argv[5]
email_count = int(sys.argv[6])
slack_status = sys.argv[7]
slack_count = int(sys.argv[8])
transcript_status = sys.argv[9]
transcript_count = int(sys.argv[10])
total_items = int(sys.argv[11])

# Load existing log
log_path = Path(seed_log_path)
if log_path.exists():
    try:
        with open(log_path) as f:
            log = json.load(f)
    except Exception:
        log = {"runs": []}
else:
    log = {"runs": []}

run = {
    "run_date": today,
    "generated_at": datetime.now(timezone.utc).isoformat(),
    "period_days": days,
    "elapsed_seconds": elapsed,
    "sources": {
        "email": {"status": email_status, "count": email_count},
        "slack": {"status": slack_status, "count": slack_count},
        "transcripts": {"status": transcript_status, "count": transcript_count},
    },
    "total_items": total_items,
}

log["runs"].append(run)
log["last_run"] = run

with open(log_path, "w") as f:
    json.dump(log, f, indent=2)

print(f"  Seed log saved to {seed_log_path}")
PYEOF

echo ""
echo "Next step: run backtest.sh to analyze seeded data"
echo "  bash scripts/backtest.sh --days ${DAYS}"
echo ""
