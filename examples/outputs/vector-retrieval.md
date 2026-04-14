# Vector Retrieval — Semantic Search with Citations

**Surface:** Response to natural-language query (Slack `/alice-search`, Telegram, or CLI)
**Persona:** Maya Patel (Aria)
**Generated:** Monday, April 13, 2026 at 10:15 PT

---

## Query

> "What did we agree with Meridian about valuation?"

---

## Top 3 results

### Result 1 — Call transcript, April 8

| Field | Value |
|-------|-------|
| **Relevance score** | 0.91 |
| **Source** | Call transcript |
| **Source ID** | `cache/transcripts/2026-04-08-meridian-intro.md` |
| **Date** | April 8, 2026 |
| **Participants** | Maya Patel, Jason Wu, Lisa Tran |

**Excerpt:**

> **Jason:** So where are you on valuation? Have you landed on a number?
>
> **Maya:** We're still calibrating. We've seen comps in the 8-12x ARR
> range for companies at our stage and growth rate, but I'd rather let
> the diligence conversations this month inform where we land rather than
> anchor prematurely.
>
> **Jason:** That's fair. We typically see 10-12x for Series A companies
> with your retention profile. We'll have a better view once Lisa runs
> the model.
>
> **Maya:** Works for me. Let's revisit once you've had a chance to dig
> into the numbers.

**Alice's annotation:** No specific valuation was agreed upon. Maya
deliberately avoided anchoring. Jason signaled a 10-12x ARR range as
Meridian's typical benchmark. Both parties agreed to revisit after
diligence. This is the most relevant source.

---

### Result 2 — Email thread, April 3

| Field | Value |
|-------|-------|
| **Relevance score** | 0.79 |
| **Source** | Email |
| **Source ID** | `thread-meridian-interest-2026-04` |
| **Date** | April 3, 2026 |
| **Participants** | Maya Patel, Jason Wu |

**Excerpt:**

> **Jason (email):** "...we're typically writing $2-3M checks for Series A
> leads. What size round are you targeting?"
>
> **Maya (reply):** "We're targeting $2.5M, which would give us 18 months
> of runway at current burn. Happy to discuss valuation mechanics on
> our call Thursday."

**Alice's annotation:** Round size discussed ($2.5M target) but no
valuation figure mentioned. Maya deferred valuation discussion to the
April 8 call. This email establishes the round size context that frames
valuation expectations.

---

### Result 3 — Slack message, April 9

| Field | Value |
|-------|-------|
| **Relevance score** | 0.74 |
| **Source** | Slack |
| **Source ID** | `slack-aria-leadership-20260409-1430` |
| **Date** | April 9, 2026 |
| **Channel** | #aria-leadership |
| **Author** | Maya Patel |

**Excerpt:**

> "Meridian call went well. Jason mentioned 10-12x ARR is their typical
> range. At our current $1.35M ARR that puts us at $13.5-16.2M pre-money.
> I think we can push for the high end given our NRR numbers. Sam — let's
> discuss positioning before the next call."

**Alice's annotation:** Maya's internal interpretation of the valuation
signal from the April 8 call. She's targeting the high end of Jason's
stated range ($16.2M pre-money). This is internal strategy, not an
agreement with Meridian.

---

## Synthesized answer

**No specific valuation has been agreed with Meridian.** Here is what has
been established:

1. **Meridian's benchmark:** Jason Wu stated that 10-12x ARR is typical
   for Series A companies with Aria's retention profile (April 8 call,
   confidence: 0.91).

2. **Aria's current ARR:** $1.35M, which at 10-12x implies a pre-money
   valuation range of $13.5M--$16.2M (Maya's internal calculation, April 9
   Slack, confidence: 0.74).

3. **Maya's strategy:** She is targeting the high end of the range and
   plans to discuss positioning with Sam before the next Meridian call
   (April 9 Slack, confidence: 0.74).

4. **Round size:** $2.5M target, which at a $16.2M pre-money valuation
   would mean ~13.4% dilution (derived from email, April 3, confidence:
   0.79).

5. **Next step:** Valuation will be revisited after Lisa Tran runs her
   financial model. No timeline was set for this, but the next Meridian
   check-in is today at 10:30 PT.

**Provenance chain:** transcript (primary) > email (supporting) > Slack
(internal context). No Notion or CRM records reference valuation for this
deal.

---

## Related entities surfaced

| Entity | Type | Relevance |
|--------|------|-----------|
| `person-jason-wu` | Person | Primary counterparty; stated valuation benchmark |
| `person-lisa-tran` | Person | Running financial model that will inform Meridian's offer |
| `company-meridian-capital` | Company | Investor entity with full interaction history |
| `opportunity-series-a-meridian` | Opportunity | Deal record: $2.5M target, diligence stage, 70% probability |
| `person-sam-torres` | Person | Co-founder; Maya wants to align on positioning before next call |

---

## How vector retrieval works

1. **Query embedding:** Alice converts the natural-language query into a
   vector embedding using the same model that indexed all source documents.

2. **Semantic search:** The query vector is compared against all indexed
   chunks (email paragraphs, transcript segments, Slack messages, Notion
   blocks) using cosine similarity. Alice retrieves the top-k results
   above a relevance threshold (default: 0.70).

3. **Source citation:** Each result includes the exact source document,
   timestamp, and participants. Alice never synthesizes an answer without
   showing which sources contributed to it.

4. **Synthesis:** Alice reads the top results in context and generates a
   narrative answer that distinguishes between what was explicitly stated,
   what was implied, and what is Alice's inference. Confidence scores
   reflect this distinction.

5. **Entity linking:** Alice cross-references the results against the
   world-state cache to surface related entities that may provide
   additional context. This helps Maya see the full picture without
   running additional queries.
