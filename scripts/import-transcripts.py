#!/usr/bin/env python3
"""
Transcript ingest for Alice v2.

Purpose:
- Ingest transcript markdown / plain-text files
- Extract entities: people, companies, projects, decisions, action items
- Emit normalized JSON for downstream entity linking and cache seeding

Supports:
- Granola MCP output (YAML frontmatter + markdown body)
- Raw markdown (no frontmatter)
- Single-file or batch (--directory) mode

Usage:
    # Single file
    python3 import-transcripts.py meeting.md

    # Directory batch
    python3 import-transcripts.py --directory ~/brain/meetings/raw

    # Dry run (no file output, prints to stdout)
    python3 import-transcripts.py --directory ~/brain/meetings/raw --dry-run

    # Write JSON for cache seeding
    python3 import-transcripts.py --directory ~/brain/meetings/raw --output-json /tmp/entities.json
"""

import argparse
import json
import os
import re
import sys
from pathlib import Path


# ---------------------------------------------------------------------------
# Frontmatter parsing
# ---------------------------------------------------------------------------

def extract_frontmatter(text: str):
    """
    Parse YAML-ish frontmatter delimited by '---'.
    Returns (dict, body_str). If no frontmatter, dict is empty and body is
    the full text.
    Supports list values under a key (indented '- item' lines).
    """
    if not text.startswith('---\n'):
        return {}, text
    end = text.find('\n---\n', 4)
    if end == -1:
        return {}, text
    fm_raw = text[4:end]
    body = text[end + 5:]
    fm = {}
    current_key = None
    for line in fm_raw.splitlines():
        # list item under current key
        if line.startswith('  - ') or line.startswith('- '):
            item = line.lstrip('- ').strip()
            if current_key:
                if not isinstance(fm[current_key], list):
                    fm[current_key] = [fm[current_key]] if fm[current_key] else []
                fm[current_key].append(item)
            continue
        if ':' in line:
            k, v = line.split(':', 1)
            current_key = k.strip()
            fm[current_key] = v.strip()
    return fm, body


# ---------------------------------------------------------------------------
# Entity extraction (heuristic / regex)
# ---------------------------------------------------------------------------

# Patterns for people: "FirstName LastName" with optional (Title at Company)
_PERSON_RE = re.compile(
    r'\b([A-Z][a-z]+(?:\s+[A-Z][a-z]+)+)'           # "First Last"
    r'(?:\s*[,\-–]\s*([A-Za-z &]+(?:at|@)\s*[A-Za-z ]+))?'  # optional role
)

# Known noise words that look like proper nouns but are not people/companies
_NOISE_WORDS = {
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
    'Today', 'Tomorrow', 'Yesterday', 'Next', 'Last', 'This',
    'Action', 'Items', 'Item', 'Summary', 'Notes', 'Note', 'Meeting',
    'Discussion', 'Agenda', 'Follow', 'Overview', 'Key', 'Points',
    'Context', 'Decisions', 'Decision', 'Risks', 'Risk', 'Project',
    'Company', 'Team', 'Group',
}

# Patterns for decisions
_DECISION_RE = re.compile(
    r'(?:we\s+decided|agreed\s+to|going\s+with|decision\s*[:–\-]|decided\s+to)\s+'
    r'(.+?)(?:[.!?]|$)',
    re.IGNORECASE
)

# Patterns for action items
_ACTION_RE = re.compile(
    r'(?:'
    r'(?:^|\s)(?:action\s*[:–\-]|TODO\s*[:–\-])\s*(.+?)'          # action: / TODO:
    r'|(?:@([A-Za-z]+))\s+(?:will\s+|to\s+)?(.+?)(?:[.!?]|$)'     # @person will ...
    r'|([A-Z][a-z]+(?:\s+[A-Z][a-z]+)?)\s+will\s+(.+?)(?:[.!?]|$)' # Person will ...
    r'|(?:by\s+(?:\d{4}-\d{2}-\d{2}|(?:Monday|Tuesday|Wednesday|Thursday|Friday|end\s+of\s+\w+)))'
    r')',
    re.IGNORECASE | re.MULTILINE
)

# Simpler pass for "will" sentences — captures owner + task
_WILL_RE = re.compile(
    r'\b([A-Z][a-z]+(?:\s+[A-Z][a-z]+)?)\s+will\s+(.+?)(?:[.!?\n]|$)'
)

# "action:" or "TODO:" lines
_ACTION_LINE_RE = re.compile(
    r'^(?:action|todo)\s*[:–\-]\s*(.+)',
    re.IGNORECASE
)

# "@mention will ..." or "- @mention ..."
_MENTION_RE = re.compile(
    r'@([A-Za-z]+)\s+(?:will\s+|to\s+)?(.+?)(?:[.!?\n]|$)',
    re.IGNORECASE
)

# Due date pattern
_DUE_RE = re.compile(
    r'\bby\s+(\d{4}-\d{2}-\d{2}|\w+\s+\d{1,2}(?:st|nd|rd|th)?|end\s+of\s+\w+|(?:Monday|Tuesday|Wednesday|Thursday|Friday))\b',
    re.IGNORECASE
)

# Project names: quoted names or "Project XYZ" / "Phase N" patterns
_PROJECT_RE = re.compile(
    r'\b(?:Project|Phase|Initiative|Program|Sprint)\s+([A-Z][A-Za-z0-9 \-]+)',
    re.IGNORECASE
)
_QUOTED_PROJECT_RE = re.compile(r'"([A-Z][A-Za-z0-9 \-]+)"')

# Organizations: "X Corp", "X Inc", "X Ltd", "X AI", "X Labs", etc.
_ORG_RE = re.compile(
    r'\b([A-Z][A-Za-z0-9]+'
    r'(?:\s+[A-Z][A-Za-z0-9]+)*'
    r'\s+(?:Corp|Inc|Ltd|LLC|GmbH|AI|Labs|Technologies|Solutions|Group|Studio|Studios|Systems|Platform|Platforms))\b'
)


def extract_people(text: str) -> list:
    seen = set()
    people = []
    for m in _PERSON_RE.finditer(text):
        name = m.group(1).strip()
        if name in _NOISE_WORDS or len(name.split()) < 2:
            continue
        # Skip if any part is a noise word
        if any(part in _NOISE_WORDS for part in name.split()):
            continue
        role = m.group(2).strip() if m.group(2) else ''
        key = name.lower()
        if key not in seen:
            seen.add(key)
            entry = {'name': name}
            if role:
                entry['role'] = role
            people.append(entry)
    return people


def extract_companies(text: str) -> list:
    seen = set()
    companies = []
    for m in _ORG_RE.finditer(text):
        name = m.group(1).strip()
        key = name.lower()
        if key not in seen:
            seen.add(key)
            companies.append(name)
    return companies


def extract_projects(text: str) -> list:
    seen = set()
    projects = []
    for m in _PROJECT_RE.finditer(text):
        name = m.group(0).strip()
        key = name.lower()
        if key not in seen:
            seen.add(key)
            projects.append(name)
    for m in _QUOTED_PROJECT_RE.finditer(text):
        name = m.group(1).strip()
        if name in _NOISE_WORDS:
            continue
        key = name.lower()
        if key not in seen:
            seen.add(key)
            projects.append(name)
    return projects


def extract_decisions(text: str) -> list:
    decisions = []
    for m in _DECISION_RE.finditer(text):
        text_frag = m.group(1).strip()
        if text_frag and len(text_frag) > 5:
            decisions.append({'decision': text_frag, 'owner': ''})
    return decisions


def extract_action_items(text: str) -> list:
    actions = []
    seen = set()

    def add(action_text, owner='', due=''):
        action_text = action_text.strip()
        if not action_text or len(action_text) < 5:
            return
        key = action_text.lower()[:60]
        if key in seen:
            return
        seen.add(key)
        entry = {'action': action_text, 'owner': owner, 'due': due}
        actions.append(entry)

    # Pass 1: action: / TODO: lines
    for line in text.splitlines():
        m = _ACTION_LINE_RE.match(line.strip())
        if m:
            frag = m.group(1).strip()
            due_m = _DUE_RE.search(frag)
            due = due_m.group(1) if due_m else ''
            add(frag, due=due)

    # Pass 2: @mention patterns
    for m in _MENTION_RE.finditer(text):
        owner = m.group(1)
        frag = m.group(2).strip()
        due_m = _DUE_RE.search(frag)
        due = due_m.group(1) if due_m else ''
        add(frag, owner=owner, due=due)

    # Pass 3: "Person will ..." sentences
    for m in _WILL_RE.finditer(text):
        name = m.group(1)
        if name in _NOISE_WORDS or any(part in _NOISE_WORDS for part in name.split()):
            continue
        frag = m.group(2).strip()
        due_m = _DUE_RE.search(frag)
        due = due_m.group(1) if due_m else ''
        add(frag, owner=name, due=due)

    return actions


def extract_entities(text: str) -> dict:
    companies = extract_companies(text)
    company_names_lower = {c.lower() for c in companies}
    # Filter people: skip any whose name matches a known company
    people_raw = extract_people(text)
    people = [
        p for p in people_raw
        if p['name'].lower() not in company_names_lower
        and not any(p['name'].lower() in c.lower() or c.lower() in p['name'].lower()
                    for c in companies)
    ]
    return {
        'people': people,
        'companies': companies,
        'projects': extract_projects(text),
        'decisions': extract_decisions(text),
        'action_items': extract_action_items(text),
    }


# ---------------------------------------------------------------------------
# Summarization
# ---------------------------------------------------------------------------

def summarize(body: str) -> str:
    lines = [ln.strip() for ln in body.splitlines() if ln.strip()]
    return ' '.join(lines[:6])[:600]


# ---------------------------------------------------------------------------
# Single-file processing
# ---------------------------------------------------------------------------

def process_file(p: Path) -> dict:
    text = p.read_text(encoding='utf-8', errors='ignore')
    fm, body = extract_frontmatter(text)
    entities = extract_entities(body)

    # Participants from frontmatter may be a comma-separated string or YAML list.
    # YAML list items often look like "name: Jane Smith" or "Jane Smith" — normalize both.
    fm_participants = fm.get('participants', '')
    if isinstance(fm_participants, list):
        raw_list = fm_participants
    elif fm_participants:
        raw_list = [s.strip() for s in re.split(r'[,;]', fm_participants) if s.strip()]
    else:
        raw_list = []

    fm_participants_list = []
    for item in raw_list:
        # Strip inline "name: " prefix produced by simple YAML list parser
        item = re.sub(r'^(?:name|participant)\s*:\s*', '', item, flags=re.IGNORECASE).strip()
        if item:
            fm_participants_list.append(item)

    # Merge frontmatter participants into extracted people (avoid duplicates)
    known_names = {p_['name'].lower() for p_ in entities['people']}
    for name in fm_participants_list:
        if name.lower() not in known_names:
            entities['people'].append({'name': name})
            known_names.add(name.lower())

    # Merge frontmatter company into companies
    fm_company = fm.get('company', '')
    if fm_company and fm_company.lower() not in {c.lower() for c in entities['companies']}:
        entities['companies'].append(fm_company)

    # Merge frontmatter project into projects
    fm_project = fm.get('project', '')
    if fm_project and fm_project.lower() not in {pr.lower() for pr in entities['projects']}:
        entities['projects'].append(fm_project)

    # Determine granola_id
    granola_id = fm.get('granola_id') or fm.get('id') or ''

    return {
        'path': str(p),
        'title': fm.get('title') or p.stem,
        'date': fm.get('date', ''),
        'type': fm.get('type', ''),
        'source': fm.get('source', 'manual-md'),
        'granola_id': granola_id,
        'summary': summarize(body),
        'entities': entities,
    }


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description='Import and extract entities from meeting transcripts.'
    )
    parser.add_argument(
        'file',
        nargs='?',
        help='Single transcript file to process (.md or .txt)',
    )
    parser.add_argument(
        '--directory', '-d',
        metavar='PATH',
        help='Process all .md/.txt files in this directory (recursive)',
    )
    parser.add_argument(
        '--output-json', '-o',
        metavar='PATH',
        help='Write JSON output to this file (for cache seeding)',
    )
    parser.add_argument(
        '--dry-run',
        action='store_true',
        help='Show what would be extracted without writing any files',
    )
    return parser


def collect_files(directory: str) -> list:
    root = Path(directory).expanduser().resolve()
    if not root.exists() or not root.is_dir():
        print(f'error: not a directory: {root}', file=sys.stderr)
        sys.exit(1)
    files = sorted(root.rglob('*.md')) + sorted(root.rglob('*.txt'))
    return files


def main():
    parser = build_parser()
    args = parser.parse_args()

    # Collect input files
    files = []
    if args.directory:
        files = collect_files(args.directory)
    elif args.file:
        p = Path(args.file).expanduser().resolve()
        if not p.exists() or not p.is_file():
            print(f'error: file not found: {p}', file=sys.stderr)
            sys.exit(1)
        files = [p]
    else:
        # Legacy positional-directory support (backward compatibility)
        # If no args at all, show usage.
        parser.print_usage(sys.stderr)
        sys.exit(1)

    if not files:
        print('No .md or .txt files found.', file=sys.stderr)
        sys.exit(0)

    results = []
    for p in files:
        record = process_file(p)
        results.append(record)

    output = {
        'count': len(results),
        'transcripts': results,
        # Flattened entity index for cache seeding
        'entity_index': {
            'people': _dedupe_people(results),
            'companies': _dedupe_list(results, 'companies'),
            'projects': _dedupe_list(results, 'projects'),
        },
    }

    output_str = json.dumps(output, indent=2)

    if args.dry_run:
        print('[dry-run] Would process the following files:')
        for p in files:
            print(f'  {p}')
        print()
        print('[dry-run] Extracted output (not written):')
        print(output_str)
        return

    if args.output_json:
        out_path = Path(args.output_json).expanduser().resolve()
        out_path.parent.mkdir(parents=True, exist_ok=True)
        out_path.write_text(output_str, encoding='utf-8')
        print(f'Wrote {len(results)} transcript(s) to {out_path}', file=sys.stderr)
    else:
        print(output_str)


# ---------------------------------------------------------------------------
# Entity deduplication helpers
# ---------------------------------------------------------------------------

def _dedupe_people(results: list) -> list:
    seen = {}
    for r in results:
        for person in r.get('entities', {}).get('people', []):
            key = person['name'].lower()
            if key not in seen:
                seen[key] = dict(person)
                seen[key].setdefault('mentioned_in', [])
            seen[key]['mentioned_in'].append(r['title'])
    return list(seen.values())


def _dedupe_list(results: list, field: str) -> list:
    seen = {}
    for r in results:
        for item in r.get('entities', {}).get(field, []):
            key = item.lower()
            if key not in seen:
                seen[key] = {'name': item, 'mentioned_in': []}
            seen[key]['mentioned_in'].append(r['title'])
    return list(seen.values())


if __name__ == '__main__':
    main()
