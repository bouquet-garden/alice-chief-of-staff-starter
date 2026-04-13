#!/usr/bin/env bash
set -euo pipefail

if ! command -v bun >/dev/null 2>&1; then
  echo "bun is required. Install it first: https://bun.sh"
  exit 1
fi

if [ -d "$HOME/gbrain/.git" ]; then
  cd "$HOME/gbrain"
  git pull --ff-only
else
  git clone --depth 1 https://github.com/garrytan/gbrain.git "$HOME/gbrain"
  cd "$HOME/gbrain"
fi

bun install
bun link
mkdir -p "$HOME/.gbrain/brain.pglite"
gbrain init --pglite || true

echo "✓ GBrain installed"
echo "Note: if OPENAI_API_KEY is missing, use gbrain search (keyword search) until embeddings are configured."
