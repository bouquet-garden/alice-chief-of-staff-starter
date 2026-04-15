# Source-of-Truth Reconciliation

The core insight most AI systems miss.

---

## The problem nobody talks about

Every business runs on 3-5 systems that contradict each other. Not occasionally — constantly.

Your CRM says the deal is "Closed Won." The Slack thread with the client still has three open questions about the contract terms. Your task tracker marks the onboarding project as "Not Started." Email has a message from the client's legal team asking about a clause you haven't responded to.

Nobody is wrong, exactly. The CRM was updated by the sales rep who got verbal confirmation. The Slack thread is between your implementation team and the client's technical lead, who has a different set of concerns. The task tracker hasn't been touched because the PM is waiting for a fully signed contract. Legal sent the email on Friday and nobody looped in anyone else.

This is the normal state of a real business. Systems diverge because different people update them at different times, for different reasons, with different definitions of "done." The bigger the team, the worse it gets. But even solo founders running a small operation hit this: your calendar, email, notes, and task tracker are constantly out of sync.

## Why reconciliation > search

The standard AI pitch for this problem is unified search: "Connect all your tools, ask any question, get the answer." This sounds great in a demo. In practice, it breaks down precisely when you need it most — when the answer is different depending on which system you ask.

Search returns results. Reconciliation detects conflicts.

This distinction matters because the most dangerous information in your business isn't the information you can't find — it's the information that looks correct but isn't. The CRM showing "Closed Won" will pass any search query about deal status. It looks right. The fact that it contradicts the reality of the open contract negotiation only becomes visible when you cross-reference multiple sources.

Alice is built around reconciliation, not search. The goal isn't to help you find information faster — it's to catch the moments when your systems disagree about the state of reality, because those moments are where balls get dropped, commitments get missed, and relationships get damaged.

## The source hierarchy

Not all contradictions are created equal. If your Slack channel says a feature is shipping Tuesday and your project tracker says Wednesday, that's a discrepancy worth flagging. If a Slack message says "sounds good" and your CRM says the deal is in negotiation, those aren't contradicting — they're just different levels of formality.

Alice handles this through a source-of-truth hierarchy — a configured ranking of which systems are authoritative for which types of information.

A typical hierarchy looks like:

- **Notion** = execution truth (project status, task ownership, sprint state)
- **Email** = external commitment truth (what you promised clients, partners, investors)
- **Obsidian/docs** = strategy truth (goals, decisions, long-term direction)
- **Slack** = live signal, not final truth (real-time discussion, reactions, updates in flight)
- **Calendar** = time commitment truth (what you've agreed to attend)
- **CRM** = deal state truth (but only for commercial relationships)

When Alice detects a conflict, it doesn't just flag it generically. It knows which source to trust based on the type of information. A project status conflict between Notion and Slack? Notion wins, but the Slack signal might indicate Notion is stale and needs updating. An external commitment conflict between email and your task tracker? Email wins, because that's what the other party is holding you to.

The hierarchy is configurable because every founder's stack is different. Some teams run on Linear instead of Notion. Some use Roam instead of Obsidian. The principle is the same: define which systems are authoritative for which domains, and let Alice use that hierarchy to resolve conflicts intelligently instead of just surfacing noise.

## A practical example

Here's how this works in practice.

Alice's overnight scan picks up the following signals:

1. **CRM:** Deal with Acme Corp marked "Closed Won" as of Thursday.
2. **Email:** Message from Acme's legal counsel on Friday asking about indemnification clause in Section 7.
3. **Slack:** Thread in #deals where your BD lead says "Acme is done, moving to onboarding."
4. **Notion:** Acme onboarding project created but marked "Blocked — waiting for signed contract."

A search system, asked "What's the status of the Acme deal?", would likely return the CRM status: Closed Won. Technically accurate per the CRM. Dangerously incomplete.

Alice's reconciliation engine sees this differently:

> **Conflict detected: Acme Corp deal state**
>
> CRM shows Closed Won, but email shows open legal questions from client counsel (Friday, unanswered). Notion onboarding project is blocked on signed contract. Slack thread treats deal as complete.
>
> **Assessment:** CRM status is premature. Legal exchange suggests contract is not finalized. Recommend: (1) respond to legal counsel today — this email is 3 days stale; (2) update CRM to "Contract Review"; (3) notify BD lead that onboarding should remain blocked.
>
> **Priority: P1** — external commitment at risk, stale response to client's legal team.

This is the difference between finding answers and maintaining truth. Alice doesn't just tell you what your systems say — it tells you where your systems are lying to you and what to do about it.

## Why this compounds

Every reconciliation Alice performs generates learning:

- It learns which source pairs tend to conflict (email vs. CRM on deal status is a recurring pattern for your team).
- It learns the typical lag between systems (your PM updates Notion on Mondays, so Friday Slack activity often runs ahead).
- It learns which conflicts are real (status divergence on active deals) and which are noise (someone reacting with an emoji in Slack doesn't constitute a status update).

Over time, Alice's reconciliation becomes sharper. It stops flagging false positives and starts catching subtler conflicts — the kind that would take you weeks to notice on your own.

This is the capability most AI systems miss entirely. They're optimized for retrieval — finding what you ask for. Alice is optimized for detection — finding what you didn't know to ask about. In an operating environment where the biggest risks are the things you're not tracking, detection is worth more than any search engine.
