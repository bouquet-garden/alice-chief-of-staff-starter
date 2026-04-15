#!/usr/bin/env bash
# setup-obsidian.sh — Scaffold Alice PARA structure in an Obsidian vault
# Copies templates/obsidian/ into the detected or specified vault path
# Usage: bash scripts/setup-obsidian.sh  OR  ALICE_OBSIDIAN_VAULT=/path bash scripts/setup-obsidian.sh

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
OBSIDIAN_TEMPLATE="$REPO_DIR/templates/obsidian"

# ─── colors ───────────────────────────────────────────────────────────────────
_ok()   { printf "\033[32m  ✅  %s\033[0m\n" "$*"; }
_info() { printf "\033[34m  ℹ️   %s\033[0m\n" "$*"; }
_warn() { printf "\033[33m  ⚠️   %s\033[0m\n" "$*"; }
_err()  { printf "\033[31m  ✗   %s\033[0m\n" "$*"; }
_h()    { printf "\n\033[1m%s\033[0m\n" "$*"; }

_h "Obsidian Vault Setup"

# ─── locate vault ─────────────────────────────────────────────────────────────

VAULT_PATH="${ALICE_OBSIDIAN_VAULT:-}"

if [ -z "$VAULT_PATH" ]; then
  # Try common locations
  for candidate in \
      "$HOME/Documents/Obsidian" \
      "$HOME/Obsidian" \
      "$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents"; do
    if [ -d "$candidate" ]; then
      VAULT_PATH="$candidate"
      break
    fi
  done
fi

if [ -z "$VAULT_PATH" ] || [ ! -d "$VAULT_PATH" ]; then
  echo ""
  _warn "Obsidian vault not found at common paths."
  echo ""
  echo "  Common vault locations:"
  echo "    ~/Documents/Obsidian"
  echo "    ~/Obsidian"
  echo "    ~/Library/Mobile Documents/iCloud~md~obsidian/Documents"
  echo ""
  printf "  Enter your vault path (or press Enter to skip): "
  read -r VAULT_PATH </dev/tty

  if [ -z "$VAULT_PATH" ]; then
    _warn "No vault path provided. Skipping Obsidian setup."
    echo "  Re-run with: ALICE_OBSIDIAN_VAULT=/your/vault bash scripts/setup-obsidian.sh"
    exit 0
  fi

  # Expand tilde
  VAULT_PATH="${VAULT_PATH/#\~/$HOME}"

  if [ ! -d "$VAULT_PATH" ]; then
    _err "Directory not found: $VAULT_PATH"
    exit 1
  fi
fi

_ok "Vault: $VAULT_PATH"

# ─── check template ───────────────────────────────────────────────────────────

if [ ! -d "$OBSIDIAN_TEMPLATE" ]; then
  _err "Obsidian template not found at: $OBSIDIAN_TEMPLATE"
  exit 1
fi

# ─── scaffold PARA structure ──────────────────────────────────────────────────

ALICE_VAULT_DIR="$VAULT_PATH/Alice"
echo ""
_info "Scaffolding Alice PARA structure into: $ALICE_VAULT_DIR"
echo ""

mkdir -p "$ALICE_VAULT_DIR"

# Copy the template tree into the Alice subfolder, skipping existing files.
# cp -Rn (no-overwrite) handles most cases; we fall back to find for a merge.
_copy_no_overwrite() {
  local src="$1"
  local dst="$2"
  mkdir -p "$dst"
  # Use find to enumerate all files, then copy each individually if absent
  find "$src" -type f | while IFS= read -r src_file; do
    rel="${src_file#$src/}"
    dst_file="$dst/$rel"
    dst_dir="$(dirname "$dst_file")"
    mkdir -p "$dst_dir"
    if [ ! -e "$dst_file" ]; then
      cp "$src_file" "$dst_file"
      _ok "Copied: Alice/${rel}"
    else
      _info "Kept existing: Alice/${rel}"
    fi
  done
}

_copy_no_overwrite "$OBSIDIAN_TEMPLATE" "$ALICE_VAULT_DIR"
_ok "PARA scaffold installed at: $ALICE_VAULT_DIR"

# ─── plugin recommendations ───────────────────────────────────────────────────

echo ""
_h "Recommended Obsidian Plugins"
echo ""
echo "  Install these community plugins for the best Alice experience:"
echo ""
echo "    1. Templater    — dynamic templates and date-aware notes"
echo "       https://github.com/SilentVoid13/Templater"
echo ""
echo "    2. Dataview     — query and table views across your vault"
echo "       https://github.com/blacksmithgu/obsidian-dataview"
echo ""
echo "    3. Tasks        — task tracking with due dates and filters"
echo "       https://github.com/obsidian-tasks-group/obsidian-tasks"
echo ""
echo "    4. Calendar     — daily notes with a calendar side panel"
echo "       https://github.com/liamcain/obsidian-calendar-plugin"
echo ""
echo "  To install: Obsidian → Settings → Community Plugins → Browse → search by name"
echo ""

# ─── export vault path for parent script ──────────────────────────────────────
export ALICE_OBSIDIAN_VAULT="$VAULT_PATH"
_ok "Obsidian setup complete."
echo ""
