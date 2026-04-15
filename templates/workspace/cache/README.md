# Alice World-State Cache

This directory is the **single source of derived truth** about Alice's world. It is populated automatically by Alice's ingestion pipelines and queried by Alice before every brief, prep doc, or follow-up task.

---

## Purpose

Alice maintains a local cache so that:

- **Briefs are fast.** Alice does not re-read every email, transcript, and Notion page on every request. She reads the cache.
- **Context is stable across sessions.** A person's relationship tier, open loops, and last contact date persist between conversations.
- **Cross-surface reconciliation is possible.** The same person appearing in email, Slack, and a transcript is deduplicated into a single canonical entity here.

The cache is **derived**, not primary. The raw sources (email, Slack, Notion, transcripts) remain the ground truth. The cache is rebuilt from them.

---

## Directory Structure

```
cache/
├── README.md                   # This file
├── freshness-rules.json        # TTL and invalidation config
├── entities/                   # One JSON file per entity, named by canonical_id
│   ├── person-jason-wu.json
│   ├── company-meridian-capital.json
│   ├── project-series-a.json
│   └── ...
├── briefs/                     # Generated brief artifacts (short-lived)
│   ├── daily-brief-2024-10-15.md
│   ├── meeting-prep-jason-wu-2024-10-17.md
│   └── ...
└── raw/                        # Raw snapshots before normalization
    ├── email-batch-2024-10-15T02-00.json
    ├── transcript-2024-10-14-product-sync.md
    └── ...
```

### `entities/`

Each entity is a single JSON file named `<entity_type>-<slug>.json`. File names are lowercase with hyphens. Examples:

- `person-jason-wu.json`
- `company-meridian-capital.json`
- `project-series-a-fundraise.json`
- `opportunity-meridian-series-a.json`
- `meeting-2024-10-14-investor-sync.json`
- `decision-2024-10-14-pricing-hold.json`
- `thread-jason-wu-metrics-follow-up.json`

All entity files validate against `schemas/entities.json`. Entity types are: `person`, `company`, `project`, `opportunity`, `meeting`, `decision`, `thread`.

### `briefs/`

Generated output artifacts. These are **short-lived** and can always be regenerated from the entity cache. Do not edit them manually — Alice will overwrite them.

Freshness rules for briefs are defined in `freshness-rules.json` under `brief_freshness`.

### `raw/`

Raw snapshots from ingestion pipelines before entity extraction and normalization. These exist so that:

1. Alice can re-derive entities if a normalization bug is found.
2. You can audit what Alice saw versus what she concluded.

Raw files are not committed to version control by default.

---

## How the Cache is Populated

### Initial Seeding

Run `scripts/seed-world-state.sh` after completing the onboarding wizard. This performs a one-time bulk import from connected sources (email, Notion, calendar) and populates the entity cache for the first time.

### Transcript Import

When a transcript lands in `inbox/` (via Granola MCP or manual drop), Alice:

1. Extracts participant names, resolves them to canonical person entities.
2. Creates or updates a `meeting` entity.
3. Extracts decisions and creates `decision` entities.
4. Extracts action items and appends `open_loops` to person and project entities.
5. Updates `last_contact` and `last_activity` on touched entities.

### Daily Updates (Nightly Refresh)

At 2 AM local time (configurable in `freshness-rules.json`), Alice:

1. Fetches new email, Slack, and calendar data.
2. Updates touched entities.
3. Runs a reconciliation pass to flag conflicts.
4. Regenerates the daily brief and follow-up queue.
5. Archives threads and loops that have been closed.

### On-Demand Refresh

Ask Alice: _"Refresh everything about Jason Wu"_ or _"Re-read the Meridian Capital thread."_

Alice will pull fresh data from the source, update the entity, and note the conflict if the new data contradicts what was cached.

---

## Freshness Rules

Defined in `freshness-rules.json`. Key concepts:

| Field | Meaning |
|---|---|
| `ttl_days` | Cache is considered fresh for this many days after `updated_at`. |
| `warn_after_days` | Alice surfaces a warning in briefs: entity is getting stale. |
| `stale_after_days` | Entity is marked stale. Alice will not use it without a refresh prompt. |
| `invalidate_on` | Events that trigger immediate invalidation regardless of TTL. |

TTL varies by entity type:

| Type | TTL | Stale After |
|---|---|---|
| project | 7 days | 14 days |
| opportunity | 7 days | 21 days |
| thread | 14 days | 30 days |
| person (tier A) | 14 days | 45 days |
| person (tier B/C) | 30–90 days | 90–180 days |
| company | 60 days | 180 days |
| meeting / decision | 1 year | 2 years |

---

## Consistency Rules

Alice follows these rules to avoid silent data corruption:

1. **Never silently overwrite contradictory facts.** If a new email says Jason Wu is at "Meridian Partners" but the cache says "Meridian Capital", Alice logs a conflict rather than overwriting.

2. **Provenance per fact.** Every entity record includes a `provenance` block identifying the source system, source ID, and extraction timestamp.

3. **Low-confidence merges are flagged.** Any automated merge where either source has confidence < 0.7 is queued for human review. Alice will surface it in the next brief.

4. **Deduplication before write.** Before writing a new person entity, Alice checks for existing entities sharing the same email domain or name alias. Duplicates are flagged for merge rather than silently created.

---

## How Alice Queries the Cache

When generating any output (brief, prep doc, follow-up list), Alice:

1. **Reads the entity index** to find relevant entities for the current task.
2. **Checks freshness** — if any required entity is stale, Alice notes it in the output and offers to refresh.
3. **Resolves open loops** across linked entities (e.g., shows all open loops with Meridian Capital in one view).
4. **Respects confidence scores** — facts with confidence < 0.7 are shown with a caveat.

Alice never writes to the entity cache during brief generation. Writes only happen during ingestion pipelines or explicit update commands.

---

## How Alice Updates the Cache

Updates follow a strict write protocol:

1. **Read current entity** (if it exists).
2. **Compare new data** with stored data field by field.
3. **Apply conflict rules** from `freshness-rules.json`.
4. **Write with updated `updated_at` and `provenance`**.
5. **Propagate** to linked entities (e.g., updating a person's `last_contact` cascades to linked threads).

Writes are atomic per entity file. Alice does not partially update an entity.

---

## Gitignore Guidance

By default, `raw/` and `briefs/` should be in `.gitignore` since they are ephemeral. The `entities/` directory can be committed if you want version-controlled entity history, or excluded if the data is sensitive. Choose based on your security posture.

```gitignore
# Cache: generated and sensitive
workspace/cache/raw/
workspace/cache/briefs/
# Optionally:
# workspace/cache/entities/
```
