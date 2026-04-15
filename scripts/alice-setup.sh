#!/usr/bin/env bash
# alice-setup.sh — Interactive onboarding wizard for the Alice chief-of-staff starter kit
#
# Usage: bash scripts/alice-setup.sh
#
# Pure bash. No Node, Python, or Bun required.
# curl is used for API calls; jq is used if available with python3 fallback.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# ─── color helpers ────────────────────────────────────────────────────────────
_bold()   { printf "\033[1m%s\033[0m" "$*"; }
_green()  { printf "\033[32m%s\033[0m" "$*"; }
_yellow() { printf "\033[33m%s\033[0m" "$*"; }
_cyan()   { printf "\033[36m%s\033[0m" "$*"; }
_dim()    { printf "\033[2m%s\033[0m" "$*"; }

_h1() { echo ""; printf "\033[1;36m══════════════════════════════════════════════\033[0m\n"; printf "\033[1;36m  %s\033[0m\n" "$*"; printf "\033[1;36m══════════════════════════════════════════════\033[0m\n"; echo ""; }
_h2() { echo ""; printf "\033[1m▸ %s\033[0m\n" "$*"; echo ""; }
_ok()   { printf "\033[32m  ✅  %s\033[0m\n" "$*"; }
_info() { printf "\033[34m  ℹ️   %s\033[0m\n" "$*"; }
_warn() { printf "\033[33m  ⚠️   %s\033[0m\n" "$*"; }
_step() { printf "\n\033[1;34m[%s]\033[0m %s\n" "$1" "$2"; echo ""; }
_ask()  { printf "\033[36m  → %s\033[0m " "$*"; }

# ─── banner ───────────────────────────────────────────────────────────────────

clear 2>/dev/null || true

cat << 'BANNER'

  ┌─────────────────────────────────────────────────────┐
  │                                                     │
  │          Alice Chief-of-Staff  ·  Setup             │
  │                                                     │
  │  This wizard will:                                  │
  │    1. Detect your available tools & integrations    │
  │    2. Ask which integrations you want to set up     │
  │    3. Configure Slack, Telegram, Obsidian, Notion,  │
  │       and/or Gmail labels                           │
  │    4. Scaffold your Alice workspace files           │
  │    5. Hand off to your AI agent to start discovery  │
  │                                                     │
  │  Pure bash. No Node, Python, or Bun required.       │
  │  Takes about 5 minutes.                             │
  │                                                     │
  └─────────────────────────────────────────────────────┘

BANNER

_ask "Press Enter to begin setup, or Ctrl+C to cancel."
read -r </dev/tty || true

# ─── Phase 1: Preflight ───────────────────────────────────────────────────────

_h1 "Phase 1 · Preflight Check"

if [ ! -f "$SCRIPT_DIR/preflight.sh" ]; then
  echo "  Error: preflight.sh not found at $SCRIPT_DIR/preflight.sh" >&2
  exit 1
fi

# Source preflight so its exports are available in this shell
# shellcheck source=scripts/preflight.sh
source "$SCRIPT_DIR/preflight.sh"

# ─── Phase 2: Integration selection ──────────────────────────────────────────

_h1 "Phase 2 · Integration Setup"

_h2 "Which integrations would you like to configure?"
echo "  (Enter the numbers, separated by spaces, or 'all', or press Enter to skip)"
echo ""

# Build the menu dynamically based on what was detected
MENU_ITEMS=()
MENU_SCRIPTS=()

_menu_item() {
  local num="$1"
  local label="$2"
  local status="$3"
  local script="$4"
  MENU_ITEMS+=("$label")
  MENU_SCRIPTS+=("$script")
  printf "  %s  %s  %s\n" "$(_bold "[$num]")" "$label" "$(_dim "($status)")"
}

_menu_item 1 "Slack channels"    "$([ "${ALICE_SLACK_OK:-0}" = "1" ] && echo "CLI detected" || echo "CLI not found — will skip gracefully")"    "setup-slack.sh"
_menu_item 2 "Telegram topics"   "$([ "${ALICE_TELEGRAM_OK:-0}" = "1" ] && echo "token set" || echo "no token — will show instructions")"          "setup-telegram.sh"
_menu_item 3 "Obsidian vault"    "$([ "${ALICE_OBSIDIAN_OK:-0}" = "1" ] && echo "vault found at $ALICE_OBSIDIAN_VAULT" || echo "will prompt for path")" "setup-obsidian.sh"
_menu_item 4 "Notion databases"  "$([ "${ALICE_NOTION_OK:-0}" = "1" ] && echo "API key set" || echo "no key — will skip gracefully")"             "setup-notion.sh"
_menu_item 5 "Gmail labels"      "$([ "${ALICE_EMAIL_OK:-0}" = "1" ] && echo "gam found" || echo "no gam — will show manual instructions")"       "setup-email-labels.sh"

echo ""
_ask "Your choice (e.g. 1 3 5, or 'all', or Enter to skip integrations):"
read -r USER_CHOICE </dev/tty

# Parse choices
SELECTED_SCRIPTS=()

if [ -z "$USER_CHOICE" ]; then
  _info "Skipping integration setup."
elif echo "$USER_CHOICE" | grep -qiE '^all$'; then
  SELECTED_SCRIPTS=("${MENU_SCRIPTS[@]}")
else
  for num in $USER_CHOICE; do
    if [[ "$num" =~ ^[1-5]$ ]]; then
      idx=$((num - 1))
      SELECTED_SCRIPTS+=("${MENU_SCRIPTS[$idx]}")
    fi
  done
fi

# Run selected setup scripts
if [ "${#SELECTED_SCRIPTS[@]}" -gt 0 ]; then
  echo ""
  for script_name in "${SELECTED_SCRIPTS[@]}"; do
    script_path="$SCRIPT_DIR/$script_name"
    if [ -f "$script_path" ]; then
      _step "Running" "$script_name"
      bash "$script_path" || {
        _warn "$script_name exited with an error — continuing"
      }
    else
      _warn "$script_path not found — skipping"
    fi
  done
else
  echo ""
  _info "No integrations selected. You can run individual setup scripts later:"
  echo ""
  echo "    bash scripts/setup-slack.sh"
  echo "    bash scripts/setup-telegram.sh"
  echo "    bash scripts/setup-obsidian.sh"
  echo "    bash scripts/setup-notion.sh"
  echo "    bash scripts/setup-email-labels.sh"
fi

# ─── Phase 3: Workspace scaffold ─────────────────────────────────────────────

_h1 "Phase 3 · Workspace Scaffold"

WORKSPACE_DIR="${ALICE_WORKSPACE_DIR:-$HOME/.alice/workspace}"

echo "  Alice workspace will be created at:"
echo "  $(_bold "$WORKSPACE_DIR")"
echo ""
_ask "Use this path? (Enter to confirm, or type a different path):"
read -r CUSTOM_PATH </dev/tty

if [ -n "$CUSTOM_PATH" ]; then
  CUSTOM_PATH="${CUSTOM_PATH/#\~/$HOME}"
  WORKSPACE_DIR="$CUSTOM_PATH"
fi
export ALICE_WORKSPACE_DIR="$WORKSPACE_DIR"

_info "Scaffolding workspace..."
echo ""

bash "$SCRIPT_DIR/bootstrap-openclaw-workspace.sh" "$WORKSPACE_DIR"

# ─── Phase 4: Agent handoff ───────────────────────────────────────────────────

_h1 "Phase 4 · Agent Handoff"

PROMPT_FILE="$WORKSPACE_DIR/ALICE_BOOTSTRAP_PROMPT.txt"

cat << HANDOFF

  $(_bold "Setup complete! Here's how to start:")

  $(_bold "1.") Open your preferred AI agent:
     - Claude Code:    claude
     - OpenAI Canvas:  https://chatgpt.com
     - Any agent that can read files

  $(_bold "2.") Your bootstrap prompt is ready at:
     $(_cyan "$PROMPT_FILE")

  $(_bold "3.") Copy and paste the contents of that file as your
     first message to the agent.

  $(_bold "4.") Alice will run discovery, calibrate to your
     preferences, and deliver your first magic moment.

  $(_bold "Your workspace:") $WORKSPACE_DIR

HANDOFF

# Print quick-copy command for Claude Code users
if command -v claude >/dev/null 2>&1; then
  echo "  $(_bold "Quick start with Claude Code:")"
  echo "    $(_dim "claude \"\$(cat $PROMPT_FILE)\"")"
  echo ""
fi

_h2 "What Alice will do in the first session"
cat << 'WHATNEXT'
  · Ask about you, your work, and your top priorities
  · Map your sources of truth (Notion, email, Obsidian, etc.)
  · Build your identity files (USER.md, CONTEXT.md, GOALS.md)
  · Deliver one high-value workflow in the first hour
  · Set up a memory system that compounds over time

  Tip: the more context you give upfront, the better
  Alice will calibrate. Share your calendar, a recent
  email thread, or a current project brief.

WHATNEXT

echo "  $(_dim "Docs: $REPO_DIR/docs/")"
echo "  $(_dim "Examples: $REPO_DIR/examples/")"
echo ""
echo "  $(_green "Ready. Good luck.")"
echo ""
