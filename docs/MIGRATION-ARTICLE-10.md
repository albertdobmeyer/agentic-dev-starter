# Migration: add `shared-code-glob:` to existing targets (SPEC-17 / SPEC-21)

> For team leads whose project was bootstrapped before the kit added explicit `shared-code-glob:` to Article 10 (pre-SPEC-17, before `kit commit 6addca4`). Your target works today, but `dna-cross-checker` runs with reduced precision until you add the block.

## Symptoms you might be hitting

- `dna-cross-checker` emits `ADVISORY: NEEDS_CONSTITUTION_UPDATE - CONSTITUTION.md Article 10 lacks shared-code-glob: block`
- Merge conflicts on shared model/type/middleware files that the cross-checker didn't catch pre-spec
- Feature specs pass `dna-cross-checker` CLEAR but conflict at merge time

If none of these apply, you don't need to migrate. Protocol E refreshes pull in kit updates for the enforcement scripts + subagents but deliberately don't touch `CONSTITUTION.md` (Article 10 is project-authored; the kit refuses to overwrite it).

## What to add

Append to your project's `CONSTITUTION.md` Article 10, inside the Project-DNA defaults section:

```markdown
- **Shared-code glob** (consumed by `dna:cross-checker`; a file matching any pattern below is shared-code; changes to it must PR to main first before feature-branch adoption). Customize this list for your project:
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
```

The kit's current `template/CONSTITUTION.md` Article 10 has this block at lines 101-112; you can copy directly from there. Adjust the globs to match your project's actual shared-code layout.

## After adding

1. Run `cp CONSTITUTION.md .specify/memory/constitution.md` to sync Spec-Kit's copy.
2. Commit with message `chore: migrate Article 10 to explicit shared-code-glob (SPEC-17)`.
3. Run `@dna-cross-checker` on your next feature; the ADVISORY should be gone.

## Why the kit doesn't auto-migrate

Article 10 is per-project. A one-size-fits-all glob would be wrong for your project's shared-code layout (the kit's defaults are Node/TypeScript-flavored; a Python or Go project has different shared-code conventions). Protocol E (`tools/refresh-target.sh`) deliberately preserves `CONSTITUTION.md` to protect your customizations; that same policy means it won't push this block in automatically.

## What if I don't want to migrate

That's fine. `dna-cross-checker` degrades to a default heuristic (treats all of `src/models/**` as shared) when Article 10 lacks the block. You'll see the ADVISORY on every run. The migration is a polish move, not a correctness requirement.

## History

- 2026-04-23: Migration doc created as part of SPEC-21 (Session 8). Block was introduced by SPEC-17 (kit commit `6addca4`, 2026-04-21) but only applies to unfolds AFTER that commit; this doc bridges the gap for earlier targets.
