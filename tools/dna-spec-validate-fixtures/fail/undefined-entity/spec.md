# Feature Specification: Undefined Entity Reference

**Feature Branch**: `test-fail-undefined-entity`

## Depth

`[W]`

## Notes

This feature reads Foobar.something, where Foobar is not declared as an interface in the dogfood Blueprint (only Project, Task, User exist).

## Files this feature will touch

- `src/models/task.ts` (SHARED)
