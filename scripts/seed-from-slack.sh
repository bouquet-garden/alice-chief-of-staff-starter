#!/usr/bin/env bash
# seed-from-slack.sh — Pull Slack channel history and extract signals for Alice backtest
# Usage: seed-from-slack.sh [--days N] [--channels CHANNEL_LIST]

set -euo pipefail

# Defaults
DAYS=30
CHANNELS=""   # empty = all alice-* channels
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
OUTPUT_DIR="${WORKSPACE_ROOT}/workspace/cache/raw/slack"

# Parse flags
while [[ $# -gt 0 ]]; do
  case "$1" in
    --days)
      DAYS="$2"
      shift 2
      ;;
    --channels)
      CHANNELS="$2"
      shift 2
      ;;
    --output)
      OUTPUT_DIR="$2"
      shift 2
      ;;
    *)
      echo "Unknown flag: $1" >&2
      echo "Usage: $0 [--days N] [--channels chan1,chan2] [--output DIR]" >&2
      exit 1
      ;;
  esac
done

# Resolve output dir
if [[ "${OUTPUT_DIR}" != /* ]]; then
  OUTPUT_DIR="${WORKSPACE_ROOT}/${OUTPUT_DIR}"
fi

echo "==> seed-from-slack: pulling last ${DAYS} days into ${OUTPUT_DIR}"

# Check token
if [[ -z "${SLACK_BOT_TOKEN:-}" ]]; then
  cat >&2 <<'EOF'
ERROR: SLACK_BOT_TOKEN is not set.

To enable Slack seeding:
  1. Go to https://api.slack.com/apps and create or open your Aria/Alice app.
  2. Under "OAuth & Permissions", add scopes:
       channels:history, channels:read, groups:history, groups:read
  3. Install the app to your workspace and copy the Bot User OAuth Token.
  4. Export: export SLACK_BOT_TOKEN=xoxb-...
  5. Re-run this script.

Skipping Slack seed.
EOF
  exit 0
fi

mkdir -p "${OUTPUT_DIR}"

TODAY=$(date +%Y-%m-%d)
OUTPUT_FILE="${OUTPUT_DIR}/slack-${TODAY}.json"

# Compute oldest timestamp for Slack API
OLDEST_TS=$(python3 -c "
import time
from datetime import datetime, timedelta, timezone
dt = datetime.now(timezone.utc) - timedelta(days=${DAYS})
print(dt.timestamp())
")

# --- list_channels ---
list_channels() {
  local cursor=""
  local channels=()

  while true; do
    local url="https://slack.com/api/conversations.list?types=public_channel,private_channel&limit=200&exclude_archived=true"
    [[ -n "${cursor}" ]] && url="${url}&cursor=${cursor}"

    local resp
    resp=$(curl -s --fail \
      -H "Authorization: Bearer ${SLACK_BOT_TOKEN}" \
      "${url}") || { echo "[]"; return; }

    # Check for API error
    local ok
    ok=$(echo "${resp}" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('ok','false'))" 2>/dev/null || echo "false")
    if [[ "${ok}" != "True" && "${ok}" != "true" ]]; then
      local err
      err=$(echo "${resp}" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('error','unknown'))" 2>/dev/null || echo "unknown")
      echo "  WARNING: conversations.list error: ${err}" >&2
      break
    fi

    local batch
    batch=$(echo "${resp}" | python3 -c "
import json, sys
d = json.load(sys.stdin)
for ch in d.get('channels', []):
    print(ch['id'] + ':' + ch['name'])
" 2>/dev/null || true)

    while IFS= read -r line; do
      [[ -z "${line}" ]] && continue
      channels+=("${line}")
    done <<< "${batch}"

    cursor=$(echo "${resp}" | python3 -c "
import json, sys
d = json.load(sys.stdin)
print(d.get('response_metadata', {}).get('next_cursor', ''))
" 2>/dev/null || true)

    [[ -z "${cursor}" ]] && break
  done

  printf '%s\n' "${channels[@]}"
}

# --- fetch_channel_history ---
fetch_channel_history() {
  local channel_id="$1"
  local cursor=""
  local all_messages="[]"

  while true; do
    local url="https://slack.com/api/conversations.history?channel=${channel_id}&oldest=${OLDEST_TS}&limit=200"
    [[ -n "${cursor}" ]] && url="${url}&cursor=${cursor}"

    local resp
    resp=$(curl -s --fail \
      -H "Authorization: Bearer ${SLACK_BOT_TOKEN}" \
      "${url}") || break

    local ok
    ok=$(echo "${resp}" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('ok','false'))" 2>/dev/null || echo "false")
    if [[ "${ok}" != "True" && "${ok}" != "true" ]]; then
      break
    fi

    all_messages=$(echo "${resp}" | EXISTING="${all_messages}" python3 -c "
import json, sys, os
resp = json.load(sys.stdin)
existing = json.loads(os.environ['EXISTING'])
existing.extend(resp.get('messages', []))
print(json.dumps(existing))
" 2>/dev/null || echo "${all_messages}")

    local has_more
    has_more=$(echo "${resp}" | python3 -c "
import json, sys
d = json.load(sys.stdin)
print(str(d.get('has_more', False)).lower())
" 2>/dev/null || echo "false")

    [[ "${has_more}" != "true" ]] && break

    cursor=$(echo "${resp}" | python3 -c "
import json, sys
d = json.load(sys.stdin)
print(d.get('response_metadata', {}).get('next_cursor', ''))
" 2>/dev/null || true)

    [[ -z "${cursor}" ]] && break
  done

  echo "${all_messages}"
}

# --- extract_signals ---
extract_signals() {
  local messages_json="$1"
  local channel_name="$2"

  python3 - "${channel_name}" <<PYEOF
import json
import sys
import re

channel_name = sys.argv[1]
messages_raw = """${messages_json}"""

try:
    messages = json.loads(messages_raw)
except Exception:
    messages = []

DECISION_PATTERNS = [
    r"we decided",
    r"agreed",
    r"going with",
    r"decision:",
    r"confirmed:",
    r"we're going",
    r"we are going",
    r"locked in",
    r"final call",
]

COMMITMENT_PATTERNS = [
    r"\bI'll\b",
    r"\bI will\b",
    r"will do",
    r"on it",
    r"\bI can\b",
    r"i'll handle",
    r"i'll take",
    r"i'll send",
    r"i'll set up",
    r"i'll follow",
    r"i'll reach",
    r"leaving it with me",
]

ESCALATION_PATTERNS = [
    r"\burgent\b",
    r"\bASAP\b",
    r"as soon as possible",
    r"\bblocked\b",
    r"\bblocker\b",
    r"\bescalate",
    r"need help",
    r"can't move forward",
    r"cannot move forward",
    r"waiting on",
    r"stuck on",
]

signals = []
for msg in messages:
    text = msg.get("text", "")
    ts = msg.get("ts", "0")
    user = msg.get("user", msg.get("username", "unknown"))
    thread_ts = msg.get("thread_ts", ts)

    text_lower = text.lower()

    detected = []
    for pat in DECISION_PATTERNS:
        if re.search(pat, text, re.IGNORECASE):
            detected.append("decision")
            break
    for pat in COMMITMENT_PATTERNS:
        if re.search(pat, text, re.IGNORECASE):
            detected.append("commitment")
            break
    for pat in ESCALATION_PATTERNS:
        if re.search(pat, text, re.IGNORECASE):
            detected.append("escalation")
            break

    if detected:
        signals.append({
            "channel": channel_name,
            "user": user,
            "timestamp": ts,
            "thread_ts": thread_ts,
            "text_snippet": text[:500],
            "signals": detected,
        })

print(json.dumps(signals))
PYEOF
}

# Determine target channels
declare -a TARGET_CHANNELS=()

if [[ -n "${CHANNELS}" ]]; then
  IFS=',' read -ra CHAN_NAMES <<< "${CHANNELS}"
  for name in "${CHAN_NAMES[@]}"; do
    name=$(echo "${name}" | xargs)
    # Look up channel ID
    chan_id=$(curl -s --fail \
      -H "Authorization: Bearer ${SLACK_BOT_TOKEN}" \
      "https://slack.com/api/conversations.list?types=public_channel,private_channel&limit=1000" \
      | python3 -c "
import json, sys
d = json.load(sys.stdin)
for ch in d.get('channels', []):
    if ch['name'] == '${name}':
        print(ch['id'] + ':' + ch['name'])
        break
" 2>/dev/null || true)
    [[ -n "${chan_id}" ]] && TARGET_CHANNELS+=("${chan_id}")
  done
else
  # Default: all alice-* channels
  echo "  Discovering alice-* channels..."
  while IFS= read -r line; do
    [[ -z "${line}" ]] && continue
    chan_name="${line#*:}"
    if echo "${chan_name}" | grep -q "^alice"; then
      TARGET_CHANNELS+=("${line}")
    fi
  done < <(list_channels)

  if [[ ${#TARGET_CHANNELS[@]} -eq 0 ]]; then
    echo "  No alice-* channels found. Falling back to first 5 accessible channels..."
    count=0
    while IFS= read -r line; do
      [[ -z "${line}" ]] && continue
      TARGET_CHANNELS+=("${line}")
      count=$((count + 1))
      [[ ${count} -ge 5 ]] && break
    done < <(list_channels)
  fi
fi

echo "  Targeting ${#TARGET_CHANNELS[@]} channel(s)..."

# Collect all signals
ALL_SIGNALS="[]"
CHANNELS_PROCESSED=()

for chan_entry in "${TARGET_CHANNELS[@]}"; do
  chan_id="${chan_entry%%:*}"
  chan_name="${chan_entry#*:}"
  echo "  Fetching #${chan_name} (${chan_id})..."

  messages=$(fetch_channel_history "${chan_id}")
  msg_count=$(echo "${messages}" | python3 -c "import json,sys; print(len(json.load(sys.stdin)))" 2>/dev/null || echo 0)
  echo "    ${msg_count} messages fetched"

  signals=$(extract_signals "${messages}" "${chan_name}")
  sig_count=$(echo "${signals}" | python3 -c "import json,sys; print(len(json.load(sys.stdin)))" 2>/dev/null || echo 0)
  echo "    ${sig_count} signals extracted"

  ALL_SIGNALS=$(EXISTING="${ALL_SIGNALS}" NEW="${signals}" python3 -c "
import json, sys, os
existing = json.loads(os.environ['EXISTING'])
new = json.loads(os.environ['NEW'])
existing.extend(new)
print(json.dumps(existing))
" 2>/dev/null || echo "${ALL_SIGNALS}")

  CHANNELS_PROCESSED+=("${chan_name}")
done

# Write output
python3 - "${OUTPUT_FILE}" "${DAYS}" <<PYEOF
import json
import sys
from datetime import datetime, timezone

output_file = sys.argv[1]
days = int(sys.argv[2])

signals_raw = """${ALL_SIGNALS}"""
try:
    signals = json.loads(signals_raw)
except Exception:
    signals = []

channels_processed_raw = """${CHANNELS_PROCESSED[*]:-}"""
channels = [c.strip() for c in channels_processed_raw.split() if c.strip()]

# Summarize by signal type
decisions = [s for s in signals if "decision" in s.get("signals", [])]
commitments = [s for s in signals if "commitment" in s.get("signals", [])]
escalations = [s for s in signals if "escalation" in s.get("signals", [])]

output = {
    "generated_at": datetime.now(timezone.utc).isoformat(),
    "period_days": days,
    "channels_processed": channels,
    "signal_count": len(signals),
    "summary": {
        "decisions": len(decisions),
        "commitments": len(commitments),
        "escalations": len(escalations),
    },
    "signals": signals,
}

with open(output_file, "w") as f:
    json.dump(output, f, indent=2)

print(f"  Wrote {len(signals)} signals to {output_file}")
PYEOF

echo "==> seed-from-slack: done"
