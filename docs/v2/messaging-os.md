# Messaging OS (v2)

Alice should install and run a messaging operating model, not just join chats.

## Scope

- Telegram topic model
- Slack manifest(s)
- channel/topic routing defaults
- reaction workflows
- App Home briefing surface

## Telegram topic defaults

Recommended topic intents:
- 💬 General (conversation)
- 📥 Inbox / triage
- 📅 Briefings
- 🧠 Strategy
- 🚨 Urgent
- 🛠 Builders

## Slack topology defaults

Recommended channels:
- `#alice-inbox`
- `#alice-briefings`
- `#alice-ops`
- `#alice-war-room`
- `#alice-builds`
- `#alice-decisions`

## Reaction workflows

- 👀 = watch this thread
- ✅ = resolved / update system of record
- 📌 = pin + create durable note
- 🚨 = urgent escalation
- 🧵 = summarize thread + extract decisions/actions

## Routing defaults

- External commitments → inbox/ops
- Daily summaries → briefings
- Delivery risk / blockers → urgent/ops
- Coding/build updates → builds
- Strategic synthesis → strategy

## UX target

After install, Alice App Home or primary chat should show:
- what needs reply
- stale threads
- open decisions
- top 3 recommended moves
