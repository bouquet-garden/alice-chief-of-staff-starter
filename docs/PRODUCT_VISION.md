# Alice Product Vision

## One-line thesis

**Gbrain gives you a knowledge substrate. Alice gives you a founder-localized Chief of Staff operating system.**

Alice v2 is designed to become a **smart, context-aware, durable, robust** operational partner that can reason across real business systems and consistently reduce founder cognitive load.

---

## Product promise

By the end of onboarding, the user should feel:

1. **Seen:** "This understands my world model, not just my prompts."
2. **Relieved:** "It already removed real work from my plate."
3. **Trusting:** "It acts safely and asks at the right decision gates."
4. **Compounding:** "It gets better every week from real operations."

---

## Positioning (relative to reference systems)

- **gbrain** demonstrates durable, personal/world knowledge structures.
- **gstack** demonstrates practical execution/tooling structure for coding and operator workflows.
- **Hermes Agent** demonstrates strong productized agent documentation and multi-surface clarity.
- **Alice v2** combines these ideas into a founder-facing product layer:
  - identity + judgment
  - source-of-truth reconciliation
  - high-leverage workflow execution
  - calibration and trust controls
  - compound learning loops

---

## Core product capabilities

1. **Messaging OS**
   - Telegram topic model
   - Slack workspace/channel model
   - routing, urgency semantics, and escalation behavior

2. **Email OS**
   - priority classification (P0–P3)
   - ownership model (`ball with us` / `ball with them`)
   - stale-thread detection
   - context-linked drafting (safe by default)

3. **Transcript Intelligence**
   - meeting ingestion (Granola/manual)
   - decisions/actions/risks extraction
   - linked context for follow-up and prep

4. **Source-of-Truth Connectors**
   - Notion execution model
   - Obsidian strategy model
   - Slack/email reconciliation

5. **World-State Cache**
   - raw events -> normalized entities -> briefing artifacts
   - freshness/invalidation rules
   - provenance and confidence tracking

6. **Founder Calibration Layer**
   - communication style adaptation
   - autonomy and escalation tuning
   - implicit goal detection

7. **Backtest Engine**
   - simulate missed follow-ups and stale commitments over historical data
   - quantify likely value and confidence

8. **Compound Learning + Nightshift**
   - incident -> rule
   - workflow -> playbook
   - overnight execution with guardrails and morning digest

---

## Onboarding confidence flow (product feature, not setup chore)

### Phase 1: Discovery (10-20 min)

Collect only what drives immediate operational value:
- role/company context
- top priorities
- dropped-ball patterns
- active systems
- preferred operating style

### Phase 2: Operating contract (5-10 min)

Explicitly set:
- autonomy ladder
- escalation policy
- quiet hours
- source-of-truth weighting
- approval gates for external actions

### Phase 3: Source mapping + cache seed (10-20 min)

- connect key systems
- define authority boundaries
- seed first entity graph (people, projects, decisions, threads)

### Phase 4: First magic moment (15-30 min)

Generate one highly concrete output (examples):
- stale-thread + follow-up brief
- meeting prep dossier
- top-risk commitments brief
- founder daily operating brief

### Phase 5: Calibration loop (ongoing)

- collect corrections and misses
- tune settings
- update confidence thresholds
- document rules and playbooks

---

## Dialogue options/settings and expected outcomes

These are critical product features. They make behavior legible and tunable.

### 1) Autonomy ladder

- **Observe** -> read + summarize only
- **Draft** -> create drafts, no sends
- **Internal actions** -> update tasks/notes
- **External with approval** -> prepare + request confirmation
- **Bounded auto-action** -> only pre-approved domains

**Outcome:** Trust grows without giving up control.

### 2) Proactivity level

- Low: alert only on P0/P1
- Medium: daily summary + notable risks
- High: proactive recommendations + staged drafts

**Outcome:** Signal-to-noise tuned to founder style.

### 3) Source-of-truth weighting

Example policy:
- Notion = execution truth
- Email = external commitments truth
- Obsidian = strategy truth
- Slack = live signal, not final truth

**Outcome:** Less contradiction, faster conflict resolution.

### 4) Escalation settings

- Escalate immediately: legal/financial/public commitments
- Escalate in digest: low-risk ops drift
- Auto-handle: formatting, tagging, categorization, draft prep

**Outcome:** Fewer interruptions, better safety.

### 5) Communication style settings

- terse / strategic / detailed
- bluntness level
- recommendation strength (suggest / recommend / strongly recommend)

**Outcome:** Better founder fit and lower correction overhead.

---

## Interactive outputs as product features

Alice should ship interactive outputs across surfaces, not static text blobs.

1. **Slack**
   - App Home brief cards
   - slash-command workflows (`/alice-brief`, `/alice-reconcile`, `/alice-followups`)
   - reaction-triggered actions

2. **Telegram**
   - topic-aware routing
   - daily/urgent brief separation
   - builder status in dedicated topic

3. **Email**
   - review queue
   - draft packets by priority/owner
   - stale-thread recovery bundle

4. **Notion**
   - project/task/meeting sync
   - reconciliation dashboard
   - risk and decision queues

5. **Database + cache**
   - normalized entity/event storage
   - confidence/provenance metadata
   - fast retrieval for brief generation

6. **Memory layer**
   - short-term state + long-term distilled memory
   - compaction-resistant continuity files

7. **QMD / briefing artifacts**
   - generated decision docs and recurring brief formats
   - reproducible, reviewable outputs

8. **Embeddings/vectors**
   - semantic recall over transcripts, threads, and notes
   - context retrieval for drafting and brief generation

---

## Reference repos (for continuation builders)

Primary references:
- gbrain: <https://github.com/garrytan/gbrain>
- gstack: <https://github.com/garrytan/gstack>
- Hermes Agent: <https://github.com/nousresearch/hermes-agent>
- OpenClaw: <https://github.com/openclaw/openclaw>

Current implementation repo:
- Alice Chief of Staff Starter: <https://github.com/bouquet-garden/alice-chief-of-staff-starter>

Related docs:
- OpenClaw docs: <https://docs.openclaw.ai>

---

## Continuation map for other agents

If you are continuing build work, start with these files:

- `docs/README.md`
- `docs/PRODUCT_VISION.md` (this doc)
- `docs/FEATURE_STATUS.md`
- `docs/ONBOARDING.md`
- `docs/SETTINGS_AND_OUTCOMES.md`
- `docs/INTERACTIVE_OUTPUTS.md`
- `docs/v2/email-os.md`
- `docs/v2/messaging-os.md`
- `docs/v2/source-connectors.md`
- `docs/v2/world-state-cache.md`
- `docs/v2/founder-calibration.md`
- `docs/v2/upstream-patch-protocol.md`

### Next build priorities

1. **Onboarding interaction spec v2**
   - convert settings into concrete dialogue trees + response contracts
2. **Email OS reference implementation**
   - queue schema, labels, ownership state machine, approval flow
3. **Backtest output schema + baseline report templates**
4. **Entity cache schema + vector retrieval contract**
5. **Cross-surface reconciliation dashboard spec**
6. **QMD briefing generation templates and examples**

### Delivery standard

Every new module should include:
- product intent
- input/output contracts
- settings and defaults
- safety gates
- confidence/provenance behavior
- concrete examples
- implemented-vs-planned labeling with evidence links

## Anti-vaporware contract

For external communication and user trust:

1. Label every claim as **Implemented**, **Spec**, or **Planned**.
2. For every Implemented claim, link to a concrete file/script/manifest.
3. Show at least one real output example per feature area.
4. Keep "what to build next" explicit, scoped, and testable.
5. Never imply auto-action for external sends without explicit approval settings.

---

## North-star metric set

- onboarding time-to-first-magic-moment
- intervention precision (high-signal recommendations)
- correction rate (how often founder rewrites)
- stale-commitment reduction
- trust score trend (weekly)
- compounding score (new reusable rules/playbooks per week)

Alice v2 wins when users say: **"It runs my operating context with me, safely, and it gets smarter every week."**
