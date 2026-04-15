#!/usr/bin/env bash
# setup-notion.sh — Create Alice Notion databases via the Notion API
# Reads schemas from templates/notion/database-schemas.json
# Saves created database IDs to workspace/NOTION_IDS.env
# Usage: bash scripts/setup-notion.sh

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SCHEMAS_FILE="$REPO_DIR/templates/notion/database-schemas.json"
NOTION_IDS_FILE="$REPO_DIR/workspace/NOTION_IDS.env"

# ─── colors ───────────────────────────────────────────────────────────────────
_ok()   { printf "\033[32m  ✅  %s\033[0m\n" "$*"; }
_info() { printf "\033[34m  ℹ️   %s\033[0m\n" "$*"; }
_warn() { printf "\033[33m  ⚠️   %s\033[0m\n" "$*"; }
_err()  { printf "\033[31m  ✗   %s\033[0m\n" "$*"; }
_h()    { printf "\n\033[1m%s\033[0m\n" "$*"; }

_h "Notion Database Setup"

# ─── dependency check ─────────────────────────────────────────────────────────

if [ -z "${NOTION_API_KEY:-}" ]; then
  _warn "NOTION_API_KEY is not set. Skipping Notion setup."
  echo ""
  echo "  To create a Notion integration:"
  echo "    1. Go to https://www.notion.so/my-integrations"
  echo "    2. Click '+ New integration'"
  echo "    3. Give it a name (e.g. 'Alice')"
  echo "    4. Copy the 'Internal Integration Token' (starts with secret_...)"
  echo "    5. export NOTION_API_KEY=secret_..."
  echo "    6. Re-run: bash scripts/setup-notion.sh"
  exit 0
fi

if ! command -v curl >/dev/null 2>&1; then
  _err "curl is required but not found"
  exit 1
fi

if [ ! -f "$SCHEMAS_FILE" ]; then
  _err "database-schemas.json not found at: $SCHEMAS_FILE"
  exit 1
fi

NOTION_API="https://api.notion.com/v1"
NOTION_VERSION="2022-06-28"

# ─── verify API key ───────────────────────────────────────────────────────────

echo ""
_info "Verifying Notion API key..."
USER_RESPONSE="$(curl -sf \
  -H "Authorization: Bearer $NOTION_API_KEY" \
  -H "Notion-Version: $NOTION_VERSION" \
  "$NOTION_API/users/me" 2>/dev/null || echo '{"object":"error"}')"

if echo "$USER_RESPONSE" | grep -q '"object":"user"'; then
  NOTION_USER="$(echo "$USER_RESPONSE" | grep -o '"name":"[^"]*"' | head -1 | cut -d'"' -f4)"
  _ok "Authenticated as: $NOTION_USER"
else
  _err "Notion API key verification failed. Check NOTION_API_KEY."
  exit 1
fi

# ─── get parent page ID ───────────────────────────────────────────────────────

PARENT_PAGE_ID="${NOTION_PARENT_PAGE_ID:-}"

if [ -z "$PARENT_PAGE_ID" ]; then
  echo ""
  _info "Where to find the parent page ID:"
  echo ""
  echo "  1. Open Notion and navigate to (or create) a page for Alice"
  echo "  2. Click 'Share' and enable access for your integration"
  echo "  3. Copy the page URL — the ID is the last part of the URL:"
  echo "     https://notion.so/My-Alice-Page-abc123def456..."
  echo "                                       ^^^^^^^^^^^^^^^^"
  echo "     The ID is: abc123de-f456-... (32 hex chars, with or without dashes)"
  echo ""
  printf "  Enter the parent page ID (or press Enter to skip): "
  read -r PARENT_PAGE_ID </dev/tty

  if [ -z "$PARENT_PAGE_ID" ]; then
    _warn "No parent page ID provided. Skipping database creation."
    echo "  Re-run with: NOTION_PARENT_PAGE_ID=your_page_id bash scripts/setup-notion.sh"
    exit 0
  fi
fi

# Normalize: strip dashes if present, then re-insert in UUID format
PARENT_PAGE_ID="$(echo "$PARENT_PAGE_ID" | tr -d '-')"
# Re-format as UUID if it looks like 32 hex chars
if [ "${#PARENT_PAGE_ID}" -eq 32 ]; then
  PARENT_PAGE_ID="${PARENT_PAGE_ID:0:8}-${PARENT_PAGE_ID:8:4}-${PARENT_PAGE_ID:12:4}-${PARENT_PAGE_ID:16:4}-${PARENT_PAGE_ID:20:12}"
fi
_ok "Parent page: $PARENT_PAGE_ID"

# ─── ensure workspace dir exists ──────────────────────────────────────────────

mkdir -p "$REPO_DIR/workspace"

# ─── build Notion property schema from our JSON ───────────────────────────────

# Map our type names to Notion API property types
_notion_property_json() {
  local name="$1"
  local type="$2"
  shift 2
  local options_json="${1:-}"

  case "$type" in
    title)
      printf '"%s":{"title":{}}' "$name"
      ;;
    rich_text)
      printf '"%s":{"rich_text":{}}' "$name"
      ;;
    select)
      # Build options array from comma-separated or JSON array
      printf '"%s":{"select":{"options":%s}}' "$name" "${options_json:-[]}"
      ;;
    multi_select)
      printf '"%s":{"multi_select":{"options":%s}}' "$name" "${options_json:-[]}"
      ;;
    date)
      printf '"%s":{"date":{}}' "$name"
      ;;
    people)
      printf '"%s":{"people":{}}' "$name"
      ;;
    checkbox)
      printf '"%s":{"checkbox":{}}' "$name"
      ;;
    url)
      printf '"%s":{"url":{}}' "$name"
      ;;
    email)
      printf '"%s":{"email":{}}' "$name"
      ;;
    phone_number)
      printf '"%s":{"phone_number":{}}' "$name"
      ;;
    number)
      printf '"%s":{"number":{}}' "$name"
      ;;
    last_edited_time)
      printf '"%s":{"last_edited_time":{}}' "$name"
      ;;
    created_time)
      printf '"%s":{"created_time":{}}' "$name"
      ;;
    relation)
      printf '"%s":{"rich_text":{}}' "$name"
      ;;
    *)
      printf '"%s":{"rich_text":{}}' "$name"
      ;;
  esac
}

# ─── create each database ─────────────────────────────────────────────────────

echo ""
_info "Creating databases from: $SCHEMAS_FILE"
echo ""

CREATED=0
FAILED=0

# Use python3 for JSON parsing since the schema is complex
if ! command -v python3 >/dev/null 2>&1 && ! command -v jq >/dev/null 2>&1; then
  _err "python3 or jq is required to parse database schemas"
  exit 1
fi

_get_database_names() {
  if command -v jq >/dev/null 2>&1; then
    jq -r '.databases[].name' "$SCHEMAS_FILE"
  else
    python3 -c "
import json
with open('$SCHEMAS_FILE') as f:
    data = json.load(f)
for db in data['databases']:
    print(db['name'])
"
  fi
}

_build_properties_json() {
  local db_name="$1"
  if command -v python3 >/dev/null 2>&1; then
    python3 -c "
import json, sys

with open('$SCHEMAS_FILE') as f:
    data = json.load(f)

db = next((d for d in data['databases'] if d['name'] == sys.argv[1]), None)
if not db:
    print('{}')
    sys.exit(0)

props = {}
for p in db.get('properties', []):
    name = p['name']
    ptype = p.get('type', 'rich_text')

    if ptype == 'title':
        props[name] = {'title': {}}
    elif ptype == 'rich_text':
        props[name] = {'rich_text': {}}
    elif ptype in ('select', 'multi_select'):
        options_list = p.get('options', [])
        options = [{'name': o, 'color': 'default'} for o in options_list]
        props[name] = {ptype: {'options': options}}
    elif ptype == 'date':
        props[name] = {'date': {}}
    elif ptype == 'people':
        props[name] = {'people': {}}
    elif ptype == 'checkbox':
        props[name] = {'checkbox': {}}
    elif ptype == 'url':
        props[name] = {'url': {}}
    elif ptype == 'email':
        props[name] = {'email': {}}
    elif ptype == 'number':
        props[name] = {'number': {}}
    elif ptype == 'last_edited_time':
        props[name] = {'last_edited_time': {}}
    elif ptype == 'created_time':
        props[name] = {'created_time': {}}
    else:
        props[name] = {'rich_text': {}}

print(json.dumps(props))
" "$db_name"
  elif command -v jq >/dev/null 2>&1; then
    jq -r --arg name "$db_name" '
      .databases[] | select(.name == $name) | .properties |
      reduce .[] as $p ({};
        . + {
          ($p.name): (
            if $p.type == "title" then {"title":{}}
            elif $p.type == "rich_text" then {"rich_text":{}}
            elif $p.type == "select" then {"select":{"options": ($p.options // [] | map({"name":., "color":"default"}))}}
            elif $p.type == "multi_select" then {"multi_select":{"options": ($p.options // [] | map({"name":., "color":"default"}))}}
            elif $p.type == "date" then {"date":{}}
            elif $p.type == "people" then {"people":{}}
            elif $p.type == "checkbox" then {"checkbox":{}}
            elif $p.type == "url" then {"url":{}}
            elif $p.type == "number" then {"number":{}}
            elif $p.type == "last_edited_time" then {"last_edited_time":{}}
            elif $p.type == "created_time" then {"created_time":{}}
            else {"rich_text":{}}
            end
          )
        }
      )
    ' "$SCHEMAS_FILE"
  fi
}

_get_db_description() {
  local db_name="$1"
  if command -v python3 >/dev/null 2>&1; then
    python3 -c "
import json, sys
with open('$SCHEMAS_FILE') as f:
    data = json.load(f)
db = next((d for d in data['databases'] if d['name'] == sys.argv[1]), None)
print(db.get('description', '') if db else '')
" "$db_name"
  elif command -v jq >/dev/null 2>&1; then
    jq -r --arg name "$db_name" '.databases[] | select(.name == $name) | .description // ""' "$SCHEMAS_FILE"
  fi
}

while IFS= read -r db_name; do
  [ -z "$db_name" ] && continue
  printf "  Creating database: %-30s " "$db_name ..."

  props_json="$(_build_properties_json "$db_name")"
  description="$(_get_db_description "$db_name")"

  # Build the request body
  request_body="$(python3 -c "
import json, sys

props = json.loads(sys.argv[1])
description = sys.argv[2]
parent_id = sys.argv[3]
db_name = sys.argv[4]

body = {
    'parent': {'type': 'page_id', 'page_id': parent_id},
    'title': [{'type': 'text', 'text': {'content': db_name}}],
    'properties': props
}
if description:
    body['description'] = [{'type': 'text', 'text': {'content': description}}]

print(json.dumps(body))
" "$props_json" "$description" "$PARENT_PAGE_ID" "$db_name" 2>/dev/null)"

  if [ -z "$request_body" ]; then
    _warn "failed to build request body"
    FAILED=$((FAILED + 1))
    continue
  fi

  RESPONSE="$(curl -sf -X POST "$NOTION_API/databases" \
    -H "Authorization: Bearer $NOTION_API_KEY" \
    -H "Notion-Version: $NOTION_VERSION" \
    -H "Content-Type: application/json" \
    -d "$request_body" 2>/dev/null || echo '{"object":"error"}')"

  if echo "$RESPONSE" | grep -q '"object":"database"'; then
    DB_ID="$(echo "$RESPONSE" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)"
    _ok "created (id: $DB_ID)"
    # Sanitize the name for use as an env var key
    ENV_KEY="NOTION_DB_$(echo "$db_name" | tr '[:lower:] ' '[:upper:]_' | tr -cd 'A-Z0-9_')"
    echo "export $ENV_KEY=$DB_ID" >> "$NOTION_IDS_FILE"
    CREATED=$((CREATED + 1))
  else
    ERROR_MSG="$(echo "$RESPONSE" | grep -o '"message":"[^"]*"' | head -1 | cut -d'"' -f4)"
    _warn "failed: $ERROR_MSG"
    FAILED=$((FAILED + 1))
  fi

done < <(_get_database_names)

echo ""
_info "Result: $CREATED created, $FAILED failed"

if [ "$CREATED" -gt 0 ]; then
  _ok "Database IDs saved to: $NOTION_IDS_FILE"
  echo "  Source this file to use IDs in other scripts:"
  echo "    source $NOTION_IDS_FILE"
fi
echo ""
