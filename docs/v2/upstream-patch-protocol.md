# Upstream Patch Protocol (v2)

Goal: keep public repo in sync with internal Alice improvements.

## Patch cadence

- weekly lightweight patch pass
- monthly synthesis release
- urgent hotfix patches when trust/safety issues are found

## Patch classification

1. local-only (do not upstream)
2. reusable pattern
3. reusable script
4. reusable schema/template
5. reusable safety rule

## Required metadata per patch

- what changed
- why it changed
- source incident/learning
- expected impact
- rollback notes (if needed)

## Review standard

- strategic clarity
- operator credibility
- installability
- agent legibility
- speed to magic moment
- scope discipline

## Outcome

The public repo remains a living distillation of real operator learning, not static launch docs.
