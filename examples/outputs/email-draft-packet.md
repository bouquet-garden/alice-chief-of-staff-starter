# Email Draft Packet — 3 Drafts Awaiting Approval

**Surface:** Telegram "Draft Review" topic or Slack DM
**Persona:** Maya Patel (Aria)
**Generated:** Monday, April 13, 2026 at 08:20 PT

---

Alice prepares draft packets during the overnight sync. Each draft includes
the thread context, why Alice chose the tone she did, the complete email,
and an approval gate. Maya reviews them in order of priority.

---

## Draft 1 of 3 — Investor follow-up (P1)

### Thread context

**Subject:** Re: Aria x Meridian Capital — Series A diligence next steps
**From:** Jason Wu (jason@meridianvc.com), Partner at Meridian Capital
**Last message:** April 11, 2026 (2 days ago)
**Ball with:** Us

Jason asked for access to Aria's data room and a breakdown of Q1 revenue
by customer segment. This is the first concrete diligence request from
Meridian, signaling they're moving from exploratory to active evaluation.

> **Jason's last message (excerpt):**
> "Thanks for the call Thursday, Maya. Before our next check-in, could
> you share data room access and a Q1 revenue breakdown by segment?
> We'd like to have our analyst run the numbers before Monday."

### Tone notes

Alice chose a **warm but precise** tone. Reasoning:
- Jason is a lead investor candidate for the Series A -- maintain
  relationship warmth while being professionally responsive.
- The request is specific and operational -- match that specificity.
- The 2-day lag is within acceptable range but should be addressed
  promptly to maintain momentum.

### Draft email

```
From: Maya Patel <maya@aria.dev>
To: Jason Wu <jason@meridianvc.com>
Subject: Re: Aria x Meridian Capital — Series A diligence next steps

Hi Jason,

Great connecting on Thursday. Here's what you asked for:

1. Data room access: [link] — I've granted view permissions for you
   and your analyst. Let me know if anyone else on your team needs
   access.

2. Q1 revenue by segment: included in the data room under
   "Financials > Q1-2026-Segment-Breakdown.pdf". The short version:
   enterprise is 62% of Q1 revenue ($840K), mid-market is 31%
   ($420K), and SMB pilots are 7% ($95K).

Happy to walk through the numbers on our call Monday. Anything else
you need before then, just let me know.

Best,
Maya
```

### Approval gate

```
Reply 'send' to send as-is
Reply 'edit' to open in compose
Reply 'skip' to defer (Alice will remind you in 4h)
```

---

## Draft 2 of 3 — Customer technical response (P1)

### Thread context

**Subject:** Re: PrizePicks API — stale odds edge case
**From:** Derek Cole (derek@prizepicks.com), VP of Engineering at PrizePicks
**Last message:** April 12, 2026 (1 day ago)
**Ball with:** Them (but we owe a status update)

Derek confirmed that the stale odds data for props posted after 8 PM ET
is a known limitation of their v2 API. He asked whether Aria's integration
can work around it or whether they should prioritize a server-side fix.
Maya needs to respond with Aria's recommended path.

> **Derek's last message (excerpt):**
> "Yeah, the after-8 PM staleness is a known v2 issue — we have a fix
> on the roadmap but it won't ship before May. Can your team work
> around it for the pilot, or should we bump the priority on our end?"

### Tone notes

Alice chose a **collaborative and technically specific** tone. Reasoning:
- Derek is an engineering counterpart -- he values directness and
  technical specificity over pleasantries.
- The relationship is strong (5 months into pilot) -- no need for
  formality.
- Maya should demonstrate that her team has already thought about the
  workaround to maintain credibility.

### Draft email

```
From: Maya Patel <maya@aria.dev>
To: Derek Cole <derek@prizepicks.com>
Subject: Re: PrizePicks API — stale odds edge case

Hey Derek,

Good to know it's a known issue — saves us from chasing a ghost.

Our plan: we'll implement a client-side freshness check that
refetches any prop with a last_updated timestamp older than 15
minutes. For props posted after 8 PM ET, we'll add a secondary
polling interval (every 5 min instead of 15) until we get a fresh
response. This should handle the pilot use case without needing a
server-side change on your timeline.

Two things that would help from your side:
1. Can you confirm the v2 staleness window? We're assuming max
   30 minutes, but if it can stretch longer we'll adjust the retry.
2. Any rate limit concerns with the extra polling? We'd go from
   ~200 req/h to ~350 req/h for the affected window.

No rush on the v2 fix for the pilot. We'll build around it.

Thanks,
Maya
```

### Approval gate

```
Reply 'send' to send as-is
Reply 'edit' to open in compose
Reply 'skip' to defer (Alice will remind you in 4h)
```

---

## Draft 3 of 3 — Team hiring update (P2)

### Thread context

**Subject:** Re: Senior backend eng — Lena Park offer
**From:** Internal thread — Maya to Aria hiring channel
**Last message:** April 11, 2026 (2 days ago)
**Ball with:** Us

The hiring committee approved Lena Park's offer on Friday. Maya needs
to send an internal update confirming the offer details and next steps
before the offer letter goes out. This is an internal communication to
the hiring committee (Priya, Ravi, and Maya's co-founder Sam).

> **Last message (Maya in #aria-hiring):**
> "Committee voted yes on Lena. I'll send the formal update Monday
> with offer details and timeline."

### Tone notes

Alice chose a **concise internal update** tone. Reasoning:
- Internal audience that already has context -- no need for background.
- The decision is made -- this is a confirmation, not a discussion.
- Include specific numbers and dates because the team will reference
  this message when onboarding.

### Draft email

```
From: Maya Patel <maya@aria.dev>
To: Priya Sharma <priya@aria.dev>, Ravi Mehta <ravi@aria.dev>,
    Sam Torres <sam@aria.dev>
Subject: Lena Park — offer details and next steps

Team,

Confirming the offer for Lena Park (Senior Backend Engineer):

• Compensation: $165K base + 0.15% equity (4yr vest, 1yr cliff)
• Start date: May 5, 2026
• Reporting to: Priya

Next steps:
1. I'm sending the offer letter today (Monday).
2. Lena has 5 business days to sign (deadline: Apr 20).
3. If she accepts, Priya — please set up her onboarding
   checklist and system access by Apr 28.
4. If she declines, we move to candidate #2 (Jordan Lee)
   immediately.

Let me know if anything needs adjusting before I send.

Maya
```

### Approval gate

```
Reply 'send' to send as-is
Reply 'edit' to open in compose
Reply 'skip' to defer (Alice will remind you in 4h)
```

---

## How draft packets work

1. **Generation:** Alice scans all threads where ball-with-us and
   identifies those needing a response. She generates drafts during
   the overnight sync (or on-demand via `/alice-drafts`).
2. **Prioritization:** Drafts are ordered by priority tier (P0 first),
   then by staleness within each tier.
3. **Tone selection:** Alice uses the relationship tier, thread history,
   and recipient entity profile to select an appropriate tone. The
   tone notes explain her reasoning so Maya can calibrate.
4. **Approval gate:** No email is ever sent without explicit approval.
   Maya can approve, edit, skip, or reject each draft independently.
5. **Learning:** When Maya edits a draft, Alice logs the delta and
   adjusts future tone and style for that recipient.
