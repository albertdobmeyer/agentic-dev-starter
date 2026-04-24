---
name: "dna-spec-validate"
description: "Spec ↔ Blueprint validator. Catches drift between per-feature specs/NNN-*/spec.md files and the target's 7-doc Blueprint."
argument-hint: "Optional: feature directory path (e.g., 'specs/004-task-status'). Defaults to current branch's spec dir."
compatibility: "Requires the 7-doc Blueprint Package (docs/00-CORE-PRINCIPLES.md through docs/05-CONSTRUCTION-SITES.md) plus CONSTITUTION.md. Pre-condition: dna:spec-auditor has reported CLEAR."
metadata:
  author: "project-dna"
  source: "template/skills/dna-spec-validate"
user-invocable: true
disable-model-invocation: false
---

## User Input

```text
$ARGUMENTS
```

## Purpose

The kit audits the **Blueprint** (via `dna:spec-auditor`) and the **implementation** (via `dna-verify` + `dna:verifier`). It does NOT audit the layer in between: per-feature `specs/NNN-feature/spec.md` files that translate Blueprint scenarios into testable contracts.

When the spec drifts from the Blueprint. wrong depth claim, file path outside any module, undefined scenario reference, sentence violating a "never has to do" assertion. the build proceeds on a false contract. Tests pass. The implementation ships. The user experience is wrong.

This skill closes that gap. Run after `/speckit-tasks` (or as early as `/speckit-specify` if plan/tasks aren't authored yet), before `/dna-test-gate`.

## Execution. two layers

The validation has a mechanical floor and a judgmental ceiling. Run them in order. Same pattern as `/dna-verify`.

### Layer 1. mechanical floor (script)

```bash
bash .claude/skills/dna-spec-validate/run.sh                     # auto-detect feature dir
bash .claude/skills/dna-spec-validate/run.sh specs/004-task      # explicit
bash .claude/skills/dna-spec-validate/run.sh --mode blocking     # enforce (default; advisory currently)
bash .claude/skills/dna-spec-validate/run.sh --mode advisory     # warn-only
bash .claude/skills/dna-spec-validate/run.sh --help              # docstring
```

Checks (mechanical, deterministic regex):
- **Depth tag matches scenario**. spec.md's declared depth (`[D]` / `[W]` / `[E]`) matches the cited Scenario's depth in `01-SYSTEM-INTENT.md`.
- **File paths inside modules**. every `src/...` path under `## Files this feature will touch` falls within a module declared in `02-ARCHITECTURE.md`'s `## Module paths` block. Exempt: `tools/**`, `tests/**`, `docs/**`, `scripts/**`, `.specify/**`, `.github/**`.
- **Principle / Scenario / Phase / entity references resolve**. every `Principle N`, `Scenario N`, `Phase N`, and entity-name reference in spec.md exists in the corresponding Blueprint doc.
- **Doc line citations exist**. cited `docs/NN-X.md:line` line refs point at lines that exist and look like the expected pattern.
- **Cross-spec ownership**. across all OPEN specs (filtered via `git branch --merged main`), no two specs claim write access to the same path without `(SHARED)`.

Exit codes:
- `0` PASS → mechanical floor met. Proceed to Layer 2.
- `1` FAIL → at least one blocking finding (in `blocking` mode). Fix before invoking the subagent.
- `2` SETUP → no spec.md, no Blueprint, no feature directory.

Mode toggle: `--mode {blocking|advisory}` CLI flag overrides `DNA_SPEC_VALIDATE_MODE` env var. Default: `advisory` for SPEC-19 Stages 1-2; flips to `blocking` once Stage 3 ships and the dogfood passes cleanly. CI (template/workflows/dna.yml) uses `blocking`.

### Layer 2. judgmental ceiling (subagent)

Invoke the `dna:spec-validator` subagent (lands in SPEC-19 Stage 4). It starts with **zero carryover from the build conversation** (PROJECT_DNA Section 4.3 audit-isolation principle), reads spec.md + Blueprint scenarios from disk, and detects semantic drift the script cannot see:

- **Negative-assertion violations**. spec language implying user must do something the cited scenario's "What they NEVER have to do" list forbids.
- **Non-goal violations**. spec describes work explicitly listed in `04-COORDINATION-HINTS.md` Non-goals.
- **Behavioral fidelity**. paraphrase OK; inversion / addition / omission of assertions = drift.
- **Production-threshold consistency**. spec for "deferred to v1.1" feature being treated as must-close.

Verdict: `CLEAR` / `WARN` / `BLOCK` with file:line refs.

## Pre-condition

This gate assumes `dna:spec-auditor` has reported CLEAR for the Blueprint. The auditor's report is an LLM artifact and not machine-readable; the script cannot programmatically verify it. Run the auditor first; if it returns BLOCK, do not run this gate. fix the Blueprint first, then re-run both.

## Relationship to other DNA gates

- `dna:spec-auditor` → Blueprint = source of truth, one-time at planning. Runs first.
- **`dna-spec-validate` (this gate) + `dna:spec-validator` subagent** → spec.md = projection, recurring per feature. Runs after `dna:spec-auditor` is CLEAR.
- `dna:cross-checker` → cross-feature file-touching coordination. The cross-spec ownership check in this gate borrows its `git branch --merged main` filter (SPEC-18) and `(SHARED)` marker convention.
- `dna-test-gate` → tests exist and fail before implementation. Runs after this gate is CLEAR.
- `dna-verify` + `dna:verifier` → implementation matches scenario contract, post-impl. The bookend partner of this gate.

## Workflow position

Insert as **step 4.5** in `kernel/methodology.md` (between `/speckit-specify equivalent` and `verify test floor`).

## Stage status (SPEC-19)

This file ships in Stage 1 with all checks **stubbed** (always-pass) so the chassis can be reviewed independently. Stage 2 implements reference-resolution checks; Stage 3 implements depth-match + module-boundary + cross-spec-ownership and flips the default to `blocking`; Stage 4 ships the `dna:spec-validator` subagent; Stage 5 wires CI. See `.exploration/specs/SPEC-19-spec-blueprint-validator.md` for the full plan.
