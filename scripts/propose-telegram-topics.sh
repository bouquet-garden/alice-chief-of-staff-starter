#!/usr/bin/env bash
set -euo pipefail

ARCHETYPE="${1:-founder-operator}"

cat <<'EOF'
Recommended Telegram Topics:

1) 💬 General
   - ad-hoc conversation
   - quick asks and thinking out loud

2) 📥 Inbox / Triage
   - thread ownership
   - stale follow-up checks
   - "ball with us / ball with them"

3) 📅 Briefings
   - morning brief
   - meeting prep
   - EOD summary

4) 🧠 Strategy
   - synthesis
   - decisions
   - narrative/positioning

5) 🚨 Urgent
   - blockers, incidents, deadlines

6) 🛠 Builders
   - coding/build updates
   - QA/review handoffs
EOF

echo "\nArchetype: $ARCHETYPE"
echo "Customize names/intents based on team style and work cadence."
