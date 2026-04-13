# First Hour Walkthrough

This is the canonical path.

If you only follow one path through this repo, follow this one.

## Goal
By the end of the first hour, the founder should have:
- a localized Alice workspace
- a source-of-truth map
- top goals and projects written down
- one obvious magic moment from live or near-live data

## Step 1 — bootstrap the workspace
```bash
curl -fsSL https://raw.githubusercontent.com/bouquet-garden/alice-chief-of-staff-starter/master/scripts/bootstrap-openclaw-workspace.sh | bash -s -- ~/.openclaw/workspace
```

Expected result:
- `ALICE_BOOTSTRAP_PROMPT.txt`
- identity and memory scaffolding
- `SOURCES_OF_TRUTH.md`
- `GOALS.md`
- `CONTEXT.md`
- daily memory file

## Step 2 — run the founder discovery
Use `examples/founder-discovery.md` and get answers to:
- what the founder does
- top 3 priorities
- what falls through the cracks
- what systems are actually used
- what would make the first hour worth it

Write the results into:
- `USER.md`
- `GOALS.md`
- `CONTEXT.md`
- `memory/YYYY-MM-DD.md`

## Step 3 — define source-of-truths
Populate `SOURCES_OF_TRUTH.md`.

Default:
- Notion = execution truth
- Email = external commitment truth
- Obsidian = strategic / intellectual truth
- Slack = team-state signal
- Memory = Alice operating memory
- GBrain = world knowledge

## Step 4 — choose exactly one first magic moment
Recommended default order:
1. Meeting prep brief
2. Email ownership / stale-thread brief
3. Executive daily briefing
4. Active deals / follow-up brief
5. Sprint health summary

If unsure, pick **email ownership / stale-thread brief**. It is one of the fastest ways to prove operator value.

## Step 5 — produce the output
See `examples/sample-magic-moment-email-brief.md` for the quality bar.

The first output should:
- synthesize, not dump
- connect at least two sources if possible
- reduce cognitive load immediately
- end with a recommendation

## Step 6 — only then add optional layers
If the founder wants more:
- `./scripts/install-gbrain.sh`
- `./scripts/install-gstack.sh`

## What good looks like
At the end of the first hour, the founder should say something like:
- “It already gets my world.”
- “That was useful immediately.”
- “I can see this compounding.”
