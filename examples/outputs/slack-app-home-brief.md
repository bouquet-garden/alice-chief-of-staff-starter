# Slack App Home — Today's Operating Brief

**Surface:** Slack App Home tab
**Persona:** Maya Patel (Aria)
**Generated:** Monday, April 13, 2026 at 08:15 PT

---

## What Maya sees when she opens the Alice app in Slack

The App Home tab is the primary morning dashboard. Alice updates it every
30 minutes while Maya's workspace is active, and on-demand when a P0 event
fires.

---

## Rendered preview

```
┌─────────────────────────────────────────────────────────────────┐
│  Alice · Chief of Staff                            Mon Apr 13   │
│─────────────────────────────────────────────────────────────────│
│                                                                 │
│  TODAY'S OPERATING BRIEF                                        │
│  Last refreshed: 08:15 PT                                       │
│                                                                 │
│  ───────────────────────────────────────────────────────────── │
│  🔴  P0 — Requires same-day action                              │
│  ───────────────────────────────────────────────────────────── │
│                                                                 │
│  1. Northfield Capital renewal — pricing deck overdue           │
│     Ball with us · 23 days stale · $180K/yr at risk             │
│     Draft ready: [Review & Send]  [Edit]  [Snooze 4h]          │
│                                                                 │
│  2. Auth flow Jira tickets — never created                      │
│     @dev-priya committed Mar 28 · no follow-up detected         │
│     [Nudge Priya]  [Reassign]  [Mark resolved]                  │
│                                                                 │
│  ───────────────────────────────────────────────────────────── │
│  🟡  P1 — Requires response within 24h                          │
│  ───────────────────────────────────────────────────────────── │
│                                                                 │
│  3. Meridian Capital — Series A diligence docs request          │
│     Jason Wu asked for data room access Apr 11 · ball with us   │
│     [Share data room link]  [Draft reply]                        │
│                                                                 │
│  4. PrizePicks pilot — Slack says "done," Notion says           │
│     "in progress"                                               │
│     Reconciliation needed before standup                        │
│     [Update Notion]  [Ask in #aria-eng]                          │
│                                                                 │
│  5. Candidate Lena Park — offer letter review pending           │
│     Hiring committee approved Fri · 48h since approval          │
│     [Review draft offer]  [Delegate to ops]                      │
│                                                                 │
│  ───────────────────────────────────────────────────────────── │
│  📅  Calendar snapshot                                           │
│  ───────────────────────────────────────────────────────────── │
│                                                                 │
│  09:00  Aria eng standup (30m) — #aria-eng                      │
│  10:30  Meridian Capital check-in (30m) — Jason Wu, Lisa Tran   │
│         ⚡ Prep brief ready: [View meeting prep]                 │
│  14:00  PrizePicks pilot review (45m) — Derek Cole              │
│  16:00  1:1 with Priya (30m) — recurring                        │
│                                                                 │
│  ───────────────────────────────────────────────────────────── │
│  💰  Deal pipeline                                               │
│  ───────────────────────────────────────────────────────────── │
│                                                                 │
│  Meridian Capital    Series A lead    Diligence   $2.5M   70%   │
│  Northfield Capital  Pilot renewal    Negotiation $180K   45%   │
│  Beacon Ventures     Seed follow-on   Intro       $500K   25%   │
│                                                                 │
│  ───────────────────────────────────────────────────────────── │
│  ⚡  Action queue (recommended order)                            │
│  ───────────────────────────────────────────────────────────── │
│                                                                 │
│  1. Send Northfield pricing deck (draft ready)                  │
│  2. Share data room link with Jason Wu                          │
│  3. Reconcile PrizePicks status before 09:00 standup            │
│  4. Review Lena Park offer letter                               │
│  5. Nudge Priya on auth flow tickets before 16:00 1:1           │
│                                                                 │
│  ───────────────────────────────────────────────────────────── │
│  📊  Overnight changes                                           │
│  ───────────────────────────────────────────────────────────── │
│                                                                 │
│  • 3 new emails (1 P1, 2 P2)                                   │
│  • 1 thread moved from "ball with them" → "ball with us"        │
│  • 1 Notion status contradiction detected                       │
│  • 0 urgent Slack mentions                                      │
│                                                                 │
│  Last full sync: 08:12 PT · Next refresh: 08:45 PT             │
└─────────────────────────────────────────────────────────────────┘
```

---

## Block Kit JSON payload

This is the actual JSON Alice would POST to `views.publish` to render the
App Home tab above.

```json
{
  "user_id": "U04MAYA_PATEL",
  "view": {
    "type": "home",
    "blocks": [
      {
        "type": "header",
        "text": {
          "type": "plain_text",
          "text": "Today's Operating Brief",
          "emoji": true
        }
      },
      {
        "type": "context",
        "elements": [
          {
            "type": "mrkdwn",
            "text": "Last refreshed: *08:15 PT* · Monday, April 13, 2026"
          }
        ]
      },
      {
        "type": "divider"
      },
      {
        "type": "section",
        "text": {
          "type": "mrkdwn",
          "text": ":red_circle: *P0 — Requires same-day action*"
        }
      },
      {
        "type": "section",
        "text": {
          "type": "mrkdwn",
          "text": "*1. Northfield Capital renewal — pricing deck overdue*\nBall with us · 23 days stale · $180K/yr at risk\nDraft ready for review."
        },
        "accessory": {
          "type": "overflow",
          "options": [
            {
              "text": { "type": "plain_text", "text": "Review & Send" },
              "value": "action_send_northfield_draft"
            },
            {
              "text": { "type": "plain_text", "text": "Edit draft" },
              "value": "action_edit_northfield_draft"
            },
            {
              "text": { "type": "plain_text", "text": "Snooze 4h" },
              "value": "action_snooze_northfield_4h"
            }
          ],
          "action_id": "p0_northfield_overflow"
        }
      },
      {
        "type": "actions",
        "elements": [
          {
            "type": "button",
            "text": { "type": "plain_text", "text": "Review & Send", "emoji": true },
            "style": "primary",
            "action_id": "send_northfield_draft",
            "value": "thread-northfield-renewal-2026-04"
          },
          {
            "type": "button",
            "text": { "type": "plain_text", "text": "Edit" },
            "action_id": "edit_northfield_draft",
            "value": "thread-northfield-renewal-2026-04"
          }
        ]
      },
      {
        "type": "section",
        "text": {
          "type": "mrkdwn",
          "text": "*2. Auth flow Jira tickets — never created*\n@dev-priya committed Mar 28 · no follow-up detected · 16 days stale"
        }
      },
      {
        "type": "actions",
        "elements": [
          {
            "type": "button",
            "text": { "type": "plain_text", "text": "Nudge Priya", "emoji": true },
            "style": "primary",
            "action_id": "nudge_priya_auth",
            "value": "person-priya-dev"
          },
          {
            "type": "button",
            "text": { "type": "plain_text", "text": "Reassign" },
            "action_id": "reassign_auth_tickets",
            "value": "project-auth-flow-migration"
          }
        ]
      },
      {
        "type": "divider"
      },
      {
        "type": "section",
        "text": {
          "type": "mrkdwn",
          "text": ":large_yellow_circle: *P1 — Requires response within 24h*"
        }
      },
      {
        "type": "section",
        "text": {
          "type": "mrkdwn",
          "text": "*3. Meridian Capital — diligence docs request*\nJason Wu asked for data room access Apr 11 · ball with us"
        }
      },
      {
        "type": "actions",
        "elements": [
          {
            "type": "button",
            "text": { "type": "plain_text", "text": "Share data room link", "emoji": true },
            "style": "primary",
            "action_id": "share_dataroom_meridian",
            "value": "company-meridian-capital"
          },
          {
            "type": "button",
            "text": { "type": "plain_text", "text": "Draft reply" },
            "action_id": "draft_reply_meridian",
            "value": "thread-meridian-diligence-2026-04"
          }
        ]
      },
      {
        "type": "section",
        "text": {
          "type": "mrkdwn",
          "text": "*4. PrizePicks pilot — status contradiction*\nSlack says \"done\" · Notion says \"in progress\" · reconciliation needed before standup"
        }
      },
      {
        "type": "actions",
        "elements": [
          {
            "type": "button",
            "text": { "type": "plain_text", "text": "Update Notion", "emoji": true },
            "action_id": "reconcile_prizepicks_notion",
            "value": "project-prizepicks-pilot"
          },
          {
            "type": "button",
            "text": { "type": "plain_text", "text": "Ask in #aria-eng" },
            "action_id": "ask_eng_prizepicks",
            "value": "project-prizepicks-pilot"
          }
        ]
      },
      {
        "type": "section",
        "text": {
          "type": "mrkdwn",
          "text": "*5. Candidate Lena Park — offer letter review*\nHiring committee approved Fri · 48h since approval"
        }
      },
      {
        "type": "actions",
        "elements": [
          {
            "type": "button",
            "text": { "type": "plain_text", "text": "Review draft offer", "emoji": true },
            "action_id": "review_offer_lena",
            "value": "person-lena-park"
          }
        ]
      },
      {
        "type": "divider"
      },
      {
        "type": "section",
        "text": {
          "type": "mrkdwn",
          "text": ":calendar: *Calendar snapshot*"
        }
      },
      {
        "type": "section",
        "text": {
          "type": "mrkdwn",
          "text": "• `09:00` Aria eng standup (30m)\n• `10:30` Meridian Capital check-in (30m) — Jason Wu, Lisa Tran :zap: *Prep brief ready*\n• `14:00` PrizePicks pilot review (45m) — Derek Cole\n• `16:00` 1:1 with Priya (30m)"
        }
      },
      {
        "type": "divider"
      },
      {
        "type": "section",
        "text": {
          "type": "mrkdwn",
          "text": ":moneybag: *Deal pipeline*"
        }
      },
      {
        "type": "section",
        "fields": [
          { "type": "mrkdwn", "text": "*Meridian Capital*\nSeries A lead · Diligence\n$2.5M · 70%" },
          { "type": "mrkdwn", "text": "*Northfield Capital*\nPilot renewal · Negotiation\n$180K/yr · 45%" },
          { "type": "mrkdwn", "text": "*Beacon Ventures*\nSeed follow-on · Intro\n$500K · 25%" }
        ]
      },
      {
        "type": "divider"
      },
      {
        "type": "section",
        "text": {
          "type": "mrkdwn",
          "text": ":zap: *Action queue — recommended order*\n1. Send Northfield pricing deck (draft ready)\n2. Share data room link with Jason Wu\n3. Reconcile PrizePicks status before 09:00 standup\n4. Review Lena Park offer letter\n5. Nudge Priya on auth flow tickets before 16:00 1:1"
        }
      },
      {
        "type": "divider"
      },
      {
        "type": "context",
        "elements": [
          {
            "type": "mrkdwn",
            "text": ":bar_chart: *Overnight:* 3 new emails (1 P1, 2 P2) · 1 thread flipped to ball-with-us · 1 Notion contradiction detected · 0 urgent Slack mentions"
          }
        ]
      },
      {
        "type": "context",
        "elements": [
          {
            "type": "mrkdwn",
            "text": "Last full sync: 08:12 PT · Next refresh: 08:45 PT"
          }
        ]
      }
    ]
  }
}
```

---

## How this works

1. **Data sources:** Alice reads from Gmail labels, Slack signals, Notion
   databases, calendar events, and the world-state cache to build the brief.
2. **Refresh cadence:** The App Home refreshes every 30 minutes via
   `views.publish`. P0 events trigger an immediate refresh.
3. **Action buttons:** Each button maps to an `action_id` that Alice's Slack
   event handler processes. "Review & Send" opens the draft in a modal;
   "Nudge" sends a DM to the relevant person; "Update Notion" writes
   directly to the linked database.
4. **Priority ordering:** P0 items always appear first. Within a priority
   tier, items are sorted by staleness (oldest first).
