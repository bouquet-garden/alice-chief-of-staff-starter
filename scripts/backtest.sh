#!/usr/bin/env bash
# backtest.sh — Scan seeded data and generate Alice backtest report
# Usage: backtest.sh [--days N]

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
REPORTS_DIR="${WORKSPACE_ROOT}/reports"
TODAY=$(date +%Y-%m-%d)
REPORT_FILE="${REPORTS_DIR}/backtest-${TODAY}.md"
TEMPLATE_FILE="${WORKSPACE_ROOT}/templates/backtest-report.md"

mkdir -p "${REPORTS_DIR}"

echo ""
echo "============================================"
echo "  Alice Backtest Engine"
echo "  Date  : ${TODAY}"
echo "  Period: last ${DAYS} days"
echo "============================================"
echo ""

# --- check_seed_data ---
EMAIL_FILE="${CACHE_DIR}/raw/email/email-${TODAY}.json"
SLACK_FILE="${CACHE_DIR}/raw/slack/slack-${TODAY}.json"
TRANSCRIPT_FILE="${CACHE_DIR}/entities/transcripts-${TODAY}.json"

SOURCES_AVAILABLE=()

[[ -f "${EMAIL_FILE}" ]] && SOURCES_AVAILABLE+=("email")
[[ -f "${SLACK_FILE}" ]] && SOURCES_AVAILABLE+=("slack")
[[ -f "${TRANSCRIPT_FILE}" ]] && SOURCES_AVAILABLE+=("transcripts")

if [[ ${#SOURCES_AVAILABLE[@]} -eq 0 ]]; then
  echo "WARNING: No seed data found for today (${TODAY})."
  echo "  Run first: bash scripts/seed-all.sh --days ${DAYS}"
  echo ""
  echo "  Looking for most recent seed data..."

  # Fall back to most recent available files
  EMAIL_FILE=$(ls -t "${CACHE_DIR}/raw/email"/email-*.json 2>/dev/null | head -1 || true)
  SLACK_FILE=$(ls -t "${CACHE_DIR}/raw/slack"/slack-*.json 2>/dev/null | head -1 || true)
  TRANSCRIPT_FILE=$(ls -t "${CACHE_DIR}/entities"/transcripts-*.json 2>/dev/null | head -1 || true)

  [[ -n "${EMAIL_FILE}" ]] && SOURCES_AVAILABLE+=("email") && echo "  Found email: ${EMAIL_FILE}"
  [[ -n "${SLACK_FILE}" ]] && SOURCES_AVAILABLE+=("slack") && echo "  Found slack: ${SLACK_FILE}"
  [[ -n "${TRANSCRIPT_FILE}" ]] && SOURCES_AVAILABLE+=("transcripts") && echo "  Found transcripts: ${TRANSCRIPT_FILE}"

  if [[ ${#SOURCES_AVAILABLE[@]} -eq 0 ]]; then
    echo "  No seed data found at all. Generating empty report."
  fi
  echo ""
fi

echo "  Sources available: ${SOURCES_AVAILABLE[*]:-none}"
echo ""

# --- Run analysis via Python ---
echo "  Running analysis..."

ANALYSIS=$(python3 - "${EMAIL_FILE:-}" "${SLACK_FILE:-}" "${TRANSCRIPT_FILE:-}" "${DAYS}" <<'PYEOF'
import json
import sys
import re
from datetime import datetime, timezone
from pathlib import Path

email_file = sys.argv[1]
slack_file = sys.argv[2]
transcript_file = sys.argv[3]
days = int(sys.argv[4])

now = datetime.now(timezone.utc)
now_ts = now.timestamp()

# Load data
email_threads = []
slack_signals = []
transcript_entities = []

if email_file and Path(email_file).exists():
    try:
        d = json.loads(Path(email_file).read_text())
        email_threads = d.get("threads", [])
    except Exception:
        pass

if slack_file and Path(slack_file).exists():
    try:
        d = json.loads(Path(slack_file).read_text())
        slack_signals = d.get("signals", [])
    except Exception:
        pass

if transcript_file and Path(transcript_file).exists():
    try:
        d = json.loads(Path(transcript_file).read_text())
        transcript_entities = d.get("entities", [])
    except Exception:
        pass

# =========================================================
# 1. STALE COMMITMENTS
#    Email/Slack where "I'll" or "will do" was said but
#    no follow-up exists (still ball-with-us after >7 days)
# =========================================================
stale_commitments = []

# From email: ball-with-us + stale + commitment language in snippet
COMMITMENT_RE = re.compile(
    r"\bI'?ll\b|\bwill do\b|\bon it\b|\bI will\b|\btaking care\b|\bi'll handle\b",
    re.IGNORECASE,
)

for t in email_threads:
    snippet = t.get("snippet", "") + " " + t.get("subject", "")
    ownership = t.get("ownership", "")
    stale = t.get("stale", False)
    age_days = t.get("age_days", 0)
    priority = t.get("priority", "P3")

    if COMMITMENT_RE.search(snippet) and ownership == "ball-with-us" and stale:
        stale_commitments.append({
            "source": "email",
            "subject": t.get("subject", ""),
            "snippet": t.get("snippet", "")[:200],
            "age_days": age_days,
            "priority": priority,
            "details": f"Commitment language detected; ball-with-us for {age_days}d",
        })

# From Slack: commitment signals older than 7 days with no apparent follow-up
slack_commitment_signals = [
    s for s in slack_signals
    if "commitment" in s.get("signals", [])
]

# Group by thread_ts — if we see a commitment but no later message in same thread, flag it
thread_last_seen = {}
for s in slack_signals:
    thread_ts = s.get("thread_ts", s.get("timestamp", "0"))
    sig_ts = float(s.get("timestamp", 0))
    if thread_ts not in thread_last_seen or sig_ts > thread_last_seen[thread_ts]["ts"]:
        thread_last_seen[thread_ts] = {"ts": sig_ts, "signals": s.get("signals", [])}

for s in slack_commitment_signals:
    thread_ts = s.get("thread_ts", s.get("timestamp", "0"))
    sig_ts = float(s.get("timestamp", 0))
    age_days = max(0, int((now_ts - sig_ts) / 86400))

    if age_days > 7:
        last = thread_last_seen.get(thread_ts, {})
        # If the last signal in the thread is still the commitment itself — no follow-up
        if last.get("ts", 0) <= sig_ts + 3600:  # nothing within 1hr after
            stale_commitments.append({
                "source": "slack",
                "channel": s.get("channel", ""),
                "snippet": s.get("text_snippet", "")[:200],
                "age_days": age_days,
                "priority": "P2",
                "details": f"Commitment in #{s.get('channel','')} with no follow-up thread activity ({age_days}d ago)",
            })

# =========================================================
# 2. UNRESOLVED THREADS
#    P0/P1 email with no response in >48h
# =========================================================
unresolved_threads = []

for t in email_threads:
    priority = t.get("priority", "P3")
    age_days = t.get("age_days", 0)
    ownership = t.get("ownership", "")

    if priority in ("P0", "P1") and age_days >= 2 and ownership == "ball-with-us":
        unresolved_threads.append({
            "source": "email",
            "subject": t.get("subject", ""),
            "snippet": t.get("snippet", "")[:200],
            "age_days": age_days,
            "priority": priority,
            "details": f"{priority} thread unanswered for {age_days} days",
        })

# =========================================================
# 3. CONTRADICTIONS
#    Cross-surface conflicts: entity state vs. email signals
# =========================================================
contradictions = []

# Build entity state map from transcripts/cache
entity_state = {}
for e in transcript_entities:
    title = e.get("title", "").lower()
    summary = e.get("summary", "").lower()
    # Look for closed/complete vs open markers
    is_closed = any(k in summary for k in ["closed", "completed", "shipped", "launched", "done", "finished"])
    is_open = any(k in summary for k in ["in progress", "ongoing", "open", "pending", "blocked", "needs"])
    if title:
        entity_state[title] = {
            "closed": is_closed,
            "open": is_open,
            "summary": e.get("summary", "")[:200],
            "date": e.get("date", ""),
            "path": e.get("path", ""),
        }

# Check email threads for contradictions against entity state
OPEN_RE = re.compile(r"open question|still waiting|not resolved|pending|need to|unclear|haven't heard", re.IGNORECASE)
CLOSED_RE = re.compile(r"closed|completed|shipped|launched|resolved|done|wrapped up", re.IGNORECASE)

for t in email_threads:
    subject = t.get("subject", "").lower()
    snippet = t.get("snippet", "").lower()

    for entity_name, state in entity_state.items():
        # Check if this email is about this entity
        if entity_name in subject or entity_name in snippet:
            # Entity marked closed but email has open questions
            if state["closed"] and OPEN_RE.search(snippet):
                contradictions.append({
                    "type": "closed-entity-open-email",
                    "entity": entity_name,
                    "entity_source": "transcript: " + Path(state.get("path", "unknown")).name if state.get("path") else "transcript",
                    "email_subject": t.get("subject", ""),
                    "email_snippet": t.get("snippet", "")[:200],
                    "details": f"Entity '{entity_name}' marked closed in transcript but email has open questions",
                })
            # Entity marked open but email says it's done
            elif state["open"] and CLOSED_RE.search(snippet):
                contradictions.append({
                    "type": "open-entity-closed-email",
                    "entity": entity_name,
                    "entity_source": "transcript",
                    "email_subject": t.get("subject", ""),
                    "email_snippet": t.get("snippet", "")[:200],
                    "details": f"Entity '{entity_name}' tracked as open in transcript but email suggests completion",
                })

# Also check Slack escalations against transcript "completed" items
for s in slack_signals:
    if "escalation" in s.get("signals", []):
        text = s.get("text_snippet", "").lower()
        for entity_name, state in entity_state.items():
            if entity_name in text and state["closed"]:
                contradictions.append({
                    "type": "closed-entity-escalation",
                    "entity": entity_name,
                    "entity_source": "transcript",
                    "slack_channel": s.get("channel", ""),
                    "slack_snippet": s.get("text_snippet", "")[:200],
                    "details": f"Entity '{entity_name}' marked done in transcript but Slack shows escalation",
                })

# =========================================================
# 4. MISSED FOLLOW-UPS
#    Calendar items (from transcript titles) that generated
#    no Slack/email follow-up within 48h
# =========================================================
missed_followups = []

MEETING_RE = re.compile(r"meeting|sync|standup|check.?in|review|kickoff|call|1:1|one.on.one|demo|debrief", re.IGNORECASE)

for e in transcript_entities:
    title = e.get("title", "")
    date_str = e.get("date", "")

    if not MEETING_RE.search(title):
        continue

    # Parse entity date
    meeting_ts = None
    if date_str:
        for fmt in ("%Y-%m-%d", "%Y/%m/%d", "%B %d, %Y", "%b %d, %Y"):
            try:
                meeting_dt = datetime.strptime(date_str, fmt).replace(tzinfo=timezone.utc)
                meeting_ts = meeting_dt.timestamp()
                break
            except ValueError:
                continue

    if meeting_ts is None:
        continue

    # Check if there's any Slack/email activity within 48h after the meeting
    deadline = meeting_ts + (48 * 3600)
    found_followup = False

    for s in slack_signals:
        sig_ts = float(s.get("timestamp", 0))
        if meeting_ts <= sig_ts <= deadline:
            # Check if snippet mentions meeting topic
            if any(word.lower() in s.get("text_snippet", "").lower()
                   for word in title.split() if len(word) > 4):
                found_followup = True
                break

    for t in email_threads:
        thread_ts = t.get("last_message_timestamp", 0)
        if meeting_ts <= thread_ts <= deadline:
            if any(word.lower() in (t.get("subject", "") + t.get("snippet", "")).lower()
                   for word in title.split() if len(word) > 4):
                found_followup = True
                break

    if not found_followup:
        age_days = max(0, int((now_ts - meeting_ts) / 86400))
        missed_followups.append({
            "source": "transcript",
            "meeting_title": title,
            "meeting_date": date_str,
            "age_days": age_days,
            "details": f"Meeting '{title}' ({date_str}) has no detectable Slack/email follow-up within 48h",
        })

# =========================================================
# Summary
# =========================================================
# Rough time impact: ~30min per stale commitment, ~20min per contradiction, ~15min per missed followup
stale_hrs = len(stale_commitments) * 0.5
contradiction_hrs = len(contradictions) * 0.33
missed_hrs = len(missed_followups) * 0.25
unresolved_hrs = len(unresolved_threads) * 0.5
total_hrs = round(stale_hrs + contradiction_hrs + missed_hrs + unresolved_hrs, 1)

result = {
    "stale_commitments": stale_commitments,
    "unresolved_threads": unresolved_threads,
    "contradictions": contradictions,
    "missed_followups": missed_followups,
    "summary": {
        "stale_count": len(stale_commitments),
        "unresolved_count": len(unresolved_threads),
        "contradiction_count": len(contradictions),
        "missed_followup_count": len(missed_followups),
        "estimated_hours_per_week": total_hrs,
    },
    "sources_analyzed": [],
}

if email_threads:
    result["sources_analyzed"].append(f"email ({len(email_threads)} threads)")
if slack_signals:
    result["sources_analyzed"].append(f"slack ({len(slack_signals)} signals)")
if transcript_entities:
    result["sources_analyzed"].append(f"transcripts ({len(transcript_entities)} entities)")

print(json.dumps(result, indent=2))
PYEOF
)

echo "  Analysis complete."
echo ""

# --- Generate report from template or inline ---
python3 - "${REPORT_FILE}" "${TEMPLATE_FILE}" "${TODAY}" "${DAYS}" <<PYEOF
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

report_file = sys.argv[1]
template_file = sys.argv[2]
today = sys.argv[3]
days = int(sys.argv[4])

analysis_raw = """${ANALYSIS}"""
try:
    analysis = json.loads(analysis_raw)
except Exception:
    analysis = {
        "stale_commitments": [],
        "unresolved_threads": [],
        "contradictions": [],
        "missed_followups": [],
        "summary": {"stale_count": 0, "unresolved_count": 0, "contradiction_count": 0, "missed_followup_count": 0, "estimated_hours_per_week": 0.0},
        "sources_analyzed": [],
    }

s = analysis["summary"]
sources_str = ", ".join(analysis.get("sources_analyzed", [])) or "none"

# Load template if it exists
tmpl_path = Path(template_file)
if tmpl_path.exists():
    template = tmpl_path.read_text()
else:
    template = """# Backtest Report — {{DATE}}
**Period:** Last {{DAYS}} days
**Sources analyzed:** {{SOURCES}}

## Summary
- {{STALE_COUNT}} stale commitments found
- {{UNRESOLVED_COUNT}} unresolved high-priority threads
- {{CONTRADICTION_COUNT}} contradictions detected
- {{MISSED_FOLLOWUP_COUNT}} missed follow-ups
- Estimated time impact: {{HOURS}} hrs/week

## Stale Commitments
{{STALE_COMMITMENTS}}

## Unresolved High-Priority Threads
{{UNRESOLVED_THREADS}}

## Contradictions
{{CONTRADICTIONS}}

## Missed Follow-ups
{{MISSED_FOLLOWUPS}}
"""

# Format findings sections
def format_items(items, fields):
    if not items:
        return "_None detected._\n"
    lines = []
    for i, item in enumerate(items, 1):
        lines.append(f"### Finding {i}")
        for field in fields:
            val = item.get(field, "")
            if val:
                label = field.replace("_", " ").title()
                lines.append(f"- **{label}:** {val}")
        lines.append("")
    return "\n".join(lines)

stale_md = format_items(analysis["stale_commitments"],
    ["source", "subject", "channel", "snippet", "age_days", "priority", "details"])

unresolved_md = format_items(analysis["unresolved_threads"],
    ["source", "subject", "snippet", "age_days", "priority", "details"])

contradictions_md = format_items(analysis["contradictions"],
    ["type", "entity", "entity_source", "email_subject", "slack_channel", "details"])

missed_md = format_items(analysis["missed_followups"],
    ["source", "meeting_title", "meeting_date", "age_days", "details"])

report = template
report = report.replace("{{DATE}}", today)
report = report.replace("{{DAYS}}", str(days))
report = report.replace("{{SOURCES}}", sources_str)
report = report.replace("{{STALE_COUNT}}", str(s["stale_count"]))
report = report.replace("{{UNRESOLVED_COUNT}}", str(s.get("unresolved_count", 0)))
report = report.replace("{{CONTRADICTION_COUNT}}", str(s["contradiction_count"]))
report = report.replace("{{MISSED_FOLLOWUP_COUNT}}", str(s["missed_followup_count"]))
report = report.replace("{{HOURS}}", str(s["estimated_hours_per_week"]))
report = report.replace("{{STALE_COMMITMENTS}}", stale_md)
report = report.replace("{{UNRESOLVED_THREADS}}", unresolved_md)
report = report.replace("{{CONTRADICTIONS}}", contradictions_md)
report = report.replace("{{MISSED_FOLLOWUPS}}", missed_md)

Path(report_file).write_text(report)
print(f"Report written to {report_file}")
PYEOF

echo ""
echo "============================================"
STALE=$(echo "${ANALYSIS}" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d['summary']['stale_count'])" 2>/dev/null || echo 0)
UNRESOLVED=$(echo "${ANALYSIS}" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d['summary'].get('unresolved_count',0))" 2>/dev/null || echo 0)
CONTRADICTIONS=$(echo "${ANALYSIS}" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d['summary']['contradiction_count'])" 2>/dev/null || echo 0)
MISSED=$(echo "${ANALYSIS}" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d['summary']['missed_followup_count'])" 2>/dev/null || echo 0)
HOURS=$(echo "${ANALYSIS}" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d['summary']['estimated_hours_per_week'])" 2>/dev/null || echo 0)

printf "  %-28s %s\n" "Stale commitments:" "${STALE}"
printf "  %-28s %s\n" "Unresolved threads (P0/P1):" "${UNRESOLVED}"
printf "  %-28s %s\n" "Contradictions:" "${CONTRADICTIONS}"
printf "  %-28s %s\n" "Missed follow-ups:" "${MISSED}"
printf "  %-28s %s hrs/week\n" "Estimated time impact:" "${HOURS}"
echo "============================================"
echo ""
echo "  Full report: ${REPORT_FILE}"
echo ""
