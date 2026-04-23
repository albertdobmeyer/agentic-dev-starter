# Feature Specification: Missing Depth Tag

**Feature Branch**: `test-fail-no-depth-tag`

This spec deliberately omits any [D]/[W]/[E] tag. The depth-tag-presence check must catch this.

(Note: bare-bracket [W] in prose without backticks does not count as a depth declaration.)

## Files this feature will touch

- `src/models/task.ts` (SHARED)
