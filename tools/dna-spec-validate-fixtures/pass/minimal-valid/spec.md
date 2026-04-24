# Feature Specification: Minimal Valid Spec (Pass Fixture)

**Feature Branch**: `test-pass-minimal-valid`

## Depth

`[W]`. pure validator function.

## Files this feature will touch

- `src/models/task.ts` (SHARED. adds a helper)
- `src/models/task.test.ts` (new. unit tests)

## Scenarios touched

- `Scenario 1` is the load-bearing scenario this feature supports.
- Phase 1 done-criterion in `docs/04-COORDINATION-HINTS.md`.

## Notes

The spec touches `Task.status`. The `Task` interface lives in `docs/01-SYSTEM-INTENT.md`. No drift from Principle 1.
