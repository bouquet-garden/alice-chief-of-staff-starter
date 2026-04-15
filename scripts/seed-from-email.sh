#!/usr/bin/env bash
# seed-from-email.sh — Pull email history and classify threads for Alice backtest
# Usage: seed-from-email.sh [--days N] [--output DIR]

set -euo pipefail

# Defaults
DAYS=30
OUTPUT_DIR="workspace/cache/raw/email"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Parse flags
while [[ $# -gt 0 ]]; do
  case "$1" in
    --days)
      DAYS="$2"
      shift 2
      ;;
    --output)
      OUTPUT_DIR="$2"
      shift 2
      ;;
    *)
      echo "Unknown flag: $1" >&2
      echo "Usage: $0 [--days N] [--output DIR]" >&2
      exit 1
      ;;
  esac
done

# Resolve output dir relative to workspace root if not absolute
if [[ "${OUTPUT_DIR}" != /* ]]; then
  OUTPUT_DIR="${WORKSPACE_ROOT}/${OUTPUT_DIR}"
fi

echo "==> seed-from-email: pulling last ${DAYS} days into ${OUTPUT_DIR}"

# Check for gam or GMAIL_API_KEY
HAS_GAM=false
HAS_API_KEY=false

if command -v gam &>/dev/null; then
  HAS_GAM=true
fi

if [[ -n "${GMAIL_API_KEY:-}" ]]; then
  HAS_API_KEY=true
fi

if ! $HAS_GAM && ! $HAS_API_KEY; then
  cat >&2 <<'EOF'
ERROR: No Gmail access method found.

To enable email seeding, choose one of:

  Option A — gam (recommended for Google Workspace)
    1. Install: https://github.com/GAM-team/GAM
    2. Run: gam create project && gam oauth create
    3. Re-run this script.

Skipping email seed.
EOF
  exit 0
fi

mkdir -p "${OUTPUT_DIR}"

TODAY=$(date +%Y-%m-%d)
OUTPUT_FILE="${OUTPUT_DIR}/email-${TODAY}.json"

# Compute cutoff date (macOS-compatible)
CUTOFF_EPOCH=$(date -v "-${DAYS}d" +%s 2>/dev/null || date -d "${DAYS} days ago" +%s)

echo "  Fetching email threads since $(date -r "${CUTOFF_EPOCH}" +%Y-%m-%d 2>/dev/null || date -d "@${CUTOFF_EPOCH}" +%Y-%m-%d)..."

# --- fetch_via_gam ---
fetch_via_gam() {
  local after_date
  after_date=$(date -v "-${DAYS}d" +%Y/%m/%d 2>/dev/null || date -d "${DAYS} days ago" +%Y/%m/%d)
  local raw_file="${OUTPUT_DIR}/.gam-raw-$$.json"
  trap 'rm -f "${raw_file}"' EXIT

  # Export thread list
  gam user me print threads query "after:${after_date}" fields id,snippet,historyId > "${raw_file}" 2>/dev/null || {
    echo "  WARNING: gam thread export failed — check auth." >&2
    echo '{"threads":[]}' > "${raw_file}"
  }

  echo "${raw_file}"
}

# --- fetch_via_api ---
fetch_via_api() {
  echo "  ERROR: Gmail API requires OAuth credentials. Use 'gam' instead (see Option A above)." >&2
  return 1
}

# --- classify_thread ---
# Classify a thread into priority, ownership, staleness
classify_thread() {
  local subject="$1"
  local snippet="$2"
  local last_reply_epoch="$3"
  local from_me="$4"   # "true" or "false"

  local now_epoch
  now_epoch=$(date +%s)
  local age_days=$(( (now_epoch - last_reply_epoch) / 86400 ))

  # Priority: heuristic keyword scoring
  local priority="P2"
  local subj_lower
  subj_lower=$(echo "${subject}" | tr '[:upper:]' '[:lower:]')
  local snip_lower
  snip_lower=$(echo "${snippet}" | tr '[:upper:]' '[:lower:]')
  local combined="${subj_lower} ${snip_lower}"

  if echo "${combined}" | grep -qE "urgent|blocker|blocked|critical|p0|outage|down|broken|emergency"; then
    priority="P0"
  elif echo "${combined}" | grep -qE "action required|follow.?up|decision|deadline|by (today|tomorrow|eod|eow|monday|friday)|asap"; then
    priority="P1"
  elif echo "${combined}" | grep -qE "update|review|feedback|question|request|please|could you|can you"; then
    priority="P2"
  else
    priority="P3"
  fi

  # Ownership: if last message was from me and no reply from them -> ball-with-them
  # if last message was from them with no reply from me -> ball-with-us
  local ownership="unknown"
  if [[ "${from_me}" == "true" ]]; then
    ownership="ball-with-them"
  else
    ownership="ball-with-us"
  fi

  # Staleness
  local stale="false"
  if (( age_days > 7 )); then
    stale="true"
  fi

  echo "${priority}|${ownership}|${stale}|${age_days}"
}

# Build output JSON
build_output() {
  local threads_json="$1"

  python3 - "${threads_json}" "${DAYS}" "${CUTOFF_EPOCH}" <<'PYEOF'
import json
import sys
from datetime import datetime, timezone

threads_raw = sys.argv[1]
days = int(sys.argv[2])
cutoff = int(sys.argv[3])
now = int(datetime.now(timezone.utc).timestamp())

try:
    with open(threads_raw) as f:
        data = json.load(f)
    threads = data.get("threads", data) if isinstance(data, dict) else data
except Exception:
    threads = []

classified = []
for t in threads:
    thread_id = t.get("id", "")
    snippet = t.get("snippet", "")[:500]
    subject = t.get("subject", snippet[:60])
    last_ts = t.get("lastMessageTimestamp", now - (days * 86400 // 2))
    from_me = t.get("fromMe", False)
    age_days = max(0, (now - int(last_ts)) // 86400)

    combined = (subject + " " + snippet).lower()

    # Priority
    if any(k in combined for k in ["urgent", "blocker", "blocked", "critical", "p0", "outage", "emergency"]):
        priority = "P0"
    elif any(k in combined for k in ["action required", "follow-up", "followup", "decision", "deadline", "asap"]):
        priority = "P1"
    elif any(k in combined for k in ["update", "review", "feedback", "question", "request"]):
        priority = "P2"
    else:
        priority = "P3"

    ownership = "ball-with-them" if from_me else "ball-with-us"
    stale = age_days > 7

    classified.append({
        "thread_id": thread_id,
        "subject": subject,
        "snippet": snippet,
        "priority": priority,
        "ownership": ownership,
        "stale": stale,
        "age_days": age_days,
        "last_message_timestamp": last_ts,
    })

output = {
    "generated_at": datetime.now(timezone.utc).isoformat(),
    "period_days": days,
    "thread_count": len(classified),
    "threads": classified,
}
print(json.dumps(output, indent=2))
PYEOF
}

# --- Main execution ---
if $HAS_GAM; then
  echo "  Using gam for email pull..."
  raw_file=$(fetch_via_gam)
  build_output "${raw_file}" > "${OUTPUT_FILE}"
else
  echo "  Using Gmail API for email pull..."
  threads_json=$(fetch_via_api)
  tmp_file=$(mktemp /tmp/seed-email-XXXXXX.json)
  echo "${threads_json}" > "${tmp_file}"
  build_output "${tmp_file}" > "${OUTPUT_FILE}"
  rm -f "${tmp_file}"
fi

THREAD_COUNT=$(python3 -c "import json; d=json.load(open('${OUTPUT_FILE}')); print(d.get('thread_count',0))" 2>/dev/null || echo 0)
echo "  Wrote ${THREAD_COUNT} classified threads to ${OUTPUT_FILE}"
echo "==> seed-from-email: done"
