<!-- Thanks for contributing to agentic-dev-starter. This template mirrors the kit's own methodology: specs, citations, scope-boundaries. Fill what applies. -->

## What this PR changes

<!-- One paragraph. What's different after merge. -->

## Which SPEC or issue does it address

- Fixes #
- Implements `.exploration/specs/SPEC-XX-name.md` (if applicable)

## Scope

- [ ] Kit methodology / kernel (affects every future unfold)
- [ ] Adapter (Claude Code / Cursor / other — specify)
- [ ] Enforcement script (`template/skills/*/run.sh` or `.cursor/scripts/*`)
- [ ] Subagent prompt / rule (`template/agents/*` or `.cursor/rules/*.mdc`)
- [ ] Blueprint skeleton (`template/blueprint/*`)
- [ ] Documentation only
- [ ] Worked example repo update

## Files touched

<!-- `Files this PR touches` block — matches the kit's cross-checker convention. -->

-

## Adapter sync

- [ ] Claude Code and Cursor adapters both updated (if the change affects shared mechanisms)
- [ ] N/A — adapter-specific change

## Tests / verification

<!-- How did you verify this works. If it's a script change, did you run it against the worked example repo? If it's a rule change, did you test the intended invocation? -->

- [ ] `tools/unfold-smoke.sh` passes (if the change touches Spec-Kit invocation)
- [ ] Manual verification described below
- [ ] N/A — docs-only change

## Non-goals

<!-- What this PR deliberately does NOT do. Anti-flattening for PRs: name what's out of scope so future contributors don't expand scope unilaterally. -->

-

## Breaking changes

<!-- If this changes a flag, renames a file, or alters Protocol A semantics, say so. Document the migration path. -->

- [ ] No breaking changes
- [ ] Breaking; migration documented in `docs/MIGRATION-*.md` or CHANGELOG

## Follow-ups

<!-- Out-of-scope ideas this PR surfaced. A good PR often leaves breadcrumbs for the next one. -->

-
