#!/usr/bin/env bash
# seed-from-transcripts.sh — Batch-process meeting transcripts into entity JSON
# Usage: seed-from-transcripts.sh [--directory PATH]

set -euo pipefail

# Defaults
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
TRANSCRIPT_DIR="${WORKSPACE_ROOT}/workspace/transcripts"
OUTPUT_DIR="${WORKSPACE_ROOT}/workspace/cache/entities"
IMPORT_SCRIPT="${SCRIPT_DIR}/import-transcripts.py"

# Parse flags
while [[ $# -gt 0 ]]; do
  case "$1" in
    --directory)
      TRANSCRIPT_DIR="$2"
      shift 2
      ;;
    --output)
      OUTPUT_DIR="$2"
      shift 2
      ;;
    *)
      echo "Unknown flag: $1" >&2
      echo "Usage: $0 [--directory PATH] [--output DIR]" >&2
      exit 1
      ;;
  esac
done

# Resolve paths
if [[ "${TRANSCRIPT_DIR}" != /* ]]; then
  TRANSCRIPT_DIR="${WORKSPACE_ROOT}/${TRANSCRIPT_DIR}"
fi
if [[ "${OUTPUT_DIR}" != /* ]]; then
  OUTPUT_DIR="${WORKSPACE_ROOT}/${OUTPUT_DIR}"
fi

echo "==> seed-from-transcripts: scanning ${TRANSCRIPT_DIR}"

# Check python3
if ! command -v python3 &>/dev/null; then
  echo "ERROR: python3 not found. Install Python 3 to use transcript seeding." >&2
  exit 1
fi

# Check import script
if [[ ! -f "${IMPORT_SCRIPT}" ]]; then
  echo "ERROR: import-transcripts.py not found at ${IMPORT_SCRIPT}" >&2
  exit 1
fi

# Check transcript directory
if [[ ! -d "${TRANSCRIPT_DIR}" ]]; then
  echo "  WARNING: Transcript directory not found: ${TRANSCRIPT_DIR}"
  echo "  Creating empty directory for future use."
  mkdir -p "${TRANSCRIPT_DIR}"
  echo "  No transcripts to process."
  echo "==> seed-from-transcripts: done (0 files processed)"
  exit 0
fi

mkdir -p "${OUTPUT_DIR}"

# Find all .md and .txt files
TRANSCRIPT_FILES=()
while IFS= read -r -d $'\0' f; do
  TRANSCRIPT_FILES+=("$f")
done < <(find "${TRANSCRIPT_DIR}" \( -name "*.md" -o -name "*.txt" \) -print0 2>/dev/null | sort -z)

TOTAL=${#TRANSCRIPT_FILES[@]}
echo "  Found ${TOTAL} transcript file(s)"

if [[ ${TOTAL} -eq 0 ]]; then
  echo "  No transcript files found. Skipping."
  echo "==> seed-from-transcripts: done (0 files processed)"
  exit 0
fi

TODAY=$(date +%Y-%m-%d)
AGGREGATED_FILE="${OUTPUT_DIR}/transcripts-${TODAY}.json"

# Process each transcript file
PROCESSED=0
FAILED=0
ALL_ENTITIES="[]"

for transcript_file in "${TRANSCRIPT_FILES[@]}"; do
  echo "  Processing: $(basename "${transcript_file}")"

  output_json=$(python3 "${IMPORT_SCRIPT}" "${transcript_file}" 2>/dev/null) && rc=0 || rc=$?

  if [[ ${rc} -ne 0 ]]; then
    echo "    WARNING: import failed for ${filename}" >&2
    FAILED=$((FAILED + 1))
    continue
  fi

  # Merge into aggregate
  ALL_ENTITIES=$(EXISTING="${ALL_ENTITIES}" NEW="${output_json}" python3 -c "
import json, sys, os
try:
    existing = json.loads(os.environ['EXISTING'])
except Exception:
    existing = []

try:
    new_batch = json.loads(os.environ['NEW'])
    new_items = new_batch.get('transcripts', [])
except Exception:
    new_items = []

existing.extend(new_items)
print(json.dumps(existing))
" 2>/dev/null || echo "${ALL_ENTITIES}")

  PROCESSED=$((PROCESSED + 1))
done

# Write aggregated output
python3 - "${AGGREGATED_FILE}" "${PROCESSED}" "${FAILED}" "${TODAY}" <<PYEOF
import json
import sys
from datetime import datetime, timezone

output_file = sys.argv[1]
processed = int(sys.argv[2])
failed = int(sys.argv[3])
today = sys.argv[4]

entities_raw = """${ALL_ENTITIES}"""
try:
    entities = json.loads(entities_raw)
except Exception:
    entities = []

# Deduplicate by path
seen = set()
deduped = []
for e in entities:
    key = e.get("path", "") + e.get("title", "")
    if key not in seen:
        seen.add(key)
        deduped.append(e)

output = {
    "generated_at": datetime.now(timezone.utc).isoformat(),
    "files_processed": processed,
    "files_failed": failed,
    "entity_count": len(deduped),
    "entities": deduped,
}

with open(output_file, "w") as f:
    json.dump(output, f, indent=2)
PYEOF

ENTITY_COUNT=$(python3 -c "import json; d=json.load(open('${AGGREGATED_FILE}')); print(d.get('entity_count',0))" 2>/dev/null || echo 0)

echo ""
echo "  Summary:"
echo "    Files processed : ${PROCESSED}"
echo "    Files failed    : ${FAILED}"
echo "    Entities found  : ${ENTITY_COUNT}"
echo "    Output file     : ${AGGREGATED_FILE}"
echo ""
echo "==> seed-from-transcripts: done"
