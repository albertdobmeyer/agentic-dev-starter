---
name: "dna-test-gate"
description: "Zero-trust pre-implementation gate. Verifies tests exist and fail before allowing implementation to proceed."
argument-hint: "Optional: specific phase or task ID to gate-check (e.g., 'Phase 3' or 'T012')"
compatibility: "Requires spec-kit project structure with tasks.md in the active feature spec directory"
metadata:
  author: "project-dna"
  source: "template/skills/dna-test-gate"
user-invocable: true
disable-model-invocation: false
---

## User Input

```text
$ARGUMENTS
```

## Purpose

This is a **zero-trust gate**. The agent MUST NOT implement production code until this gate passes. "Test-first" is not guidance — it is a structural requirement enforced by this skill.

This skill enforces CONSTITUTION.md Article 1: "Write the test BEFORE the implementation. No exceptions."

## Primary execution path — invoke the runnable script

Most projects can use the bundled bash script for the gate check. Run it first:

```bash
bash .claude/skills/dna-test-gate/run.sh
```

- Exit code `0` = gate **PASSED** — every implementation task has a test file that fails before implementation. Proceed to `/speckit-implement`.
- Exit code `1` = gate **FAILED** — tests missing or already-green. Fix per the script's output; do NOT implement.
- Exit code `2` = setup problem (no `tasks.md`, no test runner detected). Fall through to the manual checks below.

The script auto-detects feature directory (from branch name or `specs/` mtime), test runner (vitest, jest, mocha, pytest, go test), and infers test file paths from implementation file paths in each task's body.

Arguments: `bash run.sh specs/NNN-feature-name` (explicit directory) or `bash run.sh specs/NNN "T012"` (single task).

## Fallback — manual gate when the script can't run

If the script exits `2` (setup problem) or the project uses a test runner the script doesn't know about (rust, php, ruby, …), run the prose checks below. Your job is then to replicate the script's logic for the unsupported runner and escalate a PR to add that runner to `run.sh`.

## Pre-Execution (fallback path)

1. Run `.specify/scripts/powershell/check-prerequisites.ps1 -Json -RequireTasks -IncludeTasks` to locate FEATURE_DIR.
2. Read `tasks.md` from FEATURE_DIR.
3. Identify the **current phase** — the first phase with unchecked (`- [ ]`) tasks. If user input specifies a phase or task, use that instead.

## Gate Check

For every implementation task in the current phase, verify:

### Step 1: Test File Existence

For each implementation task (non-test task), determine the expected test file path:
- Implementation file `src/models/user.py` → test file `tests/test_user.py` or `tests/models/test_user.py`
- Implementation file `src/services/auth.ts` → test file `tests/services/auth.test.ts` or `src/services/__tests__/auth.test.ts`
- Use the project's test conventions from `plan.md` if available. If no convention is established, check for existing test files to infer the pattern.

**For each implementation task, report:**

```
| Task | Implementation File | Test File | Test Exists |
|------|--------------------|-----------|----|
| T012 | src/models/user.py | tests/test_user.py | YES / NO |
```

### Step 2: Test Failure Verification

For every test file that exists, run it and verify it **fails**:

```bash
# Detect test runner from project (pytest, jest, vitest, go test, etc.)
# Run ONLY the specific test file, not the full suite
```

A test that passes before implementation is either:
- **Trivial** — testing nothing meaningful
- **Wrong** — not testing what the implementation task requires
- **Leftover** — from a previous implementation that already exists

**Report:**

```
| Test File | Status | Verdict |
|-----------|--------|---------|
| tests/test_user.py | FAILS (3 assertions) | PASS — ready for implementation |
| tests/test_auth.py | PASSES | BLOCKED — test passes before implementation, review test |
| tests/test_payment.py | MISSING | BLOCKED — write test first |
```

### Step 3: Gate Decision

**PASS** — All implementation tasks in the current phase have:
- A corresponding test file that exists
- That test file fails (proving it tests something the implementation must satisfy)

→ Output: "Test gate PASSED for Phase N. Proceed to /speckit-implement."

**FAIL** — One or more implementation tasks are missing tests or have tests that already pass.

→ Output: "Test gate FAILED. N tasks blocked. Write the following tests before proceeding:"
→ List each blocked task with the expected test file path and what it should assert.
→ **Do NOT proceed to implementation. Do NOT offer to skip.**

### Step 4: Post-Implementation Verification (if invoked after /speckit-implement)

If user invokes this skill after implementation:
- Run the full test suite for the current phase
- All tests that previously failed should now pass
- Any test still failing → report as incomplete implementation
- Any NEW test failures (regression) → report as critical

## Rules

- This gate cannot be bypassed. "Just implement it and we'll add tests later" violates Article 1.
- If the project has no test runner configured, this skill's FIRST action is to set one up based on the tech stack in `plan.md` or `ARCHITECTURE.md`.
- If user argues against testing a specific task, they must explicitly log it as an Article 5 simplification with rationale.
