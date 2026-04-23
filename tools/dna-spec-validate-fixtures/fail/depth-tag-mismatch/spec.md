# Feature Specification: Depth Tag Mismatch (Spec Claims More Than Blueprint)

**Feature Branch**: `test-fail-depth-tag-mismatch`

## Depth

- `[D]` — this spec claims integration depth.

## Notes

This feature serves Scenario 3 — but Scenario 3 is classified `[W]` in the Blueprint (single-component badge rendering). Spec claiming `[D]` exceeds Blueprint's classification. Validator must BLOCK.

## Files this feature will touch

- `src/models/task.ts` (SHARED)
