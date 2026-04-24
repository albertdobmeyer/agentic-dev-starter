# SKIP defaults

> When the team lead says *"just unfold it, use defaults, I'll fill details later"* during Protocol A step 1, the agent uses the defaults in this file instead of running the full interview. Every default is opinionated. a reasonable starting point for the most common kit user (a small Node/TypeScript team building a web app or API), **not a commitment**. Review and edit each default before the first `/speckit-specify`.

This file is copied into every SKIP-unfolded target at project root so the lead can see what was assumed. Every assumption is machine-readable for `Protocol A-bis` (the promote-from-SKIP flow).

## Interview answers (Protocol A step 1)

| Field | Default | Rationale |
|---|---|---|
| Team size + tech-literacy | `3 devs mixed seniority (1 senior + 2 mid)` | Most common kit user profile from early adopters. |
| Primary tech stack | `Node.js 20 + TypeScript 5 + PostgreSQL 16` | Kit's internal examples + worked example use this stack. Easy to override one row at a time. |
| Primary framework | `Fastify 4.x` (API) / `Next.js 14` (web app) | Opinionated but widely-used. |
| Output type | `web app with REST API` | Covers 80% of kit users. Swap to `CLI`, `library`, `service` if different. |
| Quality risks | `test coverage decay / spec drift / context exhaustion / merge conflicts / onboarding gaps` | Maps cleanly to Articles 1, 2, 3, 5, 8. so generated Article 10 reflects them. |

Every field above is tagged `{DEFAULT: <value>. review before building}` in the downstream docs so Protocol A-bis can find them.

## Article 10 (CONSTITUTION.md). SKIP rules

When SKIP is used, Article 10 is written from these defaults with visible markers. Every rule has an HTML comment `<!-- SKIP-DEFAULT: review before building -->` so they're grep-targetable. Human-authored rules never get this tag.

| Rule | SKIP default | Where it's enforced |
|---|---|---|
| Test coverage threshold | `70%` line on `src/**` domain logic | `dna-verify/run.sh` reads this from CONSTITUTION.md |
| Language strictness | `TypeScript strict mode required; no implicit any; noUncheckedIndexedAccess on` | `tsc --noEmit` in CI + pre-commit |
| PR gate | `1 approver + DNA gates green + dna-verifier CONGRUENT` | `.github/workflows/dna.yml` + branch protection rule (team lead sets manually) |
| Session budget | `dna-context-check handoff at 80k tokens warn, 100k stop` | `dna-context-check/run.sh` |
| Commit convention | `Conventional commits (feat/fix/chore/docs/refactor/test)` | Pre-commit hook (optional; document) |
| Shared-code glob | `src/models/**, src/shared/**, src/lib/**`. requires shared-code PR to main before feature branches touch these files | `dna-cross-checker` subagent reads this |

Swap any row before `/speckit-specify`. The coverage threshold, strictness level, and shared-code glob are the three most project-specific; review them first.

## 7-doc Blueprint. SKIP fallback

When SKIP is used, all 6 `docs/NN-*.md` files are copied from `template/blueprint/*.skeleton.md` as-is (with `{FILL IN: ...}` markers preserved). The agent does NOT improvise content. The lead fills markers manually, or invokes Protocol A-bis to re-interview for the specific fields.

`docs/05-CONSTRUCTION-SITES.md` is always initialized empty regardless of mode.

## Graduation from SKIP

A project graduates from SKIP when:

1. Every `<!-- SKIP-DEFAULT -->` tag in `CONSTITUTION.md` is either removed (rule accepted as-is) or replaced with a human-authored rule.
2. Every `{FILL IN: ...}` marker in `docs/*.md` is resolved.
3. `dna-spec-auditor` returns CLEAR on the Blueprint.
4. `NEXT_STEPS.md` is deleted (signals graduation to the agent).

A fast path to graduation: say to the agent *"run the full interview now. promote this project from SKIP mode"* (Protocol A-bis). The agent reads the current `CONSTITUTION.md` and `docs/*.md`, diffs against this SKIP_DEFAULTS.md, and re-interviews only for fields still tagged `{DEFAULT}` or `SKIP-DEFAULT`. Never overwrites human edits to untagged fields.

## History

- 2026-04-23: Created. SPEC-03 shipped with 7-doc Blueprint alignment.
