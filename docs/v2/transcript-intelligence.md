# Transcript Intelligence (v2)

Call transcripts are first-class source-of-truth inputs.

## Ingestion routes

### Route A: Granola MCP
- List meetings
- Pull summaries + transcripts
- Extract participants, decisions, actions, risks, objections

### Route B: Manual markdown
- `brain/meetings/raw/`
- `brain/meetings/processed/`
- Frontmatter with date, participants, company, project, source

## Entity linking

Every transcript update should link to:
- people
- companies
- projects
- opportunities/deals
- decisions

## Productized outputs

- pre-meeting brief
- post-call action summary
- follow-up draft suggestions
- objection pattern library
- relationship drift signals

## Rules

- Avoid transcript dump UX.
- Always produce decision-ready synthesis.
- Preserve citation/provenance links.
