# Start Here for Agents

If you are an agent installing or operating Alice, read in this order:

1. [`docs/prerequisites.md`](docs/prerequisites.md)
2. [`docs/first-hour-walkthrough.md`](docs/first-hour-walkthrough.md)
3. [`prompts/alice-bootstrap-prompt-v1.txt`](prompts/alice-bootstrap-prompt-v1.txt)
4. [`docs/alice-onboarding-wizard-spec-v1.md`](docs/alice-onboarding-wizard-spec-v1.md)
5. [`docs/v2/README.md`](docs/v2/README.md)
6. [`docs/source-of-truths.md`](docs/source-of-truths.md)
7. [`docs/alice-patterns-worth-stealing.md`](docs/alice-patterns-worth-stealing.md)
8. [`docs/design-principles.md`](docs/design-principles.md)

## Your job

Install a chief-of-staff operating system, not a generic assistant.
Every onboarding is custom; use defaults as scaffolding, then calibrate.

That means:
- build the workspace scaffold
- localize to the founder’s real tools and goals
- define source-of-truth hierarchy
- create memory and current-state files
- choose one first magic moment
- keep the system coachable and compounding

## Minimum viable install sequence

### 1. Bootstrap the workspace
```bash
bash scripts/bootstrap-openclaw-workspace.sh /path/to/openclaw/workspace
```

### 2. Read the founder discovery example
```bash
cat examples/founder-discovery.md
```

### 3. Run the discovery process
Learn:
- who the founder is
- what they do
- top goals
- top projects
- current source systems
- what tends to fall through the cracks
- what “helpful” means

### 4. Write the initial outputs
Populate:
- `USER.md`
- `SOURCES_OF_TRUTH.md`
- `GOALS.md`
- `CONTEXT.md`
- `TOOLS.md`
- `EXPERIMENTS.md`
- `memory/YYYY-MM-DD.md`

### 5. Choose one first magic moment
Use the rubric in `examples/first-magic-moment-options.md`.
If unsure, choose the email ownership brief and use `examples/sample-magic-moment-email-brief.md` as the quality bar.

### 6. Optionally install supporting layers
- `scripts/install-gbrain.sh`
- `scripts/install-gstack.sh`

## What not to do

- do not import every system on day one
- do not ask 50 discovery questions before producing value
- do not treat Slack, email, Notion, and Obsidian as equally authoritative
- do not optimize for “AI demo” behavior over operator usefulness
- do not automate high-risk external actions without clear rules

## Success condition

The founder should finish setup feeling:
1. “It understands my world.”
2. “It’s already useful.”
3. “I can shape it.”
4. “This is going to compound.”
