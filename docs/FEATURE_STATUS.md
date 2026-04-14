# Alice v2 Feature Status Matrix (No Vaporware)

This document separates **what exists now** from **what is planned next**.

Legend:
- ✅ Implemented in this repo
- 🧪 Spec/design ready (not fully implemented)
- 🔜 Planned / next build

## Product capability status

| Capability | Status | Evidence in Repo | Notes |
|---|---|---|---|
| Product vision + continuation map | ✅ | [`PRODUCT_VISION.md`](PRODUCT_VISION.md) | Includes reference repos + next-build map |
| Messaging OS model | ✅ | [`v2/messaging-os.md`](v2/messaging-os.md), [`../manifests/slack/`](../manifests/slack/) | Slack manifests + Telegram topic recommendations |
| Slack starter/operator manifests | ✅ | [`../manifests/slack/alice-starter.manifest.json`](../manifests/slack/alice-starter.manifest.json), [`../manifests/slack/alice-operator.manifest.json`](../manifests/slack/alice-operator.manifest.json) | Importable JSON artifacts |
| Telegram topic installer helper | ✅ | [`../scripts/propose-telegram-topics.sh`](../scripts/propose-telegram-topics.sh) | Produces recommended topic taxonomy |
| Email OS workflow definition | ✅ | [`v2/email-os.md`](v2/email-os.md) | Priority/ownership/staleness/draft-first logic documented |
| Transcript intelligence model | ✅ | [`v2/transcript-intelligence.md`](v2/transcript-intelligence.md) | Granola + manual routes documented |
| Transcript ingestion skeleton | ✅ | [`../scripts/import-transcripts.py`](../scripts/import-transcripts.py) | Minimal parser emits normalized JSON |
| Source connectors model | ✅ | [`v2/source-connectors.md`](v2/source-connectors.md), [`v2/source-connectors-notion-obsidian.md`](v2/source-connectors-notion-obsidian.md) | Notion + Obsidian + reconciliation semantics |
| World-state cache architecture | ✅ | [`v2/world-state-cache.md`](v2/world-state-cache.md) | Raw -> normalized -> briefing cache layers |
| Founder calibration + autonomy ladder | ✅ | [`v2/founder-calibration.md`](v2/founder-calibration.md) | Explicit settings + calibration loop |
| Backtest concept + output model | ✅ | [`v2/backtest-engine.md`](v2/backtest-engine.md) | Simulation/report model defined |
| Onboarding confidence flow with examples | ✅ | [`ONBOARDING.md`](ONBOARDING.md) | Concrete dialogue + outputs |
| Demo first-run walkthrough | ✅ | [`DEMO_FIRST_RUN.md`](DEMO_FIRST_RUN.md) | End-to-end first session simulation |
| Founder ROI scorecard | ✅ | [`ROI_SCORECARD.md`](ROI_SCORECARD.md) | Concrete value model and success thresholds |
| Dialogue options/settings cookbook | ✅ | [`SETTINGS_AND_OUTCOMES.md`](SETTINGS_AND_OUTCOMES.md) | Recommended defaults + outcomes |
| Interactive output gallery (Slack/Telegram/Email/Notion/QMD/DB/vector) | ✅ | [`INTERACTIVE_OUTPUTS.md`](INTERACTIVE_OUTPUTS.md) | Concrete artifacts to set expectations |
| Expectation-setting / anti-hype page | ✅ | [`WHAT_ALICE_IS_AND_IS_NOT.md`](WHAT_ALICE_IS_AND_IS_NOT.md) | Sets correct mental model before install |
| End-to-end Email OS runnable pipeline | 🧪 | `docs/v2/email-os.md` + scripts/docs | Queue/state-machine implementation is next |
| Entity DB schema + migrations | 🔜 | N/A | Add concrete SQL schema + migration scripts |
| Vector retrieval pipeline + eval harness | 🔜 | N/A | Add embeddings contract + retrieval quality tests |
| Reconciliation dashboard implementation | 🔜 | N/A | Add UI/spec + data contracts |

## Why this page exists

Users should not have to guess what is real.
This matrix is the accountability contract for external communication and contributor alignment.
