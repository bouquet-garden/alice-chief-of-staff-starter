# Complete Onboarding Walkthrough

**Persona:** Maya Patel, Founder/CEO of Aria (B2B SaaS, 12-person team, Series A prep)
**Date:** Tuesday, October 15, 2024
**Duration:** ~55 minutes

---

## Table of Contents

1. [Terminal output from alice-setup.sh](#1-terminal-output-from-alice-setupsh)
2. [Discovery conversation](#2-discovery-conversation)
3. [Operating contract negotiation](#3-operating-contract-negotiation)
4. [Source-of-truth mapping](#4-source-of-truth-mapping)
5. [Seeding process output](#5-seeding-process-output)
6. [Backtest scorecard](#6-backtest-scorecard)
7. [First magic moment](#7-first-magic-moment)
8. [Calibration adjustment](#8-calibration-adjustment)
9. [Day 2 morning brief](#9-day-2-morning-brief)
10. [Final workspace state](#10-final-workspace-state)

---

## 1. Terminal output from `alice-setup.sh`

Maya opens her terminal and runs the setup wizard.

```
$ bash scripts/alice-setup.sh

  ┌─────────────────────────────────────────────────────┐
  │                                                     │
  │          Alice Chief-of-Staff  ·  Setup             │
  │                                                     │
  │  This wizard will:                                  │
  │    1. Detect your available tools & integrations    │
  │    2. Ask which integrations you want to set up     │
  │    3. Configure Slack, Telegram, Obsidian, Notion,  │
  │       and/or Gmail labels                           │
  │    4. Scaffold your Alice workspace files           │
  │    5. Hand off to your AI agent to start discovery  │
  │                                                     │
  │  Pure bash. No Node, Python, or Bun required.       │
  │  Takes about 5 minutes.                             │
  │                                                     │
  └─────────────────────────────────────────────────────┘

  → Press Enter to begin setup, or Ctrl+C to cancel.
```

Maya presses Enter.

```
══════════════════════════════════════════════
  Phase 1 · Preflight Check
══════════════════════════════════════════════

  ✅  git: git version 2.43.0
  ✅  working directory: /Users/maya/code/alice-chief-of-staff-starter
  ✅  Slack CLI: found (v2.25.0)
  ⚠️   Telegram: no TELEGRAM_BOT_TOKEN set  (skip or: export TELEGRAM_BOT_TOKEN=your_token)
  ✅  Notion: NOTION_API_KEY is set
  ⚠️   Gmail: neither 'gam' nor 'gmail-cli' found  (optional — labels will be shown as manual instructions)
  ✅  Obsidian vault: /Users/maya/Documents/Obsidian
  ⚠️   Granola: not found  (optional — install from https://granola.ai)
  ⚠️   gbrain: not installed  (optional — install with: bash scripts/install-gbrain.sh)

══════════════════════════════════════════════
  Phase 2 · Integration Setup
══════════════════════════════════════════════

▸ Which integrations would you like to configure?

  (Enter the numbers, separated by spaces, or 'all', or press Enter to skip)

  [1]  Slack channels    (CLI detected)
  [2]  Telegram topics   (no token — will show instructions)
  [3]  Obsidian vault    (vault found at /Users/maya/Documents/Obsidian)
  [4]  Notion databases  (API key set)
  [5]  Gmail labels      (no gam — will show manual instructions)

  → Your choice (e.g. 1 3 5, or 'all', or Enter to skip integrations):
```

Maya types `1 3 4 5` and presses Enter.

```
[Running] setup-slack.sh

Slack Channel Setup

  ℹ️   Creating channels from: manifests/slack/channels.json

  Creating #alice-inbox                   ✅  created
  Creating #alice-briefings               ✅  created
  Creating #alice-ops                     ✅  created
  Creating #alice-war-room                ✅  created
  Creating #alice-builds                  ✅  created
  Creating #alice-decisions               ✅  created

  ℹ️   Result: 6 created, 0 already existed, 0 failed

Next step: Import the Slack app manifests

  The Slack CLI cannot fully configure app permissions programmatically.
  Import the manifests manually at https://api.slack.com/apps:

    Operator manifest (bot with full permissions):
      manifests/slack/alice-operator.manifest.json

    Starter manifest (read-only, lighter footprint):
      manifests/slack/alice-starter.manifest.json

  Steps:
    1. Go to https://api.slack.com/apps
    2. Click 'Create New App' → 'From an app manifest'
    3. Paste the JSON from one of the files above
    4. Install the app to your workspace
    5. Copy the Bot OAuth Token (xoxb-...) to your env:
       export SLACK_BOT_TOKEN=xoxb-...

[Running] setup-obsidian.sh

Obsidian Vault Setup
  ✅  Vault: /Users/maya/Documents/Obsidian

  ℹ️   Scaffolding Alice PARA structure into: /Users/maya/Documents/Obsidian/Alice

  ✅  Copied: Alice/00 Inbox/README.md
  ✅  Copied: Alice/01 Projects/README.md
  ✅  Copied: Alice/02 Areas/README.md
  ✅  Copied: Alice/03 Resources/README.md
  ✅  Copied: Alice/04 Archive/README.md
  ✅  Copied: Alice/Templates/daily-brief.md
  ✅  Copied: Alice/Templates/meeting-prep.md
  ✅  Copied: Alice/Templates/decision-log.md
  ✅  Copied: Alice/README.md
  ✅  PARA scaffold installed at: /Users/maya/Documents/Obsidian/Alice

Recommended Obsidian Plugins

  Install these community plugins for the best Alice experience:

    1. Templater    — dynamic templates and date-aware notes
    2. Dataview     — query and table views across your vault
    3. Tasks        — task tracking with due dates and filters
    4. Calendar     — daily notes with a calendar side panel

[Running] setup-notion.sh

Notion Database Setup
  ✅  API key verified. Connected workspace: Aria

  ℹ️   Scanning for existing databases...
  ✅  Found: Projects (database_id: a3f2...)
  ✅  Found: Sprint Board (database_id: 7c19...)
  ⚠️   No 'Decisions' database found — Alice will create one if you'd like.

  ℹ️   Notion setup complete. 2 databases linked, 1 optional database suggested.

[Running] setup-email-labels.sh

Gmail Label Setup

  ⚠️   gam not found. Showing manual label creation instructions.

  Option A: Install gam (recommended for bulk label management)
    https://github.com/GAM-team/GAM/wiki/How-to-Install-Advanced-GAM
    Then re-run: bash scripts/setup-email-labels.sh

  Option B: Create labels manually in Gmail
    1. Open Gmail → Settings (gear) → See all settings → Labels
    2. Scroll to 'Labels' section → click 'Create new label'
    3. Create nested labels (e.g. 'Alice/P0') by using slashes

  Labels to create:

    Alice/P0                                   #cc0000  Requires same-day response
    Alice/P1                                   #e67e00  Requires response within 24 hours
    Alice/P2                                   #e6c200  Requires response within 72 hours
    Alice/P3                                   #1a73e8  Low priority — informational
    Alice/Ball-With-Us                         #0f9d58  We own the next move
    Alice/Ball-With-Them                       #5f6368  They own the next move
    Alice/Stale                                #9334e6  No activity in 7+ days
    Alice/Draft-Ready                          #00897b  Draft prepared, awaiting review
    Alice/Triaged                              #b0bec5  Processed, safe to archive

══════════════════════════════════════════════
  Phase 3 · Workspace Scaffold
══════════════════════════════════════════════

  Alice workspace will be created at:
  /Users/maya/.alice/workspace

  → Use this path? (Enter to confirm, or type a different path):
```

Maya presses Enter.

```
  ℹ️   Scaffolding workspace...

  ✅  Created: /Users/maya/.alice/workspace/USER.md
  ✅  Created: /Users/maya/.alice/workspace/CONTEXT.md
  ✅  Created: /Users/maya/.alice/workspace/SOURCES_OF_TRUTH.md
  ✅  Created: /Users/maya/.alice/workspace/GOALS.md
  ✅  Created: /Users/maya/.alice/workspace/ALICE_BOOTSTRAP_PROMPT.txt
  ✅  Workspace scaffolded at: /Users/maya/.alice/workspace

══════════════════════════════════════════════
  Phase 4 · Agent Handoff
══════════════════════════════════════════════

  Setup complete! Here's how to start:

  1. Open your preferred AI agent:
     - Claude Code:    claude
     - OpenAI Canvas:  https://chatgpt.com
     - Any agent that can read files

  2. Your bootstrap prompt is ready at:
     /Users/maya/.alice/workspace/ALICE_BOOTSTRAP_PROMPT.txt

  3. Copy and paste the contents of that file as your
     first message to the agent.

  4. Alice will run discovery, calibrate to your
     preferences, and deliver your first magic moment.

  Your workspace: /Users/maya/.alice/workspace

  Quick start with Claude Code:
    claude "$(cat /Users/maya/.alice/workspace/ALICE_BOOTSTRAP_PROMPT.txt)"

▸ What Alice will do in the first session

  · Ask about you, your work, and your top priorities
  · Map your sources of truth (Notion, email, Obsidian, etc.)
  · Build your identity files (USER.md, CONTEXT.md, GOALS.md)
  · Deliver one high-value workflow in the first hour
  · Set up a memory system that compounds over time

  Tip: the more context you give upfront, the better
  Alice will calibrate. Share your calendar, a recent
  email thread, or a current project brief.

  Docs: /Users/maya/code/alice-chief-of-staff-starter/docs/
  Examples: /Users/maya/code/alice-chief-of-staff-starter/examples/

  Ready. Good luck.
```

Maya launches Claude Code and pastes the bootstrap prompt.

---

## 2. Discovery conversation

Alice begins the 6-question calibration sequence. This takes about 12 minutes.

---

### Question 1: What do you work on, and what does the business look like right now?

> Alice: Let's start with context. Tell me about you and Aria — what the company does, where you are right now, and what your role looks like day to day.

**Maya:** I'm Maya Patel, founder and CEO of Aria. We're a B2B SaaS platform — we help mid-market companies automate their procurement workflows. Think: purchase orders, vendor approvals, spend tracking, all in one place. We're 12 people. Engineering is 6, sales is 3, one PM, one designer, and me. I do everything that doesn't fit into someone else's job description — fundraising, sales calls with enterprise leads, product direction, hiring, and trying to keep the trains running. We closed a $2.1M seed 14 months ago and we're prepping for Series A. Revenue is around $840K ARR, growing about 15% month over month. We need to close the round in the next 90 days or we'll need to cut burn.

---

### Question 2: What is the biggest operational pain this week?

> Alice: What is the single biggest thing slowing you down or causing dropped balls this week?

**Maya:** Honestly, my inbox is destroying me. I have 340 unread emails. Somewhere in there is a follow-up from Jason Wu at Meridian Capital about our Series A — I think he asked for updated metrics last week and I haven't sent them. There's also a big enterprise deal with Crestline Logistics that's been going back and forth for three weeks and I can't tell if the ball is with us or with them. I also had four Zoom calls yesterday and I don't remember what I promised in any of them. Everything is slipping because I'm context-switching every 15 minutes.

---

### Question 3: What are your top 3 priorities for the next 90 days?

> Alice: If nothing else gets done in the next 90 days, what three things absolutely must happen?

**Maya:**

1. **Close the Series A.** We need a lead investor committed with a term sheet by mid-January. Jason at Meridian is the warmest lead, but we're also talking to Clearpath Ventures and Oren Nachman at Tidepool. I need a clean data room and a compelling deck refresh.

2. **Land Crestline Logistics.** They'd be our largest customer — $180K ACV. If we close them before the round, it completely changes the fundraising story. Their VP of Procurement, Danielle Reeves, is the decision-maker. We're in legal review on the contract but I think something stalled.

3. **Ship the Approvals v2 module.** Our PM Raj has the spec but engineering is behind. It's the feature that Crestline specifically asked for, and two other enterprise prospects mentioned it. If it slips past November, Crestline might stall.

---

### Question 4: What tools and channels do you use? How do you want updates?

> Alice: Walk me through the systems you actually live in — email, Slack, project tools, notes, calendar. And how do you want me to communicate with you?

**Maya:** Gmail is my main inbox — everything external goes through maya@aria.so. Slack is where the team talks — we have about 10 channels but the ones I actually read are #general, #deals, #engineering, and #leadership. Notion is our project tracker — we have a Projects database and a Sprint Board. Linear is what engineering uses for tickets — I check it maybe twice a week. We use Zoom for all external calls and I just started using Granola to record meeting transcripts, though I haven't gone back and read any of them yet. I use Obsidian for personal notes and strategy thinking, but it's a mess. I want updates in Slack — post to #alice-briefings for daily stuff, DM me for anything urgent. Mornings are best. I check Slack first thing at 8am.

---

### Question 5: What decisions should Alice NEVER make without asking?

> Alice: What are the hard boundaries? Give me the categories where I should always stop and ask before acting, even if I'm confident.

**Maya:** Anything involving money — sending a contract, agreeing to pricing, committing budget. Anything to investors — do not send an email to Jason or any investor without me reviewing it word by word. Personnel decisions — if someone on the team is underperforming or there's a conflict, surface it to me but don't intervene. Legal stuff obviously. And don't reschedule any meetings on my calendar without asking — I have a hard time saying no to people and I don't want Alice doing it for me either.

---

### Question 6: One thing you wish your team knew that you haven't had time to explain?

> Alice: Last one. What's something your team should know — context you carry around in your head — that you haven't found the time to share?

**Maya:** I think Raj doesn't know how important the Approvals v2 timeline is to the fundraise. He thinks it's a product decision. It's actually a fundraising dependency — if Crestline signs before the round, we're in a completely different negotiating position. I should have explained this to him two weeks ago but every time I start to write the message I get pulled into something else. Also, the team doesn't know how tight the runway is. We have about 7 months of cash at current burn. I'm not trying to scare anyone, but the urgency level on the fundraise isn't visible to them.

---

> Alice: Got it. I have a clear picture now. Let me set up your operating contract — this is where we agree on how I work, what I can do on my own, and where I stop and check with you.

---

## 3. Operating contract negotiation

Alice proposes defaults based on Maya's discovery answers.

---

> Alice: Here's what I'm proposing for your operating contract. Review each setting and tell me if you want to change anything.

> Alice:
> **Autonomy level: Draft + Internal Actions**
> I can read all your systems, summarize, create drafts, and update internal tools (Notion tasks, Slack messages, Obsidian notes). I will not send any email, post any external message, or take action visible to anyone outside Aria without your explicit approval.

**Maya:** Perfect. That's exactly what I want for week one.

> Alice:
> **Proactivity level: Medium**
> I'll send you a daily summary and flag notable risks. I won't proactively draft emails or surface recommendations unless you ask.

**Maya:** Actually, bump that to High. I want you to proactively draft things. If you see an email that needs a reply, draft it. If you notice something slipping, tell me before I ask. The whole point of this is that I'm drowning — I need you to be ahead of me, not waiting for me to notice things.

> Alice: Understood. Changing proactivity to **High**. That means I will:
> - Proactively draft email responses for P0 and P1 threads
> - Surface risks and stale commitments without being asked
> - Prepare meeting agendas and pre-reads before your calendar events
> - Recommend actions in your daily brief, not just report status
>
> I'll still hold all external sends for your approval.

**Maya:** Good. Do that.

> Alice:
> **Escalation policy:**
> - Immediate escalation (DM, any time of day): legal, financial commitments, investor communications, personnel issues
> - Daily digest: operational drift, stale threads, minor blockers
> - Auto-handle (no escalation): formatting, tagging, categorization, draft prep, internal Notion/Linear updates

**Maya:** Add "any communication with Crestline Logistics" to the immediate escalation list. They're too important to risk a wrong signal.

> Alice: Done. Crestline Logistics added to immediate escalation alongside legal, financial, investor, and personnel matters.

> Alice:
> **Brief cadence:**
> - 8:00 AM daily morning brief (posted to #alice-briefings)
> - EOD summary optional — I'll send one if there are open items that changed during the day
> - Quiet hours: 10 PM to 8 AM, P0 bypass only

**Maya:** That works. Let's try it.

> Alice: Operating contract locked in. Here's the summary:
>
> ```
> ┌─────────────────────────────────────────────────┐
> │         OPERATING CONTRACT — Maya Patel          │
> │         Effective: October 15, 2024              │
> ├─────────────────────────────────────────────────┤
> │ Autonomy:     Draft + Internal Actions           │
> │ Proactivity:  High                               │
> │ Escalation:   Immediate — legal, financial,      │
> │               investor, personnel, Crestline     │
> │               Digest — ops drift, stale threads  │
> │               Auto — tagging, drafts, updates    │
> │ Brief:        8 AM daily, EOD optional           │
> │ Quiet hours:  10 PM – 8 AM (P0 bypass only)     │
> │ Comm style:   Strategic, direct, no fluff        │
> │ Channel:      #alice-briefings (daily),          │
> │               Slack DM (urgent)                  │
> └─────────────────────────────────────────────────┘
> ```
>
> I'll evolve this as we learn what works. You can change any setting at any time.

---

## 4. Source-of-truth mapping

Alice maps Maya's tool stack with specific priorities and reconciliation rules.

---

> Alice: Now I need to map which systems are authoritative for what. This prevents me from giving you contradictory information. Here's what I'm proposing based on what you told me:

> Alice:
> ```
> SOURCE-OF-TRUTH MAP
> ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
>
> Notion Projects DB    → Authoritative for project status and milestones
> Linear                → Authoritative for engineering task state
> Gmail                 → Authoritative for external commitments and promises
> Slack #deals          → Signal for deal momentum (not authoritative)
> Slack #engineering    → Signal for build status (not authoritative)
> Zoom/Granola          → Decision evidence from meetings
> Obsidian              → Strategic thinking and personal notes
> Calendar              → Schedule truth (never modify without asking)
>
> RECONCILIATION RULES
> ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
>
> If Slack says something is done but Notion still shows "In Progress":
>   → Flag as contradiction. Do not auto-resolve.
>
> If email contains a commitment not reflected in Notion:
>   → Surface in daily brief. Suggest creating a task.
>
> If Linear shows a ticket closed but Notion project is still open:
>   → Check if all tickets under that project are closed.
>   → If yes, flag project for review. If no, just note it.
>
> If a Zoom transcript contains a promise or deadline:
>   → Extract and surface in next brief. Link to thread/task if exists.
> ```

**Maya:** This looks right. One addition — Slack #deals is where our sales team drops updates about pipeline conversations. Sometimes Priya will say "Crestline is going to sign next week" in Slack and it never makes it to Notion. Can you watch for that specifically?

> Alice: Absolutely. I'll monitor #deals for commitment signals — verbal close dates, pricing mentions, contract status updates — and cross-reference against the Notion Projects DB. If I find something in #deals that isn't reflected in Notion, I'll flag it.
>
> Adding rule:
> ```
> If #deals contains a deal status update not reflected in Notion:
>   → Surface in daily brief with recommendation to update project record.
>   → Tag as "deal signal gap" for pattern tracking.
> ```

**Maya:** Great.

> Alice: I'll also need read access to these specific sources. Let me confirm what I can reach:
>
> ```
> ACCESS VERIFICATION
> ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
>
> ✅  Gmail (maya@aria.so)         — connected via OAuth
> ✅  Slack (aria-team.slack.com)  — bot token active, 10 channels visible
> ✅  Notion (Aria workspace)      — API key valid, 2 databases found
>       Projects DB (a3f2...)
>       Sprint Board (7c19...)
> ✅  Obsidian vault               — /Users/maya/Documents/Obsidian/Alice scaffolded
> ⚠️   Linear                      — no API token. I can still read what surfaces in Slack.
>                                    For direct access: export LINEAR_API_KEY=lin_api_...
> ⚠️   Granola transcripts         — not yet configured. Drop transcript files in
>                                    ~/.alice/workspace/inbox/ and I'll process them.
> ✅  Calendar                     — visible through Gmail integration
> ```
>
> Linear and Granola are optional but valuable. We can add them later.

**Maya:** I'll get the Linear token from Raj later today. Granola can wait.

---

## 5. Seeding process output

Alice seeds her world-state cache from Maya's connected sources.

---

> Alice: I'm scanning your connected systems now to build an initial picture of your world. This is a one-time seed — after this, I'll maintain a running cache.
>
> Give me about 3 minutes.

```
SEEDING WORLD-STATE CACHE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Scanning Gmail (last 30 days)...
  Threads found: 412
  Threads with action required: 47
  ✅ 47 threads processed

  Ownership classification:
    Ball-With-Us:    19 threads
    Ball-With-Them:  23 threads
    Resolved:         5 threads

  Priority classification:
    P0 (same-day):   3 threads
    P1 (24-hour):    5 threads
    P2 (72-hour):   14 threads
    P3 (info only):  25 threads

  Requires response: 8 threads
    P0: 3 threads
      → Jason Wu (Meridian Capital): Series A metrics follow-up [6 days stale]
      → Danielle Reeves (Crestline): Contract redline questions [4 days stale]
      → Sarah Lund (Clearpath Ventures): Intro meeting scheduling [3 days stale]
    P1: 5 threads
      → Kevin Cho (candidate): Engineering lead interview follow-up [5 days]
      → Nisha Bhat (AWS): Partnership program application status [7 days]
      → Tom Aldridge (Panorama Legal): MSA markup review [3 days]
      → Priya Sharma (internal): Crestline pricing approval [2 days]
      → Marcus Webb (DataSync): Integration API access request [4 days]

Scanning Slack (last 30 days)...
  Channels scanned: 10
  Messages analyzed: 2,847
  ✅ Decision points extracted: 12

  Key decisions found:
    1. Oct 3  — #engineering: "Approvals v2 scope locked to 4 workflows" (Raj)
    2. Oct 4  — #deals: "Crestline wants Approvals v2 before signing" (Priya)
    3. Oct 7  — #leadership: "Freeze non-critical hiring until round closes" (Maya)
    4. Oct 7  — #engineering: "Moving to bi-weekly deploys for stability" (Arun)
    5. Oct 9  — #deals: "Danielle says legal review will take 2 weeks" (Priya)
    6. Oct 9  — #general: "Team offsite pushed to November" (Maya)
    7. Oct 10 — #engineering: "API rate limiting shipped to prod" (Arun)
    8. Oct 10 — #deals: "DataSync wants pilot program — 3 month trial" (Marcus)
    9. Oct 11 — #leadership: "Q3 board deck due October 25" (Maya)
   10. Oct 12 — #engineering: "Vendor approval flow has a blocker — waiting on API spec" (Raj)
   11. Oct 14 — #deals: "Crestline demo went well, Danielle asking about timeline" (Priya)
   12. Oct 14 — #engineering: "Approvals v2 will slip 1 week — dependency on auth refactor" (Arun)

Scanning Notion...
  Projects DB: 8 active projects
  Sprint Board: 34 open tickets (12 in current sprint)
  ✅ Cross-referenced against Slack and email

  Stale projects (no update in 14+ days):
    ⚠️  "SOC 2 Compliance Prep" — last updated Sep 29
        No owner assigned. Last mention: #leadership on Sep 28.
    ⚠️  "Customer Onboarding Revamp" — last updated Oct 1
        Owner: Priya. No Slack or email activity since Oct 2.

Seeding complete.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Email threads processed:   47
  Decision points extracted:  12
  Stale projects flagged:      2
  Entity graph:              68 people, 8 projects, 12 decisions, 47 threads
  Cache freshness:           October 15, 2024 09:14 AM
```

> Alice: Seeding is done. A few things jumped out immediately — I'll cover them in the backtest. But first, here's one number that matters: you have 3 P0 emails that are between 3 and 6 days old. Two of them are from people critical to your top 90-day priorities.

---

## 6. Backtest scorecard

Alice runs a retrospective analysis over the last 30 days to show what she would have caught.

---

> Alice: I ran a backtest against your last 30 days of email, Slack, and Notion activity. This is what I would have caught if I'd been active.

```
BACKTEST SCORECARD — Last 30 Days
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 SUMMARY
   Stale commitments found:    4
   Contradictions found:       2
   Missed follow-ups:          1
   Estimated time savings:     3.5 hrs/week

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔴 STALE COMMITMENTS (4)

1. Jason Wu (Meridian Capital) — cap table + Q3 metrics
   You told Jason you'd send the updated cap table and Q3 metrics
   "by end of this week." That was October 9 — 6 days ago.
   Source: email thread, Oct 8 reply from you
   Risk: Meridian is your warmest Series A lead. Silence reads as
   disorganization to an investor evaluating your operational maturity.

2. Danielle Reeves (Crestline) — contract redline response
   On Oct 11, Danielle's legal team sent a redlined MSA. You replied
   same day saying "we'll turn this around by Monday." It is now
   Tuesday. No response sent.
   Source: email thread, Oct 11
   Risk: Crestline is your largest pending deal. Legal delays compound.

3. Kevin Cho (eng candidate) — interview debrief
   You told Kevin after his onsite on Oct 10 that you'd "get back to
   him by early next week with next steps." No email sent.
   Source: email thread, Oct 10
   Risk: Engineering lead candidates in this market move fast. 5-day
   silence after a final round is a bad signal.

4. Board deck — due October 25
   You committed in #leadership on Oct 11 to having the Q3 board deck
   ready by October 25. No Notion task exists. No draft started.
   Source: Slack #leadership, Oct 11
   Risk: 10 days away with no artifact. This will become a fire drill.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🟡 CONTRADICTIONS (2)

1. "Approvals v2" status mismatch
   Notion Projects DB shows "Approvals v2" status as "On Track"
   (last updated Oct 8). But Slack #engineering from Oct 12 has Raj
   saying "vendor approval flow has a blocker — waiting on API spec"
   and Arun posted yesterday that "Approvals v2 will slip 1 week."
   → Notion is stale. Actual status: blocked, will slip.

2. Crestline deal stage mismatch
   Notion Projects DB shows Crestline as "Contract Sent" (Oct 7).
   But email shows a redlined MSA was returned on Oct 11 and is
   awaiting your response. Priya posted in #deals on Oct 14 that
   "Danielle is asking about timeline."
   → Notion is 8 days behind reality. Actual stage: Legal Review — Ball With Us.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🟠 MISSED FOLLOW-UPS (1)

1. Nisha Bhat (AWS) — partnership program
   You applied to the AWS SaaS Accelerator on Oct 1 and received a
   confirmation requesting "additional technical documentation within
   10 business days." Today is business day 10. No documentation sent.
   Source: email, Oct 1
   Risk: Missing this deadline likely means reapplying next quarter.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⏱️  ESTIMATED TIME SAVINGS

   Email triage + priority sort:         1.5 hrs/week
   Stale commitment detection:           0.5 hrs/week
   Cross-system reconciliation:          0.5 hrs/week
   Meeting follow-up extraction:         0.5 hrs/week
   Draft preparation:                    0.5 hrs/week
                                        ─────────────
   Total estimated:                      3.5 hrs/week
```

> Alice: The two most time-sensitive items are Jason Wu's metrics request and Danielle Reeves' contract redline. I've already started drafting responses for both. Want to see them now, or should we finish setup first and I'll include them in your first email brief?

**Maya:** Show me the email brief. Let's do the magic moment.

---

## 7. First magic moment

Alice delivers a complete email ownership brief.

---

> Alice: Here's your first email ownership brief. Everything marked "Draft ready" has a response prepared for your review. Nothing has been sent.

```
📧 EMAIL OWNERSHIP BRIEF — Tuesday, October 15
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔴 NEEDS RESPONSE TODAY (3)

1. Jason Wu (Meridian Capital) — Series A term sheet follow-up
   Sent: 6 days ago | Thread: 4 messages | Ball: with us
   Summary: Jason asked for updated cap table and Q3 revenue
   metrics on Oct 9. You said "end of this week." No reply since.
   Why it matters: Meridian is your warmest Series A lead. Every day
   of silence increases the chance he fills his allocation elsewhere.
   Draft ready: ✅ [see below]

2. Danielle Reeves (Crestline Logistics) — MSA redline response
   Sent: 4 days ago | Thread: 7 messages | Ball: with us
   Summary: Crestline legal returned the redlined MSA on Oct 11.
   Your response is needed on 3 clauses: limitation of liability,
   data retention, and SLA guarantees. Tom Aldridge at Panorama
   Legal also emailed you a markup review — unread.
   Why it matters: $180K ACV deal. Each day of legal delay risks
   Q4 close, which is a fundraising dependency.
   Draft ready: ✅ [see below — forwarding redlines to Tom with instructions]

3. Sarah Lund (Clearpath Ventures) — intro meeting scheduling
   Sent: 3 days ago | Thread: 2 messages | Ball: with us
   Summary: Sarah was introduced by your board member David Chen.
   She proposed three times for an intro call. No response from you.
   Why it matters: Clearpath is a backup investor if Meridian
   doesn't close. Board member made the intro — ignoring it looks bad.
   Draft ready: ✅ [see below — accepting Thursday 2pm slot]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🟡 NEEDS RESPONSE WITHIN 24 HOURS (5)

4. Kevin Cho (candidate) — engineering lead next steps
   Sent: 5 days ago | Thread: 3 messages | Ball: with us
   Summary: Kevin completed his onsite on Oct 10. You told him
   you'd follow up "early next week." It's now Tuesday.
   Recommendation: Send a short holding message today, even if
   the hiring decision isn't final. Silence loses candidates.
   Draft ready: ✅

5. Nisha Bhat (AWS) — SaaS Accelerator documentation
   Sent: 10 business days ago | Thread: 2 messages | Ball: with us
   Summary: AWS requested additional technical docs for the SaaS
   Accelerator application. Deadline is today.
   Recommendation: Send what you have. A partial submission is
   better than a missed deadline.
   Draft ready: ⚠️ [needs your technical input — I drafted the cover email]

6. Tom Aldridge (Panorama Legal) — MSA markup acknowledgment
   Sent: 3 days ago | Thread: 1 message | Ball: with us
   Summary: Tom sent his review of the Crestline MSA redlines. Unread.
   Recommendation: Read his markup, then send the Crestline response.
   These two threads are connected.
   Draft ready: 🔗 [linked to item #2 above]

7. Priya Sharma (internal) — Crestline pricing approval
   Sent: 2 days ago | Thread: 1 message (Slack DM forwarded to email) | Ball: with us
   Summary: Priya is asking whether to hold firm at $180K ACV or
   offer a 10% discount to accelerate close. Needs your call.
   Recommendation: Decide today. Priya can't move until you do.
   Draft ready: ❌ [decision required — cannot draft without your input]

8. Marcus Webb (DataSync) — integration API access
   Sent: 4 days ago | Thread: 2 messages | Ball: with us
   Summary: DataSync wants API access for a pilot integration.
   This was discussed in #deals as a 3-month trial opportunity.
   Recommendation: Approve or decline. Low risk either way.
   Draft ready: ✅

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🟢 BALL WITH THEM — WATCHING (5)

 9. Oren Nachman (Tidepool) — waiting on his availability
     Last activity: Oct 12 | You proposed 3 meeting times
     ⏰ Will flag as stale if no reply by Oct 17

10. Lisa Park (Segment) — waiting on technical review
     Last activity: Oct 10 | They're evaluating your API docs
     ⏰ Will flag as stale if no reply by Oct 17

11. HR benefits broker — waiting on updated quotes
     Last activity: Oct 8 | They said "end of next week"
     ⏰ Deadline passed. Flagging as stale tomorrow if no update.

12. Aria design contractor — waiting on portfolio samples
     Last activity: Oct 13 | They said "by Wednesday"
     Tracking.

13. Conference organizer (SaaS North) — waiting on speaker confirmation
     Last activity: Oct 11 | Panel invitation, pending their logistics
     No action needed yet.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📎 DRAFT PACKET — Ready for Review (5 drafts)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

DRAFT 1 — To: Jason Wu (Meridian Capital)
Subject: RE: Aria — Q3 metrics + cap table

  Hi Jason,

  Apologies for the delay on this. Attached are the updated Q3
  metrics and current cap table as of October 15.

  Highlights:
  - ARR: $840K (15% MoM growth, sustained since June)
  - Net revenue retention: 118%
  - Pipeline: $420K in active enterprise opportunities
  - Burn multiple: 1.4x (down from 1.9x in Q1)

  Happy to walk through any of this on a call. Do you have
  30 minutes Thursday or Friday?

  Best,
  Maya

  [📎 Attachments needed: Q3_metrics.pdf, cap_table_oct24.xlsx]

  ⚠️  Note from Alice: You'll need to attach the actual files.
  I've flagged this because the metrics doc doesn't exist in your
  Notion or Drive yet. Recommend creating it today.

─────────────────────────────────────────────

DRAFT 2 — To: Danielle Reeves (Crestline Logistics)
CC: Tom Aldridge (Panorama Legal)
Subject: RE: Aria x Crestline — MSA Redlines

  Hi Danielle,

  Thank you for the thorough review from your legal team. We've
  gone through each markup and have responses on the three open
  items:

  1. Limitation of liability — [needs Tom's input, placeholder]
  2. Data retention — [needs Tom's input, placeholder]
  3. SLA guarantees — [needs Tom's input, placeholder]

  I've CC'd Tom Aldridge from our outside counsel to provide the
  specific language. We'd like to have this wrapped up this week
  if possible.

  Looking forward to getting this across the finish line.

  Best,
  Maya

  ⚠️  Note from Alice: This draft has placeholders. Read Tom's
  markup email first (item #6), then I'll fill in the specifics.
  Escalation: This thread is on your immediate-escalation list.

─────────────────────────────────────────────

DRAFT 3 — To: Sarah Lund (Clearpath Ventures)
Subject: RE: Intro — Maya / Aria

  Hi Sarah,

  Great to connect — David has said wonderful things about
  Clearpath. Thursday at 2pm PT works perfectly.

  I'll send a Zoom link. Looking forward to the conversation.

  Best,
  Maya

─────────────────────────────────────────────

DRAFT 4 — To: Kevin Cho
Subject: RE: Aria Engineering Lead — Next Steps

  Hi Kevin,

  Thanks again for coming in last week — the team really enjoyed
  meeting you and the systems design discussion was one of the
  strongest we've seen.

  We're finalizing our timeline this week and I'll have a
  definitive update for you by Thursday. Wanted to make sure
  you're not left waiting in the meantime.

  Talk soon,
  Maya

─────────────────────────────────────────────

DRAFT 5 — To: Marcus Webb (DataSync)
Subject: RE: Aria API Access — Pilot Integration

  Hi Marcus,

  Thanks for your patience on this. We'd be happy to set up API
  access for a pilot integration. I'll have our engineering lead
  Arun send you the sandbox credentials and rate limit details
  by end of week.

  Let's plan a quick sync once you're set up to align on the
  pilot scope and timeline.

  Best,
  Maya

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 RECOMMENDED ACTIONS — Priority Order
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  1. Read Tom Aldridge's MSA markup (5 min)
  2. Review + send Draft 2 to Danielle/Crestline (10 min)
  3. Create Q3 metrics doc, then review + send Draft 1 to Jason (20 min)
  4. Review + send Draft 3 to Sarah Lund (1 min)
  5. Review + send Draft 4 to Kevin Cho (1 min)
  6. Decide on Crestline pricing for Priya (5 min)
  7. Gather AWS docs, review + send to Nisha Bhat (15 min)
  8. Review + send Draft 5 to Marcus Webb (1 min)

  Estimated time to clear P0 + P1 queue: ~60 minutes
  Without Alice triage + drafting: ~2.5 hours estimated

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Maya:** ...holy shit. Okay. This is real. Give me 20 minutes.

*Maya reviews and sends drafts 1, 3, 4, and 5. She reads Tom's markup, fills in the Crestline placeholders, and sends draft 2. She messages Priya on Slack to hold firm at $180K. She bookmarks the AWS docs task for after lunch.*

> Alice: Five emails sent. Crestline and Meridian threads are now active again. I've updated ownership tracking:
>
> ```
> Thread status changes:
>   Jason Wu (Meridian)     →  Ball-With-Them (awaiting reply)
>   Danielle Reeves (Crestline) →  Ball-With-Them (awaiting legal response)
>   Sarah Lund (Clearpath)  →  Ball-With-Them (meeting confirmed Thu 2pm)
>   Kevin Cho               →  Ball-With-Them (update promised by Thu)
>   Marcus Webb (DataSync)  →  Ball-With-Them (API access in progress)
>   Priya Sharma            →  Resolved (pricing decision: hold at $180K)
> ```
>
> Remaining open: Nisha Bhat (AWS docs, due today) and Tom Aldridge (no separate reply needed — covered in Crestline thread).
>
> I'll watch all these threads and alert you when replies come in.

---

## 8. Calibration adjustment

Later that afternoon, Maya messages Alice.

---

**Maya:** Hey Alice — this morning was really good. But I want even more. Can you also watch my Zoom calendar and prep me for meetings? Like, before a call, tell me who the person is, what we last discussed, and what I should push for.

> Alice: Absolutely. I'm updating your operating contract:
>
> ```
> OPERATING CONTRACT UPDATE — October 15, 2024 3:47 PM
> ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
>
> Changed:
>   Proactivity: High → High + Meeting Prep
>
> New behavior:
>   - 15 minutes before each calendar event, I will post a meeting
>     prep brief to your Slack DM.
>   - The brief will include:
>       • Who is on the call (name, title, company, last interaction)
>       • What you discussed last time (from transcripts, email, Slack)
>       • Open commitments between you and them
>       • Recommended agenda items or asks
>       • Any relevant deal/project status from Notion
>   - After the meeting (if Granola transcript is available), I will
>     extract decisions, action items, and promises within 1 hour.
>
> Unchanged:
>   Autonomy: Draft + Internal Actions
>   Escalation: same policy
>   Brief cadence: 8 AM daily, EOD optional
>   Quiet hours: 10 PM – 8 AM, P0 bypass only
> ```
>
> Here's what this means in practice. You have a call with Oren Nachman at Tidepool on Thursday at 10am if he confirms. When he does, you'll get something like this 15 minutes before:
>
> ```
> 🎯 MEETING PREP — Oren Nachman, Tidepool
>
> Who: Oren Nachman, Partner at Tidepool Ventures
>       Focus: B2B SaaS, procurement/supply chain
>       Portfolio: PacketAI, Clervia, OrderStack
>
> Last contact: Email intro from David Chen (Oct 6).
>       You proposed 3 times. Oren hasn't confirmed yet.
>       This is a first meeting — no prior relationship.
>
> Context: Tidepool is your third investor target for Series A.
>       Meridian (Jason Wu) is warmest. Clearpath (Sarah Lund)
>       meeting is Thursday 2pm. Having 3 active conversations
>       strengthens your negotiating position.
>
> Recommended agenda:
>   • Aria overview + traction (keep to 10 min)
>   • Ask about Tidepool's typical check size and timeline
>   • Probe whether they'd co-invest or want to lead
>   • Mention Crestline deal (close is imminent — social proof)
>
> Open items: None (first meeting).
> ```
>
> That's the format. I'll refine it based on your feedback after the first few calls.

**Maya:** Perfect. Do that for every meeting.

---

## 9. Day 2 morning brief

Wednesday, October 16, 8:00 AM. Alice posts to #alice-briefings.

---

```
☀️ MORNING BRIEF — Wednesday, October 16
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Good morning Maya. Here's where things stand.

📬 OVERNIGHT INBOX CHANGES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Replies received (3):
    ✉️  Jason Wu (Meridian) — replied 11:47 PM
        "Thanks Maya. Numbers look strong. Let's do Thursday 3pm
        for a deep-dive. I'll have my partner Sam Reiter join."
        → Ball: with us. You need to confirm the time.
        → Draft ready: ✅ [confirmation + Zoom link]

    ✉️  Kevin Cho — replied 9:12 PM
        "Thanks for the update, Maya. I do have another process
        moving but Aria is my top choice. Thursday works."
        → Ball: with them (waiting for your Thursday update)
        → Note: he has competing offers. Decision urgency is real.

    ✉️  Marcus Webb (DataSync) — replied 7:30 AM
        "Great, looking forward to it. Arun can reach me at
        marcus@datasync.io."
        → Ball: with us. Need to loop in Arun.
        → Draft ready: ✅ [Slack message to Arun with context]

  New inbound (2):
    ✉️  Rachel Torres (TechCrunch) — press inquiry
        Asking if you'd comment on a procurement automation
        market overview piece. Deadline: Friday.
        Priority: P2 | Ball: with us
        → Draft ready: ✅ [short quote + company positioning]

    ✉️  Aria billing system — automated alert
        Monthly invoice batch completed. No action needed.
        Priority: P3 | Auto-triaged.

  No reply yet:
    ⏳ Danielle Reeves (Crestline) — MSA redlines sent yesterday
       Expected response time: 1-3 business days. Not stale yet.
    ⏳ Sarah Lund (Clearpath) — meeting confirmed Thu 2pm
       Nothing needed until then.
    ⏳ Nisha Bhat (AWS) — docs sent yesterday afternoon
       Tracking. Will flag if no confirmation by Friday.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📅 TODAY'S CALENDAR
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  09:00  Aria team standup (30 min) — #general
         💡 Recommend mentioning: Approvals v2 slip (Arun's update
         from Monday). Ask Raj for revised timeline.

  11:00  Product review with Raj (45 min) — Zoom
         📋 Meeting prep will be sent at 10:45 AM
         Key topic: Approvals v2 timeline and Crestline dependency

  14:00  Candidate sync — eng hiring (30 min) — internal
         💡 Kevin Cho has competing offers. Bring a decision
         framework or you'll lose another week.

  16:00  Free block — no meetings
         💡 Recommend using this to start the Q3 board deck.
         Due in 9 days. No draft exists yet.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚡ ACTIVE RISKS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  🔴 Board deck (due Oct 25) — 9 days, no draft
     No Notion task. No document started. This will become a
     fire drill next week if you don't start today.
     → Recommendation: Create a Notion task and block 2 hours
       Friday afternoon. I can draft an outline from Q2's deck
       if you share it.

  🟡 Approvals v2 slip — engineering says 1 week delay
     Notion still shows "On Track." Reality: blocked on auth
     refactor. Raj may not know this affects Crestline timeline.
     → Recommendation: Raise in today's product review with Raj.
       Connect the Crestline signing dependency explicitly.

  🟡 SOC 2 Compliance Prep — stale since Sep 29
     No owner. No updates in 16 days. If this is deprioritized
     intentionally, mark it as such. If not, it needs an owner.
     → Recommendation: Decide today — active or parked?

  🟢 Customer Onboarding Revamp — stale since Oct 1
     Owner: Priya. She's been focused on Crestline. Likely
     intentionally paused. Confirming with her today.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 DEAL PIPELINE STATUS (from #deals + Notion + email)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Crestline Logistics   $180K ACV   Legal Review     Ball: with them
  DataSync              $45K ACV    Pilot Setup      Ball: with us
  Meridian Capital      Series A    Deep-dive Thu    Ball: with us
  Clearpath Ventures    Series A    Intro Thu        Ball: confirmed
  Tidepool              Series A    Awaiting reply   Ball: with them

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ RECOMMENDED FIRST ACTIONS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  1. Confirm Thursday 3pm with Jason Wu (1 min — draft ready)
  2. Forward DataSync API request to Arun (1 min — draft ready)
  3. Raise Approvals v2 / Crestline link with Raj at 11am
  4. Decide on Kevin Cho by end of candidate sync at 2:30pm
  5. Block 2 hours Friday for board deck draft
  6. Decide: SOC 2 — active or parked?

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Cache freshness: Oct 16, 2024 07:58 AM
  Next brief: EOD summary if open items change
  Settings: Proactivity High + Meeting Prep | Autonomy: Draft + Internal
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## 10. Final workspace state

After Day 1 discovery and onboarding, Alice has populated three key files in Maya's workspace.

---

### USER.md

```markdown
# USER.md

## Founder
- Name: Maya Patel
- Role: Founder / CEO
- Company: Aria
- Industry: B2B SaaS — procurement automation for mid-market
- Team size: 12 (6 eng, 3 sales, 1 PM, 1 design, 1 CEO)
- Stage: Post-seed ($2.1M, 14 months ago), Series A prep
- Timezone: America/Los_Angeles
- Communication preferences: strategic, direct, no fluff; lead with the answer
- Preferred channel: Slack (#alice-briefings for daily, DM for urgent)
- Quiet hours: 10 PM – 8 AM, P0 bypass only

## What good help looks like
- Reduces cognitive load — don't add to the noise
- Surfaces decisions, not data dumps
- Follows through without needing reminders
- Notices what is drifting before she does
- Drafts things proactively — she wants Alice ahead of her, not behind
- Understands that fundraising, deals, and product are interconnected

## Hard boundaries — always escalate, never act alone
- Financial commitments (contracts, pricing, budget)
- Investor communications (Jason Wu, Sarah Lund, Oren Nachman, any VC)
- Crestline Logistics communications (Danielle Reeves, anyone @crestline)
- Personnel decisions (hiring, firing, performance, conflict)
- Legal matters (MSA, NDA, terms of service, compliance)
- Calendar changes (never reschedule or decline without asking)

## Working style notes
- Context-switches every 15 minutes — needs help staying on priority
- Tends to promise timelines in email then forget them
- Carries strategic context in her head that team doesn't have visibility into
- Struggles to write the "important but not urgent" messages
- Checks Slack first at 8 AM — that's the best time to reach her
```

---

### GOALS.md

```markdown
# GOALS.md

## 90-Day Priorities (October 15 – January 15)

### 1. Close Series A
- Target: Lead investor committed with term sheet by mid-January
- Key contacts:
  - Jason Wu, Meridian Capital (warmest — deep-dive scheduled Thu Oct 17)
  - Sarah Lund, Clearpath Ventures (intro meeting Thu Oct 17)
  - Oren Nachman, Tidepool (awaiting scheduling confirmation)
- Dependencies:
  - Clean data room (Q3 metrics doc, cap table, financial model)
  - Deck refresh (not started)
  - Q3 board deck due Oct 25
  - Crestline close before round = stronger negotiating position
- Risk: 7 months runway at current burn. Round must close or burn cuts needed.

### 2. Land Crestline Logistics ($180K ACV)
- Decision-maker: Danielle Reeves, VP of Procurement
- Current stage: Legal review — MSA redlines sent, awaiting response
- Sales lead: Priya Sharma
- Dependencies:
  - Approvals v2 module (Crestline specifically requested this feature)
  - Legal turnaround on MSA (Tom Aldridge, Panorama Legal)
  - Pricing decision: holding firm at $180K ACV (decided Oct 15)
- Risk: If Approvals v2 slips past November, Crestline may stall.

### 3. Ship Approvals v2 Module
- PM: Raj
- Eng lead: Arun
- Current status: Blocked — auth refactor dependency, 1-week slip
  (Notion shows "On Track" but Slack shows blocker since Oct 12)
- Scope: 4 approval workflows (locked Oct 3)
- Why it matters: Crestline requires this feature. Two other enterprise
  prospects mentioned it. Fundraising dependency via Crestline close.
- Risk: Raj doesn't know the fundraising connection. Maya needs to
  communicate urgency directly.

## Secondary Priorities
- Q3 board deck (due Oct 25)
- Kevin Cho engineering lead hire (competing offers, decision needed this week)
- SOC 2 Compliance Prep (stale — needs owner or intentional pause)
- Customer Onboarding Revamp (paused while Priya focuses on Crestline)
- DataSync pilot setup ($45K ACV opportunity)
- AWS SaaS Accelerator application (docs submitted Oct 15)

## Implicit Goal (surfaced by Alice)
- Improve information flow to team. Raj, Priya, and Arun are each missing
  context that would change their prioritization. The connection between
  Approvals v2, Crestline, and Series A is not visible to anyone but Maya.
```

---

### SOURCES_OF_TRUTH.md

```markdown
# SOURCES_OF_TRUTH.md

## Authority Map

| System | Authoritative For | Access |
|---|---|---|
| Notion Projects DB | Project status, milestones, ownership | ✅ API connected |
| Linear | Engineering task state, sprint progress | ⚠️ No API token yet |
| Gmail (maya@aria.so) | External commitments, promises, deadlines | ✅ OAuth connected |
| Slack #deals | Deal momentum signals (not authoritative) | ✅ Bot active |
| Slack #engineering | Build status signals (not authoritative) | ✅ Bot active |
| Slack #leadership | Strategic decisions, internal commitments | ✅ Bot active |
| Zoom / Granola | Meeting decisions, action items, promises | ⚠️ Granola not configured |
| Obsidian | Strategic thinking, personal notes | ✅ Vault scaffolded |
| Google Calendar | Schedule truth | ✅ Via Gmail integration |

## Reconciliation Rules

1. **Slack vs Notion conflict:** If Slack says something is done but Notion
   still shows "In Progress," flag as contradiction. Do not auto-resolve.

2. **Email commitment not in Notion:** If an email contains a promise or
   deadline not reflected in Notion, surface in daily brief and suggest
   creating a task.

3. **Linear vs Notion project:** If all Linear tickets under a Notion project
   are closed but the project is still open, flag for review. Otherwise note.

4. **Zoom/transcript promises:** Extract decisions, action items, and promises
   from meeting transcripts. Surface in next brief. Link to existing
   threads/tasks where possible.

5. **#deals vs Notion gap:** If #deals contains a deal status update (verbal
   close date, pricing discussion, contract status) not reflected in Notion
   Projects DB, surface in daily brief with recommendation to update the
   project record. Tag as "deal signal gap."

## Local Overrides

- Slack is never final truth for task state — it only triggers reconciliation.
- Calendar is read-only. Alice must never modify calendar entries without
  explicit approval.
- Crestline Logistics is on the immediate-escalation list. Any communication
  involving Crestline requires Maya's review before action.

## Pending Integrations

- Linear API token (Raj to provide)
- Granola transcript ingestion (manual drop to ~/.alice/workspace/inbox/)
```

---

## Timeline Summary

```
09:00  Maya runs alice-setup.sh                     (5 min)
09:05  Maya launches Claude Code with bootstrap prompt
09:07  Discovery conversation begins                (12 min)
09:19  Operating contract negotiation               (5 min)
09:24  Source-of-truth mapping                      (6 min)
09:30  Seeding process runs                         (3 min)
09:33  Backtest scorecard delivered                  (2 min review)
09:35  First email ownership brief delivered         (5 min review)
09:40  Maya reviews and sends 5 drafts              (20 min)
10:00  First magic moment complete                  (55 min total)

15:47  Calibration adjustment: meeting prep added    (2 min)

08:00  Day 2 morning brief delivered automatically
       Maya acts on 2 items before standup at 9am
```

---

## What Maya said after Day 1

"I've been meaning to hire a chief of staff for six months. I couldn't justify the salary for someone who'd need three months to ramp. Alice ramped in an hour and already caught things that would have cost me a deal."

---

## What compounded by Day 7

- Alice caught 2 more stale commitments that would have slipped
- Meeting prep briefs saved ~20 minutes/day of pre-call research
- The Q3 board deck was drafted on time (Alice created the outline, Maya edited)
- Crestline MSA was finalized — Danielle signed on October 22
- Jason Wu scheduled the partner meeting for the following week
- Kevin Cho accepted the offer after Maya made the decision on Day 2
- Alice's correction rate dropped from 30% (Day 1 drafts) to 12% (Day 7 drafts)
- Total estimated time saved in Week 1: 14 hours
