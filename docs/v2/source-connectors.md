# Source-of-Truth Connectors (v2)

Connectors map real systems into one operational model.

## Connector set

1. Notion starter schema
2. Obsidian PARA starter
3. Slack reconciliation model
4. Email ownership model

## Notion starter schema

Core DBs:
- Projects
- Tasks
- Meetings
- People/Accounts
- Experiments
- OKRs

Core properties:
- status, owner, due, priority, estimate, stage
- linked project/entity
- source system
- confidence/review status

## Obsidian PARA starter

- `00 Inbox`
- `01 Projects`
- `02 Areas/Alice Executive Assistant`
- `03 Resources`
- `04 Archive`

## Slack reconciliation model

Detect and flag contradictions such as:
- Slack says done, Notion says in progress
- Slack promise not reflected in task/project state

## Email ownership model

- classify ownership and staleness per thread
- synchronize external commitments to execution systems

## Principle

Connectors are not data pipes only — they enforce operating semantics.
