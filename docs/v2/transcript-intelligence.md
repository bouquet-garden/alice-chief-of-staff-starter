# Transcript Intelligence (v2)

Call transcripts are first-class source-of-truth inputs. Every meeting produces
structured intelligence that feeds Alice's world-state cache, briefing pipeline,
and follow-up drafts.

---

## Ingestion routes

### Route A: Granola MCP

Granola exposes a local MCP server that Alice queries directly.

**Setup:**
1. Install Granola and sign in: https://granola.so
2. Enable the local MCP server in Granola's settings (Settings → Integrations → MCP).
3. Add the server to your Claude Desktop or Alice config:

```json
{
  "mcpServers": {
    "granola": {
      "command": "npx",
      "args": ["-y", "@granola-hq/mcp-server-granola"]
    }
  }
}
```

4. Alice can then call `list_meetings`, `get_transcript`, and `get_summary` tools.

**Recommended flow:**
1. List meetings for the past N days.
2. Pull summary + full transcript for each.
3. Run `import-transcripts.py` on exported files, or pipe Granola output directly.
4. Entity-linked JSON is written to the world-state cache.

### Route B: Manual markdown

Drop `.md` or `.txt` files in `brain/meetings/raw/`. Use the template at
`templates/meeting-note.md` for processed notes.

```bash
python3 scripts/import-transcripts.py --directory ~/brain/meetings/raw \
  --output-json /tmp/entities.json
```

---

## Input schema

`import-transcripts.py` accepts two file formats.

### Format 1 — Granola MCP output (YAML frontmatter + markdown body)

```yaml
---
title: "Discovery call — Acme Corp"
date: "2026-04-13"
participants:
  - name: "Jane Smith"
    role: "VP Sales at Acme Corp"
  - name: "Bob Lee"
    role: "CEO"
type: "sales"
source: "granola"
granola_id: "abc-123"
company: "Acme Corp"
project: "Project Atlas"
---

Body text follows...
```

### Format 2 — Raw markdown (no frontmatter)

Plain meeting notes without delimiters. All metadata is extracted heuristically
from the body text.

---

## Output schema

The importer emits a single JSON envelope:

```json
{
  "count": 3,
  "transcripts": [
    {
      "path": "/absolute/path/to/file.md",
      "title": "Discovery call — Acme Corp",
      "date": "2026-04-13",
      "type": "sales",
      "source": "granola",
      "granola_id": "abc-123",
      "summary": "First 600 chars of body...",
      "entities": {
        "people": [
          { "name": "Jane Smith", "role": "VP Sales at Acme Corp" }
        ],
        "companies": ["Acme Corp"],
        "projects": ["Project Atlas"],
        "decisions": [
          { "decision": "move to a paid pilot in Q2", "owner": "Jane Smith" }
        ],
        "action_items": [
          { "action": "send pricing deck", "owner": "Bob", "due": "Friday" }
        ]
      }
    }
  ],
  "entity_index": {
    "people": [
      {
        "name": "Jane Smith",
        "role": "VP Sales at Acme Corp",
        "mentioned_in": ["Discovery call — Acme Corp"]
      }
    ],
    "companies": [
      { "name": "Acme Corp", "mentioned_in": ["Discovery call — Acme Corp"] }
    ],
    "projects": [
      { "name": "Project Atlas", "mentioned_in": ["Discovery call — Acme Corp"] }
    ]
  }
}
```

The `entity_index` block is flattened and deduplicated across all processed files,
ready for direct seeding into the world-state cache.

---

## Meeting-to-brief pipeline

```
transcript file (raw)
        |
        v
import-transcripts.py
        |
        v
entity-linked JSON  ──────────────────────────────>  world-state cache
        |                                             (people / companies /
        v                                              projects / decisions)
processed note  (templates/meeting-note.md)
        |
        +──> pre-next-meeting brief
        |       - who is attending, relationship history
        |       - open action items from last call
        |       - pending decisions and context
        |
        +──> post-call action summary
        |       - decisions made, owners, deadlines
        |       - new risks flagged
        |
        +──> follow-up draft suggestions
                - email / Slack follow-up for each action item
                - objection patterns logged for future calls
```

**Step-by-step:**

1. **Ingest** — run `import-transcripts.py` on raw transcript(s).
2. **Cache seed** — merge `entity_index` into `schemas/world-state-cache.json`.
3. **Process** — fill out `templates/meeting-note.md` using extracted entities.
4. **Brief** — before the next meeting with the same company/person, Alice reads
   their cache entry and the processed note to generate a pre-meeting brief.
5. **Follow-up** — Alice drafts follow-up messages for each open action item.

---

## Entity propagation rules

Every person or company extracted from a transcript gets an entry (or update) in
the world-state cache. Rules:

| Entity type | Trigger | Cache action |
|-------------|---------|--------------|
| Person | Appears in `participants` or body text | Upsert `people[name]` with role, last-seen date, meeting history |
| Company | Appears in `company` field or org regex match | Upsert `companies[name]` with last-contacted date |
| Project | Appears in `project` field or "Project X" pattern | Upsert `projects[name]` with associated companies and people |
| Decision | Matched by decision regex | Append to `decisions[]` with source meeting ref |
| Action item | Matched by action regex | Append to `action_items[]` with owner and due date |

**Provenance:** every cache entry includes `source_file` and `date` so records can
be traced back to the originating transcript.

**Confidence:** heuristic extractions (regex matches with no frontmatter
confirmation) are tagged `"confidence": "low"`. Frontmatter-confirmed values are
`"confidence": "high"`.

---

## Productized outputs

- **Pre-meeting brief** — relationship history, open items, context for attendees
- **Post-call action summary** — decisions, owners, deadlines, risks
- **Follow-up draft suggestions** — email/Slack per action item
- **Objection pattern library** — recurring objections across sales calls
- **Relationship drift signals** — contacts not seen in > N days

---

## Rules

- Never produce a transcript dump. Always synthesize into decisions and actions.
- Preserve provenance links back to source meeting IDs (Granola IDs or file paths).
- Label uncertain extractions with `"confidence": "low"`.
- Every person mentioned gets a cache entry — even one-time mentions.
