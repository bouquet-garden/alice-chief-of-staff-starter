# Alice v2 Feature Status Matrix (No Vaporware)

This document separates **what exists now** from **what is planned next**.

Legend:
- ✅ Implemented in this repo
- 🧪 Spec/design ready (not fully implemented)
- 🔜 Planned / next build

## Product capability status

| Capability | Status | Evidence in Repo | Notes |
|---|---|---|---|
| Product vision + continuation map | ✅ | [`alice-v2-product-vision.md`](alice-v2-product-vision.md) | Includes reference repos + next-build map |
| Messaging OS model | ✅ | [`messaging-os.md`](messaging-os.md), [`../..//manifests/slack/`](../../manifests/slack/) | Slack manifests + Telegram topic recommendations |
| Slack starter/operator manifests | ✅ | [`../../manifests/slack/alice-starter.manifest.json`](../../manifests/slack/alice-starter.manifest.json), [`../../manifests/slack/alice-operator.manifest.json`](../../manifests/slack/alice-operator.manifest.json) | Importable JSON artifacts |
| Telegram topic installer helper | ✅ | [`../../scripts/propose-telegram-topics.sh`](../../scripts/propose-telegram-topics.sh) | Produces recommended topic taxonomy |
| Email OS workflow definition | ✅ | [`email-os.md`](email-os.md) | Priority/ownership/staleness/draft-first logic documented |
| Transcript intelligence model | ✅ | [`transcript-intelligence.md`](transcript-intelligence.md) | Granola + manual routes documented |
| Transcript ingestion skeleton | ✅ | [`../../scripts/import-transcripts.py`](../../scripts/import-transcripts.py) | Minimal parser emits normalized JSON |
| Source connectors model | ✅ | [`source-connectors.md`](source-connectors.md), [`source-connectors-notion-obsidian.md`](source-connectors-notion-obsidian.md) | Notion + Obsidian + reconciliation semantics |
| World-state cache architecture | ✅ | [`world-state-cache.md`](world-state-cache.md) | Raw -> normalized -> briefing cache layers |
| Founder calibration + autonomy ladder | ✅ | [`founder-calibration.md`](founder-calibration.md) | Explicit settings + calibration loop |
| Backtest concept + output model | ✅ | [`backtest-engine.md`](backtest-engine.md) | Simulation/report model defined |
| Onboarding confidence flow with examples | ✅ | [`onboarding-confidence-flow.md`](onboarding-confidence-flow.md) | Concrete dialogue + outputs |
| Demo first-run walkthrough | ✅ | [`demo-first-run-walkthrough.md`](demo-first-run-walkthrough.md) | End-to-end first session simulation |
| Founder ROI scorecard | ✅ | [`founder-roi-scorecard.md`](founder-roi-scorecard.md) | Concrete value model and success thresholds |
| Dialogue options/settings cookbook | ✅ | [`dialogue-options-and-outcomes.md`](dialogue-options-and-outcomes.md) | Recommended defaults + outcomes |
| Interactive output gallery (Slack/Telegram/Email/Notion/QMD/DB/vector) | ✅ | [`interactive-output-examples.md`](interactive-output-examples.md) | Concrete artifacts to set expectations |
| Expectation-setting / anti-hype page | ✅ | [`what-alice-is-and-is-not.md`](what-alice-is-and-is-not.md) | Sets correct mental model before install |
| End-to-end Email OS runnable pipeline | 🧪 | `email-os.md` + scripts/docs | Queue/state-machine implementation is next |
| Entity DB schema + migrations | 🔜 | N/A | Add concrete SQL schema + migration scripts |
| Vector retrieval pipeline + eval harness | 🔜 | N/A | Add embeddings contract + retrieval quality tests |
| Reconciliation dashboard implementation | 🔜 | N/A | Add UI/spec + data contracts |

## Why this page exists

Users should not have to guess what is real.
This matrix is the accountability contract for external communication and contributor alignment.
