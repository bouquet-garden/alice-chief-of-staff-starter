# Telegram Daily Brief — Morning Message

**Surface:** Telegram supergroup, "Daily Briefings" topic
**Persona:** Maya Patel (Aria)
**Generated:** Monday, April 13, 2026 at 08:30 PT

---

## What Maya sees on her phone

Alice posts to the "Daily Briefings" topic in Maya's private Telegram
supergroup every morning at 08:30 PT. The message is formatted in
Telegram's MarkdownV2 for clean rendering on mobile.

---

## Rendered message (as it appears in Telegram)

```
Alice · Daily Brief
Monday, April 13, 2026 · 08:30 PT

━━━━━━━━━━━━━━━━━━━━━━

🔴 P0 — Same-day action

1. Northfield Capital pricing deck
   Overdue 23 days · $180K renewal at risk
   Draft ready — reply 1 to review & send

2. Auth flow Jira tickets
   @priya committed Mar 28 · never created
   Reply 2 to send nudge DM

━━━━━━━━━━━━━━━━━━━━━━

🟡 P1 — Within 24h

3. Meridian Capital data room access
   Jason Wu asked Apr 11 · ball with us
   Reply 3 to share link

4. PrizePicks status contradiction
   Slack: "done" vs Notion: "in progress"
   Reply 4 to reconcile

5. Lena Park offer letter
   Hiring committee approved Fri · 48h ago
   Reply 5 to review draft

━━━━━━━━━━━━━━━━━━━━━━

📅 Today's calendar

09:00  Eng standup (30m)
10:30  Meridian check-in (30m) ⚡
14:00  PrizePicks review (45m)
16:00  1:1 with Priya (30m)

━━━━━━━━━━━━━━━━━━━━━━

⚡ Start here

Send the Northfield pricing deck. Draft is
ready — it's your oldest open P0 and the
renewal deadline is May 1.

━━━━━━━━━━━━━━━━━━━━━━

Reply 1-5 for details · Reply 6 for full inbox
```

---

## Raw MarkdownV2 (what Alice sends via Telegram Bot API)

```
*Alice \· Daily Brief*
_Monday, April 13, 2026 \· 08:30 PT_

━━━━━━━━━━━━━━━━━━━━━━

🔴 *P0 — Same\-day action*

*1\.* Northfield Capital pricing deck
Overdue 23 days \· $180K renewal at risk
Draft ready — reply `1` to review \& send

*2\.* Auth flow Jira tickets
@priya committed Mar 28 \· never created
Reply `2` to send nudge DM

━━━━━━━━━━━━━━━━━━━━━━

🟡 *P1 — Within 24h*

*3\.* Meridian Capital data room access
Jason Wu asked Apr 11 \· ball with us
Reply `3` to share link

*4\.* PrizePicks status contradiction
Slack: "done" vs Notion: "in progress"
Reply `4` to reconcile

*5\.* Lena Park offer letter
Hiring committee approved Fri \· 48h ago
Reply `5` to review draft

━━━━━━━━━━━━━━━━━━━━━━

📅 *Today's calendar*

`09:00`  Eng standup \(30m\)
`10:30`  Meridian check\-in \(30m\) ⚡
`14:00`  PrizePicks review \(45m\)
`16:00`  1:1 with Priya \(30m\)

━━━━━━━━━━━━━━━━━━━━━━

⚡ *Start here*

Send the Northfield pricing deck\. Draft is ready — it's your oldest open P0 and the renewal deadline is May 1\.

━━━━━━━━━━━━━━━━━━━━━━

_Reply 1\-5 for details \· Reply 6 for full inbox_
```

---

## Bot API call

```json
{
  "method": "sendMessage",
  "chat_id": "-1001234567890",
  "message_thread_id": 42,
  "parse_mode": "MarkdownV2",
  "text": "<the MarkdownV2 string above>",
  "reply_markup": {
    "inline_keyboard": [
      [
        { "text": "1 — Northfield", "callback_data": "brief_detail_1" },
        { "text": "2 — Auth tickets", "callback_data": "brief_detail_2" }
      ],
      [
        { "text": "3 — Meridian", "callback_data": "brief_detail_3" },
        { "text": "4 — PrizePicks", "callback_data": "brief_detail_4" }
      ],
      [
        { "text": "5 — Lena Park", "callback_data": "brief_detail_5" },
        { "text": "6 — Full inbox", "callback_data": "brief_full_inbox" }
      ]
    ]
  }
}
```

---

## Interaction flow

1. Maya sees the brief on her phone at 08:30.
2. She taps the "1 -- Northfield" button (or replies with `1`).
3. Alice responds with the full Northfield context: thread history,
   the draft email, and approve/edit/skip options.
4. Maya taps "Send" -- Alice sends the email and updates the thread
   status to "resolved" in the world-state cache.
5. The daily brief message is not edited in place; Alice posts a
   follow-up confirmation message in the same topic thread.
