# Roadmap — Team Transformation & Junior Pack Vision

*Drafted 2026-04-16, after the bigwolf-pond-board-game validation session. Intentionally directional — meant to be revisited and refined, not executed line-by-line.*

## Context

project-dna today is a methodology kit for a single practitioner (or a small team of experienced engineers) who wants to keep their AI agent on rails. It filters bad agent behavior: skipped tests, flattened scenarios, spec-vs-code drift, runaway context.

The next question is larger: **can the same kit turn a team of 5 junior engineers — each paired with Claude Code — into a team that ships senior-quality work? And does it accelerate their individual growth from junior to senior?**

This document captures the vision for that expansion.

## The Core Insight

**The gap isn't methodology. The gap is taste.**

project-dna already filters agent-level flattening. A team of juniors operating it will still hit a ceiling, because:

- The agent can execute well, but can't develop taste *for the human*.
- Spec-writing and code-review are the two skills that convert juniors to seniors.
- Neither is sufficiently scaffolded in the current kit.

Everything in this vision targets that specific gap.

## The North Star

**A team of 5 junior engineers, each with Claude Code, using project-dna, ships production-quality code at senior velocity — and becomes senior engineers through the process.**

Concrete definitions:
- **Senior-quality code**: specs that don't flatten; tests that cover behavior, not implementation; reviews that catch subtle spec-code divergence; no merge conflicts from parallel work; no broken mains.
- **Senior velocity**: under half the tokens a naïve junior would burn, because the methodology forces bounded scope per session.
- **Peer culture**: juniors reviewing each other's PRs with the agent's help, not senior-bottlenecked.

## Prioritized Additions

### 1. `/dna-review` skill — zero-trust PR review (the 6th DNA skill)

Unlike `/dna-verify` (which checks built-vs-specced for the original author), `/dna-review` operates on a diff prepared for merge and outputs junior-appropriate findings.

**What it checks** (expanding beyond `/dna-verify`):
- Every changed test actually covers the behavior from the spec's acceptance scenarios, not just the implementation shape.
- Every `[D]` task actually delivers the multi-component integration — no silent `[D] → [W]` drift.
- Negative assertions from VISION.md scenarios are satisfied by the changes.
- Code matches the interface contracts from plan.md; if not, flags the divergence as "spec says X, code does Y — refine spec or fix code."
- Commit discipline per Article 8 (phase boundaries, test-green commits).

**Why it's the highest-leverage add**: a junior reviewer learns what to catch by watching the skill catch it. Over time, the same patterns become second nature and the skill becomes a safety net rather than a crutch.

### 2. Graduated spec-writing curriculum

A new `docs/SPEC_WRITING.md` plus `examples/spec-progressions/` containing 5 worked examples of the same feature spec'd three ways each (bad / mediocre / good), paired with the output of `/dna-test-gate` when you try to build against each. Juniors see WHY vague specs produce flat code by watching the gate respond.

Candidate feature examples (pick one per progression):
- A data import pipeline — surfaces format variability, partial failures, idempotency
- A user-facing form — surfaces validation, error states, accessibility
- An API endpoint with auth — surfaces authorization, rate limits, failure modes
- A batch job — surfaces resumability, observability, scheduling
- A state machine — surfaces invariants, illegal transitions, persistence

This also fixes the current `example/` gap — reframed as pedagogy rather than one worked example.

### 3. Pair-review ritual (workflow doc, not code)

A new `docs/PAIR_REVIEW.md` codifying a junior-to-junior review protocol:
- Two juniors review each other's PRs.
- Both have Claude Code open.
- Structured prompt template: "ask your agent to identify what a senior reviewer would catch, then review the PR with that list in hand."
- Findings feed back into the spec, not just the code — matching project-dna's human-stays-at-spec philosophy.

Infrastructure-free — no tooling, no dashboards. Just a one-page protocol that makes peer review muscle-building rather than senior-bottlenecked.

## Anti-Scope (What We're NOT Building)

- **Team dashboards.** GitHub PR status already shows who's on what. Custom tooling here is yak-shaving.
- **Project tracker.** Existing handoff docs + `specs/NNN-feature/` directories already surface in-flight work.
- **Coordination tooling** (standup bots, sprint boards). Slack + verbal syncs do this fine. project-dna's job is agent discipline, not team PM.
- **Custom IDE integrations.** Claude Code IS the IDE layer.
- **LLM-of-LLMs orchestrators.** `/dna-delegate` already scopes sub-agents. Meta-orchestration over-engineers the current pain points.

**The rule**: every piece of scaffolding is more surface juniors must absorb before being productive. AGENT.md is already 170 lines. Additions must earn their place by solving a specific, observed pain — not by closing hypothetical gaps.

## Open Questions

1. **Packaging**: does the junior pack live in project-dna (as additional docs + skills), or as a separate `project-dna-team-pack` repo that imports project-dna as the foundation? *Leaning*: keep project-dna as methodology, add team pack as an overlay.

2. **Onboarding depth**: what's the minimum reading a junior must do before Day 1 shipping? Current floor is CLAUDE.md + CONSTITUTION.md (~270 lines combined). Too much? Needs a "Day 1" quick-start.

3. **The senior's role on a mostly-junior team**: who customizes Article 10? Who writes VISION.md? Does the team need a `docs/HOW_TO_SENIOR.md` explaining what the senior DOES when the agents handle execution?

4. **Measuring transformation**: how do we know a junior has become senior? What's the filmable success criterion? (Per Article 3, every vision needs one.) Candidate: *"After 6 months, the junior specs a feature the agent produces with zero `/dna-verify` divergences."*

5. **Anti-cargo-cult protection**: what prevents a team from adopting project-dna mechanically — running all the skills without absorbing the why? The constitution says "every rule exists because its absence caused a specific failure" — but do juniors see those failure stories? Needs explicit failure-mode documentation.

## Suggested Next Step

Before building any of the three priorities above, **prototype `/dna-review` as a skill file with no production use yet**. Run it against a real PR from an existing project and see whether its output feels like senior review. If yes: flesh it out, add to `template/skills/`, document in AGENT.md's workflow table. If no: iterate on the checks list before expanding.

Same pattern as the other DNA skills — small file, sharp focus, zero-trust enforcement — so it fits the existing architecture naturally.

## When to Revisit This Document

- After every real team adoption (write a field notes entry first, then update this).
- Every quarter, even absent field notes, to re-evaluate priorities against current pain.
- Whenever a skill or doc is added or changed, check if it moves closer to or further from the North Star.

---

*This roadmap is aspirational and subject to change. The only non-negotiable is the North Star. Everything else is iteration space.*
