# 01-SYSTEM-INTENT — {PROJECT_NAME}

> **Purpose**: Layer 1 — WHAT must exist. Domain model, state machines, user flows, invariants, acceptance criteria, Experience Fidelity Scenarios, Scenario Validation Matrices, depth-classified requirements, non-goals.
>
> **This is the most load-bearing document in the Blueprint Package.** If it is thin, implementation will be flat.

## Domain model

### Entities

{FILL IN: Every entity with complete schema. All fields with types, constraints, relationships. Use TypeScript/Python/SQL style — whichever matches the stack in `02-ARCHITECTURE.md`. "Add fields as needed" is not a spec; list them all now.}

```typescript
interface {Entity} {
  // FILL IN
}
```

### State machines

{FILL IN: Every entity with states. List the states, the transitions, what triggers each transition, whether each is reversible. State without a transition diagram leaves the implementing agent guessing.}

```
{Entity} states: {state1} → {state2} → {state3}
  Trigger {state1}→{state2}: {user action / scheduled event / external signal}
  Reversible: yes/no
```

### Invariants

{FILL IN: Statements of the form "the system NEVER does X" or "the system always does Y." Each invariant is both a design constraint AND a test case.}

- The system never {...}
- The system always {...}

## User flows

{FILL IN: For each core flow, write the narrative. Not as a feature list — as a sequence of user actions with acceptance criteria.}

### Flow 1 — {name}
**Trigger**: {what starts the flow}
**Steps**: {numbered sequence}
**Acceptance**: {testable outcome with quantified thresholds}

---

## Experience Fidelity Scenarios

> **One scenario per core principle** from `00-CORE-PRINCIPLES.md`. Each scenario follows the full format below. All five sections are mandatory — partial scenarios produce partial implementations.

### Scenario 1 — {name}, satisfying Principle {N}

**CONTEXT**
{FILL IN: When and where this happens in the user's day. Time of day, environment, what they're carrying, what they just finished, what they need to accomplish, how much time they have. Specificity here prevents abstract implementations.}

**USER EXPERIENCES — What they see/hear**
{FILL IN: Sensory details — screen content, audio feedback, visual confirmations. What reaches the user without them seeking it out.}

**USER EXPERIENCES — What they do**
{FILL IN: Physical actions in sequence — taps, speaks, walks, points camera. Narrative of behavior, not feature list.
Must include at least 2–3 behavioral variations: nothing-to-act-on, standard action, and special case.
Must include the error / correction flow: what happens when the system misunderstands, the user makes a mistake, or input is ambiguous.}

**USER EXPERIENCES — What they NEVER have to do** (minimum 3 negative assertions)
- {Negative assertion 1 — e.g., "never opens a second tool to cross-reference"}
- {Negative assertion 2}
- {Negative assertion 3}

**USER EXPERIENCES — Why this matters**
{FILL IN: Connection to the principle. Include at least one quantified impact comparison with specific numbers. "Faster" is not testable. "45 minutes vs 90 minutes for 47 items — 2× productivity" is testable and becomes both success criterion and regression threshold.}

**SUCCESS CRITERION** (filmable)
{FILL IN: Describe a video that would prove the scenario works. Observable behaviors, measurable outcomes, time constraint. If you can't describe the verification video, the scenario isn't concrete enough.}

**DEPTH**: `[D]` — requires {list of components that must work together}

---

### Scenario 2 — {name}
_(Same structure as Scenario 1.)_

---

## Scenario Validation Matrix

> **Mandatory deliverable.** One matrix per scenario, produced by the derivation protocol in PROJECT_DNA Section 3.5.3. Both "Uncovered Assertions" and "Tasks Without Assertions" columns must be empty before `/speckit-plan` runs.

### Matrix: Scenario 1 ({name})

| # | Scenario Assertion | Required Task(s) | Load-Bearing? | Depth | Without This Task... |
|---|---|---|---|---|---|
| 1 | {assertion} | {task} | Yes/No | `[E]`/`[W]`/`[D]` | {what breaks} |
| 2 | {...} | {...} | | | |

**Uncovered Assertions**: {list any scenario assertion that no task addresses, OR write "none"}
**Tasks Without Assertions**: {list any task that doesn't map to an assertion, OR write "none"}

---

## Depth classification summary

| Requirement | Depth | Rationale |
|---|---|---|
| {requirement} | `[D]` | {one line — why this needs full experience fidelity} |
| {requirement} | `[W]` | {one line — why unit-correctness is sufficient} |
| {requirement} | `[E]` | {one line — why scaffolding is sufficient} |

Rules (see `CONSTITUTION.md` Article 4):
- Every core principle has ≥1 `[D]` requirement. If you can't find one, the principle isn't being specified adequately.
- `[D]` requirements are never satisfied by a single component. Multi-component integration is the test.
- Data structures that imply automatic behavior (reports arriving in inbox, notifications firing) need `[W]` for structure AND `[D]` for the automation that makes them fire.

## Non-goals

_(Short summary; full list with rationale in `04-COORDINATION-HINTS.md` §Production Threshold.)_
- No {...}
- No {...}

---

**Completion checks** (run before moving to `/speckit-plan`):
- [ ] Every principle in `00-CORE-PRINCIPLES.md` has a corresponding Experience Fidelity Scenario above
- [ ] Every scenario has ≥3 negative assertions
- [ ] Every scenario has behavioral variation (happy + edge + error)
- [ ] Every scenario's "Why this matters" has a quantified comparison
- [ ] Every scenario's success criterion is filmable
- [ ] Every scenario has a Validation Matrix with empty "Uncovered Assertions" and "Tasks Without Assertions"
- [ ] Every core principle has ≥1 `[D]` requirement in the depth summary
