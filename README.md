# Alice Chief of Staff Starter

**Install an AI Chief of Staff that behaves like an operator, not a chatbot.**

Alice is a founder-facing operating layer on top of OpenClaw-style agents:
- context-aware across your real systems
- safe by default (draft-first + explicit approval gates)
- durable across sessions (memory + world-state)
- compounding over time (incident -> rule -> playbook)

Inspired by:
- [gbrain](https://github.com/garrytan/gbrain)
- [gstack](https://github.com/garrytan/gstack)
- [Hermes Agent](https://github.com/nousresearch/hermes-agent)

---

## Main docs (canonical)

Core product docs are now top-level under `docs/` (not hidden in `docs/v2/`).

1. [`docs/README.md`](docs/README.md)
2. [`docs/PRODUCT_VISION.md`](docs/PRODUCT_VISION.md)
3. [`docs/ONBOARDING.md`](docs/ONBOARDING.md)
4. [`docs/SETTINGS_AND_OUTCOMES.md`](docs/SETTINGS_AND_OUTCOMES.md)
5. [`docs/INTERACTIVE_OUTPUTS.md`](docs/INTERACTIVE_OUTPUTS.md)
6. [`docs/FEATURE_STATUS.md`](docs/FEATURE_STATUS.md)
7. [`docs/ROI_SCORECARD.md`](docs/ROI_SCORECARD.md)
8. [`docs/WHAT_ALICE_IS_AND_IS_NOT.md`](docs/WHAT_ALICE_IS_AND_IS_NOT.md)

If you are implementing this with agents:
- [`START_HERE_FOR_AGENTS.md`](START_HERE_FOR_AGENTS.md)

---

## Reality check (anti-vaporware)

We explicitly separate:
- ✅ implemented artifacts in repo
- 🧪 spec/design-level docs
- 🔜 planned next builds

See:
- [`docs/FEATURE_STATUS.md`](docs/FEATURE_STATUS.md)

---

## What this repo includes

### Messaging
- Slack starter manifest: [`manifests/slack/alice-starter.manifest.json`](manifests/slack/alice-starter.manifest.json)
- Slack operator manifest: [`manifests/slack/alice-operator.manifest.json`](manifests/slack/alice-operator.manifest.json)
- Slack guide: [`docs/v2/slack-manifest-guide.md`](docs/v2/slack-manifest-guide.md)
- Telegram topic helper: [`scripts/propose-telegram-topics.sh`](scripts/propose-telegram-topics.sh)

### Transcript ingestion
- Granola MCP route: [`docs/v2/transcript-ingestion-granola-mcp.md`](docs/v2/transcript-ingestion-granola-mcp.md)
- Manual markdown route: [`docs/v2/transcript-ingestion-manual-md.md`](docs/v2/transcript-ingestion-manual-md.md)
- Ingestion script skeleton: [`scripts/import-transcripts.py`](scripts/import-transcripts.py)

### Module specs (deeper implementation docs)
Detailed module specs remain in `docs/v2/`.

---

## Fast start

### Option A — read and adapt
```bash
git clone https://github.com/bouquet-garden/alice-chief-of-staff-starter.git
cd alice-chief-of-staff-starter
```

Read in this order:
1. `START_HERE_FOR_AGENTS.md`
2. `docs/README.md`
3. `docs/PRODUCT_VISION.md`
4. `docs/FEATURE_STATUS.md`
5. `docs/ONBOARDING.md`

### Option B — bootstrap workspace
```bash
curl -fsSL https://raw.githubusercontent.com/bouquet-garden/alice-chief-of-staff-starter/master/scripts/bootstrap-openclaw-workspace.sh | bash -s -- /path/to/openclaw/workspace
```

---

## Mental model for contributors

Treat the system as three layers:
1. Behavior layer (identity, judgment, safety, calibration)
2. Knowledge layer (source mapping, memory, world-state cache)
3. Execution layer (messaging/email/transcript workflows + reconciliation)

A good change improves at least one layer without breaking the others.

---

## License

MIT
