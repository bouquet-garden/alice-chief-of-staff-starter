# Email OS (v2)

This module productizes the local Alice triage/draft pattern (Serif-style, but integrated with world-state).

## Workflow

1. Read inbound threads
2. Classify priority (P0–P3)
3. Determine ownership (`ball with us` / `ball with them`)
4. Compute staleness
5. Pull context from Notion, Slack, meetings/transcripts, entities
6. Draft responses (never auto-send)
7. Save to draft folder + update labels
8. Notify founder with concise action queue
9. Await explicit send approval

## Non-negotiable safety

- External send is gated by explicit approval.
- Drafting/labeling/contextual synthesis is safe automation.
- High-risk recipients (legal/finance/press) require extra confirmation.

## Outputs

- draft queue with rationale
- stale-thread queue
- commitment-risk queue
- daily/weekly email operating brief

## Integration points

- Source-of-truth connectors (Notion/Slack/Obsidian)
- Transcript intelligence (meeting context)
- World-state cache (entity context)
- Founder calibration (tone + initiative tuning)
