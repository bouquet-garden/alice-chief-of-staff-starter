# Transcript Ingestion — Granola MCP Route

## Goal
Ingest meeting context as first-class operational intelligence.

## Recommended flow

1. List meetings by date range
2. Pull summaries + transcript
3. Extract decisions, actions, risks, objections
4. Link to entities (people/company/project/opportunity)
5. Write outputs:
   - meeting brief page
   - post-call action queue
   - follow-up draft suggestions

## Notes

- Keep provenance links back to source meeting IDs.
- Preserve confidence labels when extraction is uncertain.
- Avoid raw transcript dump UX; synthesize into decisions and actions.

## Suggested integration points

- Source-of-truth connectors (Notion tasks)
- Email OS (draft follow-up suggestions)
- World-state cache (entity updates)
- Founder calibration (communication style learnings)
