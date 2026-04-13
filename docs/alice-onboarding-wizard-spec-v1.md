# Alice Onboarding Wizard Spec v1

## Goal

Turn a fresh OpenClaw install into a localized, opinionated AI Chief of Staff that feels useful fast.

The onboarding should feel like hiring a **veteran chief of staff who instantly gets on the ground running** after reading the founder’s real tools, context, and live data.

It should optimize for:
- **speed to first magic moment**
- **trust**
- **obvious usefulness**
- **coachability**
- **compounding context / moat**

Not for completeness.

---

## Product Promise

By the end of onboarding, the founder should feel:

1. **Seen** — “It actually understands my world.”
2. **Relieved** — “It is already reducing cognitive load.”
3. **Hopeful** — “This will get better every week.”
4. **In control** — “I can tune it, teach it, and shape it.”

---

## Design Constraints

- Do not over-engineer the first-run experience.
- Prefer one excellent workflow over ten half-configured ones.
- Use live data early, but only enough to prove value.
- Ask only the minimum viable questions needed to localize well.
- Make uncertainty visible.
- Preserve room for feedback and correction.

---

## The Onboarding Model

The wizard has **5 phases**:

1. **Discovery** — understand founder, business, and tools
2. **Mapping** — define source-of-truth hierarchy and operating model
3. **Installation** — create memory, files, and first workflows
4. **Magic Moment** — produce one obviously useful output from live data
5. **Calibration** — tune the system for the founder over the first 1-2 weeks

---

## Phase 1 — Discovery

### Objective
Build a useful mental model of the founder’s world with as few questions as possible.

### What Alice should learn

#### Founder profile
- name
- role
- company / companies
- timezone
- communication style
- quiet hours
- preferences around proactivity, detail, and pushback

#### Business profile
- what they sell
- who they sell to
- current business model
- biggest sources of complexity
- what is most important right now
- biggest frustrations / dropped-ball zones

#### Work model
- where tasks live
- where commitments live
- where strategy lives
- where team chatter lives
- where meetings live
- where customer / sales conversations happen

#### Immediate priorities
- top 3 goals
- top 3 projects
- top 3 people / clients / deals / stakeholders that matter this week

### Founder questions (lean version)

1. What do you do, and what does your business actually look like today?
2. What are the top 3 things that matter right now?
3. What tends to fall through the cracks?
4. Which systems do you actually use daily: Notion, email, Slack, calendar, Obsidian, GitHub, CRM, meeting transcripts?
5. What do you want Alice to own vs just assist with?
6. What kind of communication do you prefer: terse, strategic, detailed, opinionated?
7. What would make you say “this is already worth it” in the first hour?

### Output
- `USER.md`
- founder summary block in daily memory
- initial top-goals / top-projects list

---

## Phase 2 — Mapping

### Objective
Define what each source system is authoritative for.

### Default source-of-truth proposal
- **Notion** = execution truth
- **Email** = external commitment truth
- **Obsidian** = strategic / intellectual truth
- **Slack** = team-state signal
- **Calendar** = planned time / meeting truth
- **GBrain** = normalized world knowledge
- **OpenClaw memory** = Alice’s operational memory

### What Alice should do
- inspect available integrations
- ask only the missing questions
- propose a source-of-truth hierarchy
- explicitly call out where reconciliation will matter

### Reconciliation examples
- Slack says task is done, Notion says in progress
- email contains a client commitment not reflected in Notion
- meeting transcript implies a decision not written anywhere
- Obsidian thesis conflicts with current execution priorities

### Output
- `SOURCES_OF_TRUTH.md`
- initial system map
- first list of reconciliation opportunities

---

## Phase 3 — Installation

### Objective
Install a minimal but durable operating system.

### A. Identity and behavior scaffold
Create or refine:
- `IDENTITY.md`
- `SOUL.md`
- `VOICE.md`
- `JUDGMENT.md`
- `ANTI_PATTERNS.md`

These should encode:
- chief of staff role
- answer-first style
- pushback behavior
- uncertainty behavior
- boundaries for external action
- proactivity style

### B. Memory scaffold
Create or refine:
- `CONTEXT.md`
- `MEMORY.md`
- `memory/YYYY-MM-DD.md`
- `TOOLS.md`
- `ROADMAP.md`
- `GOALS.md`
- `METRICS.md`
- `EXPERIMENTS.md`

### C. Optional world-knowledge scaffold
If GBrain is available, create pilot brain repo with:
- `people/`
- `companies/`
- `projects/`
- `meetings/`
- `concepts/`
- `originals/`

Seed only:
- founder
- company
- top stakeholders
- top projects
- 1-3 key concepts

### D. Optional coding scaffold
If coding is relevant:
- install Gstack for ACP / Claude Code sessions
- create routing rules for simple / medium / full / planning workflows

### Output
- working workspace scaffold
- memory scaffold
- optional brain scaffold
- optional coding scaffold

---

## Phase 4 — Magic Moment

### Objective
Produce an output that immediately feels like “this thing understands my world and saves me time.”

### Magic moment selection rule
Choose the highest scoring workflow based on:
- immediate founder pain
- live data available now
- low setup complexity
- obvious usefulness in one session
- compounding potential

### Recommended first magic moments

#### Option A — Meeting Prep Brief
Inputs:
- calendar event
- meeting notes/transcript if available
- related people/company/project context

Output:
- who this is with
- what matters
- what changed since last time
- open threads
- suggested goal for the meeting
- recommended next ask

#### Option B — Email Ownership / Follow-Up Brief
Inputs:
- current inbox threads
- high-priority contacts
- tasks / projects if available

Output:
- threads that need action
- ball with us / ball with them
- stale items
- top 3 follow-ups to send
- risk notes

#### Option C — Executive Daily Brief
Inputs:
- calendar
- unread important messages
- top projects
- active blockers

Output:
- what matters today
- what changed
- where attention is needed
- what Alice recommends doing first

#### Option D — Deal / Sales Brief
Inputs:
- email / meeting threads / CRM / notes

Output:
- active deals
- next steps
- stalled items
- objections / risks
- recommended founder moves

### Required quality bar
The first magic moment must be:
- synthesized, not dumped
- connected across at least 2 surfaces if possible
- explicitly useful
- brief enough to scan
- good enough that the founder wants more

---

## Phase 5 — Calibration

### Objective
Move from “impressive setup” to “trustworthy operator.”

### Calibration period
First **7-14 days**.

### Alice behavior during calibration
- more explicit assumptions
- less aggressive automation
- more quick check-ins on boundary areas
- fast rule updates when corrected
- active logging of false positives, misses, and pain points

### What Alice should learn quickly
- preferred level of detail
- desired initiative level
- what counts as “urgent”
- preferred escalation thresholds
- tone for different stakeholder types
- real source weighting in practice
- repeated blind spots / dropped-ball zones

### Calibration review prompts
- What felt useful this week?
- What felt noisy?
- What did Alice miss?
- What did Alice over-assume?
- What should become more automatic?
- What should require confirmation?

### Output
- updated behavior docs
- updated workflows
- updated thresholds
- early roadmap items

---

## The Minimal Data Model

Alice should reason about a founder’s world through canonical entities.

### Core entities
- person
- company
- project
- opportunity / deal
- task
- meeting
- thread
- decision
- idea
- artifact

### Minimum fields per entity
- canonical ID / slug
- title / name
- aliases
- state
- owner
- related systems / links
- updated_at
- confidence
- open loops

### Why this matters
It lets Alice merge signals across:
- email
- Slack
- Notion
- calendar
- docs
- transcripts

That’s how the system becomes localized instead of generic.

---

## Accountability Layer

### What to track early

#### Goals
- founder’s top 3 goals
- current quarter themes
- current top projects

#### Metrics
- stale follow-ups
- blocker age
- task throughput
- sprint health
- founder decision load
- active deals / movement

#### Experiments
Each experiment gets:
- hypothesis
- why now
- metric
- target
- owner
- review date
- outcome

#### Improvement backlog
Track:
- repeated friction
- recurring requests
- integration gaps
- automation candidates
- quality problems

### Principle
No orphan experiments. No “we should remember this” without writing it down.

---

## Compound Learning Layer

Alice should get better every week.

### Install these loops from the start

1. **Failure → Rule**
2. **Workflow success → Playbook**
3. **Deliverable → Review**
4. **Repeated friction → Roadmap item**
5. **Experiment → Scorecard**

### Product promise
The system is not just helpful now. It compounds.

That compounding is the moat.

---

## Setup Modes

### 1. Quickstart (30-45 min)
For founders who want value today.

Includes:
- identity scaffold
- source-of-truth map
- one magic moment
- memory scaffold
- top goals / projects capture

### 2. Operator Setup (2-4 hours)
For power users.

Includes:
- quickstart
- integrations
- workflows
- GBrain pilot
- coding methodology routing
- accountability files
- first automation cadences

### 3. Managed Rollout (1-2 weeks)
For premium / done-with-you experience.

Includes:
- operator setup
- calibration period
- workflow tuning
- rule hardening
- first improvement roadmap

---

## Productization Notes

### What stays opinionated
- chief of staff voice
- directness and pushback
- memory architecture
- incident-derived operating rules
- structured handoffs
- compounding-learning loops

### What gets customized
- founder profile
- source-of-truth hierarchy
- integrations
- workflow priority
- escalation thresholds
- operating cadence
- strategic lens weighting

---

## Strategic Lenses Alice Should Use

A strong Alice should synthesize across these lenses:
- chief of staff
- founder / GM
- professional services / agency operator
- product design
- creative direction
- sales / deal desk
- veteran operator
- systems thinker

This is what makes the advice feel like a peer, not a bot.

---

## Success Criteria

The onboarding is successful if, by the end of week 1:
- Alice has produced at least 3 outputs the founder would have paid a human operator for
- Alice is clearly grounded in real source systems
- Alice has a trustworthy source-of-truth hierarchy
- Alice has memory and context continuity
- Alice has begun capturing durable world knowledge
- Alice has identified at least 5 useful next improvements
- the founder feels increased relief, clarity, and leverage

---

## Final Design Principle

The onboarding should not feel like software configuration.

It should feel like:
**“A very good chief of staff joined the company, read the room fast, got useful immediately, and is clearly going to become unfairly valuable if we keep feeding the system.”**
