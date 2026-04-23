# Handoff Document Format Reference

> The kit uses the **7-doc Blueprint Package** from the original PROJECT_DNA methodology. Six docs live under `docs/` in the target, plus `CONSTITUTION.md` at root. Each doc serves a different consumer at a different abstraction level. Skeletons in `template/blueprint/` are copied to target during Protocol A step 7.

> Do not confuse the 7-doc Blueprint Package with Spec-Kit's per-feature `specs/NNN-*/spec.md` files. The Blueprint Package describes the **whole project**; Spec-Kit spec dirs describe **individual features** built against that Blueprint.

---

## The 7 documents

```
target/
├── CONSTITUTION.md                     ← Hard rules. 10 articles. Article 10 is project-specific.
└── docs/
    ├── 00-CORE-PRINCIPLES.md           ← Why this system exists. Domain knowledge. Principles that generate scenarios.
    ├── 01-SYSTEM-INTENT.md             ← What must exist. Entities, scenarios, Scenario Validation Matrix, depth tags.
    ├── 02-ARCHITECTURE.md              ← System shape. Modules, APIs, data flows. Architecture Impact Assessment per scenario.
    ├── 03-EXECUTION-CONTEXT.md         ← How to write code. Pinned versions, standards, testing philosophy.
    ├── 04-COORDINATION-HINTS.md        ← Build ordering. Phases with depth-tagged done criteria. Production Threshold.
    └── 05-CONSTRUCTION-SITES.md        ← Living tracker. Agent-maintained. Every simplification logged.
```

## What goes where (decision guide)

| If it answers... | It goes in... |
|---|---|
| "Why does this system exist? What does the domain look like?" | `00-CORE-PRINCIPLES.md` |
| "What entities exist? What states can they be in? What invariants always hold?" | `01-SYSTEM-INTENT.md` |
| "What does the user actually *experience* when a principle is fully realized?" | `01-SYSTEM-INTENT.md` (Experience Fidelity Scenarios) |
| "Which scenario assertions does this task satisfy?" | `01-SYSTEM-INTENT.md` (Scenario Validation Matrix) |
| "Is this requirement about existence, correctness, or experience?" | Depth tag `[E]`/`[W]`/`[D]` on the requirement, in `01-SYSTEM-INTENT.md` |
| "What must the user NEVER have to do?" | `01-SYSTEM-INTENT.md` (Negative Assertions in scenarios) |
| "What modules exist? How do they communicate?" | `02-ARCHITECTURE.md` |
| "What does the API look like?" | `02-ARCHITECTURE.md` |
| "Does this scenario require new services or subsystem redesign?" | `02-ARCHITECTURE.md` (Architecture Impact Assessment) |
| "What version of X do we use? Where do files go? How do we write tests?" | `03-EXECUTION-CONTEXT.md` |
| "What gets built first? What depends on what?" | `04-COORDINATION-HINTS.md` |
| "What must ship at `[D]` depth vs what's v1.1?" | `04-COORDINATION-HINTS.md` (Production Threshold) |
| "What was simplified during implementation, and why?" | `05-CONSTRUCTION-SITES.md` (agent-maintained via `dna-construction-logger` subagent) |
| "What hard rules never bend?" | `CONSTITUTION.md` (Articles 1–9 universal, Article 10 project-specific) |

---

## Required elements per document

### `00-CORE-PRINCIPLES.md`
- Problem statement (one paragraph)
- Target users (2–3 segments with context, pain, %)
- Domain model (entities as nouns, not features)
- Core principles (3–7 typical; each must produce a scenario in `01-SYSTEM-INTENT.md`)
- Business model, hard constraints, anti-principles

> **See example**: [team-project-scheduler-example/docs/00-CORE-PRINCIPLES.md](https://github.com/albertdobmeyer/team-project-scheduler-example/blob/c084166/docs/00-CORE-PRINCIPLES.md) — three principles each paired to a scenario, domain model named as nouns (Task, User, TaskStatus), anti-principles explicit.

### `01-SYSTEM-INTENT.md` — the most load-bearing doc
- Entity schemas (all fields, all types, all constraints — no "TBD")
- State machines (transitions, triggers, reversibility)
- Invariants ("the system NEVER...")
- **Experience Fidelity Scenarios** — one per principle, each with:
  - Context (when/where/carrying/time budget)
  - What they see/hear, what they do (2–3 behavioral variations + error/correction flow)
  - **≥3 negative assertions** ("user NEVER has to...")
  - Why this matters (≥1 quantified comparison — numbers, not adjectives)
  - Filmable success criterion
  - Depth tag
- **Scenario Validation Matrix** — **mandatory**, one per scenario:
  - Columns: `#`, assertion, required task(s), load-bearing?, depth, without-this-task-what-breaks
  - "Uncovered Assertions" row must be empty before `/speckit-plan`
  - "Tasks Without Assertions" row must be empty before `/speckit-plan`
- Depth classification summary (every requirement tagged `[E]`/`[W]`/`[D]`)

> **See example**: [team-project-scheduler-example/docs/01-SYSTEM-INTENT.md](https://github.com/albertdobmeyer/team-project-scheduler-example/blob/c084166/docs/01-SYSTEM-INTENT.md) — Scenario 1 shows ≥3 negative assertions, filmable success at ≤15s, behavioral variation (happy/edge/error), and a Validation Matrix with real task IDs from specs/001-*/ and specs/005-*/. "Uncovered Assertions" is empty.

### `02-ARCHITECTURE.md`
- Module boundaries, interface contracts, API surface
- Data flows + event/sync flows (every data structure that implies automatic behavior names its trigger here)
- Infrastructure decisions (chosen + rejected)
- **Architecture Impact Assessment** — one per scenario:
  - Fits existing patterns / requires new infrastructure / requires subsystem redesign / cross-scenario conflicts
  - New-infrastructure items must be reflected as requirements in `04-COORDINATION-HINTS.md` phases

> **See example**: [team-project-scheduler-example/docs/02-ARCHITECTURE.md](https://github.com/albertdobmeyer/team-project-scheduler-example/blob/c084166/docs/02-ARCHITECTURE.md) — Architecture Impact Assessment per scenario. Scenario 1's assessment names the calendar/view module boundary and the HTTP contract surface; Scenario 2's assessment forced Slack client infrastructure to be listed as a Phase 2 prerequisite in 04-COORDINATION-HINTS.md.

### `03-EXECUTION-CONTEXT.md`
- Tech stack (every row pinned to exact `major.minor` + rationale)
- Repo structure, coding standards (specific, not "follow best practices")
- Error handling house style
- Testing philosophy + numeric coverage thresholds
- Environment / secrets / infra setup (≤ 4 commands from `git clone` to running tests)

### `04-COORDINATION-HINTS.md`
- Phases: "what exists after" (one sentence), "done when" (3–8 criteria each depth-tagged), "correctness > speed" flags, Experience Audit step
- Every phase touching a core principle has ≥1 `[D]` done-criterion
- **Production Threshold**: must-close scenarios vs deferred-to-v1.1 (each with rationale)
- Risk hotspots + mitigation
- Seed data requirements per phase
- Non-goals (8+ explicit)

> **See example**: [team-project-scheduler-example/docs/04-COORDINATION-HINTS.md](https://github.com/albertdobmeyer/team-project-scheduler-example/blob/c084166/docs/04-COORDINATION-HINTS.md) — five phases with depth-tagged done criteria; Phase 2 (Calendar rendering) has three `[D]` done criteria (`:48-:50`) that remain **open** because 005 shipped only the server read path — an intentionally open gate until 006 ships. 10 non-goals, Production Threshold explicit.

### `05-CONSTRUCTION-SITES.md`
- Initialized at bootstrap (empty "Active sites" table)
- Maintained during implementation by `dna-construction-logger` subagent
- Every `[D]→[W]` or `[W]→[E]` downgrade logged with scenario impact, reason, resolution plan
- Accumulation of 3+ entries on one scenario → escalate (architecture problem, not patching problem)

> **See example**: [team-project-scheduler-example/docs/05-CONSTRUCTION-SITES.md](https://github.com/albertdobmeyer/team-project-scheduler-example/blob/c084166/docs/05-CONSTRUCTION-SITES.md) — **CS-001 RESOLVED** (cross-feature shared-model merge conflict, addressed by installing `dna:cross-checker`) and **CS-002 OPEN** (`[D]`-depth scenario partially delivered: server contract in 005, UI deferred to committed sibling 006). CS-002 is the canonical demonstration of legitimate Article 5 scope-deferral: logged at merge time, committed sibling named, phase not closed until sibling ships.

### `CONSTITUTION.md`
- Articles 1–9 universal (testing, specs, anti-flattening, depth, simplification logging, behavior specs, drift, workflow, reserved)
- Article 10 project-specific (4–8 rules customized during Protocol A step 6)
- Pre-Implementation Gate Checklist at the bottom — every box must be checkable before building starts

> **See example**: [team-project-scheduler-example/CONSTITUTION.md](https://github.com/albertdobmeyer/team-project-scheduler-example/blob/c084166/CONSTITUTION.md) — Article 10 customized for a small Node/TS team (coverage threshold, shared-code PR gate with explicit file globs, review depth rules). Compare against the kit's uncustomized [template/CONSTITUTION.md](../template/CONSTITUTION.md) to see what project-specific customization looks like in practice.

---

## Quality checks before implementation

Run these against every doc. Every failure is blocking.

### Structural
- [ ] All 6 `docs/NN-*.md` files exist plus root `CONSTITUTION.md`
- [ ] No file contains the literal string `{FILL IN` (all markers resolved)
- [ ] No file contains `[PROJECT_NAME] Constitution` (Spec-Kit stub marker — indicates constitution sync failed)

### Scenario fidelity (from `01-SYSTEM-INTENT.md`)
- [ ] Every principle in `00-CORE-PRINCIPLES.md` has a corresponding Experience Fidelity Scenario
- [ ] Every scenario has ≥3 negative assertions
- [ ] Every scenario has behavioral variation (happy + edge + error)
- [ ] Every scenario has a filmable success criterion
- [ ] Every scenario has a Scenario Validation Matrix with **both** "Uncovered Assertions" and "Tasks Without Assertions" empty
- [ ] Every scenario's "Why this matters" has a quantified comparison (numbers, not "faster"/"easier")

### Architecture impact (from `02-ARCHITECTURE.md`)
- [ ] Every scenario has an Architecture Impact Assessment
- [ ] "Requires new infrastructure" items appear as requirements in `04-COORDINATION-HINTS.md` phases
- [ ] Every data structure that implies automatic behavior has its trigger mechanism in Event/sync flows

### Depth discipline
- [ ] Every core principle has ≥1 `[D]` requirement
- [ ] No `[D]` requirement is satisfiable by a single component (if so, reclassify as `[W]`)
- [ ] Every phase touching a core principle has ≥1 `[D]` done-criterion

### Execution + coordination
- [ ] Every tech-stack row in `03-EXECUTION-CONTEXT.md` is pinned to exact `major.minor`
- [ ] Testing coverage thresholds are numeric
- [ ] `04-COORDINATION-HINTS.md` defines explicit Production Threshold with must-close and deferred scenarios
- [ ] `04-COORDINATION-HINTS.md` lists 8+ non-goals
- [ ] `CONSTITUTION.md` Article 10 is customized (not a placeholder)

---

## Relationship to Spec-Kit

The 7-doc Blueprint Package is the **pre-spec** for the whole project. Per-feature Spec-Kit dirs (`specs/NNN-*/spec.md`) reference the Blueprint during `/speckit-specify`:

- `00-CORE-PRINCIPLES.md` → informs which principle this feature serves
- `01-SYSTEM-INTENT.md` → the feature's Experience Fidelity Scenario(s) live here; `spec.md` formalizes them into Given/When/Then
- `02-ARCHITECTURE.md` → the feature's Architecture Impact block lives here
- `03-EXECUTION-CONTEXT.md` → authoritative for the feature's implementation standards
- `04-COORDINATION-HINTS.md` → the feature belongs to a named phase with depth-tagged done criteria
- `05-CONSTRUCTION-SITES.md` → any simplification during the feature's implementation lands here via `dna-construction-logger`

Once `/speckit-specify` formalizes the spec, it's the operational source of truth for that feature. The Blueprint remains the strategic reference.

---

## History and naming

Earlier versions of this kit used a compressed 4-doc format (`VISION.md`, `ARCHITECTURE.md`, `SCOPE.md`, `CONSTITUTION.md`). Restored to the original 7-doc Blueprint in 2026-04-21 after a methodology audit against `PROJECT_DNA.md` surfaced lost artifacts: the Scenario Validation Matrix, Architecture Impact Assessment, Production Threshold, and living Construction Sites tracker. See `.exploration/RESTORATION-2026-04-21.md` for the rationale.

Projects on the old 4-doc format continue to work but will not benefit from the anti-flattening mechanisms restored in the 7-doc package. Migrate when convenient.
