#!/usr/bin/env bash
# preflight.sh — Detect available tools and integrations for Alice setup
# Exports detected values as environment variables for child scripts.
# Usage: source scripts/preflight.sh   OR   bash scripts/preflight.sh

set -uo pipefail

# ─── helpers ──────────────────────────────────────────────────────────────────

_ok()   { printf "  \033[32m✅\033[0m  %s\n" "$*"; }
_warn() { printf "  \033[33m⚠️ \033[0m  %s\n" "$*"; }

# ─── required: git ─────────────────────────────────────────────────────────────

if command -v git >/dev/null 2>&1; then
  _ok "git: $(git --version 2>/dev/null | head -1)"
  export ALICE_GIT_OK=1
else
  _warn "git: not found — git is required for workspace scaffolding"
  export ALICE_GIT_OK=0
fi

# ─── required: working directory ──────────────────────────────────────────────

export ALICE_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
export ALICE_REPO_DIR="$(cd "$ALICE_SCRIPT_DIR/.." && pwd)"
export ALICE_WORKSPACE_DIR="${ALICE_WORKSPACE_DIR:-$HOME/.alice/workspace}"
_ok "working directory: $ALICE_REPO_DIR"

# ─── optional: jq ─────────────────────────────────────────────────────────────

if command -v jq >/dev/null 2>&1; then
  export ALICE_JQ_OK=1
else
  export ALICE_JQ_OK=0
fi

# ─── optional: Slack CLI ───────────────────────────────────────────────────────

if command -v slack >/dev/null 2>&1; then
  _ok "Slack CLI: found ($(slack version 2>/dev/null | head -1 || echo 'unknown version'))"
  export ALICE_SLACK_OK=1
else
  _warn "Slack CLI: not found  (optional — install from https://api.slack.com/automation/cli/install)"
  export ALICE_SLACK_OK=0
fi

# ─── optional: Telegram bot token ─────────────────────────────────────────────

if [ -n "${TELEGRAM_BOT_TOKEN:-}" ]; then
  _ok "Telegram: TELEGRAM_BOT_TOKEN is set"
  export ALICE_TELEGRAM_OK=1
else
  _warn "Telegram: no TELEGRAM_BOT_TOKEN set  (skip or: export TELEGRAM_BOT_TOKEN=your_token)"
  export ALICE_TELEGRAM_OK=0
fi

# ─── optional: Notion API key ─────────────────────────────────────────────────

if [ -n "${NOTION_API_KEY:-}" ]; then
  _ok "Notion: NOTION_API_KEY is set"
  export ALICE_NOTION_OK=1
else
  _warn "Notion: no NOTION_API_KEY set  (skip or: export NOTION_API_KEY=secret_...)"
  export ALICE_NOTION_OK=0
fi

# ─── optional: Gmail / gam ────────────────────────────────────────────────────

if command -v gam >/dev/null 2>&1; then
  _ok "Gmail (gam): found"
  export ALICE_GAM_OK=1
  export ALICE_EMAIL_OK=1
elif command -v gmail-cli >/dev/null 2>&1; then
  _ok "Gmail (gmail-cli): found"
  export ALICE_GAM_OK=0
  export ALICE_EMAIL_OK=1
else
  _warn "Gmail: neither 'gam' nor 'gmail-cli' found  (optional — labels will be shown as manual instructions)"
  export ALICE_GAM_OK=0
  export ALICE_EMAIL_OK=0
fi

# ─── optional: Obsidian vault ─────────────────────────────────────────────────

ALICE_OBSIDIAN_VAULT=""
for candidate in \
    "$HOME/Documents/Obsidian" \
    "$HOME/Obsidian" \
    "$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents"; do
  if [ -d "$candidate" ]; then
    ALICE_OBSIDIAN_VAULT="$candidate"
    break
  fi
done

if [ -n "$ALICE_OBSIDIAN_VAULT" ]; then
  _ok "Obsidian vault: $ALICE_OBSIDIAN_VAULT"
  export ALICE_OBSIDIAN_OK=1
  export ALICE_OBSIDIAN_VAULT
else
  _warn "Obsidian vault: not found at common paths  (will prompt during setup-obsidian)"
  export ALICE_OBSIDIAN_OK=0
  export ALICE_OBSIDIAN_VAULT=""
fi

# ─── optional: Granola ────────────────────────────────────────────────────────

if [ -d "/Applications/Granola.app" ]; then
  _ok "Granola: /Applications/Granola.app"
  export ALICE_GRANOLA_OK=1
else
  _warn "Granola: not found  (optional — install from https://granola.ai)"
  export ALICE_GRANOLA_OK=0
fi

# ─── optional: gbrain ─────────────────────────────────────────────────────────

if command -v gbrain >/dev/null 2>&1; then
  _ok "gbrain: found"
  export ALICE_GBRAIN_OK=1
else
  _warn "gbrain: not installed  (optional — install with: bash $ALICE_SCRIPT_DIR/install-gbrain.sh)"
  export ALICE_GBRAIN_OK=0
fi

echo ""
