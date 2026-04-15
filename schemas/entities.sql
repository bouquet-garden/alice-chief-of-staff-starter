-- =============================================================================
-- Alice World-State Cache — Postgres / PGlite Schema
-- Compatible with gbrain and any Postgres-compatible backend.
--
-- Usage:
--   psql -d alice -f schemas/entities.sql
--   OR: load via PGlite in the browser/edge runtime
--
-- Design principles:
--   - Polymorphic base table (entities) + typed tables per entity type.
--   - All writes include source provenance and confidence scores.
--   - Never silently overwrite facts — conflicts logged in entity_conflicts.
--   - open_loops and source_links are child tables, not JSONB blobs,
--     so they can be queried efficiently across entity types.
--   - Freshness views surface stale and reconciliation-needed entities.
-- =============================================================================

-- ---------------------------------------------------------------------------
-- Extensions
-- ---------------------------------------------------------------------------
-- PGlite supports a subset of extensions. Only use what's available cross-env.
-- If using full Postgres, you can enable pgcrypto for gen_random_uuid().
-- CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ---------------------------------------------------------------------------
-- Enum types
-- ---------------------------------------------------------------------------

-- Relationship tier for persons (A = active/high-priority, C = cold/background)
CREATE TYPE relationship_tier_enum AS ENUM ('A', 'B', 'C');

-- Operational status of a project
CREATE TYPE project_status_enum AS ENUM ('active', 'stalled', 'complete', 'blocked', 'not_started');

-- How a company relates to the user's business
CREATE TYPE company_relationship_enum AS ENUM (
  'customer', 'investor', 'partner', 'vendor', 'competitor', 'prospect', 'other'
);

-- Relationship status with a company
CREATE TYPE company_status_enum AS ENUM (
  'active', 'inactive', 'churned', 'prospect', 'closed_lost'
);

-- Type of meeting
CREATE TYPE meeting_type_enum AS ENUM (
  'internal', 'investor', 'customer', 'sales', 'hiring', 'board', '1:1', 'all_hands', 'other'
);

-- Communication channel for threads
CREATE TYPE channel_enum AS ENUM (
  'email', 'slack', 'telegram', 'sms', 'notion', 'other'
);

-- Status of a communication thread or open loop
CREATE TYPE thread_status_enum AS ENUM ('open', 'pending', 'closed', 'stale');

-- Open loop status
CREATE TYPE loop_status_enum AS ENUM ('open', 'pending', 'resolved', 'stale');

-- Source system type
CREATE TYPE source_type_enum AS ENUM (
  'email', 'slack', 'notion', 'transcript', 'calendar', 'manual', 'crm', 'inferred'
);

-- ---------------------------------------------------------------------------
-- Base: entities
--
-- Polymorphic base table. Every entity of every type has a row here.
-- Type-specific data lives in the typed tables (persons, companies, etc.).
-- This table enables cross-type queries (e.g., "all stale entities") without
-- UNION-ing every typed table.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS entities (
  -- Stable human-readable ID: <type>-<slug>. E.g., 'person-jason-wu'.
  id               TEXT PRIMARY KEY,

  -- Discriminator. Matches the typed table name (singular).
  entity_type      TEXT NOT NULL
    CHECK (entity_type IN ('person','company','project','opportunity','meeting','decision','thread')),

  -- Confidence in this record's accuracy. 1.0 = manually confirmed.
  -- < 0.7 = flag for review before use.
  confidence       NUMERIC(4,3) NOT NULL DEFAULT 0.8
    CHECK (confidence >= 0 AND confidence <= 1),

  -- Provenance: which source system and document produced this record.
  provenance_source_type  source_type_enum NOT NULL,
  provenance_source_id    TEXT,
  provenance_extracted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  provenance_extractor    TEXT,

  -- Timestamps
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE entities IS
  'Polymorphic base table for all world-state entities. Every typed entity has a corresponding row here. Enables cross-type freshness queries and reconciliation scans.';

COMMENT ON COLUMN entities.confidence IS
  'Confidence score 0–1. Below 0.7: Alice surfaces a caveat before using. 1.0: manually confirmed by user.';

-- ---------------------------------------------------------------------------
-- persons
--
-- People Alice tracks: investors, customers, partners, candidates, advisors.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS persons (
  id               TEXT PRIMARY KEY REFERENCES entities(id) ON DELETE CASCADE,

  name             TEXT NOT NULL,
  aliases          TEXT[],         -- Alternative names / nicknames observed

  -- Foreign key to companies.id (may be null if company not yet resolved)
  company_id       TEXT REFERENCES entities(id) ON DELETE SET NULL,
  company_name_raw TEXT,           -- Raw company name as extracted, before resolution

  role             TEXT,           -- Title or role at the company

  -- Contact info (flat for query efficiency; extend with contact_methods child table if needed)
  email_primary    TEXT,
  email_aliases    TEXT[],
  phone            TEXT,
  linkedin         TEXT,
  twitter          TEXT,
  slack_handle     TEXT,
  timezone         TEXT,           -- IANA timezone

  relationship_tier relationship_tier_enum NOT NULL DEFAULT 'B',

  -- Denormalized from linked threads/emails for fast brief generation
  last_contact     DATE,

  notes            TEXT
);

COMMENT ON TABLE persons IS
  'People tracked by Alice. Deduplication key: email_primary + name similarity. Tier A persons have tighter freshness TTLs.';

COMMENT ON COLUMN persons.aliases IS
  'Array of alternative names and email display names observed across sources. Used for fuzzy matching during entity resolution.';

-- ---------------------------------------------------------------------------
-- companies
--
-- Organizations: customers, investors, partners, vendors, competitors.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS companies (
  id               TEXT PRIMARY KEY REFERENCES entities(id) ON DELETE CASCADE,

  name             TEXT NOT NULL,
  aliases          TEXT[],
  domain           TEXT,           -- Primary web domain; used for email-based dedup

  relationship_type company_relationship_enum,
  status            company_status_enum DEFAULT 'active',

  -- Owner: person responsible for this relationship on Alice's side
  owner_id         TEXT REFERENCES entities(id) ON DELETE SET NULL,

  notes            TEXT
);

COMMENT ON TABLE companies IS
  'Organizations tracked by Alice. Deduplication key: domain. When two entities share a domain, Alice flags for merge.';

-- ---------------------------------------------------------------------------
-- projects
--
-- Named initiatives with status, owner, and deadlines.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS projects (
  id               TEXT PRIMARY KEY REFERENCES entities(id) ON DELETE CASCADE,

  name             TEXT NOT NULL,
  aliases          TEXT[],
  status           project_status_enum NOT NULL DEFAULT 'active',

  owner_id         TEXT REFERENCES entities(id) ON DELETE SET NULL,
  due_date         DATE,

  -- Denormalized: when the most recent substantive update was observed
  last_update      TIMESTAMPTZ
);

COMMENT ON TABLE projects IS
  'Projects go stale fast (TTL: 7 days). Status auto-transitions to stalled when no update in 7 days.';

-- ---------------------------------------------------------------------------
-- opportunities
--
-- Sales, fundraising, or partnership opportunities in a pipeline.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS opportunities (
  id               TEXT PRIMARY KEY REFERENCES entities(id) ON DELETE CASCADE,

  name             TEXT NOT NULL,
  company_id       TEXT REFERENCES entities(id) ON DELETE SET NULL,

  stage            TEXT,           -- E.g., 'intro', 'diligence', 'term_sheet', 'closed_won'
  value            NUMERIC(18,2),  -- Estimated value in USD
  probability      NUMERIC(5,2)    -- 0–100
    CHECK (probability IS NULL OR (probability >= 0 AND probability <= 100)),

  owner_id         TEXT REFERENCES entities(id) ON DELETE SET NULL,

  next_action      TEXT,
  next_action_date DATE
);

COMMENT ON TABLE opportunities IS
  'Sales and fundraising pipeline. Alice flags opportunities where next_action_date is past-due.';

-- ---------------------------------------------------------------------------
-- meetings
--
-- Recorded or observed meetings, calls, and syncs.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS meetings (
  id               TEXT PRIMARY KEY REFERENCES entities(id) ON DELETE CASCADE,

  title            TEXT NOT NULL,
  meeting_date     TIMESTAMPTZ NOT NULL,
  meeting_type     meeting_type_enum DEFAULT 'other',

  -- Participants stored as array of canonical entity IDs (persons) or raw names
  participant_ids  TEXT[],
  participant_names_raw TEXT[],

  follow_up_needed BOOLEAN NOT NULL DEFAULT FALSE,

  -- Source of this meeting record (e.g., Granola transcript file path)
  source_type      source_type_enum,
  source_id        TEXT,
  source_url       TEXT
);

COMMENT ON TABLE meetings IS
  'Meeting records created from transcripts, calendar events, or manual entry. Largely immutable after creation.';

-- ---------------------------------------------------------------------------
-- meeting_projects / meeting_companies
--
-- Many-to-many join tables linking meetings to related projects and companies.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS meeting_projects (
  meeting_id  TEXT NOT NULL REFERENCES meetings(id) ON DELETE CASCADE,
  project_id  TEXT NOT NULL REFERENCES entities(id) ON DELETE CASCADE,
  PRIMARY KEY (meeting_id, project_id)
);

CREATE TABLE IF NOT EXISTS meeting_companies (
  meeting_id  TEXT NOT NULL REFERENCES meetings(id) ON DELETE CASCADE,
  company_id  TEXT NOT NULL REFERENCES entities(id) ON DELETE CASCADE,
  PRIMARY KEY (meeting_id, company_id)
);

-- ---------------------------------------------------------------------------
-- meeting_action_items
--
-- Action items extracted from meeting transcripts or notes.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS meeting_action_items (
  id           SERIAL PRIMARY KEY,
  meeting_id   TEXT NOT NULL REFERENCES meetings(id) ON DELETE CASCADE,
  description  TEXT NOT NULL,
  owner_id     TEXT REFERENCES entities(id) ON DELETE SET NULL,
  owner_raw    TEXT,              -- Raw name if not yet resolved
  due_date     DATE,
  status       loop_status_enum NOT NULL DEFAULT 'open'
);

COMMENT ON TABLE meeting_action_items IS
  'Action items extracted from meetings. Alice syncs these to open_loops on linked entities.';

-- ---------------------------------------------------------------------------
-- decisions
--
-- Recorded decisions with context, rationale, and reversibility flag.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS decisions (
  id               TEXT PRIMARY KEY REFERENCES entities(id) ON DELETE CASCADE,

  summary          TEXT NOT NULL,  -- One-sentence statement of what was decided
  decision_date    DATE,
  context          TEXT,           -- Why it was decided; alternatives considered

  -- Links
  linked_project_id TEXT REFERENCES entities(id) ON DELETE SET NULL,
  linked_meeting_id TEXT REFERENCES entities(id) ON DELETE SET NULL,

  -- Type 1 (hard to undo) vs Type 2 (reversible)
  reversible       BOOLEAN,

  -- Who made the decision (stored as array of person canonical_ids or raw names)
  made_by_ids      TEXT[],
  made_by_raw      TEXT[]
);

COMMENT ON TABLE decisions IS
  'Decisions are append-only. To reverse a decision, create a new decision entity that supersedes it — do not update the original.';

-- ---------------------------------------------------------------------------
-- threads
--
-- Communication threads across email, Slack, or other channels.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS threads (
  id               TEXT PRIMARY KEY REFERENCES entities(id) ON DELETE CASCADE,

  subject          TEXT NOT NULL,
  channel          channel_enum NOT NULL,
  status           thread_status_enum NOT NULL DEFAULT 'open',

  last_activity    TIMESTAMPTZ,
  owner_id         TEXT REFERENCES entities(id) ON DELETE SET NULL,

  -- Participants as canonical IDs or raw names
  participant_ids  TEXT[],
  participant_names_raw TEXT[],

  -- Related entities (mixed type IDs)
  linked_entity_ids TEXT[]
);

COMMENT ON TABLE threads IS
  'Threads go stale after 30 days without activity. Alice auto-transitions status to stale during nightly refresh.';

-- ---------------------------------------------------------------------------
-- open_loops
--
-- Unresolved commitments, questions, or action items.
-- Child table — each row is linked to exactly one parent entity of any type.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS open_loops (
  id           SERIAL PRIMARY KEY,
  entity_id    TEXT NOT NULL REFERENCES entities(id) ON DELETE CASCADE,

  loop_id      TEXT NOT NULL,      -- Stable string ID within the entity: 'loop-jason-wu-...'
  description  TEXT NOT NULL,
  status       loop_status_enum NOT NULL DEFAULT 'open',
  ball_with    TEXT,               -- 'us', 'them', or a canonical_id

  due_date     DATE,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  resolved_at  TIMESTAMPTZ,

  UNIQUE (entity_id, loop_id)
);

COMMENT ON TABLE open_loops IS
  'Unresolved commitments associated with any entity. Alice surfaces open loops in briefs and flags overdue ones.';

-- ---------------------------------------------------------------------------
-- source_links
--
-- Many-to-many: entities ↔ source documents.
-- Tracks every source that contributed to an entity record.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS source_links (
  id           SERIAL PRIMARY KEY,
  entity_id    TEXT NOT NULL REFERENCES entities(id) ON DELETE CASCADE,

  source_type  source_type_enum NOT NULL,
  source_id    TEXT NOT NULL,
  url          TEXT,
  title        TEXT,
  source_date  TIMESTAMPTZ,

  UNIQUE (entity_id, source_type, source_id)
);

COMMENT ON TABLE source_links IS
  'Provenance links from entities to the source documents they were derived from. Enables audit trail and re-derivation.';

-- ---------------------------------------------------------------------------
-- entity_conflicts
--
-- Log of contradictory facts detected during cache writes.
-- Alice never silently overwrites a high-confidence fact; it logs here instead.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS entity_conflicts (
  id              SERIAL PRIMARY KEY,
  entity_id       TEXT NOT NULL REFERENCES entities(id) ON DELETE CASCADE,

  field_name      TEXT NOT NULL,   -- Which field has conflicting values
  stored_value    TEXT,            -- What was already in the cache
  new_value       TEXT,            -- What the new source claims
  stored_confidence NUMERIC(4,3),
  new_confidence    NUMERIC(4,3),

  source_type     source_type_enum,
  source_id       TEXT,

  detected_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  resolved_at     TIMESTAMPTZ,
  resolution      TEXT            -- How it was resolved: 'accepted_new', 'kept_stored', 'manual'
);

COMMENT ON TABLE entity_conflicts IS
  'Conflict log. When a new source contradicts a stored fact (confidence >= 0.8), Alice writes here instead of overwriting. Surfaced to user in daily brief.';

-- ---------------------------------------------------------------------------
-- Indexes
-- ---------------------------------------------------------------------------

-- Core lookups
CREATE INDEX IF NOT EXISTS idx_entities_type        ON entities(entity_type);
CREATE INDEX IF NOT EXISTS idx_entities_updated_at  ON entities(updated_at DESC);
CREATE INDEX IF NOT EXISTS idx_entities_confidence  ON entities(confidence);

-- Person lookups
CREATE INDEX IF NOT EXISTS idx_persons_company      ON persons(company_id);
CREATE INDEX IF NOT EXISTS idx_persons_tier         ON persons(relationship_tier);
CREATE INDEX IF NOT EXISTS idx_persons_last_contact ON persons(last_contact DESC);
CREATE INDEX IF NOT EXISTS idx_persons_email        ON persons(email_primary);

-- Project/opportunity status
CREATE INDEX IF NOT EXISTS idx_projects_status      ON projects(status);
CREATE INDEX IF NOT EXISTS idx_projects_due_date    ON projects(due_date);
CREATE INDEX IF NOT EXISTS idx_opportunities_stage  ON opportunities(stage);
CREATE INDEX IF NOT EXISTS idx_opportunities_owner  ON opportunities(owner_id);
CREATE INDEX IF NOT EXISTS idx_opportunities_next   ON opportunities(next_action_date);

-- Thread status / activity
CREATE INDEX IF NOT EXISTS idx_threads_status       ON threads(status);
CREATE INDEX IF NOT EXISTS idx_threads_last_activity ON threads(last_activity DESC);

-- Open loops
CREATE INDEX IF NOT EXISTS idx_open_loops_entity    ON open_loops(entity_id);
CREATE INDEX IF NOT EXISTS idx_open_loops_status    ON open_loops(status);
CREATE INDEX IF NOT EXISTS idx_open_loops_due_date  ON open_loops(due_date);

-- Source links
CREATE INDEX IF NOT EXISTS idx_source_links_entity  ON source_links(entity_id);
CREATE INDEX IF NOT EXISTS idx_source_links_source  ON source_links(source_type, source_id);

-- Conflicts
CREATE INDEX IF NOT EXISTS idx_conflicts_entity     ON entity_conflicts(entity_id);
CREATE INDEX IF NOT EXISTS idx_conflicts_unresolved ON entity_conflicts(resolved_at)
  WHERE resolved_at IS NULL;

-- ---------------------------------------------------------------------------
-- freshness_view
--
-- Shows all entities with their freshness status relative to configured TTLs.
-- TTL values here match freshness-rules.json; update both if you change them.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE VIEW freshness_view AS
SELECT
  e.id,
  e.entity_type,
  e.confidence,
  e.updated_at,
  NOW() - e.updated_at                         AS age,
  EXTRACT(EPOCH FROM (NOW() - e.updated_at)) / 86400 AS age_days,

  -- TTL thresholds by entity type (in days)
  CASE e.entity_type
    WHEN 'project'     THEN 7
    WHEN 'opportunity' THEN 7
    WHEN 'thread'      THEN 14
    WHEN 'person'      THEN 30
    WHEN 'company'     THEN 60
    WHEN 'meeting'     THEN 365
    WHEN 'decision'    THEN 365
    ELSE 30
  END AS ttl_days,

  CASE e.entity_type
    WHEN 'project'     THEN 14
    WHEN 'opportunity' THEN 21
    WHEN 'thread'      THEN 30
    WHEN 'person'      THEN 90
    WHEN 'company'     THEN 180
    WHEN 'meeting'     THEN 730
    WHEN 'decision'    THEN 730
    ELSE 90
  END AS stale_after_days,

  -- Freshness classification
  CASE
    WHEN EXTRACT(EPOCH FROM (NOW() - e.updated_at)) / 86400 >
      CASE e.entity_type
        WHEN 'project'     THEN 14
        WHEN 'opportunity' THEN 21
        WHEN 'thread'      THEN 30
        WHEN 'person'      THEN 90
        WHEN 'company'     THEN 180
        WHEN 'meeting'     THEN 730
        WHEN 'decision'    THEN 730
        ELSE 90
      END
      THEN 'stale'
    WHEN EXTRACT(EPOCH FROM (NOW() - e.updated_at)) / 86400 >
      CASE e.entity_type
        WHEN 'project'     THEN 10
        WHEN 'opportunity' THEN 14
        WHEN 'thread'      THEN 21
        WHEN 'person'      THEN 60
        WHEN 'company'     THEN 120
        WHEN 'meeting'     THEN 400
        WHEN 'decision'    THEN 400
        ELSE 60
      END
      THEN 'warn'
    ELSE 'fresh'
  END AS freshness_status

FROM entities e
ORDER BY age_days DESC;

COMMENT ON VIEW freshness_view IS
  'Shows all entities with age, TTL thresholds, and freshness_status (fresh / warn / stale). Used by nightly refresh script to determine which entities need updating.';

-- ---------------------------------------------------------------------------
-- reconciliation_needs
--
-- Finds entities that are referenced across multiple sources with data
-- that may conflict — either via the entity_conflicts log, or via low
-- confidence scores that suggest uncertain provenance.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE VIEW reconciliation_needs AS
SELECT
  e.id,
  e.entity_type,
  e.confidence,
  e.updated_at,
  COUNT(DISTINCT sl.source_type)   AS source_type_count,
  COUNT(DISTINCT sl.id)            AS source_link_count,
  COUNT(DISTINCT ec.id)            AS unresolved_conflict_count,
  COUNT(DISTINCT ol.id)            AS open_loop_count,

  -- Priority: higher = needs more urgent review
  (
    CASE WHEN e.confidence < 0.7 THEN 3 ELSE 0 END
    + CASE WHEN COUNT(DISTINCT ec.id) > 0 THEN 2 ELSE 0 END
    + CASE WHEN COUNT(DISTINCT sl.source_type) > 2 THEN 1 ELSE 0 END
  ) AS reconciliation_priority

FROM entities e
LEFT JOIN source_links sl ON sl.entity_id = e.id
LEFT JOIN entity_conflicts ec ON ec.entity_id = e.id AND ec.resolved_at IS NULL
LEFT JOIN open_loops ol ON ol.entity_id = e.id AND ol.status IN ('open', 'pending')

GROUP BY e.id, e.entity_type, e.confidence, e.updated_at

HAVING
  -- Include entities with unresolved conflicts
  COUNT(DISTINCT ec.id) > 0
  -- OR entities referenced by 3+ different source types (higher merge risk)
  OR COUNT(DISTINCT sl.source_type) >= 3
  -- OR low-confidence entities with multiple sources
  OR (e.confidence < 0.7 AND COUNT(DISTINCT sl.id) > 1)

ORDER BY reconciliation_priority DESC, unresolved_conflict_count DESC;

COMMENT ON VIEW reconciliation_needs IS
  'Identifies entities that need human review: those with unresolved conflicts, low confidence, or references from 3+ distinct source types. Alice surfaces top results in the daily brief.';

-- ---------------------------------------------------------------------------
-- open_loops_summary
--
-- Convenience view: all open/pending loops with entity context.
-- Used by Alice to build the follow-up queue.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE VIEW open_loops_summary AS
SELECT
  ol.id            AS loop_row_id,
  ol.loop_id,
  ol.entity_id,
  e.entity_type,
  ol.description,
  ol.status,
  ol.ball_with,
  ol.due_date,
  ol.created_at,
  -- Days since loop was created
  EXTRACT(EPOCH FROM (NOW() - ol.created_at)) / 86400 AS age_days,
  -- Overdue flag
  CASE WHEN ol.due_date IS NOT NULL AND ol.due_date < CURRENT_DATE THEN TRUE ELSE FALSE END AS overdue

FROM open_loops ol
JOIN entities e ON e.id = ol.entity_id
WHERE ol.status IN ('open', 'pending')
ORDER BY overdue DESC, ol.due_date ASC NULLS LAST, ol.created_at ASC;

COMMENT ON VIEW open_loops_summary IS
  'All open and pending loops with entity context and overdue flag. Primary input for Alice follow-up queue generation.';
