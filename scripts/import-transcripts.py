#!/usr/bin/env python3
"""
Transcript ingest skeleton for Alice v2.

Purpose:
- ingest transcript markdown files
- extract minimal metadata
- emit normalized JSON for downstream entity linking

This intentionally stays minimal and safe as a starter.
"""

import json
import re
import sys
from pathlib import Path


def extract_frontmatter(text: str):
    if not text.startswith('---\n'):
        return {}, text
    end = text.find('\n---\n', 4)
    if end == -1:
        return {}, text
    fm_raw = text[4:end]
    body = text[end + 5 :]
    fm = {}
    for line in fm_raw.splitlines():
        if ':' in line:
            k, v = line.split(':', 1)
            fm[k.strip()] = v.strip()
    return fm, body


def summarize(body: str):
    lines = [ln.strip() for ln in body.splitlines() if ln.strip()]
    return ' '.join(lines[:6])[:600]


def main():
    if len(sys.argv) < 2:
        print('usage: import-transcripts.py <directory>', file=sys.stderr)
        sys.exit(1)

    root = Path(sys.argv[1]).expanduser().resolve()
    if not root.exists() or not root.is_dir():
        print(f'not a directory: {root}', file=sys.stderr)
        sys.exit(1)

    out = []
    for p in sorted(root.rglob('*.md')):
        text = p.read_text(encoding='utf-8', errors='ignore')
        fm, body = extract_frontmatter(text)
        out.append(
            {
                'path': str(p),
                'title': fm.get('title') or p.stem,
                'date': fm.get('date'),
                'participants': fm.get('participants'),
                'company': fm.get('company'),
                'project': fm.get('project'),
                'source': fm.get('source', 'manual-md'),
                'summary': summarize(body),
            }
        )

    print(json.dumps({'count': len(out), 'transcripts': out}, indent=2))


if __name__ == '__main__':
    main()
