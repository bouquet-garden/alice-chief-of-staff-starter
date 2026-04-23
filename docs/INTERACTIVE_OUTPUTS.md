# Interactive Output Examples (What users actually see)

This page shows concrete output shapes across surfaces. Each example below
links to a full, realistic artifact in `examples/outputs/` using the Maya
Patel / Aria persona.

---

## Full output gallery

| # | Output | File | Description |
|---|--------|------|-------------|
| 1 | Slack App Home brief | [slack-app-home-brief.md](../examples/outputs/slack-app-home-brief.md) | Complete App Home tab with Block Kit JSON, rendered preview, P0/P1 items, calendar, deal pipeline, and action queue |
| 2 | Slack thread summary | [slack-thread-summary.md](../examples/outputs/slack-thread-summary.md) | `/alice-brief` response in a thread with key points, decisions, open items, and suggested reply |
| 3 | Telegram daily brief | [telegram-daily-brief.md](../examples/outputs/telegram-daily-brief.md) | Morning brief to the "Daily Briefings" topic with MarkdownV2 formatting and inline keyboard |
| 4 | Telegram urgent alert | [telegram-urgent-alert.md](../examples/outputs/telegram-urgent-alert.md) | P0 escalation to "Urgent Escalations" topic with trigger context, risk assessment, and audit trail |
| 5 | Email draft packet | [email-draft-packet.md](../examples/outputs/email-draft-packet.md) | 3 complete draft emails (investor, customer, internal) with thread context, tone notes, and approval gates |
| 6 | Email stale recovery | [email-stale-recovery.md](../examples/outputs/email-stale-recovery.md) | 5 stale threads identified with recovery plans, priority ordering, and draft replies |
| 7 | Notion reconciliation | [notion-reconciliation.md](../examples/outputs/notion-reconciliation.md) | 5 cross-surface contradictions with confidence scores, proposed Notion API updates, and approval gates |
| 8 | Meeting prep brief | [meeting-prep-brief.md](../examples/outputs/meeting-prep-brief.md) | Pre-meeting dossier for investor call with participant profiles, talking points, and open loops |
| 9 | Backtest scorecard | [backtest-scorecard.md](../examples/outputs/backtest-scorecard.md) | Executive summary of Alice's 30-day backtest with ROI projection and confidence breakdown |
| 10 | Cache entity (company) | [cache-entity.json](../examples/outputs/cache-entity.json) | Fully populated company entity JSON for Meridian Capital with interaction history and open loops |
| 11 | Vector retrieval | [vector-retrieval.md](../examples/outputs/vector-retrieval.md) | Semantic search result for "what did we agree with Meridian about valuation?" with citations and synthesis |

---

## Quick reference: output shapes

### 1) Slack App Home (briefing card)

```text
TODAY'S OPERATING BRIEF
- 3 priorities: v2 docs ship, client follow-up, partner prep
- 2 risks: stale external commitment, unresolved owner on deliverable
- 3 suggested moves:
  1) approve draft packet A
  2) assign owner to task #92
  3) send partner pre-read by 3 PM
```

### 2) Telegram topic-routed update

```text
[Briefings]
Daily Brief — 08:30 PT
- Top 3: ...
- Risks: ...
- Decisions needed: ...
```

```text
[Urgent]
P0: Client commitment aging past SLA. Draft prepared, awaiting approval.
```

### 3) Email draft packet

```text
Draft Packet (3)
- Thread: ACME renewal follow-up (P1, ball with us, stale 72h)
- Thread: Partner meeting agenda confirmation (P1)
- Thread: Vendor quote clarification (P2)

Each draft includes:
- context snapshot
- recommended tone
- explicit ask
- approval gate before send
```

### 4) Notion reconciliation row example

```text
Item: PrizePicks pricing follow-up
Notion status: In Progress
Slack signal: "done"
Email evidence: no outbound in 9 days
Resolution: Keep In Progress, assign owner, draft external follow-up
Confidence: 0.82
```

### 5) DB / cache / memory artifact example

```json
{
  "entity": "thread:acme-renewal-2026-04",
  "owner": "us",
  "staleness_hours": 72,
  "sources": ["gmail", "notion", "slack"],
  "confidence": 0.82,
  "last_updated": "2026-04-13T15:20:00Z"
}
```

### 6) QMD briefing example

```markdown
# Partner Prep Brief (QMD)
## Objective
Align on v2 rollout scope and partner responsibilities.
## Since Last Meeting
- ...
## Open Risks
- ...
## Decisions Needed Today
1. ...
2. ...
## Recommended Ask
...
```

### 7) Embedding/vector retrieval example

```text
Query: "What did we promise ACME about launch timing?"
Top matches:
1) email thread ACME-Launch (score 0.89)
2) meeting transcript 2026-04-04 (score 0.85)
3) notion task #342 notes (score 0.81)

Synthesized answer includes source citations and confidence score.
```

## Why this matters

These examples set expectations and reduce onboarding anxiety.
Users should see that Alice is concrete, not hand-wavy.
