#!/usr/bin/env bash
set -euo pipefail

mkdir -p "$HOME/.claude/skills"
if [ -d "$HOME/.claude/skills/gstack/.git" ]; then
  cd "$HOME/.claude/skills/gstack"
  git pull --ff-only
else
  git clone --depth 1 https://github.com/garrytan/gstack.git "$HOME/.claude/skills/gstack"
  cd "$HOME/.claude/skills/gstack"
fi

./setup --host claude --quiet --no-prefix

echo "✓ Gstack installed into ~/.claude/skills/gstack"
echo "Use it selectively for heavier Claude Code / ACP coding sessions."
