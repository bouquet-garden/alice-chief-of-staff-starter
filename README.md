# Alice Chief of Staff Starter

**Install an AI Chief of Staff that behaves like an operator, not a chatbot.**

Alice v2 is a founder-facing operating layer on top of OpenClaw-style agents:
- context-aware across your real systems
- safe by default (draft-first, explicit approval gates)
- durable across sessions (memory + world-state model)
- compounding over time (incident -> rule -> playbook)

Inspired by:
- [gbrain](https://github.com/garrytan/gbrain) (durable world knowledge)
- [gstack](https://github.com/garrytan/gstack) (operator-grade execution flows)
- [Hermes Agent](https://github.com/nousresearch/hermes-agent) (agent product clarity, docs quality, integration confidence)

---

## What this repo is

A practical, opinionated starter that helps you install and evolve:

1. **Messaging OS** (Slack/Telegram routing and operating semantics)
2. **Email OS** (priority, ownership, staleness, draft queue)
3. **Transcript Intelligence** (meeting context -> decisions/actions)
4. **Source-of-Truth Connectors** (Notion/Slack/Obsidian/email reconciliation)
5. **World-State Cache** (raw -> normalized entities -> briefing outputs)
6. **Founder Calibration** (settings, autonomy ladder, escalation)
7. **Backtesting + Accountability** (what would Alice have caught?)
8. **Compound learning + Nightshift** (gets better week over week)

---

## Reality check: what exists now vs what is next

Users should not have to guess if this is real or vaporware.

- ✅ **Implemented docs/artifacts in repo now**: manifests, scripts, v2 architecture docs, concrete onboarding examples
- 🧪 **Spec-level (designed, not full runtime)**: some pipeline internals (e.g., full email queue/state machine)
- 🔜 **Planned**: full schemas/eval harness/reconciliation dashboard implementation

See the accountability matrix:
- [`docs/v2/feature-status-matrix.md`](docs/v2/feature-status-matrix.md)

---

## Start here (v2)

- [`docs/v2/README.md`](docs/v2/README.md)
- [`docs/v2/alice-v2-product-vision.md`](docs/v2/alice-v2-product-vision.md)
- [`docs/v2/onboarding-confidence-flow.md`](docs/v2/onboarding-confidence-flow.md)
- [`docs/v2/dialogue-options-and-outcomes.md`](docs/v2/dialogue-options-and-outcomes.md)
- [`docs/v2/interactive-output-examples.md`](docs/v2/interactive-output-examples.md)
- [`docs/v2/feature-status-matrix.md`](docs/v2/feature-status-matrix.md)

If you are an agent/operator implementing this for a team:
- [`START_HERE_FOR_AGENTS.md`](START_HERE_FOR_AGENTS.md)

---

## Why this is different

Most AI setups optimize for response quality.

Alice v2 optimizes for:
- **operational reliability** (what gets done, what gets dropped)
- **decision clarity** (what matters now, what to do next)
- **cross-system consistency** (Notion vs Slack vs Email vs transcripts)
- **human trust** (predictable behavior, explicit controls)

The product is not “a better prompt.”
It is a **behavioral operating system**.

---

## Example onboarding flow (confidence before install)

A concrete onboarding should feel like this:

### 1) Discovery (10-20 min)
- captures founder profile, priorities, dropped-ball patterns

### 2) Operating contract (5-10 min)
- sets autonomy level, escalation rules, quiet hours, approval gates

### 3) Source mapping (10-20 min)
- defines authority boundaries: Notion/email/Slack/Obsidian/transcripts

### 4) First magic moment (15-30 min)
- produces one real operational output (not a demo paragraph)

### 5) Calibration loop (ongoing)
- adjusts style/proactivity/escalation based on observed corrections

Full walkthrough:
- [`docs/v2/onboarding-confidence-flow.md`](docs/v2/onboarding-confidence-flow.md)

---

## Dialogue options/settings are product features

Not hidden config. Explicit controls users can understand.

Examples:
- **Autonomy ladder**: Observe -> Draft -> Internal actions -> External with approval -> Bounded auto-action
- **Proactivity level**: Low / Medium / High
- **Escalation policy**: immediate vs digest
- **Source weighting**: where truth lives for each domain
- **Communication style**: terse/strategic/detailed, recommendation strength

Settings + recommended defaults:
- [`docs/v2/dialogue-options-and-outcomes.md`](docs/v2/dialogue-options-and-outcomes.md)

---

## Interactive outputs (what users actually see)

Alice outputs should be concrete and operationally useful:

- Slack App Home brief cards
- Telegram topic-routed updates
- Email draft packets by priority/ownership
- Notion reconciliation rows
- DB/cache entity records with confidence/provenance
- QMD-style decision briefs
- vector-retrieval-backed contextual answers with citations

Concrete examples:
- [`docs/v2/interactive-output-examples.md`](docs/v2/interactive-output-examples.md)

---

## Integrations + artifacts in this repo

### Messaging
- Slack starter manifest: [`manifests/slack/alice-starter.manifest.json`](manifests/slack/alice-starter.manifest.json)
- Slack operator manifest: [`manifests/slack/alice-operator.manifest.json`](manifests/slack/alice-operator.manifest.json)
- Slack guide: [`docs/v2/slack-manifest-guide.md`](docs/v2/slack-manifest-guide.md)
- Telegram topic helper: [`scripts/propose-telegram-topics.sh`](scripts/propose-telegram-topics.sh)

### Transcript ingestion
- Granola MCP route: [`docs/v2/transcript-ingestion-granola-mcp.md`](docs/v2/transcript-ingestion-granola-mcp.md)
- Manual markdown route: [`docs/v2/transcript-ingestion-manual-md.md`](docs/v2/transcript-ingestion-manual-md.md)
- Ingestion script skeleton: [`scripts/import-transcripts.py`](scripts/import-transcripts.py)

### Core architecture docs
- Vision: [`docs/v2/alice-v2-product-vision.md`](docs/v2/alice-v2-product-vision.md)
- Messaging OS: [`docs/v2/messaging-os.md`](docs/v2/messaging-os.md)
- Email OS: [`docs/v2/email-os.md`](docs/v2/email-os.md)
- Source connectors: [`docs/v2/source-connectors.md`](docs/v2/source-connectors.md)
- World-state cache: [`docs/v2/world-state-cache.md`](docs/v2/world-state-cache.md)
- Founder calibration: [`docs/v2/founder-calibration.md`](docs/v2/founder-calibration.md)
- Backtest engine: [`docs/v2/backtest-engine.md`](docs/v2/backtest-engine.md)
- Compound learning: [`docs/v2/compound-learning-nightshift.md`](docs/v2/compound-learning-nightshift.md)

---

## Fast start

### Option A — read and adapt
```bash
git clone https://github.com/bouquet-garden/alice-chief-of-staff-starter.git
cd alice-chief-of-staff-starter
```

Read in this order:
1. `START_HERE_FOR_AGENTS.md`
2. `docs/v2/README.md`
3. `docs/v2/alice-v2-product-vision.md`
4. `docs/v2/feature-status-matrix.md`
5. `docs/v2/onboarding-confidence-flow.md`

### Option B — bootstrap workspace
```bash
curl -fsSL https://raw.githubusercontent.com/bouquet-garden/alice-chief-of-staff-starter/master/scripts/bootstrap-openclaw-workspace.sh | bash -s -- /path/to/openclaw/workspace
```

---

## Mental model for contributors

Treat this system as three layers:

1. **Behavior layer** (identity, judgment, safety, calibration)
2. **Knowledge layer** (source mapping, memory, world-state cache)
3. **Execution layer** (messaging/email/transcript workflows + reconciliation)

A good change improves at least one layer without breaking the others.

---

## Continuation map for other agents

If you are continuing implementation, start here:
- [`docs/v2/alice-v2-product-vision.md`](docs/v2/alice-v2-product-vision.md)
- [`docs/v2/feature-status-matrix.md`](docs/v2/feature-status-matrix.md)
- [`docs/v2/onboarding-confidence-flow.md`](docs/v2/onboarding-confidence-flow.md)
- [`docs/v2/dialogue-options-and-outcomes.md`](docs/v2/dialogue-options-and-outcomes.md)
- [`docs/v2/interactive-output-examples.md`](docs/v2/interactive-output-examples.md)

Then ship concrete implementation artifacts with:
- input/output contracts
- safety gates
- evidence links
- implemented-vs-planned labeling

---

## Repo structure

```text
docs/
  v2/
    README.md
    alice-v2-product-vision.md
    feature-status-matrix.md
    onboarding-confidence-flow.md
    dialogue-options-and-outcomes.md
    interactive-output-examples.md
    messaging-os.md
    email-os.md
    transcript-intelligence.md
    transcript-ingestion-granola-mcp.md
    transcript-ingestion-manual-md.md
    source-connectors.md
    source-connectors-notion-obsidian.md
    slack-manifest-guide.md
    backtest-engine.md
    world-state-cache.md
    founder-calibration.md
    compound-learning-nightshift.md
    upstream-patch-protocol.md
manifests/
  slack/
    alice-starter.manifest.json
    alice-operator.manifest.json
scripts/
  bootstrap-openclaw-workspace.sh
  install-gbrain.sh
  install-gstack.sh
  propose-telegram-topics.sh
  import-transcripts.py
```

---

## License

MIT
