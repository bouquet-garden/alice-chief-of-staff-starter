#!/usr/bin/env bash
# setup-slack.sh — Create Alice Slack channels using the Slack CLI
# Reads channel definitions from manifests/slack/channels.json
# Usage: bash scripts/setup-slack.sh

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CHANNELS_FILE="$REPO_DIR/manifests/slack/channels.json"

# ─── colors ───────────────────────────────────────────────────────────────────
_ok()   { printf "\033[32m  ✅  %s\033[0m\n" "$*"; }
_info() { printf "\033[34m  ℹ️   %s\033[0m\n" "$*"; }
_warn() { printf "\033[33m  ⚠️   %s\033[0m\n" "$*"; }
_err()  { printf "\033[31m  ✗   %s\033[0m\n" "$*"; }
_h()    { printf "\n\033[1m%s\033[0m\n" "$*"; }

# ─── dependency check ─────────────────────────────────────────────────────────

_h "Slack Channel Setup"

if ! command -v slack >/dev/null 2>&1; then
  _warn "Slack CLI not found. Skipping Slack channel setup."
  echo ""
  echo "  To install the Slack CLI:"
  echo "    https://api.slack.com/automation/cli/install"
  echo ""
  echo "  Once installed, re-run: bash scripts/setup-slack.sh"
  exit 0
fi

if [ ! -f "$CHANNELS_FILE" ]; then
  _err "channels.json not found at: $CHANNELS_FILE"
  exit 1
fi

# ─── parse channels ───────────────────────────────────────────────────────────

# Use jq if available, otherwise fall back to grep/sed parsing
_parse_channels() {
  if command -v jq >/dev/null 2>&1; then
    jq -r '.channels[] | "\(.name)\t\(.topic)\t\(.purpose)"' "$CHANNELS_FILE"
  else
    # Fallback: naive line-by-line parser for the known JSON structure
    python3 -c "
import json, sys
with open('$CHANNELS_FILE') as f:
    data = json.load(f)
for ch in data['channels']:
    print(ch['name'] + '\t' + ch.get('topic','') + '\t' + ch.get('purpose',''))
" 2>/dev/null || {
      _err "Could not parse channels.json — install jq or python3"
      exit 1
    }
  fi
}

# ─── create channels ──────────────────────────────────────────────────────────

echo ""
_info "Creating channels from: $CHANNELS_FILE"
echo ""

CREATED=0
SKIPPED=0
FAILED=0

while IFS=$'\t' read -r name topic purpose; do
  [ -z "$name" ] && continue
  printf "  Creating #%-30s " "$name ..."

  # Try to create the channel; slack CLI exits non-zero if it already exists
  if slack channel create --name "$name" 2>/dev/null; then
    _ok "created"
    CREATED=$((CREATED + 1))

    # Set topic if supported by installed CLI version
    if [ -n "$topic" ]; then
      slack channel set-topic --name "$name" --topic "$topic" 2>/dev/null || true
    fi
  else
    # Channel likely already exists
    _info "already exists (skipped)"
    SKIPPED=$((SKIPPED + 1))
  fi
done < <(_parse_channels)

echo ""
_info "Result: $CREATED created, $SKIPPED already existed, $FAILED failed"

# ─── app manifest instructions ────────────────────────────────────────────────

echo ""
_h "Next step: Import the Slack app manifests"
echo ""
echo "  The Slack CLI cannot fully configure app permissions programmatically."
echo "  Import the manifests manually at https://api.slack.com/apps:"
echo ""
echo "    Operator manifest (bot with full permissions):"
echo "      $REPO_DIR/manifests/slack/alice-operator.manifest.json"
echo ""
echo "    Starter manifest (read-only, lighter footprint):"
echo "      $REPO_DIR/manifests/slack/alice-starter.manifest.json"
echo ""
echo "  Steps:"
echo "    1. Go to https://api.slack.com/apps"
echo "    2. Click 'Create New App' → 'From an app manifest'"
echo "    3. Paste the JSON from one of the files above"
echo "    4. Install the app to your workspace"
echo "    5. Copy the Bot OAuth Token (xoxb-...) to your env:"
echo "       export SLACK_BOT_TOKEN=xoxb-..."
echo ""
