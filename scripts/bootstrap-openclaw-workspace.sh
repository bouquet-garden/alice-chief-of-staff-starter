#!/usr/bin/env bash
# bootstrap-openclaw-workspace.sh — Scaffold Alice workspace files
# Now called by alice-setup.sh (Phase 3) but still works standalone.
# Pre-populates TOOLS.md and SOURCES_OF_TRUTH.md with detected integrations.
#
# Usage:
#   bash scripts/bootstrap-openclaw-workspace.sh [TARGET_DIR]
#
# Environment variables (set by preflight.sh or manually):
#   ALICE_SLACK_OK, ALICE_TELEGRAM_OK, ALICE_NOTION_OK, ALICE_EMAIL_OK,
#   ALICE_OBSIDIAN_OK, ALICE_OBSIDIAN_VAULT, ALICE_GRANOLA_OK, ALICE_GBRAIN_OK

set -euo pipefail

TARGET="${1:-${OPENCLAW_WORKSPACE_DIR:-${ALICE_WORKSPACE_DIR:-$HOME/.alice/workspace}}}"
REPO_URL="${ALICE_STARTER_REPO_URL:-https://github.com/bouquet-garden/alice-chief-of-staff-starter.git}"

# ─── locate repo dir ──────────────────────────────────────────────────────────
# When called from alice-setup.sh the repo is already local; otherwise clone it.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMPLATES_DIR="$REPO_DIR/templates/workspace"

echo "→ Bootstrapping Alice workspace into: $TARGET"
mkdir -p "$TARGET"
mkdir -p "$TARGET/memory"

# ─── copy template files ──────────────────────────────────────────────────────
if [ -d "$TEMPLATES_DIR" ]; then
  # Local — copy directly
  cp -Rn "$TEMPLATES_DIR/." "$TARGET/" 2>/dev/null || true
else
  # Remote — clone then copy
  TMPDIR_CLONE="$(mktemp -d)"
  trap 'rm -rf "$TMPDIR_CLONE"' EXIT
  git clone --depth 1 "$REPO_URL" "$TMPDIR_CLONE/repo" >/dev/null 2>&1
  cp -Rn "$TMPDIR_CLONE/repo/templates/workspace/." "$TARGET/" 2>/dev/null || true
  TEMPLATES_DIR="$TMPDIR_CLONE/repo/templates/workspace"
fi

# Copy bootstrap prompt
PROMPT_SRC="$REPO_DIR/prompts/alice-bootstrap-prompt-v1.txt"
if [ -f "$PROMPT_SRC" ]; then
  cp "$PROMPT_SRC" "$TARGET/ALICE_BOOTSTRAP_PROMPT.txt"
fi

# Create today's memory file
TODAY="$(date +%F)"
if [ ! -f "$TARGET/memory/$TODAY.md" ] && [ -f "$TARGET/memory/README.md" ]; then
  cp "$TARGET/memory/README.md" "$TARGET/memory/$TODAY.md"
fi

# ─── pre-populate TOOLS.md with detected integrations ────────────────────────

TOOLS_FILE="$TARGET/TOOLS.md"

{
  echo "# TOOLS.md"
  echo ""
  echo "## Integration Status (detected by alice-setup.sh on $(date +%F))"
  echo ""

  if [ "${ALICE_GIT_OK:-0}" = "1" ]; then
    echo "- git: ✅ available"
  else
    echo "- git: ⚠️  not found"
  fi

  if [ "${ALICE_SLACK_OK:-0}" = "1" ]; then
    echo "- Slack CLI: ✅ available"
  else
    echo "- Slack CLI: ⚠️  not installed"
  fi

  if [ "${ALICE_TELEGRAM_OK:-0}" = "1" ]; then
    echo "- Telegram bot: ✅ TELEGRAM_BOT_TOKEN set"
  else
    echo "- Telegram bot: ⚠️  TELEGRAM_BOT_TOKEN not set"
  fi

  if [ "${ALICE_NOTION_OK:-0}" = "1" ]; then
    echo "- Notion API: ✅ NOTION_API_KEY set"
  else
    echo "- Notion API: ⚠️  NOTION_API_KEY not set"
  fi

  if [ "${ALICE_EMAIL_OK:-0}" = "1" ]; then
    if [ "${ALICE_GAM_OK:-0}" = "1" ]; then
      echo "- Gmail: ✅ gam available"
    else
      echo "- Gmail: ✅ gmail-cli available"
    fi
  else
    echo "- Gmail: ⚠️  neither gam nor gmail-cli found"
  fi

  if [ "${ALICE_OBSIDIAN_OK:-0}" = "1" ]; then
    echo "- Obsidian vault: ✅ ${ALICE_OBSIDIAN_VAULT:-detected}"
  else
    echo "- Obsidian vault: ⚠️  not detected at common paths"
  fi

  if [ "${ALICE_GRANOLA_OK:-0}" = "1" ]; then
    echo "- Granola: ✅ /Applications/Granola.app"
  else
    echo "- Granola: ⚠️  not installed"
  fi

  if [ "${ALICE_GBRAIN_OK:-0}" = "1" ]; then
    echo "- gbrain: ✅ available"
  else
    echo "- gbrain: ⚠️  not installed (optional)"
  fi

  echo ""
  echo "## Notes"
  echo ""
  echo "Record local tool paths, API credential locations, and workflow-specific"
  echo "caveats here as you configure integrations."
  echo ""
  echo "## Rule"
  echo "Never say \"I don't have access\" without checking first."
  echo ""
} > "$TOOLS_FILE"

# ─── pre-populate SOURCES_OF_TRUTH.md ────────────────────────────────────────

SOT_FILE="$TARGET/SOURCES_OF_TRUTH.md"

{
  echo "# SOURCES_OF_TRUTH.md"
  echo ""
  echo "## Active Integration Map (detected on $(date +%F))"
  echo ""

  if [ "${ALICE_NOTION_OK:-0}" = "1" ]; then
    echo "- Notion: ✅ ACTIVE — execution truth (projects, tasks, decisions)"
  else
    echo "- Notion: ⚠️  not configured — execution truth (configure NOTION_API_KEY)"
  fi

  echo "- Email: external commitment truth (configure via gam or manual Gmail access)"

  echo "- Calendar: planned time / meeting truth"

  if [ "${ALICE_OBSIDIAN_OK:-0}" = "1" ]; then
    VAULT_DISPLAY="${ALICE_OBSIDIAN_VAULT:-detected}"
    echo "- Obsidian: ✅ ACTIVE — strategic / intellectual truth (vault: $VAULT_DISPLAY)"
  else
    echo "- Obsidian: ⚠️  not configured — strategic / intellectual truth"
  fi

  if [ "${ALICE_SLACK_OK:-0}" = "1" ]; then
    echo "- Slack: ✅ ACTIVE — team-state signal"
  else
    echo "- Slack: ⚠️  not configured — team-state signal"
  fi

  if [ "${ALICE_GBRAIN_OK:-0}" = "1" ]; then
    echo "- GBrain: ✅ ACTIVE — normalized world knowledge"
  else
    echo "- GBrain: ⚠️  not installed — optional world knowledge layer"
  fi

  echo "- Memory: Alice operational memory (this workspace)"
  echo ""
  echo "## Reconciliation Rules"
  echo "- Slack can imply state changes, but does not override task truth by itself"
  echo "- email commitments should update task/project state when material"
  echo "- meeting decisions should be written down, not left in transcript-only form"
  echo ""
  echo "## Local Overrides"
  echo "-"
  echo ""
} > "$SOT_FILE"

# ─── done ─────────────────────────────────────────────────────────────────────

echo "✓ Workspace scaffold installed at: $TARGET"
echo ""
echo "Files created:"
echo "  $TARGET/TOOLS.md              ← pre-populated with detected integrations"
echo "  $TARGET/SOURCES_OF_TRUTH.md   ← pre-populated with active sources"
echo "  $TARGET/ALICE_BOOTSTRAP_PROMPT.txt"
echo "  (+ all other workspace template files)"
echo ""
