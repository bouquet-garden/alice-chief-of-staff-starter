# Alice Chief of Staff Starter

**An opinionated OpenClaw starter for building an AI Chief of Staff that feels like an operator, not a chatbot.**

This repo is a practical response to the format innovations in [gbrain](https://github.com/garrytan/gbrain) and [gstack](https://github.com/garrytan/gstack):
- **gbrain** showed how personal/world knowledge can become a compounding substrate
- **gstack** showed how skillpacks and agent-friendly operating docs can upgrade execution quality

This repo asks a different question:

> What would it take to install a **veteran chief of staff** into a fresh OpenClaw instance, localize it fast to a founder’s real world, and make it obviously useful in the first hour?

That means:
- less demo energy
- more source-of-truth discipline
- more memory architecture
- more operator-grade workflows
- more compounding value
- more lived-in judgment from real operational use

## What this repo contains

### 1. Bootstrap prompt
A single early-install prompt that tells a fresh OpenClaw instance how to become Alice fast.

See: [`prompts/alice-bootstrap-prompt-v1.txt`](prompts/alice-bootstrap-prompt-v1.txt)

### 2. Full onboarding wizard spec
A productized onboarding flow optimized for **speed to magic moment**.

See: [`docs/alice-onboarding-wizard-spec-v1.md`](docs/alice-onboarding-wizard-spec-v1.md)

### 3. Agent-friendly install path
Docs and scripts that let an agent:
- read the right docs in the right order
- scaffold a workspace
- install optional layers like GBrain and Gstack
- start asking the minimum viable discovery questions

See:
- [`START_HERE_FOR_AGENTS.md`](START_HERE_FOR_AGENTS.md)
- [`scripts/bootstrap-openclaw-workspace.sh`](scripts/bootstrap-openclaw-workspace.sh)
- [`scripts/install-gbrain.sh`](scripts/install-gbrain.sh)
- [`scripts/install-gstack.sh`](scripts/install-gstack.sh)

### 4. Opinionated Alice patterns
Patterns worth stealing if you want an AI operator rather than a prompt-wrapped chat app.

See:
- [`docs/alice-patterns-worth-stealing.md`](docs/alice-patterns-worth-stealing.md)
- [`docs/strategic-lenses.md`](docs/strategic-lenses.md)
- [`docs/world-state-and-accountability.md`](docs/world-state-and-accountability.md)

---

## The audience

This is for:
- prosumer AI operators
- indie hackers
- founders
- small teams
- professional services / agency owners
- people who want AI to **run real operational work**, not just produce impressive outputs on command

If your ambition is:
- “I want AI to help me think” — this may be overkill.
- “I want AI to help me **run my business**” — this is for you.

---

## Product point of view

A real AI Chief of Staff is not a better prompt.

It is a stack:
- **identity**
- **source-of-truth mapping**
- **memory**
- **world-state**
- **workflows**
- **accountability**
- **compound learning**

The gap between “I use AI” and “AI runs meaningful parts of my life/work” is architecture, not vibes.

## v2: Founder OS Core (implemented)

v2 pushes beyond onboarding docs into a cohesive operating pipeline:

1. Messaging OS
2. Email OS
3. Transcript Intelligence
4. Source-of-Truth Connectors
5. Backtest Engine
6. World-State Cache
7. Founder Calibration Layer
8. Compound Learning + Nightshift

Start here:
- [`docs/v2/README.md`](docs/v2/README.md)
- [`docs/v2/alice-v2-product-vision.md`](docs/v2/alice-v2-product-vision.md)
- [`docs/v2/messaging-os.md`](docs/v2/messaging-os.md)
- [`docs/v2/email-os.md`](docs/v2/email-os.md)
- [`docs/v2/transcript-intelligence.md`](docs/v2/transcript-intelligence.md)
- [`docs/v2/source-connectors.md`](docs/v2/source-connectors.md)
- [`docs/v2/backtest-engine.md`](docs/v2/backtest-engine.md)
- [`docs/v2/world-state-cache.md`](docs/v2/world-state-cache.md)
- [`docs/v2/founder-calibration.md`](docs/v2/founder-calibration.md)
- [`docs/v2/compound-learning-nightshift.md`](docs/v2/compound-learning-nightshift.md)

## Custom by default

This repo does **not** assume rigid prebuilt installs.
Every Alice onboarding should be customized to the founder’s:
- systems
- operating style
- risk posture
- communication preferences
- goals and work cadence

Opinionated defaults are provided, then calibrated.

---

## Before you start

Read [`docs/prerequisites.md`](docs/prerequisites.md).

The short version:
- minimum: OpenClaw + one working chat surface + git + curl
- optional: GBrain needs `bun`
- optional: Gstack assumes a Claude-oriented coding setup

## Fast start

### Decision tree
- **I want the fastest path to value** → follow [`docs/first-hour-walkthrough.md`](docs/first-hour-walkthrough.md)
- **I want to install into a real OpenClaw workspace now** → use the bootstrap script
- **I want to understand the philosophy first** → read the bootstrap prompt + wizard spec

### Option A — clone and read
```bash
git clone https://github.com/bouquet-garden/alice-chief-of-staff-starter.git
cd alice-chief-of-staff-starter
```

Then read:
1. `START_HERE_FOR_AGENTS.md`
2. `docs/first-hour-walkthrough.md`
3. `prompts/alice-bootstrap-prompt-v1.txt`
4. `docs/alice-onboarding-wizard-spec-v1.md`
5. `docs/v2/README.md`
6. `docs/v2/alice-v2-product-vision.md`

### Option B — bootstrap an OpenClaw workspace directly
```bash
curl -fsSL https://raw.githubusercontent.com/bouquet-garden/alice-chief-of-staff-starter/master/scripts/bootstrap-openclaw-workspace.sh | bash -s -- /path/to/openclaw/workspace
```

This will:
- copy workspace templates
- install the bootstrap prompt into the target workspace
- create a daily memory file
- give the agent the minimum structure needed to start discovery and produce a first magic moment

### What a good first hour looks like
By the end of the first hour, you should have:
- a source-of-truth map
- top goals and projects written down
- a localized `USER.md`
- a current-state `CONTEXT.md`
- one real magic-moment output

See:
- [`docs/first-hour-walkthrough.md`](docs/first-hour-walkthrough.md)
- [`examples/sample-magic-moment-email-brief.md`](examples/sample-magic-moment-email-brief.md)
- [`examples/sample-workspace/`](examples/sample-workspace/)

---

## Optional layers

### Install GBrain
Use if you want a **world-knowledge spine** for people, companies, projects, meetings, and concepts.

```bash
./scripts/install-gbrain.sh
```

### Install Gstack
Use if you want a **coding methodology layer** for heavier Claude Code / ACP sessions.

```bash
./scripts/install-gstack.sh
```

---

## Repo structure

```text
prompts/
  alice-bootstrap-prompt-v1.txt

docs/
  alice-bootstrap-prompt-v1.md
  alice-onboarding-wizard-spec-v1.md
  alice-patterns-worth-stealing.md
  design-principles.md
  source-of-truths.md
  prerequisites.md
  first-hour-walkthrough.md
  strategic-lenses.md
  world-state-and-accountability.md
  why-this-exists.md
  review-scorecard.md
  v2/
    README.md
    alice-v2-product-vision.md
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

templates/workspace/
  IDENTITY.md
  SOUL.md
  VOICE.md
  JUDGMENT.md
  ANTI_PATTERNS.md
  USER.md
  CONTEXT.md
  MEMORY.md
  TOOLS.md
  SOURCES_OF_TRUTH.md
  GOALS.md
  METRICS.md
  ROADMAP.md
  WORKFLOWS.md
  EXPERIMENTS.md
  memory/README.md

scripts/
  bootstrap-openclaw-workspace.sh
  install-gbrain.sh
  install-gstack.sh
  propose-telegram-topics.sh
  import-transcripts.py
  review.sh

manifests/
  slack/
    alice-starter.manifest.json
    alice-operator.manifest.json

examples/
  founder-discovery.md
  first-magic-moment-options.md
  sample-magic-moment-email-brief.md
  sample-workspace/
```

---

## Why this exists

This repo comes out of a few months of using OpenClaw for real operational work:
- email triage
- sprint management
- meeting processing
- overnight builds
- vendor ops
- relationship tracking
- founder support

It is not trying to win Twitter for 48 hours.
It is trying to capture durable patterns from real use.

See:
- [`docs/design-principles.md`](docs/design-principles.md)
- [`docs/why-this-exists.md`](docs/why-this-exists.md)

---

## Recommended first magic moments

Pick **one** on day 1:
- meeting prep brief
- email ownership / stale-thread brief
- daily founder briefing
- active deals / follow-up brief
- sprint health summary

Do not try to automate everything in the first hour.

---

## What makes Alice different

The most important patterns are not flashy:
- source-of-truth hierarchy
- operator-style judgment
- compaction-proof context
- memory as moat
- incident → rule
- thread ownership tracking
- cross-surface reconciliation
- explicit/implicit goal sensing
- draft-first overnight work
- fresh-eyes review loops

These are the boring things that become unfair advantages.

---

## Review standard

This repo uses a simple quality bar. See [`docs/review-scorecard.md`](docs/review-scorecard.md).

The deliverable should rate **10/10** on:
- strategic clarity
- operator credibility
- installability
- agent legibility
- speed to magic moment
- thought leadership quality

---

## License

MIT
