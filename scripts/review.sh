#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

cat <<EOF
Review this repo using docs/review-scorecard.md.

Read in order:
1. $ROOT/README.md
2. $ROOT/START_HERE_FOR_AGENTS.md
3. $ROOT/docs/first-hour-walkthrough.md
4. $ROOT/docs/alice-onboarding-wizard-spec-v1.md
5. $ROOT/docs/alice-patterns-worth-stealing.md
6. $ROOT/docs/strategic-lenses.md
7. $ROOT/docs/world-state-and-accountability.md
8. $ROOT/examples/sample-magic-moment-email-brief.md

Then score:
- strategic clarity
- operator credibility
- installability
- agent legibility
- speed to magic moment
- thought leadership quality
- scope discipline

Classify findings as P1 / P2 / P3.
Then patch anything preventing a 10/10 release.
EOF
