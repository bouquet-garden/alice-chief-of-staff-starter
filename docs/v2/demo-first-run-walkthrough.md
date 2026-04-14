# Demo: First-Run Walkthrough

This document simulates a strong first run of Alice onboarding.

The goal is not to pretend everything is magically automated on minute one.
The goal is to show what a **credible, high-confidence, founder-useful** experience looks like.

---

## Scenario

Founder profile:
- runs a 6-person team
- uses Slack, Telegram, Gmail, Notion, calendar, meeting transcripts, markdown notes
- biggest pain: dropped follow-ups, unclear ownership, buried decisions

Initial configuration:
- autonomy: **Draft + Internal Actions**
- proactivity: **Medium**
- escalation: **Immediate for legal/finance/public commitments**
- quiet hours: **22:00-08:00 local time**

---

## Minute 0-5: install posture

Alice does not begin by acting like a magical omniscient assistant.
It begins by establishing the operating contract.

Example dialogue:

> Alice: "I can read, reconcile, draft, and prepare updates across your systems. I will not send external messages unless you explicitly allow that. For week 1, do you want Draft + Internal Actions as the default?"

> Founder: "Yes."

Immediate outcome:
- expectations are clear
- trust is preserved
- the user understands where automation stops

---

## Minute 5-15: discovery

Example questions:
- What are the top 3 outcomes this week?
- What usually falls through the cracks?
- Which systems do you actually trust for execution, commitments, strategy, and discussion?
- What communication style should I use with you?

Example founder answers:
- top outcomes: ship docs, recover stale client follow-ups, prep partner meeting
- dropped-ball zone: email follow-ups and Slack decisions
- system trust: Notion for execution, Gmail for commitments, notes for strategy
- style: concise, strategic, direct

Artifacts created:
- `USER.md`
- `GOALS.md`
- `SOURCES_OF_TRUTH.md`
- first-pass settings profile

---

## Minute 15-25: source mapping

Alice proposes a source hierarchy:
- Notion = execution truth
- Email = external commitment truth
- Slack = live signal
- transcripts = decision evidence
- markdown/Obsidian = strategic truth

Example dialogue:

> Alice: "If Slack says something is done but Notion is still open, should I treat that as a contradiction to resolve rather than mark complete automatically?"

> Founder: "Yes."

Outcome:
- the user sees that Alice is designed to reconcile, not guess
- the operating model becomes explicit instead of implicit

---

## Minute 25-40: first magic moment

Alice chooses one workflow that can produce value immediately.
In this scenario: **stale-thread recovery + ownership brief**.

Example output:

```text
Operating Brief — Follow-up Recovery

Threads needing action: 8
High-risk commitments: 3
Missing owners: 2
Drafts prepared: 3

Top actions:
1. Approve ACME follow-up draft (P1, stale 72h)
2. Assign owner to partner pre-read task
3. Confirm shipping timeline reply before 4 PM
```

Why this builds confidence:
- it is concrete
- it names real work
- it includes explicit next actions
- it does not require the user to trust a black box

---

## Minute 40-60: draft packet review

Alice presents a safe output surface.
No external sends. Just reviewed drafts.

Example draft packet:

```text
Draft Packet (3)

1. ACME renewal follow-up
- priority: P1
- ownership: ball with us
- stale: 72h
- supporting context: related Notion task still open; Slack thread implies promise not yet fulfilled

2. Partner agenda confirmation
- priority: P1
- ownership: ball with us
- stale: 36h

3. Vendor clarification reply
- priority: P2
- ownership: ball with us
- stale: 28h
```

The user now understands the product behavior:
- Alice finds risk
- Alice prepares work
- Alice asks at the right approval boundary

---

## What a successful first session should leave behind

By the end of a good first run, there should be durable artifacts:

- `USER.md` with founder profile
- `SOURCES_OF_TRUTH.md` with authority model
- `GOALS.md` with current priorities
- a settings profile for autonomy/escalation/style
- at least one concrete operational brief
- at least one interactive output example the user can inspect

If these don’t exist, onboarding is underperforming.

---

## What this demo teaches users

1. Alice is not a generic prompt wrapper.
2. Alice does not require blind trust.
3. Alice is useful before full automation exists.
4. Alice creates durable structure, not just one-off answers.
5. Alice behaves like an operating partner, not a chat toy.
