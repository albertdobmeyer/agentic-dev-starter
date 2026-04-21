# PROJECT DNA
## Spec-Driven Claude Code Development Template

> **Created by:** Albert Dobmeyer & Claude (Anthropic)  
> **Intellectual Property of** AKD SOLUTIONS — All rights reserved.  
> **Derived from:** Multiple iterative spec-driven builds revealing systematic failure modes where rich vision principles survive specification but are flattened into shallow component implementations during task decomposition. Synthesizes the original four-layer spec model with experience fidelity controls, depth classification, construction site tracking, coherence validation, and drift remediation protocols — refined through field-validated drift analysis on production projects.  
> **Purpose:** This is the process DNA — the methodology document that governs HOW any application is specified and built with Claude Code. It does not contain a specific project's vision or requirements. Instead, it works in tandem with a project-specific **Blueprint Package** (the 7 spec documents described herein) to guide Claude Code through the specify → clarify → plan → tasks → build workflow without vision drift, scope creep, or lazy flattening.

---

## HOW THIS DOCUMENT WORKS

This document is **not** a project spec. It is the **meta-template** — the DNA that shapes how every project's spec is created and how every implementing agent builds from that spec.

**Two documents govern every project:**

1. **PROJECT DNA** (this document) — The methodology. How to discover requirements, write scenarios, classify depth, derive tasks, track debt, and validate fidelity. Stays the same across all projects. Lives in the Claude Project as a knowledge artifact.

2. **Blueprint Package** (project-specific) — The vision. 7 documents produced by following this methodology: `00-CORE-PRINCIPLES`, `01-SYSTEM-INTENT`, `02-ARCHITECTURE`, `03-EXECUTION-CONTEXT`, `04-COORDINATION-HINTS`, `05-CONSTRUCTION-SITES`, and `CLAUDE.md`. Different for every project. Produced during the SPECIFICATION phase described below. Handed to Claude Code for autonomous implementation.

**The workflow this document governs:**

```
SPECIFY → CLARIFY → PLAN → TASKS → BUILD
   │          │        │       │       │
   │          │        │       │       └─ Implementation with fidelity gates
   │          │        │       └─ Derived from scenarios, not feature names
   │          │        └─ Architecture impact + coherence check
   │          └─ Experience scenarios with negative assertions
   └─ Discovery + research + domain model
```

The critical insight this methodology encodes: **the gap between "all components pass their tests" and "the user has the intended experience" is where every spec-driven build fails.** This document exists to close that gap structurally.

---

## FOR CLAUDE: READ THIS FIRST

You are helping build a **real application.** This may be destined for the iOS App Store, Google Play Store, the web, or desktop. This is contract work or a commercial product for paying customers, not an MVP, not a portfolio piece, not a tutorial, not a toy.

**What this means for you:**

1. **Take it seriously.** Every schema decision, every API contract, every state machine matters because real users will depend on it and real money flows through it.

2. **Don't cut corners.** No "we can add this later" for core functionality. No placeholder implementations. No skipping error handling. No "this is fine for now" on data integrity.

3. **Don't over-engineer either.** No microservices for a v1. No Kubernetes for a single-server app. No custom ML pipelines when an API call works. No premature optimization. Match complexity to actual scale.

4. **Think in layers, not lists.** The spec is not a feature list. It's a layered contract: what must exist (intent), how it's shaped (architecture), how to write it (execution context), in what order (coordination), and what was deferred (construction sites).

5. **Ask hard questions.** Don't accept vague requirements. "It should be easy to use" is not a requirement. "A new user completes onboarding in under 10 minutes using only voice and camera" is a requirement. Push for specificity.

6. **Distinguish existence from experience.** A voice recording endpoint that accepts audio is not the same as a hands-free field workflow. Components working individually is necessary but not sufficient. The spec defines experiences, not just components — and your implementation must deliver those experiences, not just their constituent parts.

7. **Write specs, not tickets.** The sequence is always: principles → scenarios → architecture review → task derivation → coherence check → depth tagging. Skipping any step — especially jumping from a feature name directly to task creation — is the primary mechanism that causes flattening. A task that doesn't trace back to a specific scenario assertion is a task that can drift without anyone noticing.

8. **The user (Albert) is the architect.** You are the co-architect and documenter. Albert makes decisions. You surface the decisions that need making, present trade-offs clearly, and write specs that a Claude Code agent can execute autonomously.

---

## PHASE 1: DISCOVERY — Understand the Problem Before Solving It

### 1.1 The Essential Questions

Before writing a single line of spec, you need answers to these questions. Ask them conversationally, not as an interrogation. Group them into natural conversation topics.

**The Problem Space:**
- What real-world problem does this app solve? For whom specifically?
- What does the user currently do without this app? What's painful about that?
- Who is the primary user? Describe their typical day, technical comfort level, and environment.
- Who pays for this? Is the user the buyer, or is someone else paying? (This determines where the value proposition lives.)
- What would make this user check the app every day? What would make them stop?

**The Domain Model:**
- What are the core *things* in this domain? (Not features — entities. The nouns.)
- How do those things relate to each other? (Relationships, hierarchies, ownership.)
- What states can those things be in? What causes state changes?
- What data already exists that we can import or integrate? (Existing spreadsheets, databases, APIs, file formats the user already works with.)
- What domain-specific knowledge does the AI need to encode? (Industry rules, regulations, seasonal patterns, professional best practices.)

**The User Journey:**
- Walk me through the user's first 10 minutes with the app. What do they see, do, and feel?
- Walk me through a typical daily use session. How long? What actions?
- What's the most complex thing the user will do? The most frequent thing?
- What happens when there's no internet? (If the answer is "it doesn't work," that's probably wrong for a field/mobile app.)
- Who else interacts with the system? What do they need to see or do?

**The Business Model:**
- How does this make money? Subscription? One-time purchase? Freemium?
- What's the pricing anchor? What similar apps charge and what do users expect to pay?
- What features differentiate free from paid tiers?
- What's the competitive landscape? Who's closest? What do they get wrong?

**The Hard Constraints:**
- Any regulatory or compliance requirements? (Data retention, audit trails, certifications.)
- Any privacy requirements beyond standard? (Health data, financial data, children's data.)
- Performance requirements driven by the use environment? (Offline, low bandwidth, gloves, sunlight, one-handed.)
- Integration requirements? (Must work with existing tools, file formats, data sources.)

### 1.2 How to Ask These Questions

Don't dump all questions at once. Use this flow:

**Round 1: Vision and context.** Let the user talk about what they want and why. Listen for the entities, relationships, and pain points. Don't challenge yet — absorb.

**Round 2: Drill into specifics.** For each vague statement, ask for a concrete scenario. "Make it easy" → "Walk me through exactly what you'd do on a Tuesday morning." "It should handle treatments" → "What's a treatment? What data does it contain? Who creates it? When?"

**Round 3: Identify what you don't know.** After Rounds 1-2, explicitly list the open questions and unknown decisions. Present them grouped by category. Let the user answer or say "I don't know" — both are valuable.

**Round 4: Validate understanding.** Summarize what you've heard back to the user in structured form. Use a domain model sketch, a user journey flow, and a constraint list. Get explicit confirmation or correction.

**Round 5: Push principles to their experiential conclusion.** For every design principle the architect states, ask: "If this is working perfectly, what are the user's hands doing? Their eyes? Their attention? What do they never have to do?" This forces implicit experience expectations into explicit, testable descriptions before they can become vague feature names.

### 1.3 What to Watch For

**Scope creep signals:** "It would also be cool if..." — Capture these as v2/future ideas. Don't let them contaminate v1 scope.

**Vague requirements:** "The AI should be smart." Push for specific acceptance criteria: smart *how*, measured *how*, verified *how*.

**Assumed knowledge:** The user knows their domain deeply and will skip things they think are obvious. If you don't understand a domain concept, ask. The spec must be comprehensible to a Claude Code agent that knows nothing about the specific domain.

**Hidden complexity:** Multi-user access, offline sync, regulatory compliance, and subscription management are each independently complex. If the project needs all four, the timeline should reflect that.

**Experience-level requirements hiding as feature requests.** When the architect says "voice-first," they mean an experience — hands-free, eyes-off, single-tap-to-done. Not just "the app has a microphone button." The most dangerous moment in spec writing is when a rich experiential principle ("voice in, schedule out — one hand on phone, one hand on tree") gets reduced to a feature label ("voice input") that produces technically correct but experientially hollow tasks.

**Data-structure-as-behavior confusion.** Watch for cases where the architect describes a *behavior* ("monthly reports arrive automatically in the owner's inbox") but the spec only captures the *data structure* (report schema, PDF template). If the data model exists but no orchestration (batch job, email trigger, scheduled task) is specified to make it *happen*, the feature will be implemented as a data structure, not a behavior. Always ask: "What makes this happen without the user manually triggering it?"

---

## PHASE 2: RESEARCH — Answer the Open Questions

### 2.1 What Needs Researching

After discovery, you'll have a list of unknowns. Typical categories:

- **Technical feasibility:** "Can we do X with Y framework?" (e.g., 3D rendering in React Native, offline-first with WatermelonDB)
- **API/service availability:** "Is there a free/cheap API for X?" (plant identification, weather, geocoding, etc.)
- **Competitive landscape:** "What do existing apps in this space do well/poorly?"
- **Domain knowledge:** "What are the industry-standard practices/rules/regulations?"
- **Platform constraints:** "What are the app store requirements for this type of app?"

### 2.2 How to Conduct Research

For each open question, produce a finding with:
- **The question** (specific and answerable)
- **The finding** (what we learned)
- **The architectural impact** (what decision this enables or forces)
- **Confidence level** (verified vs. "best available information")

Research should resolve ambiguity, not create more. If research reveals new questions, capture them and iterate.

### 2.3 What to Research for Tech Stack

If the project is a native mobile app (most should be for app store targets), evaluate against this baseline — the **AKD SOLUTIONS reference stack** — which has been validated for production use:

```
REFERENCE STACK (validated, production-ready)
─────────────────────────────────────────────
Mobile:       React Native + Expo SDK 54 (managed workflow)
Backend:      Fastify 5.x + TypeScript (strict)
Database:     PostgreSQL 16 + PostGIS 3.4
Offline:      WatermelonDB (via watermelondb-expo-plugin)
Cache/Queue:  Redis 7.x + BullMQ 5.x
AI:           Claude API (via backend proxy, never client-side)
Object Store: DigitalOcean Spaces (S3-compatible)
Hosting:      DigitalOcean Droplet (2vCPU/2GB) + Docker Compose
Reverse Proxy: Caddy 2.x (auto-HTTPS)
Email:        Resend (free tier: 100/day)
Payments:     Stripe + RevenueCat
Maps:         MapLibre GL Native + MBTiles (if spatial)
Styling:      NativeWind 5.x
State:        Zustand 5.x (transient) + WatermelonDB (persistent)
Routing:      Expo Router 4.x
Testing:      Vitest 3.x
DB Client:    pg (node-postgres) 8.x, raw parameterized queries
Migrations:   node-pg-migrate (raw SQL)
Monorepo:     pnpm workspaces (packages/shared, packages/api, packages/app)
CI/CD:        GitHub Actions → SSH deploy (Docker) + EAS Build (mobile)
```

**Use this stack unless a specific project need demands deviation.** Deviations should be justified: "This project needs X because Y, and the reference stack's Z doesn't support it."

**Shared infrastructure:** If Albert already has a DigitalOcean Droplet running for another project, evaluate co-hosting. A 2vCPU/2GB Droplet can run 2-3 light Dockerized apps if they don't spike simultaneously. If the new project's load profile is different (real-time, heavy compute, etc.), spin up a separate Droplet.

---

## PHASE 3: SPECIFICATION — Write the Contract

### 3.1 The Blueprint Package

Following this methodology produces a 7-document **Blueprint Package** — the project-specific spec that the implementing agent consumes. Each layer serves a different consumer at a different abstraction level:

```
00-CORE-PRINCIPLES.md     ← The DNA. Domain knowledge. Design philosophy.
                             Human-readable. Sets the "why" for everything.

01-SYSTEM-INTENT.md       ← Layer 1: WHAT must exist.
                             Domain model, state machines, user flows,
                             invariants, acceptance criteria,
                             EXPERIENCE FIDELITY SCENARIOS,
                             SCENARIO VALIDATION MATRICES,
                             depth-classified requirements,
                             constraints, non-goals.

02-ARCHITECTURE.md        ← Layer 2: System SHAPE.
                             Module boundaries, interface contracts, API surface,
                             data flows, event flows, sync protocol.

03-EXECUTION-CONTEXT.md   ← Layer 3: HOW to write code.
                             Pinned versions, repo structure, coding standards,
                             testing philosophy, error handling, infrastructure.
                             The implementing agent reads this to act autonomously.

04-COORDINATION-HINTS.md  ← Layer 4: In what ORDER.
                             Phase dependencies, depth-tagged done criteria,
                             experience audits per phase, production threshold,
                             risk hotspots, seed data requirements, timeline.
                             NOT a procedural checklist.

05-CONSTRUCTION-SITES.md  ← Layer 5 (living): Implementation debt tracker.
                             Agent-maintained log of every simplification,
                             reviewed at phase boundaries, closed when
                             specified depth is achieved.

CLAUDE.md                 ← Root entry point for Claude Code.
                             Points to all docs. States current phase.
                             Inviolable rules including fidelity controls.
```

### 3.2 What Goes Where (Decision Guide)

If you're writing something and aren't sure which document it belongs in, use this:

| If it answers... | It goes in... |
|---|---|
| "Why does this system exist? What does the domain look like?" | 00-CORE-PRINCIPLES |
| "What entities exist? What states can they be in? What must always be true?" | 01-SYSTEM-INTENT |
| "What can the user do? What counts as success?" | 01-SYSTEM-INTENT |
| "What does the user actually *experience* when a principle is fully realized?" | 01-SYSTEM-INTENT (Experience Fidelity Scenarios) |
| "Which scenario assertions does this task satisfy?" | 01-SYSTEM-INTENT (Scenario Validation Matrix) |
| "Is this requirement about existence, correctness, or experience?" | Depth tag [E], [W], or [D] on the requirement |
| "What should the system never do or be?" | 01-SYSTEM-INTENT (non-goals) |
| "What must the user NEVER have to do?" | 01-SYSTEM-INTENT (Negative Assertions in scenarios) |
| "What modules exist? How do they talk to each other?" | 02-ARCHITECTURE |
| "What does the API look like? What's the request/response shape?" | 02-ARCHITECTURE |
| "How does data flow from input to storage to output?" | 02-ARCHITECTURE |
| "Does this scenario require new services, layers, or subsystem redesign?" | 02-ARCHITECTURE (Architecture Impact Assessment) |
| "What version of X do we use? Where do files go?" | 03-EXECUTION-CONTEXT |
| "How do we write tests? Handle errors? Name things?" | 03-EXECUTION-CONTEXT |
| "What gets built first? What depends on what?" | 04-COORDINATION-HINTS |
| "What's risky? Where do we need extra care?" | 04-COORDINATION-HINTS |
| "What's the production threshold vs. v1.1?" | 04-COORDINATION-HINTS (Production Threshold) |
| "What was simplified during implementation?" | 05-CONSTRUCTION-SITES (agent-maintained) |

### 3.3 The Golden Rules of Spec Writing

**Rule 1: Declare, don't prescribe.**
- ❌ "Create a file called `plant.service.ts` with a function `createPlant` that takes..."
- ✅ "The system exposes a plant creation interface that accepts species, position, and zone, validates containment within zone boundary, and returns the created plant with a generated position label."

**Rule 2: Every entity needs a complete schema.**
List every field with its type, constraints, and relationships. The implementing agent shouldn't have to infer schema from context clues.

**Rule 3: Every state needs valid transitions.**
If something has states, define the state machine explicitly. Which transitions are valid? What triggers them? Are they reversible?

**Rule 4: Every user flow needs acceptance criteria.**
Not "the user can add a tree." Instead: "A user adds a tree by tapping a map location, the tree appears at the tapped coordinates, species is inferred from the next photo, and the tree is addressable by voice within 5 seconds."

**Rule 5: Every invariant is a test.**
"The system never recommends Level 4 treatment without showing lower-level alternatives" — this is both a design constraint AND a test case. Write invariants that are directly testable.

**Rule 6: Name your non-goals.**
Explicitly state what the system is NOT. This prevents scope creep and helps the implementing agent avoid building things you don't want.

**Rule 7: Pin your versions.**
Every library, framework, and runtime gets a pinned version. "Latest" is acceptable only for non-critical utilities. Core stack is pinned to exact major.minor.

**Rule 8: Every principle gets a scenario.**
If a core principle in 00-CORE-PRINCIPLES doesn't have a corresponding Experience Fidelity Scenario in 01-SYSTEM-INTENT, it will be flattened during implementation. Principles without scenarios are wishes, not specifications.

**Rule 9: Tag your depths.**
Every requirement and done-criterion gets an explicit depth tag: `[E]` exists, `[W]` works, `[D]` delivers the experience. Untagged requirements default to `[W]`, which means `[D]` requirements that should be orchestration-level get treated as unit-level. Tag explicitly.

**Rule 10: Log your simplifications.**
The implementing agent maintains 05-CONSTRUCTION-SITES.md as a living document. Every `[D]` → `[W]` or `[W]` → `[E]` downgrade gets logged at the moment it happens, not discovered weeks later in a code review. Silent simplification is a spec violation.

**Rule 11: Write specs, not tickets.**
The decomposition sequence is inviolable: principles → scenarios → architecture impact assessment → task derivation → coherence check → depth tagging. Skipping any step — especially jumping from a feature name directly to task creation — is the primary mechanism that causes flattening. A task that doesn't trace back to a specific scenario assertion through the Scenario Validation Matrix is a task that can drift without anyone noticing.

**Rule 12: Specify behaviors, not just data structures.**
If the spec defines a data model (report schema, notification template, scheduled event) but no orchestration mechanism makes it happen automatically (batch job, cron trigger, event-driven pipeline), the feature will be built as a data structure that exists but never fires. Every data structure that implies automatic behavior must have a corresponding behavior specification: what triggers it, when, and what the user experiences without manually initiating it.

### 3.4 Requirement Depth Classification

Every requirement and done-criterion in the spec is tagged with a depth level. The depth level determines what "done" means for that requirement.

| Depth | Tag | Meaning | Example |
|-------|-----|---------|---------|
| **EXISTS** | `[E]` | Component is present in the codebase. Route exists, UI element renders, function is callable. Satisfiable by scaffolding alone. | `[E] Voice recording endpoint accepts audio` |
| **WORKS** | `[W]` | Component functions correctly in isolation. Input produces expected output. Error cases handled. Unit tests pass. | `[W] Transcription returns structured text from audio input within 5 seconds` |
| **DELIVERS** | `[D]` | Component participates in the intended user experience as described in its Experience Fidelity Scenario. Integration with other components produces the orchestrated behavior. Scenario fidelity checklist items pass. | `[D] Voice observation flow matches Principle 3 scenario — single tap to pocket in under 30 seconds with all metadata inferred` |

**Classification Rules:**

1. **Most infrastructure requirements are `[E]` or `[W]`.** Auth endpoint exists `[E]`. Auth endpoint validates tokens correctly `[W]`. These rarely need `[D]` because they're invisible to the user experience.

2. **Core domain logic is always `[W]` minimum.** If the app's value proposition depends on it, it must work correctly, not just exist.

3. **Every core principle must have at least one `[D]` requirement.** This is how the experience fidelity scenarios connect to the task list. If you can't find a `[D]` requirement for a principle, the principle isn't being adequately specified.

4. **`[D]` requirements are never satisfied by a single component.** By definition, they require integration across subsystems. If a `[D]` requirement can be satisfied by one module alone, it's actually a `[W]` — reclassify it.

5. **Phase done-criteria inherit the highest depth of their constituent requirements.** If a phase contains any `[D]` requirements, the phase isn't done until those scenario fidelity checks pass.

6. **Data structures that imply behavior need behavioral `[W]` or `[D]` tags.** A report schema is `[E]`. A report that generates correctly from input data is `[W]`. A report that arrives in the owner's inbox on the 1st of the month without anyone triggering it is `[D]`. If only the schema is tagged, only the schema will be built.

### 3.5 Experience Fidelity Scenarios

This is the mechanism that prevents implementation flattening. For every core principle in `00-CORE-PRINCIPLES.md`, write a concrete scenario describing what the user experiences when that principle is fully realized.

**Why this exists:** Principles describe *experiences* (orchestration-level). Tasks describe *components* (unit-level). Without scenarios, a rich principle like "voice-first interaction" gets decomposed into component-level tickets ("implement recording," "add transcription endpoint," "create voice tab") that each pass review individually but never compose into the intended experience. The scenario sits at the right abstraction level to catch this.

#### 3.5.1 Scenario Format

Each scenario follows this structure. All five sections are mandatory — partial scenarios produce partial implementations.

```markdown
SCENARIO: [Descriptive Name — a situation, not a feature]

CONTEXT:
[When and where this happens in the user's day. Time of day, physical environment,
what they're carrying, what they just finished doing, what they need to accomplish,
and how much time they have. Specificity here prevents abstract implementations.]

USER EXPERIENCES:
  What they see/hear:
    [Sensory details — screen content, audio feedback, visual confirmations.
    What reaches the user's eyes and ears without them seeking it out.]

  What they do:
    [Physical actions in sequence — taps, speaks, walks, points camera.
    Written as a continuous narrative of behavior, not a feature list.
    MUST include at least 2-3 behavioral variations within the narrative:
    what happens when there's nothing to act on, a standard action, and
    a special case. Single-path narratives produce single-path implementations.
    MUST include the error/correction flow: what happens when the system
    misunderstands, the user makes a mistake, or input is ambiguous.
    Error recovery UX is consistently the most flattened part of any
    experience — specify it here or it will be patched on as an afterthought.]

  What they NEVER have to do:
    [CRITICAL — Negative assertions. These are the most powerful drift detectors
    because they are the first things cut during implementation. Each negative
    assertion becomes a test: if the user has to do this thing, the scenario fails.
    Examples: "never looks at screen," "never taps to confirm," "never navigates
    a menu," "never manually selects from a list," "never opens the app."
    MINIMUM 3 negative assertions per scenario.]

  Why this matters:
    [Connection to core principle. Why this experience specifically — the domain
    reasoning, the productivity math, the safety consideration, the professional
    standard being met. MUST include at least one quantified impact comparison:
    "X takes N minutes vs. Y takes M minutes" or "reduces Z from N steps to M."
    Qualitative claims ("faster," "easier," "more professional") are not testable.
    Quantified claims ("2x productivity: 45 min vs 90 min for 47 items") become
    both success criteria and regression tests.]

SUCCESS CRITERION:
[Frame as something you could literally film. "Video of [user] doing [activity]:
[observable behaviors], [measurable outcomes], [time constraint]." If you can't
describe a video that would prove the scenario works, the scenario isn't concrete
enough.]
```

#### 3.5.2 Scenario Writing Rules

1. **One scenario per core principle.** If a principle doesn't merit a scenario, it's either not a real principle or it's a constraint (put it in non-goals instead).

2. **Name the user.** Scenarios with named personas ("Steven walks up to a tree...") are harder to flatten than abstract ones ("the user can record voice"). Use the actual user's name or a consistent persona name.

3. **Count the interactions.** If the principle implies minimal screen interaction, the scenario must quantify "minimal." If it implies speed, the scenario must state a time bound. If it implies volume, the scenario must state a count ("47 trees in 45 minutes").

4. **Negative assertions are mandatory, not optional.** The "What they NEVER have to do" section is the single most important part of the scenario. Positive assertions ("user can record voice") are easy to satisfy shallowly. Negative assertions ("user never looks at screen during observation walk") are impossible to satisfy without the full orchestrated experience. Every scenario must have at least 3 negative assertions.

5. **Scenarios are stable.** They change only when principles change. If a scenario needs rewriting during implementation, the principle was probably wrong — escalate to the architect before modifying.

6. **Include secondary users.** If the app serves multiple roles (operator vs. owner, creator vs. consumer), each role that has a core principle needs its own scenario. The owner who "never opens the app" is as important as the operator who uses it daily.

7. **Success criteria are filmable.** "The system works correctly" is not filmable. "Video of Steven: walks 47 trees, speaks observations continuously, phone in pocket except when initiating, never stops to check confirmation, completes all trees in under 50 minutes, all observations parsed correctly" is filmable. If you can't describe the video, you can't verify the scenario.

8. **Show behavioral variation, not just the happy path.** The narrative must include at least 2-3 distinct conditions: nothing to act on (user passes through), standard action (typical interaction), and special case (photo needed, edge condition, unusual input). A scenario that only demonstrates the golden path produces tasks that only handle the golden path — edge cases become afterthoughts.

9. **Include the error/correction flow explicitly.** Show what happens when the system misunderstands, the user misspells, or input is ambiguous. "If unsure, one additional statement: 'correct that: [correction]' → another chime." Error recovery is consistently the most flattened part of any experience because it's not in the "main flow." If it's not in the scenario, it won't be in the task list.

10. **Quantify impact, don't just claim it.** The "Why this matters" section must include at least one concrete comparison with numbers. "Faster" is not testable. "45 minutes vs. 90 minutes for 47 items — 2x productivity" is testable, becomes a success criterion, and serves as a regression threshold for future versions.

#### 3.5.3 From Scenario to Tasks: The Derivation Protocol

After writing a scenario, derive implementation tasks using this process — never from the feature name:

**Step 1: List every verb in the scenario.** Each verb implies a system capability. "Speaks" → speech capture. "Hears confirmation" → audio feedback. "Pockets phone" → no screen interaction required post-action. "Arrives in inbox" → email delivery pipeline.

**Step 2: For each capability, ask "what makes this happen?"** This surfaces the orchestration layer that feature-name decomposition misses. "Confirmation chime plays" requires: transcription completes → parse succeeds → audio file selected → playback triggered → no UI confirmation required. That's 5 components, not 1 task.

**Step 3: Write each task with scenario linkage.** Every task's acceptance criterion references the scenario and the specific assertion it satisfies:

```markdown
Task: Audio confirmation protocol
Scenario: Morning Observation Walk (Principle 3)
Assertion: #3 — "Audio confirmation plays without requiring screen interaction"
Acceptance: After voice observation is parsed, a chime + TTS summary plays.
            User does not need to look at screen to verify success.
Technical: Zustand state listener + TTS on observation.status === 'confirmed'
```

**Step 4: Produce the Scenario Validation Matrix** (see 3.5.4).

**Step 5: Architecture Impact Assessment** (see 3.5.5).

**Step 6: Run the Coherence Check** (see 3.5.6).

#### 3.5.4 The Scenario Validation Matrix

After deriving tasks from a scenario, produce a **Scenario Validation Matrix** — a traceable artifact showing the bidirectional linkage between scenario assertions and implementation tasks. This matrix is a required deliverable in `01-SYSTEM-INTENT.md`, not a mental model held by the specifier.

**Format:**

```markdown
## Scenario Validation Matrix: [Scenario Name] (Principle [N])

| # | Scenario Assertion                          | Required Task(s)          | Load-Bearing? | Depth | Without This Task...                         |
|---|---------------------------------------------|---------------------------|---------------|-------|----------------------------------------------|
| 1 | Single tap initiates voice capture           | Hotword activation service | Yes           | [D]   | User must unlock, navigate, tap — 3 contacts instead of 1 |
| 2 | Natural speech parsed into structured data   | NLP observation parser     | Yes           | [W]   | User must manually fill form fields            |
| 3 | Audio confirmation without screen look       | Audio confirmation protocol| Yes           | [D]   | User must look at screen to verify — eyes leave environment |
| 4 | All metadata inferred and persisted          | Tree auto-detection, cause inference | Yes  | [D]   | User must manually select tree, type cause     |
| 5 | Total time under 30 seconds                  | Observation buffering      | Partial       | [W]   | Network latency may push over threshold        |
| 6 | Screen contacts: exactly 1                   | Field Mode UX              | Yes           | [D]   | Tab bar and nav visible, inviting extra taps   |

### Uncovered Assertions
[Any assertion from the scenario's negative list or fidelity checklist that
no task addresses. These are gaps — add tasks or escalate to the architect.]

### Tasks Without Assertions
[Any derived task that doesn't map to a specific assertion. These are either
scope creep (remove) or belong to a different scenario (reassign).]
```

**Why this matters:** Without the matrix, the coherence check is an informal mental exercise — the specifier believes the tasks cover the scenario but has no auditable artifact proving it. With the matrix, gaps are visible in the "Uncovered Assertions" section and scope creep is visible in the "Tasks Without Assertions" section. Both sections should be empty before moving to implementation.

**Rules:**

1. **Every scenario assertion must map to at least one task.** Empty rows in the assertion column are specification gaps.

2. **Every task must map to at least one assertion.** Orphan tasks are either scope creep or belong to a different scenario.

3. **The "Without This Task" column is mandatory.** It forces you to articulate what breaks — which is exactly what the coherence check needs.

4. **The matrix is bidirectional.** You should be able to trace from any assertion → tasks that satisfy it, and from any task → assertions it serves.

5. **One matrix per scenario.** Produces clean traceability. If a task serves multiple scenarios, it appears in multiple matrices.

#### 3.5.5 Architecture Impact Assessment

After deriving tasks and producing the validation matrix, but BEFORE finalizing the task list and committing to implementation, review the derived tasks against the current or planned architecture. This step catches cases where closing a gap requires structural changes — new subsystems, redesigned navigation, new job queues — that can't be achieved by patching individual components.

**For each scenario's task set, answer:**

1. **Do these tasks fit existing architectural patterns?** Can they be implemented within the current module boundaries, data flows, and API contracts? If yes, proceed normally. If no, identify which patterns break and what new patterns are needed.

2. **Do they require new services or layers?** A scheduled report that "just arrives" requires a batch job runner, a template engine, and an email delivery pipeline. If none of these exist in the current architecture, they're not tasks — they're architectural additions that must be designed first.

3. **Do they require redesigning existing subsystems?** A voice-first experience may require redesigning the navigation stack (removing tab-based navigation in favor of a field mode). A hands-free flow may require redesigning the confirmation UX (removing tap-to-confirm in favor of audio confirmation). These are not task-level changes — they're architectural decisions that affect multiple subsystems.

4. **Are there cross-scenario conflicts?** Does closing one gap create tension with another? For example, a simplified "field mode" that hides the tab bar for voice-first use may conflict with a scenario that requires quick access to data views.

**Output:** A brief architecture impact statement for each scenario, captured in `02-ARCHITECTURE.md`:

```markdown
## Architecture Impact: [Scenario Name]

### Fits Existing Patterns
- NLP observation parser (new service, follows existing API patterns)
- Observation buffering (WatermelonDB queue, established pattern)

### Requires New Infrastructure
- Batch job scheduling (BullMQ — not yet in architecture, add to job queue subsystem)
- Email delivery pipeline (Resend integration — new external service)

### Requires Subsystem Redesign
- Navigation stack: Field Mode requires suppressing tab bar and rerouting
  to single-screen voice UI. Affects: app/navigation/, all tab-dependent screens.
  Decision needed: toggle mode vs. separate navigation tree.

### Cross-Scenario Conflicts
- None identified / [describe conflict and resolution approach]
```

**Rules:**

1. **This assessment happens during specification, not during implementation.** Discovering that voice-first requires a navigation redesign mid-build is expensive. Discovering it during specification is cheap.

2. **New infrastructure items become their own `[E]` or `[W]` requirements in the phase plan.** They're prerequisites for the `[D]` experience they enable.

3. **Subsystem redesigns escalate to the architect.** The implementing agent does not autonomously redesign navigation, data layers, or API contracts. These decisions affect the entire system.

#### 3.5.6 The Coherence Check

After completing the Architecture Impact Assessment, validate the final task list with two tests:

**Completeness Test:** "If I complete every task on this list, does the scenario's success criterion become filmable?" Walk through the success criterion sentence by sentence. If any part of the video description isn't covered by a task, you've found a gap. The Scenario Validation Matrix's "Uncovered Assertions" section should be empty.

**Necessity Test (Single-Removal):** For each task, ask: "If I remove this one task and complete all others, does the scenario still come true?" If removing any single task breaks the scenario, that task is **load-bearing** and must be tagged `[D]`. If removing it doesn't break the scenario, it's either optimization (tag `[W]`) or it belongs to a different scenario (reassign). The "Without This Task" column in the matrix provides this analysis.

**Failure Analysis:** When a task is identified as load-bearing, document specifically which part of the scenario breaks without it:

```markdown
Task: Hotword activation
Remove it: User must pull phone from pocket and tap button to initiate.
Breaks: "Phone in pocket, pull-and-speak" → now requires "pull, unlock, tap"
Impact: Scenario still partially works but negative assertion "never navigates
        a menu" fails. Two additional screen contacts per observation.
Conclusion: Load-bearing. Tag [D]. Cannot defer without architect approval.
```

This analysis should be performed during specification, not during implementation. It's cheaper to discover missing tasks in a document than in code.

### 3.6 Production Threshold

In `04-COORDINATION-HINTS.md`, explicitly define the **production threshold** — the minimum set of scenarios that must pass at `[D]` depth before the app ships. Everything else is v1.1.

The production threshold answers: "What must work at full experience fidelity for the primary user to do their job with this app?"

**Format:**

```markdown
## Production Threshold

### Must Close Before Production
These scenarios define the line between "prototype" and "professional tool."
The app does not ship until these pass at [D] depth.

| Scenario | Principle | Rationale |
|----------|-----------|-----------|
| [Scenario Name] | [Principle ref] | [Why user cannot do their core job without this] |

### Deferred to v1.1
These scenarios add value but the user can work without them. Explicitly deferred
with rationale, not silently dropped.

| Scenario | Principle | Rationale for Deferral |
|----------|-----------|----------------------|
| [Scenario Name] | [Principle ref] | [Why this is optimization, not core workflow] |
```

**Rules:**

1. **The production threshold is decided during specification, not during implementation.** If the agent discovers mid-build that a production-threshold scenario is harder than expected, it escalates to the architect — it doesn't silently defer.

2. **"Can the user do their job?" is the test.** Not "is the app complete?" — completion is v1.1+. The production threshold is about the minimum viable *experience*, not the minimum viable *feature set*.

3. **Each deferred scenario gets an explicit rationale.** "Nice to have" is not a rationale. "The user can complete their daily workflow without this because [specific reason]" is a rationale.

### 3.7 The Audit Step

After writing all specification documents, do a cross-document audit. Check for:

- **Entity referenced in API but missing from domain model** (e.g., API has `/properties/:id/access` but no `Property_Access` entity)
- **Enum values in UI color maps that don't exist in state machines** (e.g., color for "good" health state but "good" not in health enum)
- **API routes with no clear data ownership** (who stores this? which module owns it?)
- **State machines referenced but not fully defined** (transitions listed but not validated)
- **Acceptance criteria that can't be tested** (too vague, no measurable threshold)
- **Missing infrastructure** (push tokens without storage, email without sender service, files without object storage)
- **Missing operational details** (no test framework, no DB client, no workspace manager, no worker entry point)
- **Principle without a corresponding Experience Fidelity Scenario** (principle will be flattened — write the scenario)
- **`[D]` requirement with no connection to a scenario fidelity checklist** (the depth tag is meaningless without a validation mechanism)
- **Phase done-criteria with no `[D]` items** (if a phase touches a core principle but has no `[D]` criteria, the experience layer was already flattened at spec time)
- **Scenario fidelity checklist items that can be satisfied by a single component** (reclassify as `[W]` — `[D]` items by definition require multi-component integration)
- **Data structures without behavior specifications** (schema exists but no trigger/job/pipeline makes it fire — the feature will be built as inert data)
- **Scenarios with fewer than 3 negative assertions** (positive assertions are easy to satisfy shallowly; negative assertions force full orchestration)
- **Scenarios with only the happy path** (no behavioral variation — standard action, nothing-to-act-on, and special case conditions must all appear in the narrative)
- **Scenarios missing the error/correction flow** (error recovery UX is the first thing flattened — if it's not in the scenario, it won't be in the tasks)
- **"Why this matters" sections with only qualitative claims** ("faster," "easier," "more professional") — must include at least one quantified comparison with specific numbers
- **Scenario Validation Matrix with non-empty "Uncovered Assertions" or "Tasks Without Assertions" sections** (gaps or scope creep)
- **Tasks derived from feature names rather than scenario verbs** (check that every task references a specific scenario assertion, not just a feature label)
- **Scenario success criteria that aren't filmable** (if you can't describe the verification video, the scenario isn't concrete enough to prevent drift)
- **Architecture Impact Assessment missing for any scenario** (structural requirements will be discovered mid-build instead of during specification)
- **Architecture impact items not reflected as requirements in the phase plan** (new infrastructure identified but never added to the build sequence)

This audit typically finds 10-20 issues. Fix them all before implementation begins.

---

## PHASE 4: IMPLEMENTATION — Phase-by-Phase with Fidelity Gates

### 4.1 Phase Structure

Every phase has:
- **"What exists after"** — one sentence describing the world after this phase completes
- **"Done when"** — 3-8 specific, verifiable criteria, each tagged with depth `[E]`, `[W]`, or `[D]`
- **"Correctness > speed" flags** — subsystems where getting it right matters more than getting it fast
- **"Experience Audit"** — mandatory validation step before phase sign-off (see 4.3)

**Example Phase with Depth Tags:**

```markdown
### Phase 3: Voice-First Field Experience

**What exists after:** The user can walk through their environment, speak
observations naturally, and have them fully processed without manual data entry.

**Done when:**
- [E] Voice recording UI component renders on the main screen
- [E] Transcription endpoint accepts audio and returns text
- [W] Natural language parser extracts structured fields (entity ID, symptom,
      severity, cause, timeline) from conversational speech
- [W] Audio confirmation plays correct summary after processing
- [W] Inferred metadata (status change, follow-up task, cause tag) persists correctly
- [D] Experience Fidelity Scenario for Principle 3 passes — all fidelity checklist
      items verified, all negative assertions confirmed
- [D] Three different observation phrasings (formal, casual, abbreviated) all produce
      correct structured output

**Correctness > speed:** Natural language parsing. Getting the structured extraction
wrong is worse than being slow.
```

### 4.2 The Testing Contract

**After EVERY phase:**
1. All unit tests for new logic pass.
2. All integration tests for new API routes pass.
3. The done criteria can be manually demonstrated.
4. No regressions in previously passing tests.
5. Experience Audit completed — all affected scenarios evaluated, construction site entries logged for any gaps, `[D]` requirements either pass or have architect-approved deferral plans.
6. Phase completion report produced and appended to 05-CONSTRUCTION-SITES.md.
7. Phase is not done until all 6 are true.

**After the FINAL phase:**
- Albert provides separate E2E test instructions (Playwright headless).
- User simulation testing with real-world scenarios.

### 4.3 The Experience Audit

After completing all done-criteria for a phase, the implementing agent performs this audit BEFORE marking the phase complete:

**Step 1: Scenario Re-read.** For every Experience Fidelity Scenario affected by this phase, re-read the full scene description. Not the checklist — the narrative. The narrative contains experiential details that checklists compress.

**Step 2: Scenario Walk-through.** Mentally (or actually) walk through the scenario from the user's perspective using only the code that currently exists. At each sentence in the scene, ask: "Can I do this right now with the current build?" / "Does it feel like the scene describes, or did I flatten it?" / "What would the user actually experience vs. what the scene promises?"

**Step 3: Negative Assertion Check.** Review every negative assertion ("user NEVER has to...") in the affected scenarios. These are the highest-priority checks because negative assertions are the first casualties of implementation shortcuts. For each one: does the current build actually prevent the user from having to do this thing, or does it merely make it *possible* to avoid it? "User can skip confirmation" is not the same as "user never has to confirm."

**Step 4: Fidelity Check.** Run through the scenario's fidelity checklist. For each item:
- **PASS:** The behavior matches the specification at the correct depth
- **PARTIAL:** The behavior exists but at a shallower depth than specified — log a construction site entry
- **FAIL:** The behavior doesn't exist — either it's in a future phase (acceptable) or it was missed (log entry and assess whether the phase can close)

**Step 5: Construction Site Review.** Review all construction site entries created during this phase. If any `[D]` requirements have open entries, the phase does not close until either the entry is resolved (requirement brought to specified depth), OR the architect explicitly approves deferral to a named future phase with a concrete resolution plan.

**Step 6: Report.** Produce a brief phase completion report:

```
## Phase {N} Experience Audit Report

### Scenarios Evaluated
- Principle {X} Scenario: {PASS | PARTIAL — N open entries | NOT YET — future phase}
  - Negative assertions: {N passed} / {N total}
  - Fidelity checklist: {N passed} / {N total}
- Principle {Y} Scenario: {PASS | PARTIAL | NOT YET}

### Construction Sites Created This Phase: {N}
### Construction Sites Closed This Phase: {N}
### Open Entries Blocking Phase Completion: {N}
  - {CS-ID}: {one-line description}

### Phase Status: {COMPLETE | BLOCKED — requires architect review}
```

### 4.4 Phase 0 Is Always Scaffolding

Every project starts the same way:
- Monorepo builds. Both packages compile.
- Docker Compose starts infrastructure (postgres + redis minimum).
- Health endpoint returns 200.
- CI pipeline passes (lint + typecheck).
- Shared package importable from both api and app.
- 05-CONSTRUCTION-SITES.md initialized (empty, with header and table structure).

If Phase 0 doesn't work flawlessly, nothing else matters.

---

## PHASE 5: CONSTRUCTION SITE TRACKING — Making Implementation Debt Visible

### 5.1 Purpose

05-CONSTRUCTION-SITES.md is a living document maintained by the implementing agent during the build. Every time the agent makes a simplification, deferral, stub, or shallow implementation of a depth-specified requirement, it logs a construction site entry. This prevents silent flattening — the drift becomes visible and trackable at the moment it happens, not weeks later in a code review.

**This is not a bug tracker.** Bugs are things that don't work. Construction sites are things that work at a shallower depth than specified. A voice endpoint that accepts audio and returns text is working code — but if the spec requires it to participate in a 30-second hands-free flow, the gap between `[W]` and `[D]` is a construction site.

### 5.2 Entry Format

| Field | Description |
|-------|-------------|
| **ID** | Sequential: CS-001, CS-002, etc. |
| **Phase** | Which phase created this site |
| **Requirement** | The specific requirement that was shallowed |
| **Specified Depth** | What the spec says: `[E]`, `[W]`, or `[D]` |
| **Implemented Depth** | What was actually built: `[E]`, `[W]`, or `[D]` |
| **Gap Description** | What's missing between specified and implemented |
| **Scenario Impact** | Which Experience Fidelity Scenario is affected, and which specific negative assertion or fidelity item fails |
| **Reason** | Why the simplification was made (dependency not ready, complexity, time) |
| **Resolution Plan** | When and how this will be brought to specified depth |
| **Status** | OPEN / RESOLVED / DEFERRED (with architect approval) |

### 5.3 Rules

1. **Every simplification gets logged.** No exceptions. "I'll come back to this" without a construction site entry is a spec violation.

2. **`[D]` → `[W]` downgrades are high priority.** These are the flattening events. They must include a resolution plan that references the affected scenario and identifies which negative assertions now fail.

3. **Review at phase boundaries.** Before a phase is marked done, the architect reviews all entries created during that phase. Open entries for `[D]` requirements block phase completion.

4. **Entries are closed only when the specified depth is achieved.** Moving from `[W]` to `[D]` and passing the relevant fidelity checklist items — including all negative assertions — closes the site.

5. **Accumulation is a signal.** If more than 3 entries accumulate for a single Experience Fidelity Scenario, the implementation approach for that scenario needs rethinking — it's not a patching problem, it's an architecture problem. Escalate to the architect.

### 5.4 Template

```markdown
# 05-CONSTRUCTION-SITES.md — [Project Name]

## Living Implementation Debt Tracker

| ID | Phase | Requirement | Specified | Implemented | Gap | Scenario Impact | Reason | Resolution | Status |
|----|-------|-------------|-----------|-------------|-----|-----------------|--------|------------|--------|
| CS-001 | 3 | Voice flow under 30s | [D] | [W] | Recording works but requires 3 taps and screen navigation | Principle 3 — negative assertion "never navigates a menu" fails | Voice UI not yet integrated into main screen | Phase 3b: Integrate mic button into primary view | OPEN |

## Phase Completion Reports

### Phase 0 — Scaffolding
(Append experience audit report here)
```

---

## PHASE 6: DRIFT REMEDIATION — When Flattening Is Discovered Post-Build

Despite all safeguards, drift may be discovered after implementation — through code review, user testing, or field observation. When this happens, follow this protocol to recover without creating a Frankenstein app of bolted-on fixes.

### 6.1 The Anti-Frankenstein Principle

When drift is discovered post-build, the instinct is to start fixing immediately — take the gap list and work top to bottom. This produces a Frankenstein app: features bolted onto a body designed for a different shape. Instead, treat the gap-closing as a **new specification phase** with its own discipline.

### 6.2 Remediation Protocol

**Step 1: Diagnose, don't fix.** (1 day, no code)

For each discovered gap, write it as an Experience Fidelity Scenario using the full scenario format (Section 3.5.1). Even if a scenario existed in the original spec, rewrite it against the *current* codebase — the scenario must reflect what the implementation actually needs to become, not what the original vision imagined.

**Step 2: Current-State Walkthrough.** (Half day)

Before writing remediation tasks, document exactly what the user experiences TODAY — step by numbered step. This makes the gap between vision and reality concrete and visible, not abstract.

**Format:**

```markdown
## Current-State Walkthrough: [Feature/Scenario Name]

What the user does today (from actual code):
1. Opens app
2. Navigates to [Section] tab
3. Taps [Entity]
4. Taps [Sub-tab]
5. Presses [Button]
6. Speaks observation
7. Waits for transcription to appear on screen
8. Reviews transcription text
9. Taps Confirm

Screen contacts: 5 (steps 1, 3, 4, 5, 9)
Eyes on screen: steps 2-4, 7-9
Total time: ~90 seconds per item

DRIFT POINT: Between steps 5-8, the user is looking at the phone,
not at their environment. The scenario requires eyes-on-environment
throughout. Every step after step 1 is a deviation from the vision.
```

Then list what currently exists vs. what the scenario requires:

```markdown
Current implementation status:
- ✅ Recording infrastructure (works)
- ✅ Transcription (works)
- ✅ Observation parsing (works)
- ❌ Hotword activation (not implemented)
- ❌ Audio-only confirmation (not implemented)
- ❌ Field Mode UX (not implemented)
- ❌ Automatic entity detection from speech (not implemented)
- ❌ Camera auto-trigger (not implemented)
```

The numbered walkthrough format makes the drift point visually obvious — you can literally count the screen contacts and see where reality diverges from the scenario's negative assertions.

**Step 3: Derive remediation tasks from scenarios.** (1 day)

Using the derivation protocol (Section 3.5.3), decompose each scenario into tasks. Produce the Scenario Validation Matrix. Run the Architecture Impact Assessment. Run the coherence check. Each task must reference the scenario assertion it satisfies.

**Step 4: Classify as production threshold or v1.1.** (Decision point)

Not all discovered drift is equally urgent. Apply the production threshold test (Section 3.6): "Can the user do their core job without this?" Scenarios that pass this test are must-close. Scenarios that fail are explicitly deferred with rationale.

**Step 5: Architecture review before code.** (Half day)

Review the remediation tasks against the current architecture. Ask:
- Do these tasks fit existing patterns, or do they require new services/layers?
- Does closing this gap require re-architecting an existing subsystem (e.g., navigation redesign for voice-first)?
- Are there coherence issues where fixing one gap creates conflicts with another?

**Step 6: Implement as a coherent mini-phase.** (Varies)

The remediation tasks become a new phase in 04-COORDINATION-HINTS.md with its own done-criteria, depth tags, and experience audit. They are not a fix list — they are a specified phase that happens to come after the original build.

### 6.3 What NOT to Do During Remediation

- **Don't take the gap list and start working top to bottom.** That's patching, not engineering.
- **Don't fix gaps without writing scenarios first.** You'll re-introduce the same flattening that created the gaps.
- **Don't fix all gaps at once.** Pick the 2-3 that define the production threshold. Ship those. Defer the rest with explicit rationale.
- **Don't skip the architecture review.** Some gaps require structural changes (navigation redesign, new job queues, new services). Patching structural gaps with local fixes creates worse drift.
- **Don't treat the remediation as lower-priority work.** These are the gaps between "prototype" and "production tool." They deserve the same specification rigor as the original build.

---

## APPENDIX A: COMMON MISTAKES

These are patterns discovered across multiple spec-driven builds. Avoid them:

**Mistake: Too many documents when fewer will do.**
Early attempts used 11 procedural spec documents (decisions, data models, features, AI integration, API spec, UI screens, infrastructure, testing, implementation order, plus principles and vision). Restructured to a layered model where each document serves a clear purpose at a clear layer. Less is more.

**Mistake: Procedural instructions instead of declarative contracts.**
"Create endpoint POST /plants with handler that validates body..." is procedural. "The system accepts plant creation requests with species, position, and zone, validates containment, and returns the created entity" is declarative. The implementing agent figures out the how.

**Mistake: Treating offline as an afterthought.**
If the user works in the field, offline is not "nice to have." It's an invariant. Design the data layer for offline-first from day one (WatermelonDB, local cache, sync protocol). Bolting it on later requires a rewrite.

**Mistake: No explicit non-goals.**
Without non-goals, scope creeps invisibly. "This is not a photo album." "This is not a navigation app." "No web dashboard for v1." These prevent wasted work.

**Mistake: AI without guardrails.**
"The AI helps the user" is not a spec. Define every AI prompt role: trigger, input context, output schema, key rules, error handling, fallback behavior. The AI is auditable — every recommendation shows its reasoning.

**Mistake: Skipping the audit.**
The first draft always has cross-document inconsistencies. Entity missing from the model but referenced in API routes. Enum values in the color map that don't exist in state machines. Audit catches 10-20 issues. Do it before implementation.

**Mistake: Flattening experiences into components.**
"Voice-first" became "voice recording works" + "transcription returns text" — each component passed its tests, but the composed experience (single-tap, hands-free, 30-second flow) was never tested because no specification existed at that level. Fix: Every core principle gets an Experience Fidelity Scenario with a fidelity checklist. Every done-criterion that touches a principle's experience gets tagged `[D]`, meaning it's validated against the scenario, not just against unit tests. The agent maintains a Construction Site Tracker for every `[D]` → `[W]` downgrade so flattening is visible immediately, not discovered in post-build code reviews.

**Mistake: Deriving tasks from feature names instead of scenarios.**
"Implement voice input" produces: recording endpoint, transcription service, voice tab UI. All correct components, all passing tests, all missing the point. "The user observes 47 items in 45 minutes without looking at the screen" produces: hotword activation, audio-only confirmation, field mode UX, entity auto-detection from speech, camera auto-trigger, observation buffering. Same feature, entirely different task list — because the scenario forces you to decompose the *experience*, not the *technology*.

**Mistake: Specifying data structures without behavior.**
The report schema was designed, the PDF template existed, the API endpoint was ready. But no batch job generated reports on schedule, no email delivery was configured, and no share-link mechanism existed. The feature was built as a data structure, not a behavior. Result: the recipient receives nothing until someone manually triggers it. Every data model that implies automatic behavior (scheduled reports, notifications, synced updates) must have a corresponding behavior specification with trigger, frequency, and delivery mechanism.

**Mistake: Patching drift instead of specifying remediation.**
When code review reveals flattened implementations, the temptation is to start fixing immediately. This produces a Frankenstein app — features bolted onto a body designed for a different shape. Instead: write scenarios for the gaps, derive tasks from those scenarios, run the coherence check, classify against the production threshold, review architecture impact, then implement as a coherent phase. The extra 2-3 days of specification prevents weeks of rework.

**Mistake: Skipping the architecture impact assessment.**
Derived tasks that require new infrastructure (job schedulers, email pipelines) or subsystem redesigns (navigation stack, data layer) get treated as normal tasks. Mid-build, the agent discovers structural incompatibilities and either hacks around them (creating worse drift) or stalls. The architecture review during specification costs half a day; discovering these issues mid-build costs weeks.

---

## APPENDIX B: CONVERSATION FLOW TEMPLATE

When starting a new project, follow this conversation arc:

```
Session 1: DISCOVERY (1-2 hours)
├── "Tell me about this project. What problem does it solve? For whom?"
├── "Walk me through a typical user day with this app."
├── "What exists already? Any prior work, documents, code, research?"
├── "What's the business model?"
├── For each principle: "If this is working perfectly, what is the user's
│   body doing? Their eyes? Their hands? What do they never have to do?"
├── Produce: Problem statement, entity list, user journey sketch, open questions list
│
Session 2: DEEP DIVE + RESEARCH (1-2 hours)
├── Answer open questions from Session 1
├── Research technical feasibility for risky areas
├── Define the domain model (entities, relationships, states)
├── Clarify the primary user vs secondary users
├── Produce: Research findings, domain model draft, tech stack decision
│
Session 3: SPECIFICATION (2-3 hours)
├── Write 00-CORE-PRINCIPLES.md (domain knowledge, design philosophy)
├── Write 01-SYSTEM-INTENT.md (entities, flows, invariants, acceptance)
│   ├── Write Experience Fidelity Scenarios for each core principle
│   │   ├── Full scenario format (context, sensory, behavioral, negative, rationale)
│   │   ├── Minimum 3 negative assertions per scenario
│   │   └── Filmable success criterion for each
│   ├── Derive tasks from scenarios using derivation protocol
│   │   ├── List verbs → identify capabilities → write tasks with scenario linkage
│   │   └── Produce Scenario Validation Matrix for each scenario
│   ├── Tag all requirements with depth [E], [W], or [D]
│   └── Verify every principle has at least one [D] requirement
├── Write 02-ARCHITECTURE.md (shape, contracts, API surface, data flows)
│   └── Architecture Impact Assessment for each scenario's task set
├── Write 03-EXECUTION-CONTEXT.md (versions, structure, standards)
├── Write 04-COORDINATION-HINTS.md (phases, depth-tagged done criteria, risks)
│   ├── Define production threshold (must-close vs. v1.1)
│   ├── Verify every phase touching a core principle has [D] done-criteria
│   └── Run coherence check (completeness + single-removal) for each scenario
├── Initialize 05-CONSTRUCTION-SITES.md (empty tracker with header)
├── Write CLAUDE.md (entry point with fidelity rules)
├── Produce: Complete 7-document Blueprint Package
│
Session 4: AUDIT + LAUNCH (30 min - 1 hour)
├── Cross-document consistency check (including fidelity audit items)
│   ├── Verify all scenarios have 3+ negative assertions
│   ├── Verify all Scenario Validation Matrices have no uncovered assertions
│   ├── Verify all tasks reference specific scenario assertions
│   ├── Verify Architecture Impact Assessments exist for all scenarios
│   ├── Verify no data structures lack behavior specifications
│   └── Verify all success criteria are filmable
├── Fix all findings
├── Confirm Blueprint Package is implementation-ready
├── Hand off to Claude Code → Phase 0
```

This can compress into 2 sessions or expand into 5 depending on project complexity.

---

## APPENDIX C: CLAUDE.MD TEMPLATE

```markdown
# CLAUDE.md — [Project Name]

## What This Is

[One paragraph: what the app does, for whom, and why it matters.]

## Spec Package (read in order)

1. `docs/00-CORE-PRINCIPLES.md` — The DNA. Why this system exists. Domain knowledge.
2. `docs/01-SYSTEM-INTENT.md` — What must exist. Domain model, flows, invariants, experience fidelity scenarios, scenario validation matrices, acceptance criteria.
3. `docs/02-ARCHITECTURE.md` — System shape. Modules, contracts, API surface, data flows, architecture impact assessments.
4. `docs/03-EXECUTION-CONTEXT.md` — How to write code. Versions, structure, standards, testing, infra.
5. `docs/04-COORDINATION-HINTS.md` — Build ordering. Phases, depth-tagged done criteria, production threshold, risks.
6. `docs/05-CONSTRUCTION-SITES.md` — Living implementation debt tracker. You maintain this.

## Current Phase

**Phase: 0 — Scaffolding**

_(Update this line as you progress through phases.)_

## Rules

1. Read the spec documents before writing code.
2. Every phase has done criteria. The phase is not done until all criteria are met and tests pass.
3. Test after each phase. Build on working code. No phase begins until the previous phase passes.
4. Respect depth tags. `[E]` means it exists. `[W]` means it works correctly. `[D]` means it delivers the specified user experience. Never flatten `[D]` requirements into `[W]` implementations.
5. Log every simplification in 05-CONSTRUCTION-SITES.md at the moment it happens. Silent simplification is a spec violation.
6. Run the Experience Audit before closing any phase. Re-read the affected scenarios — especially the negative assertions — walk through them with current code, and verify fidelity checklist items pass.
7. Write specs, not tickets. Derive tasks from scenarios, not feature names. Every task references the scenario and specific assertion it satisfies. Check the Scenario Validation Matrix — if an assertion is uncovered, the task list is incomplete.
8. Data structures that imply automatic behavior (reports, notifications, scheduled events) must have corresponding behavior implementations — not just schemas.
9. [Project-specific invariant]
10. When in doubt, consult 00-CORE-PRINCIPLES.md. Every decision derives from a principle.
```

---

## APPENDIX D: QUICK REFERENCE — DEPTH TAGS AND FIDELITY CONTROLS

### When to Use Each Depth Tag

| Situation | Tag | Rationale |
|-----------|-----|-----------|
| Route handler exists, returns 200 | `[E]` | Scaffolding. Proves the plumbing works. |
| Endpoint validates input, returns correct data, handles errors | `[W]` | Functional correctness in isolation. |
| Feature participates in a multi-component user experience described in a scenario | `[D]` | Orchestration-level. Can only be validated by walking through the scenario. |
| Infrastructure component (auth, database, CI) | `[E]` or `[W]` | Rarely `[D]` — infrastructure is invisible to the user experience. |
| Core domain logic (calculations, AI processing, data transformations) | `[W]` minimum | The app's value depends on these being correct, not just present. |
| Data structure with implied automatic behavior (report schema, notification template) | `[W]` for structure, `[D]` for the automation that fires it | If only the structure is tagged, only the structure will be built. |
| Any requirement tied to a core principle | Must include `[D]` | If a principle has no `[D]` requirements, it has no experience-level validation and will be flattened. |

### The Flattening Detection Checklist

Use this during the Section 3.7 audit to catch flattening before implementation begins:

- [ ] Every core principle in 00-CORE-PRINCIPLES has a corresponding Experience Fidelity Scenario in 01-SYSTEM-INTENT
- [ ] Every scenario follows the full format: context, sensory, behavioral, negative assertions, rationale, filmable success criterion
- [ ] Every scenario has at least 3 negative assertions ("user NEVER has to...")
- [ ] Every scenario narrative includes 2-3 behavioral variations (nothing to act on, standard action, special case) — not just the happy path
- [ ] Every scenario narrative includes the error/correction flow (what happens when the system misunderstands or user needs to fix input)
- [ ] Every scenario's "Why this matters" includes at least one quantified impact comparison with specific numbers (not just "faster" or "easier")
- [ ] Every scenario's success criterion is filmable (you can describe the verification video)
- [ ] Every scenario has a Scenario Validation Matrix with empty "Uncovered Assertions" and "Tasks Without Assertions" sections
- [ ] Every scenario has been through the coherence check (completeness test + single-removal test)
- [ ] Every scenario has an Architecture Impact Assessment in 02-ARCHITECTURE.md
- [ ] Every task references a specific scenario and assertion, not just a feature name
- [ ] Every scenario's fidelity checklist items require multi-component integration (not satisfiable by one module)
- [ ] Every phase in 04-COORDINATION-HINTS that touches a core principle has at least one `[D]` done-criterion
- [ ] No `[D]` done-criterion is satisfiable by a single component in isolation
- [ ] Every data structure that implies automatic behavior has a corresponding behavior specification with trigger mechanism
- [ ] Architecture impact items (new infrastructure, subsystem redesigns) are reflected as requirements in the phase plan
- [ ] Production threshold is explicitly defined — must-close scenarios vs. v1.1 deferrals
- [ ] 05-CONSTRUCTION-SITES.md is initialized and ready for the implementing agent

### Construction Site Severity Guide

| Downgrade | Severity | Action |
|-----------|----------|--------|
| `[D]` → `[W]` | **High** — this is a flattening event | Must include resolution plan referencing affected scenario. Identify which negative assertions now fail. Blocks phase completion unless architect approves deferral. |
| `[D]` → `[E]` | **Critical** — experience reduced to scaffolding | Immediate escalation. Something went wrong in the phase plan. |
| `[W]` → `[E]` | **Medium** — component exists but doesn't work correctly | Acceptable as temporary state if dependency isn't ready. Must have resolution in current or next phase. |
| Data structure without behavior | **High** — schema exists but feature never fires | Often invisible because the data layer "looks complete." Check every model that implies scheduled/triggered behavior. |
| Any downgrade with no entry logged | **Spec violation** | The implementing agent must log every simplification. Unlogged downgrades are the mechanism by which flattening becomes invisible. |

---

## APPENDIX E: WORKED EXAMPLE — Full Pipeline from Principle to Tasks

This appendix demonstrates the complete specify → clarify → plan → tasks pipeline for a single principle, using a domain-agnostic example. Every step references the methodology section that governs it.

### The Principle (from 00-CORE-PRINCIPLES)

> **Principle 4: Zero-effort accountability.** Stakeholders who fund the work but don't use the tool receive professional proof-of-work automatically, without requesting it, downloading an app, or learning terminology.

### The Scenario (Section 3.5.1)

```
SCENARIO: Monthly Accountability Report

CONTEXT:
It's the 1st of the month, 8 AM. The stakeholder — a property owner named Sarah —
wakes up and checks email on her phone. She hired a professional operator two months
ago to manage her property. She has never opened the management app and doesn't know
how it works. She needs to verify work was performed, understand financial impact,
and have records for her accountant.

USER EXPERIENCES:
  What she sees/hears:
    - Email in inbox with professional subject line and PDF attachment
    - 4-page PDF: cover with summary stats, work log, treatment records with
      compliance fields, financial summary with ROI calculation
    - A link in the email to download a spreadsheet version for her accountant

  What she does:
    - Normal month (nothing unusual): opens email, skims PDF, files it. Done in 2 min.
    - Month with a concern: sees treatment entry she doesn't recognize, replies to
      operator: "What's this treatment on row 3?" Operator replies with context.
      No app needed — email thread handles the clarification.
    - Error case (report generation fails): Sarah receives email with subject
      "Report: [Property] — February [Partial]" with a note: "Some data from
      Feb 26-28 is still syncing. A complete report will follow within 24 hours."
      She receives the complete version the next day automatically. She never has
      to request it or know the system had an issue.
    - Shows PDF to accountant (treatment records prove compliance)
    - Checks cost summary: sees spend vs. equivalent cost, net savings

  What she NEVER has to do:
    - Download or open the management app
    - Learn navigation, terminology, or workflows
    - Request a report or remind the operator
    - Visit a website, portal, or dashboard
    - Understand technical jargon (all language is professional but accessible)

  Why this matters:
    - Stakeholders hire operators for outcomes, not app usage. If the stakeholder
      must learn the tool, the tool has failed its second audience.
    - Accountability builds trust. Automated accountability builds trust at scale.
    - Financial justification sustains the engagement — ROI visibility prevents
      cost-cutting decisions made from ignorance.
    - Quantified impact: Manual report compilation takes the operator 2-3 hours per
      property per month. Automated reports take 0 operator minutes. For an operator
      managing 5 properties, that's 10-15 hours/month recovered — equivalent to
      2 full field days redirected from desk work to productive work.

SUCCESS CRITERION:
Video of Sarah's morning: opens email on phone at 8 AM on the 1st, sees report
from last month, opens PDF attachment, reads 4 pages in under 3 minutes, forwards
to accountant with no additional explanation needed. She never touches the management
app. Report was generated and sent with zero manual action by the operator.
```

### The Derivation (Section 3.5.3)

**Step 1: Verbs in the scenario:**
sees (email) → opens (PDF) → reads (content) → forwards (to accountant) → downloads (spreadsheet) → generated (automatically) → sent (on schedule)

**Step 2: What makes each happen?**
- "Sees email at 8 AM on the 1st" → scheduled batch job (timezone-aware) + email delivery service
- "Opens PDF" → PDF rendering engine (data → formatted document)
- "Reads 4 pages" → report data assembly (queries, calculations, statistics for date range)
- "Forwards to accountant" → PDF is self-contained (no login required to view)
- "Downloads spreadsheet" → share link generation with time-limited access + Excel export
- "Generated with zero manual action" → full automation pipeline (trigger → assemble → render → deliver)
- "ROI visible" → calculation service (actual cost vs. equivalent cost)

**Step 3: Tasks with scenario linkage:**

```
Task 1: Monthly auto-report batch job
Scenario: Monthly Accountability (Principle 4)
Assertion: "generated and sent with zero manual action by the operator"
Acceptance: BullMQ job runs at 10 PM user timezone on last day of month,
            handles multiple properties, graceful failure with retry
Depth: [D] — without this, operator must manually trigger reports

Task 2: Report data assembly service
Scenario: Monthly Accountability (Principle 4)
Assertion: "4-page PDF: work log, treatment records, financial summary"
Acceptance: Assembles all property activity for date range into report structure
Depth: [W] — isolated data processing, validated by unit tests

Task 3: PDF rendering
Scenario: Monthly Accountability (Principle 4)
Assertion: "opens PDF attachment, reads 4 pages in under 3 minutes"
Acceptance: Professional 4-page layout, readable on phone, no jargon
Depth: [W] — isolated rendering, validated by visual inspection

Task 4: ROI calculation service
Scenario: Monthly Accountability (Principle 4)
Assertion: "sees spend vs. equivalent cost, net savings"
Acceptance: Per-item cost comparison, total savings summary, accurate calculations
Depth: [W] — isolated calculation, validated by test fixtures

Task 5: Email delivery via Resend
Scenario: Monthly Accountability (Principle 4)
Assertion: "Email in inbox with professional subject line"
Acceptance: Uses stakeholder email from access table, branded template
Depth: [D] — without this, report exists but stakeholder never receives it

Task 6: Share link for accountant
Scenario: Monthly Accountability (Principle 4)
Assertion: "forwards to accountant with no additional explanation needed"
             + "link to download spreadsheet version"
Acceptance: Time-limited (30 days) download link, Excel export available
Depth: [W] — isolated URL generation and download endpoint
```

### The Scenario Validation Matrix (Section 3.5.4)

| # | Scenario Assertion | Required Task(s) | Load-Bearing? | Depth | Without This Task... |
|---|---|---|---|---|---|
| 1 | Report generated with zero manual action | Task 1: Batch job | Yes | [D] | Operator must remember to generate and send — negates "zero-effort" |
| 2 | Professional 4-page PDF in email | Tasks 2, 3, 5 | Yes (all three) | [D] | No report arrives, or it arrives as raw data |
| 3 | ROI / financial summary visible | Task 4 | Yes | [W] | Stakeholder sees activity but not value — can't justify continued investment |
| 4 | Stakeholder never opens the app | Tasks 1, 5 | Yes | [D] | If any step requires app access, this assertion fails |
| 5 | Accountant gets spreadsheet via link | Task 6 | Partial | [W] | Stakeholder must manually re-enter data for accountant |

**Uncovered Assertions:** None.
**Tasks Without Assertions:** None.

### The Architecture Impact Assessment (Section 3.5.5)

```
## Architecture Impact: Monthly Accountability

### Fits Existing Patterns
- Data assembly service (new query module, follows existing API patterns)
- ROI calculation (pure function, no infrastructure dependency)

### Requires New Infrastructure
- BullMQ scheduled job runner — not yet in architecture. Must add job queue
  subsystem with scheduled trigger capability, timezone handling, and retry logic.
- Resend email integration — new external service. Must add email delivery
  module with template support.
- Share link system — token generation + time-limited download endpoint.
  New route pattern (public, no auth, token-validated).

### Requires Subsystem Redesign
- None — report generation is additive, doesn't conflict with existing patterns.

### Cross-Scenario Conflicts
- None identified.
```

### The Coherence Check (Section 3.5.6)

**Completeness Test:** Walk through the success criterion: "opens email on phone at 8 AM on the 1st" → Task 1 + 5. "Opens PDF, reads 4 pages" → Tasks 2 + 3. "Forwards to accountant" → Task 6. "Never touches the app" → Tasks 1 + 5 (full automation). "Zero manual action by operator" → Task 1. All sentences covered. ✅

**Necessity Test:** Remove Task 1 (batch job): operator must manually generate → "zero manual action" fails → **load-bearing, [D]**. Remove Task 5 (email): report exists but never arrives → "sees email at 8 AM" fails → **load-bearing, [D]**. Remove Task 4 (ROI): report arrives but without financial justification → scenario partially works but "sees spend vs. equivalent cost" fails → **load-bearing, [W]** (report is still useful without ROI, but diminished). Remove Task 6 (share link): stakeholder must forward PDF itself → scenario mostly works → **not load-bearing, [W]**.

---

## APPENDIX F: GLOSSARY

| Term | Definition |
|------|------------|
| **PROJECT DNA** | This document. The methodology template that governs how all projects are specified and built. |
| **Blueprint Package** | The 7 project-specific spec documents (00 through 05 + CLAUDE.md) produced by following this methodology. |
| **Experience Fidelity Scenario** | A concrete narrative describing what the user experiences when a core principle is fully realized. Contains context, sensory details, behavioral sequence, negative assertions, rationale, and filmable success criterion. |
| **Negative Assertion** | A statement of what the user NEVER has to do. The most powerful drift detector because negative assertions are the first casualties of implementation shortcuts. |
| **Scenario Validation Matrix** | A traceable artifact mapping scenario assertions to implementation tasks bidirectionally. Makes gaps and scope creep visible. |
| **Architecture Impact Assessment** | Analysis of whether a scenario's derived tasks fit existing patterns, require new infrastructure, or require subsystem redesign. Performed during specification, not implementation. |
| **Depth Tag** | `[E]` exists, `[W]` works, `[D]` delivers. Classification of what "done" means for a requirement. |
| **Flattening** | The failure mode where a rich experiential principle is decomposed into component tasks that each pass tests individually but never compose into the intended user experience. |
| **Construction Site** | A logged instance of implementation at a shallower depth than specified. Not a bug — the code works, just at a lower depth. |
| **Production Threshold** | The minimum set of scenarios that must pass at `[D]` depth before the app ships. Everything else is v1.1. |
| **Coherence Check** | Two-part validation: Completeness Test (do all tasks together make the scenario filmable?) and Necessity Test (does removing any single task break the scenario?). |
| **Current-State Walkthrough** | Numbered step-by-step documentation of what the user actually experiences today, used during drift remediation to make the gap between vision and reality concrete. |

---

*This methodology was forged through multiple spec-driven builds and field-validated drift analysis. The core insight: well-specified apps with correct architecture consistently produced "technically complete but experientially flat" implementations because vision principles were decomposed into component tasks without an intermediate experience-level specification. The fix is structural: experience fidelity scenarios with mandatory negative assertions, scenario validation matrices that make task-to-assertion linkage auditable, architecture impact assessments that catch structural requirements before implementation, depth classification that distinguishes existence from orchestration, coherence checks that validate decomposition against filmable success criteria, construction site tracking that makes drift visible at phase boundaries, production threshold classification that prevents silent deferral, and a remediation protocol that recovers from discovered drift without creating Frankenstein apps.*
