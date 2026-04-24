---
name: "dna-verify"
description: "Post-implementation verification. Checks whether what was built actually matches what was specced."
argument-hint: "Optional: specific user story or phase to verify (e.g., 'US1' or 'Phase 3')"
compatibility: "Requires spec-kit project structure with spec.md and tasks.md in the active feature spec directory"
metadata:
  author: "project-dna"
  source: "template/skills/dna-verify"
user-invocable: true
disable-model-invocation: false
---

## User Input

```text
$ARGUMENTS
```

## Purpose

The true cost of agentic coding is verification. confirming that what was built is congruent with what was planned. Tests passing is necessary but not sufficient. This skill closes the gap between "agent says it's done" and "it actually matches the spec."

This is the post-implementation counterpart to `/dna-test-gate` (pre-implementation). Together they bookend every implementation phase:
- `/dna-test-gate` → tests exist and fail → implement → `/dna-verify` → outcomes match spec

The human reviews `/dna-verify` reports, not implementation code. If the report says CONGRUENT, the code is correct by definition. If DIVERGENT, the human refines the spec. they don't fix the code directly.

## Execution. two layers

The verification has a mechanical floor and a judgmental ceiling. Run them in order.

### Layer 1. mechanical floor (script)

```bash
bash .claude/skills/dna-verify/run.sh
```

Checks: test suite passes, coverage ≥ CONSTITUTION threshold, every `[D]` requirement in `docs/01-SYSTEM-INTENT.md` has ≥1 integration test, every Experience Fidelity Scenario has ≥1 referencing test.

- Exit `0` → mechanical floor met. Proceed to Layer 2.
- Exit `1` → floor not met. Fix before the subagent audit. The subagent cannot credibly audit fidelity on a broken test floor.
- Exit `2` → setup problem (no Blueprint, no tests dir).

### Layer 2. judgmental ceiling (subagent)

Invoke the `dna:verifier` subagent. It starts with **zero carryover from the build conversation** (PROJECT_DNA Section 4.3 audit-isolation principle), reads spec + code from disk, walks every Experience Fidelity Scenario against current code, and returns a verdict.

- `CONGRUENT` → ship / close phase.
- `PARTIAL` → escalate to architect; optionally log construction sites via `dna:construction-logger`.
- `DIVERGENT` → PHASE DOES NOT CLOSE. Every FAIL either gets implemented or logged as an architect-approved deferral in `docs/05-CONSTRUCTION-SITES.md`.

## Fallback (prose path. when neither layer runs)

If the project lacks a supported test runner AND the subagent is unavailable, the main agent replicates the scenario walkthrough manually using the structured steps below. This is a last resort. whenever possible, the subagent should do the walkthrough with fresh context to avoid builder-as-auditor bias.

## Pre-Execution

1. Run `.specify/scripts/powershell/check-prerequisites.ps1 -Json -RequireTasks -IncludeTasks` to locate FEATURE_DIR.
2. Read `spec.md` from FEATURE_DIR. the acceptance scenarios.
3. Read `tasks.md` from FEATURE_DIR. the task list.
4. Read `plan.md` from FEATURE_DIR. the technical plan.
5. Read `CONSTITUTION.md` from project root. the engineering contract.

## Verification Steps

### Step 1: Task Completion Check

Scan tasks.md for unchecked tasks:

```
| Phase | Total Tasks | Completed | Incomplete |
|-------|-------------|-----------|------------|
| Phase 1: Setup | 3 | 3 | 0 |
| Phase 3: US1 | 8 | 7 | 1 (T016) |
```

If any tasks are incomplete, report them and ask whether to proceed with partial verification or wait.

### Step 2: Test Suite Execution

Run the full test suite for the project (detect runner from project config):

```
| Test Suite | Tests | Passing | Failing | Skipped |
|------------|-------|---------|---------|---------|
| Unit | 24 | 24 | 0 | 0 |
| Integration | 8 | 7 | 1 | 0 |
| Contract | 5 | 5 | 0 | 0 |
```

Any failing tests → report as DIVERGENT immediately with the specific failure.

### Step 3: Spec Fidelity. Acceptance Scenario Walkthrough

For each acceptance scenario in spec.md (Given/When/Then):

1. **Trace** the scenario through the implementation. does the code path exist?
2. **Map** the scenario to tests. is there a test that directly verifies this scenario?
3. **Check depth**. is it tested at the right depth?
   - `[W]` requirements: unit test is sufficient
   - `[D]` requirements: MUST have an integration test that exercises multiple components together. A unit test alone is NOT sufficient for `[D]`.

```
| Scenario | Depth | Test Coverage | Depth Match | Verdict |
|----------|-------|---------------|-------------|---------|
| US1-S1: User creates account | [D] | test_auth_integration.py | Integration ✓ | PASS |
| US1-S2: User resets password | [W] | test_auth_unit.py | Unit ✓ | PASS |
| US2-S1: User views dashboard | [D] | test_dashboard_unit.py | Unit only ✗ | FAIL. [D] needs integration test |
```

### Step 4: Negative Assertion Audit

For every negative assertion in VISION.md ("user NEVER has to..."):

1. Check whether the assertion is encoded as a test
2. Check whether the implementation respects it

These are the first things that get silently dropped. If a negative assertion has no corresponding test, it is unverified and counts as DIVERGENT.

```
| Negative Assertion | Test Exists | Implementation Respects | Verdict |
|-------------------|-------------|------------------------|---------|
| Never manually visit each bookmark | test_auto_check.py | ✓ | PASS |
| Never lose original bookmarks | (none) | unclear | FAIL. unverified |
```

### Step 5: Simplification Audit (Article 5)

Search the codebase and conversation for logged simplifications:
- Check git log for `[SIMPLIFICATION]` or `[D]→[W]` markers
- Check for TODO/FIXME comments that indicate deferred work
- Compare original depth tags in spec.md vs what was actually delivered

Any unlogged downgrade is a silent flattening event. the most dangerous kind.

### Step 6: Verdict

**CONGRUENT**. All of:
- All tasks complete
- All tests pass
- Every acceptance scenario has a test at the correct depth
- Every negative assertion is verified
- All simplifications are logged

→ Output: "Verification CONGRUENT. Implementation matches spec. Ready for human review of this report."

**DIVERGENT**. Any of:
- Incomplete tasks
- Failing tests
- Acceptance scenarios without tests or at wrong depth
- Unverified negative assertions
- Unlogged simplifications

→ Output: "Verification DIVERGENT. N issues found."
→ List each divergence with:
  - What was specced
  - What was built (or not built)
  - Recommended action: fix implementation, add test, or refine spec

## After Verification

The human reviews this report. Their options:
1. **Accept**. divergences are acceptable, log as Article 5 simplifications
2. **Refine spec**. the spec was wrong or incomplete, update spec.md, re-run /speckit-tasks
3. **Fix implementation**. the code is wrong, go back to /speckit-implement for specific tasks
4. **Ship**. everything is congruent, merge the feature branch

The human decides at the architecture level. They do not debug code.
