# Constitution Template — AKD AUTOMATION SOLUTIONS
## Hard Rules for Spec-Driven, Test-First Agentic Development

> **Created by:** Albert Dobmeyer & Claude (Anthropic)  
> **Intellectual Property of** AKD AUTOMATION SOLUTIONS — Licensed under CC BY-SA 4.0.  
> **Derived from:** The PROJECT DNA methodology — axioms extracted from multiple production builds where predictable failure modes were identified and structurally prevented.  
> **Purpose:** Feed this into `/speckit.constitution` at the start of every new project. Customize the `{PROJECT-SPECIFIC}` sections per project. The rules above the project-specific section are universal — they apply to every build.  
> **Distribution:** OPEN-SOURCE — Licensed under CC BY-SA 4.0

---

## Article 1: Testing Discipline

- Write the test BEFORE the implementation. No exceptions.
- Every commit leaves the full test suite green. Never commit on red.
- Build only on working code. If any test is failing, fix it before starting new work.
- Every acceptance criterion must be directly testable. If you can't write a test for it, the spec is too vague — refine it before proceeding.
- Every invariant is a test. "The system never does X" is both a design constraint and a test case. Encode it.
- Run the full test suite before every phase completion, not just per-task tests.

## Article 2: Specification Standards

- Declare, don't prescribe. Describe WHAT must exist, not HOW to code it.
- Every entity needs a complete schema. All fields, types, constraints, relationships. Never infer schema from context.
- Every state needs explicitly defined transitions. What triggers each transition. Whether it's reversible. No implicit state machines.
- Every user flow needs testable acceptance criteria with measurable outcomes. Not "the user can post a job." Instead: "A logged-in client submits title, location, and budget. The job appears in the feed within 5 seconds. The client sees confirmation with a link to the detail page."
- Pin every version. Every library, framework, and runtime gets a pinned major.minor version. "Latest" is not a version.
- Name non-goals explicitly. What the project is NOT prevents scope creep and stops the agent from building unwanted features.

## Article 3: Anti-Flattening

The #1 failure mode in spec-driven development is "flattening" — a rich user experience gets decomposed into component tasks that each pass tests individually but never compose into the intended experience.

- Derive tasks from user BEHAVIORS, not feature NAMES. "Implement authentication" produces wrong tasks. "A visitor submits email and password, a user record is created, the visitor is redirected to dashboard" produces correct tasks.
- Every core principle must have an Experience Fidelity Scenario — a concrete narrative describing what the user experiences when that principle is fully realized. Principles without scenarios are wishes, not specifications.
- Every scenario must have at least 3 negative assertions: things the user NEVER has to do. These are the most powerful drift detectors because they are the first things cut during implementation.
- Every scenario must include behavioral variation: happy path, edge case, AND error/correction flow. Single-path scenarios produce single-path implementations.
- Success criteria must be filmable. "The system works correctly" is not filmable. "Video of user doing X, completing in Y seconds, without doing Z" is filmable.
- Quantify impact. "Faster" is not testable. "45 minutes vs 90 minutes for 47 items — 2x productivity" is testable and becomes a regression threshold.

## Article 4: Depth Classification

Every requirement gets tagged with a depth that defines what "done" means:

- `[E]` EXISTS — Component is present. Route exists, UI renders, function is callable. Scaffolding only.
- `[W]` WORKS — Component functions correctly in isolation. Input produces expected output. Error cases handled. Unit tests pass.
- `[D]` DELIVERS — Component participates in the intended user experience as described in its scenario. Requires multi-component integration. Scenario fidelity checklist passes.

Rules:
- Infrastructure requirements are `[E]` or `[W]`. Auth, database, CI — invisible to user experience.
- Core domain logic is `[W]` minimum. The app's value depends on correctness.
- Every core principle must have at least one `[D]` requirement. No `[D]` = no experience-level validation = flattening.
- `[D]` requirements are NEVER satisfied by a single component. If one module alone can satisfy it, it's actually `[W]`.
- Data structures that imply automatic behavior need behavioral tags. A report schema is `[E]`. A report that generates correctly is `[W]`. A report that arrives in the inbox on the 1st without anyone triggering it is `[D]`.

## Article 5: Implementation Debt Tracking

- Every simplification gets logged at the moment it happens. "I'll come back to this" without a logged entry is a spec violation.
- `[D]` → `[W]` downgrades are HIGH severity flattening events. They must include a resolution plan identifying which negative assertions now fail.
- `[D]` → `[E]` downgrades are CRITICAL. Immediate escalation.
- If 3+ simplifications accumulate for a single scenario, the implementation approach needs rethinking — it's an architecture problem, not a patching problem.
- Unlogged downgrades are the mechanism by which flattening becomes invisible. The agent logs every simplification or it is in violation.

## Article 6: Specification Behaviors, Not Just Data

- Every data structure that implies automatic behavior (scheduled reports, notifications, synced updates) MUST have a corresponding behavior specification: what triggers it, when, and what the user experiences without manually initiating it.
- If only the schema exists but no orchestration (batch job, cron, event pipeline) is specified, the feature will be built as inert data. It will "exist" but never fire.
- Always ask: "What makes this happen without the user manually triggering it?"

## Article 7: Drift Remediation

When flattening or drift is discovered post-build:
- Do NOT take the gap list and start fixing top to bottom. That produces Frankenstein code.
- Write scenarios for the gaps FIRST. Derive tasks from those scenarios. Run the coherence check.
- Classify against the production threshold: must-close vs v1.1 deferral.
- Review architecture impact before writing fix code. Some gaps require structural changes.
- Implement remediation as a coherent phase, not a patch list.

## Article 8: Git & Workflow Discipline

- Commit per logical milestone, phase boundary, or independently reviewable work unit. Never batch more than one phase into a single commit.
- Commit messages follow: `type: description` (feat, fix, docs, chore, test, refactor).
- Never commit failing tests.
- Main branch always works — every commit is green.
- Use Spec-Kit's feature branch model. Each feature gets its own numbered branch and spec directory.
- Follow the Spec-Kit command sequence: constitution → specify → clarify → plan → analyze → tasks → implement. Don't skip steps.

## Article 9: Agent Conduct

- The agent is the co-engineer, not the architect. The handoff documents (VISION.md, ARCHITECTURE.md) define the vision. The agent does not change the vision — it implements it.
- When something is unclear, ask the human. Don't guess.
- After every correction, update CLAUDE.md so the mistake doesn't repeat.
- Keep CLAUDE.md under 200 lines. It's an index and ruleset, not a knowledge dump.
- Use `@path` imports in CLAUDE.md to reference detailed docs (e.g., `@CONSTITUTION.md`, `@.specify/memory/constitution.md`) without inlining them. This keeps the file lean while giving full access to context.
- When CLAUDE.md grows beyond 200 lines, move detail to docs/ and keep CLAUDE.md as an index.
- Run `/speckit.clarify` before `/speckit.plan`. Always. Unanswered questions in the spec become wrong assumptions in the plan.
- Run `/speckit.analyze` before `/speckit.implement`. Catch cross-artifact inconsistencies before they become code.

---

## Article 10: {PROJECT-SPECIFIC RULES}

Add project-specific axioms here. Examples:

```
- Only Python standard library — no pip dependencies
- All state in SQLite — no external databases
- Flat repo — maximum 2 directory levels
- Every function must have a docstring
- No TypeScript enums — use string literal unions
- Mobile-first responsive design — test at 375px width minimum
- All API responses follow JSON:API spec
- No ORM — raw parameterized SQL only
```

---

## Pre-Implementation Gate Checklist

Before `/speckit.implement`, verify:

- [ ] Every core principle has an Experience Fidelity Scenario with 3+ negative assertions
- [ ] Every scenario includes behavioral variation (happy path + edge case + error flow)
- [ ] Every scenario's success criterion is filmable
- [ ] Every acceptance criterion is directly testable
- [ ] Every entity has a complete schema (all fields, types, constraints)
- [ ] Every state machine has explicit transitions
- [ ] Every data structure with implied automatic behavior has a behavior specification
- [ ] All tasks are derived from scenario behaviors, not feature names
- [ ] All depth tags are assigned: `[E]`, `[W]`, `[D]`
- [ ] Every core principle has at least one `[D]` requirement
- [ ] Non-goals are explicitly stated
- [ ] All versions are pinned
- [ ] Production threshold is defined (must-ship vs v1.1)
- [ ] `/speckit.analyze` passes with no unresolved inconsistencies

---

*Forged through the PROJECT DNA methodology by AKD AUTOMATION SOLUTIONS. Every rule exists because its absence caused a specific, documented failure in a production build.*
