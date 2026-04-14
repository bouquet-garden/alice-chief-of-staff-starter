#!/usr/bin/env bash
# setup-email-labels.sh — Create Alice Gmail labels via gam or manual instructions
# Reads label definitions from templates/email/gmail-labels.json
# Usage: bash scripts/setup-email-labels.sh

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
LABELS_FILE="$REPO_DIR/templates/email/gmail-labels.json"

# ─── colors ───────────────────────────────────────────────────────────────────
_ok()   { printf "\033[32m  ✅  %s\033[0m\n" "$*"; }
_info() { printf "\033[34m  ℹ️   %s\033[0m\n" "$*"; }
_warn() { printf "\033[33m  ⚠️   %s\033[0m\n" "$*"; }
_err()  { printf "\033[31m  ✗   %s\033[0m\n" "$*"; }
_h()    { printf "\n\033[1m%s\033[0m\n" "$*"; }

_h "Gmail Label Setup"

if [ ! -f "$LABELS_FILE" ]; then
  _err "gmail-labels.json not found at: $LABELS_FILE"
  exit 1
fi

# ─── parse label names ────────────────────────────────────────────────────────

_get_label_names() {
  if command -v jq >/dev/null 2>&1; then
    jq -r '.labels[].name' "$LABELS_FILE"
  elif command -v python3 >/dev/null 2>&1; then
    python3 -c "
import json
with open('$LABELS_FILE') as f:
    data = json.load(f)
for label in data['labels']:
    print(label['name'])
"
  else
    grep '"name"' "$LABELS_FILE" | sed 's/.*"name": *"\([^"]*\)".*/\1/'
  fi
}

_get_label_color() {
  local label_name="$1"
  if command -v jq >/dev/null 2>&1; then
    jq -r --arg n "$label_name" '.labels[] | select(.name == $n) | .color_hex // "#000000"' "$LABELS_FILE"
  elif command -v python3 >/dev/null 2>&1; then
    python3 -c "
import json, sys
with open('$LABELS_FILE') as f:
    data = json.load(f)
label = next((l for l in data['labels'] if l['name'] == sys.argv[1]), None)
print(label.get('color_hex', '#000000') if label else '#000000')
" "$label_name"
  else
    echo "#000000"
  fi
}

# ─── gam path ─────────────────────────────────────────────────────────────────

GAM_CMD=""
if command -v gam >/dev/null 2>&1; then
  GAM_CMD="gam"
fi

# ─── create labels via gam ────────────────────────────────────────────────────

echo ""

if [ -n "$GAM_CMD" ]; then
  _ok "gam found: $($GAM_CMD version 2>/dev/null | head -1 || echo 'gam')"
  echo ""
  _info "Creating labels via gam..."
  echo ""

  CREATED=0
  SKIPPED=0
  FAILED=0

  while IFS= read -r label_name; do
    [ -z "$label_name" ] && continue
    printf "  Creating label: %-40s " "$label_name ..."

    # gam create label; ignore error if label already exists
    if $GAM_CMD user me label "$label_name" 2>/dev/null; then
      _ok "created"
      CREATED=$((CREATED + 1))
    else
      # Could be existing or auth issue
      _info "already exists or skipped"
      SKIPPED=$((SKIPPED + 1))
    fi
  done < <(_get_label_names)

  echo ""
  _info "Result: $CREATED created, $SKIPPED skipped"
  echo ""
  _info "Note: gam cannot set label colors directly. Set colors manually in Gmail:"
  echo "    Gmail → Settings → Labels → hover over label → color dot"

else
  # ─── manual instructions fallback ────────────────────────────────────────────

  _warn "gam not found. Showing manual label creation instructions."
  echo ""
  echo "  Option A: Install gam (recommended for bulk label management)"
  echo "    https://github.com/GAM-team/GAM/wiki/How-to-Install-Advanced-GAM"
  echo "    Then re-run: bash scripts/setup-email-labels.sh"
  echo ""
  echo "  Option B: Create labels manually in Gmail"
  echo "    1. Open Gmail → Settings (gear) → See all settings → Labels"
  echo "    2. Scroll to 'Labels' section → click 'Create new label'"
  echo "    3. Create nested labels (e.g. 'Alice/P0') by using slashes in the name"
  echo ""
  echo "  Labels to create:"
  echo ""

  # Print all labels with their colors and purposes
  if command -v python3 >/dev/null 2>&1; then
    python3 -c "
import json
with open('$LABELS_FILE') as f:
    data = json.load(f)
for label in data['labels']:
    color = label.get('color_hex', '')
    purpose = label.get('purpose', '')
    print(f\"    {label['name']:<40} {color}  {purpose}\")
"
  elif command -v jq >/dev/null 2>&1; then
    jq -r '.labels[] | "    \(.name) \t\(.color_hex // "") \t\(.purpose // "")"' "$LABELS_FILE"
  else
    _get_label_names | while IFS= read -r name; do
      printf "    %s\n" "$name"
    done
  fi

  echo ""
  echo "  Option C: Use Gmail filters with a simpler label structure"
  echo "    Alice just needs: Alice/P0, Alice/P1, Alice/P2, Alice/P3,"
  echo "    Alice/Ball-With-Us, Alice/Ball-With-Them, Alice/Delegated,"
  echo "    Alice/Watching, Alice/Deferred, Alice/Done, Alice/Waiting"
fi

echo ""
