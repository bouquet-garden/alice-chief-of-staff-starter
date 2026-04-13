# World-State Cache (v2)

Cache architecture keeps Alice fast, consistent, and reliable.

## Cache layers

1. Raw cache
   - raw snapshots from email/slack/notion/transcripts
2. Normalized entity cache
   - people, companies, projects, opportunities, meetings, decisions, threads
3. Briefing cache
   - daily briefs, meeting prep briefs, follow-up queues

## Invalidation / freshness rules

- event-driven invalidation on new messages/tasks/meeting data
- time-based freshness windows by entity type
- manual refresh path for high-priority contexts

## Consistency rules

- never silently overwrite contradictory facts
- keep provenance per fact
- flag low-confidence merges for review

## Benefit

- lower latency for brief generation
- stable outputs across sessions
- better cross-surface reconciliation
