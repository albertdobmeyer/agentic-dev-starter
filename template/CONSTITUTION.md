# Constitution — Project DNA
## Hard Rules for Spec-Driven, Test-First Agentic Development

> Copy this file into your project alongside AGENT.md (renamed to your agent's convention).
> Articles 1-9 are universal. Customize Article 10 for your project.
> Licensed under CC BY-SA 4.0 — AKD AUTOMATION SOLUTIONS

---

## Article 1: Testing Discipline

- Write the test BEFORE the implementation. No exceptions.
- Every commit leaves the full test suite green. Never commit on red.
- Build only on working code. If any test is failing, fix it before starting new work.
- Every acceptance criterion must be directly testable. If you can't write a test for it, the spec is too vague — refine it before proceeding.
- Every invariant is a test. "The system never does X" is both a design constraint and a test case.
- Run the full test suite before every phase completion, not just per-task tests.

## Article 2: Specification Standards

- Declare, don't prescribe. Describe WHAT must exist, not HOW to code it.
- Every entity needs a complete schema. All fields, types, constraints, relationships.
- Every state needs explicitly defined transitions. What triggers each. Whether reversible.
- Every user flow needs testable acceptance criteria with measurable outcomes.
- Pin every version. Every library, framework, and runtime gets a pinned major.minor version.
- Name non-goals explicitly. What the project is NOT prevents scope creep.

## Article 3: Anti-Flattening

- Derive tasks from user BEHAVIORS, not feature NAMES.
- Every core principle must have an Experience Fidelity Scenario — a concrete narrative of what the user experiences. Principles without scenarios are wishes, not specifications.
- Every scenario must have at least 3 negative assertions: things the user NEVER has to do.
- Every scenario must include behavioral variation: happy path, edge case, AND error flow.
- Success criteria must be filmable. "Video of user doing X in Y seconds without Z."
- Quantify impact. "Faster" is not testable. "45 min vs 90 min for 47 items" is testable.

## Article 4: Depth Classification

- `[E]` EXISTS — Present but not functional. Scaffolding only.
- `[W]` WORKS — Functions correctly in isolation. Unit tests pass.
- `[D]` DELIVERS — Participates in the intended user experience. Requires multi-component integration.
- Every core principle must have at least one `[D]` requirement.
- `[D]` is NEVER satisfied by a single component. If one module alone satisfies it, it's `[W]`.
- Data structures implying automatic behavior need behavioral tags.

## Article 5: Implementation Debt Tracking

- Every simplification gets logged at the moment it happens.
- `[D]` → `[W]` downgrades are HIGH severity. Must include which negative assertions now fail.
- `[D]` → `[E]` downgrades are CRITICAL. Immediate escalation.
- 3+ simplifications on one scenario = architecture problem. Stop patching.
- Unlogged downgrades are how flattening becomes invisible.

## Article 6: Specification Behaviors, Not Just Data

- Every data structure implying automatic behavior MUST have a behavior specification.
- If only the schema exists but no trigger is specified, the feature will be built as inert data.
- Always ask: "What makes this happen without the user manually triggering it?"

## Article 7: Drift Remediation

- Do NOT fix gaps top-to-bottom. Write scenarios for the gaps FIRST.
- Derive tasks from those scenarios. Run the coherence check.
- Implement remediation as a coherent phase, not a patch list.

## Article 8: Git & Workflow Discipline

- Commit per logical milestone, phase boundary, or independently reviewable work unit.
- Commit messages: `type: description` (feat, fix, docs, chore, test, refactor).
- Never commit failing tests. Main branch always works.
- Each feature gets its own numbered branch and spec directory.
- Follow: constitution → specify → clarify → plan → analyze → tasks → implement.

## Article 9: Agent Conduct

- The agent operates as co-architect. It plans, delegates, orchestrates, verifies, and pushes back.
- The agent does NOT please-seek. If the human's direction contradicts the spec, the agent says so — citing the specific article or scenario.
- When unclear, ask the human. Don't guess. Don't assume.
- After every correction, update CLAUDE.md so the mistake doesn't repeat.
- Keep CLAUDE.md under 200 lines. Use `@path` imports for detailed docs.
- Self-audit loops run after every implementation phase. Gaps are fixed before proceeding.
- Run `/speckit-clarify` before `/speckit-plan`. Unanswered questions become wrong assumptions.

---

## Article 10: {PROJECT-SPECIFIC RULES}

Customize for your project. Examples:

```
- Only Python standard library — no pip dependencies
- All state in SQLite — no external databases
- Mobile-first — test at 375px minimum width
- No TypeScript enums — use string literal unions
- All API responses follow JSON:API spec
```

**Project-DNA defaults** (remove if not applicable):
- Merge conflict prevention is a design constraint. If `[P]` tasks overlap on files, the task decomposition is wrong — fix the tasks, not the conflicts.
- Sub-agents get ONE file each. Interfaces defined before delegation.
- **Shared-code glob** (consumed by `dna:cross-checker` — a file matching any pattern below is shared-code; changes to it must PR to main first before feature-branch adoption). Customize this list for your project:
  ```
  shared-code-glob:
    - src/models/**
    - src/shared/**
    - src/types/**
    - src/common/**
    - src/middleware/**
    - src/api/routes/**
    - packages/*/shared/**
  ```
  Edit the list above to match your project's shared-code surface. Anything NOT in this list is feature-local and can evolve on a feature branch without shared-code PR discipline.

---

## Pre-Implementation Gate Checklist

- [ ] Every core principle has an Experience Fidelity Scenario with 3+ negative assertions
- [ ] Every scenario includes behavioral variation (happy + edge + error)
- [ ] Every scenario's success criterion is filmable
- [ ] Every acceptance criterion is directly testable
- [ ] Every entity has a complete schema (all fields, types, constraints)
- [ ] Every data structure with implied automatic behavior has a behavior spec
- [ ] All tasks derived from scenario behaviors, not feature names
- [ ] All depth tags assigned: `[E]`, `[W]`, `[D]`
- [ ] Every core principle has at least one `[D]` requirement
- [ ] Non-goals explicitly stated
- [ ] All versions pinned
- [ ] `[P]` tasks have zero file overlap

---

*Forged through the PROJECT DNA methodology. Every rule exists because its absence caused a specific, documented failure in a production build.*
