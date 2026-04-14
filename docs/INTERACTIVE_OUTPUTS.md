# Interactive Output Examples (What users actually see)

This page shows concrete output shapes across surfaces.

## 1) Slack App Home (briefing card)

```text
TODAY'S OPERATING BRIEF
- 3 priorities: v2 docs ship, client follow-up, partner prep
- 2 risks: stale external commitment, unresolved owner on deliverable
- 3 suggested moves:
  1) approve draft packet A
  2) assign owner to task #92
  3) send partner pre-read by 3 PM
```

## 2) Telegram topic-routed update

```text
[📅 Briefings]
Daily Brief — 08:30 PT
- Top 3: ...
- Risks: ...
- Decisions needed: ...
```

```text
[🚨 Urgent]
P0: Client commitment aging past SLA. Draft prepared, awaiting approval.
```

## 3) Email draft packet

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

## 4) Notion reconciliation row example

```text
Item: PrizePicks pricing follow-up
Notion status: In Progress
Slack signal: "done"
Email evidence: no outbound in 9 days
Resolution: Keep In Progress, assign owner, draft external follow-up
Confidence: 0.82
```

## 5) DB / cache / memory artifact example

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

## 6) QMD briefing example

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

## 7) Embedding/vector retrieval example

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
