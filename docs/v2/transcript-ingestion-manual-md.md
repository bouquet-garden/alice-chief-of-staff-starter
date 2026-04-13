# Transcript Ingestion — Manual Markdown Route

Use this when Granola MCP is unavailable.

## Folder convention

- `brain/meetings/raw/`
- `brain/meetings/processed/`

## Frontmatter convention

```yaml
---
title: "Meeting title"
date: "2026-04-13"
participants: "Alice, Bob"
company: "Example Co"
project: "Project X"
source: "manual-md"
---
```

## Ingestion

```bash
python3 scripts/import-transcripts.py ~/brain/meetings/raw > /tmp/transcripts.json
```

## Next step

Feed normalized output into entity linking and briefing generation.
