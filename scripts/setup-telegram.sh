#!/usr/bin/env bash
# setup-telegram.sh — Create Alice Telegram forum topics via Bot API
# Reads topic definitions from manifests/telegram/topics.json
# Usage: bash scripts/setup-telegram.sh

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TOPICS_FILE="$REPO_DIR/manifests/telegram/topics.json"

# ─── colors ───────────────────────────────────────────────────────────────────
_ok()   { printf "\033[32m  ✅  %s\033[0m\n" "$*"; }
_info() { printf "\033[34m  ℹ️   %s\033[0m\n" "$*"; }
_warn() { printf "\033[33m  ⚠️   %s\033[0m\n" "$*"; }
_err()  { printf "\033[31m  ✗   %s\033[0m\n" "$*"; }
_h()    { printf "\n\033[1m%s\033[0m\n" "$*"; }

_h "Telegram Topic Setup"

# ─── dependency check ─────────────────────────────────────────────────────────

if [ -z "${TELEGRAM_BOT_TOKEN:-}" ]; then
  _warn "TELEGRAM_BOT_TOKEN is not set. Skipping Telegram setup."
  echo ""
  echo "  To get a bot token:"
  echo "    1. Open Telegram and message @BotFather"
  echo "    2. Send /newbot and follow the prompts"
  echo "    3. Copy the token BotFather gives you"
  echo "    4. export TELEGRAM_BOT_TOKEN=your_token_here"
  echo "    5. Re-run: bash scripts/setup-telegram.sh"
  exit 0
fi

if ! command -v curl >/dev/null 2>&1; then
  _err "curl is required but not found"
  exit 1
fi

if [ ! -f "$TOPICS_FILE" ]; then
  _err "topics.json not found at: $TOPICS_FILE"
  exit 1
fi

BOT_API="https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}"

# ─── verify bot token ─────────────────────────────────────────────────────────

echo ""
_info "Verifying bot token..."
ME_RESPONSE="$(curl -sf "$BOT_API/getMe" 2>/dev/null || echo '{"ok":false}')"
if echo "$ME_RESPONSE" | grep -q '"ok":true'; then
  BOT_USERNAME="$(echo "$ME_RESPONSE" | grep -o '"username":"[^"]*"' | cut -d'"' -f4)"
  _ok "Bot verified: @$BOT_USERNAME"
else
  _err "Bot token verification failed. Check TELEGRAM_BOT_TOKEN."
  exit 1
fi

# ─── get or prompt for chat ID ────────────────────────────────────────────────

CHAT_ID="${TELEGRAM_CHAT_ID:-}"

if [ -z "$CHAT_ID" ]; then
  echo ""
  _info "How to find your group chat ID:"
  echo ""
  echo "  1. Add your bot to a Telegram group"
  echo "  2. Make the group a 'Supergroup with Topics' (Group Settings → Topics)"
  echo "  3. Ensure the bot is admin with 'Manage Topics' permission"
  echo "  4. Send a message in the group, then visit:"
  echo "     https://api.telegram.org/bot\$TELEGRAM_BOT_TOKEN/getUpdates"
  echo "  5. Look for 'chat' → 'id' (it will be a negative number like -1001234567890)"
  echo ""
  printf "  Enter your group chat ID (or press Enter to skip): "
  read -r CHAT_ID </dev/tty

  if [ -z "$CHAT_ID" ]; then
    _warn "No chat ID provided. Skipping topic creation."
    echo "  Re-run with: TELEGRAM_CHAT_ID=-100xxxxxxxxxx bash scripts/setup-telegram.sh"
    exit 0
  fi
fi

export TELEGRAM_CHAT_ID="$CHAT_ID"
_ok "Using chat ID: $CHAT_ID"

# ─── icon color map (Telegram's 7 supported forum topic icon colors) ──────────
# Telegram supports specific color IDs for forum topics, not arbitrary emoji.
# These are the 7 official icon_color values (integer IDs):
#   7322096 = blue, 16766590 = yellow, 13338331 = violet,
#   9367192 = green, 16749490 = rose, 16478047 = red, 6134715 = teal
_icon_color_for() {
  local icon="$1"
  case "$icon" in
    "📋") echo "7322096"  ;;   # blue
    "🚨") echo "16478047" ;;   # red
    "⚙️") echo "13338331" ;;   # violet
    "🎯") echo "9367192"  ;;   # green
    "🔍") echo "16766590" ;;   # yellow
    "🔨") echo "16749490" ;;   # rose
    "🌐") echo "6134715"  ;;   # teal
    *)    echo "7322096"  ;;   # default blue
  esac
}

# ─── parse and create topics ──────────────────────────────────────────────────

echo ""
_info "Creating forum topics from: $TOPICS_FILE"
echo ""

CREATED=0
FAILED=0

_create_topic() {
  local name="$1"
  local icon_color="$2"

  local payload="{\"chat_id\":\"$CHAT_ID\",\"name\":\"$name\",\"icon_color\":$icon_color}"
  local response
  response="$(curl -sf -X POST "$BOT_API/createForumTopic" \
    -H "Content-Type: application/json" \
    -d "$payload" 2>/dev/null || echo '{"ok":false}')"

  if echo "$response" | grep -q '"ok":true'; then
    return 0
  else
    local desc
    desc="$(echo "$response" | grep -o '"description":"[^"]*"' | cut -d'"' -f4)"
    echo "    API error: $desc" >&2
    return 1
  fi
}

if command -v jq >/dev/null 2>&1; then
  # jq available — clean parsing
  while IFS=$'\t' read -r name icon; do
    [ -z "$name" ] && continue
    icon_color="$(_icon_color_for "$icon")"
    printf "  Creating topic: %-30s " "$name ..."
    if _create_topic "$name" "$icon_color"; then
      _ok "created"
      CREATED=$((CREATED + 1))
    else
      _warn "failed (may already exist or bot lacks Manage Topics permission)"
      FAILED=$((FAILED + 1))
    fi
  done < <(jq -r '.topics[] | "\(.name)\t\(.icon)"' "$TOPICS_FILE")
else
  # Fallback: use python3
  if command -v python3 >/dev/null 2>&1; then
    while IFS=$'\t' read -r name icon; do
      [ -z "$name" ] && continue
      icon_color="$(_icon_color_for "$icon")"
      printf "  Creating topic: %-30s " "$name ..."
      if _create_topic "$name" "$icon_color"; then
        _ok "created"
        CREATED=$((CREATED + 1))
      else
        _warn "failed"
        FAILED=$((FAILED + 1))
      fi
    done < <(python3 -c "
import json
with open('$TOPICS_FILE') as f:
    data = json.load(f)
for t in data['topics']:
    print(t['name'] + '\t' + t.get('icon',''))
")
  else
    _warn "Neither jq nor python3 found. Cannot parse topics.json automatically."
    echo ""
    echo "  Topics to create manually in your Telegram group:"
    grep '"name"' "$TOPICS_FILE" | sed 's/.*"name": *"\([^"]*\)".*/    - \1/'
  fi
fi

echo ""
_info "Result: $CREATED created, $FAILED failed"

if [ "$FAILED" -gt 0 ]; then
  echo ""
  _warn "Some topics failed. Common causes:"
  echo "    - Bot is not an admin in the group"
  echo "    - Bot does not have 'Manage Topics' permission"
  echo "    - Group is not a supergroup with Topics enabled"
  echo "    - Topics already exist (safe to ignore)"
fi
echo ""
