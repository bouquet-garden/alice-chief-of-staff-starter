#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-${OPENCLAW_WORKSPACE_DIR:-$HOME/.openclaw/workspace}}"
REPO_URL="${ALICE_STARTER_REPO_URL:-https://github.com/bouquet-garden/alice-chief-of-staff-starter.git}"
TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

echo "→ Bootstrapping Alice workspace into: $TARGET"
mkdir -p "$TARGET"

if [ -d "$REPO_URL" ]; then
  cp -R "$REPO_URL" "$TMPDIR/repo"
else
  git clone --depth 1 "$REPO_URL" "$TMPDIR/repo" >/dev/null 2>&1
fi
mkdir -p "$TARGET/memory"
cp -R "$TMPDIR/repo/templates/workspace/." "$TARGET/"
cp "$TMPDIR/repo/prompts/alice-bootstrap-prompt-v1.txt" "$TARGET/ALICE_BOOTSTRAP_PROMPT.txt"

TODAY="$(date +%F)"
if [ ! -f "$TARGET/memory/$TODAY.md" ]; then
  cp "$TMPDIR/repo/templates/workspace/memory/README.md" "$TARGET/memory/$TODAY.md"
fi

echo "✓ Workspace scaffold installed"
echo "Next steps:"
echo "  1. Open $TARGET/ALICE_BOOTSTRAP_PROMPT.txt"
echo "  2. Run discovery with the founder"
echo "  3. Fill USER.md, SOURCES_OF_TRUTH.md, GOALS.md, CONTEXT.md"
echo "  4. Produce one first magic moment"
