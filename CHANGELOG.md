# Changelog

All notable changes to this kit are documented here. Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) style. Versioning per [SemVer](https://semver.org/).

## [0.9.0] — 2026-04-23

First publishable release. Field-tested through three dogfood feature builds on the worked example ([team-project-scheduler-example](https://github.com/albertdobmeyer/team-project-scheduler-example)). Team-lead-evaluation-ready; known gaps listed below so adopters have honest expectations.

### Added

- **Cursor adapter** (`adapters/cursor/payload/`) — 12 `.cursor/rules/*.mdc` rule files + `CURSOR.md` primary instructions + 6 agent-agnostic `run.sh` scripts + copied blueprint + workflows. Role mapping 12/17 (parity with Claude Code adapter).
- **`npx tiged` delivery path** — 1-command install, ~260 KB payload, no git history:
  - `npx tiged albertdobmeyer/agentic-dev-starter/template <target>` (Claude Code)
  - `npx tiged albertdobmeyer/agentic-dev-starter/adapters/cursor/payload <target>` (Cursor)
- **`docs/SPEC_KIT_PINNING.md`** — pinned Spec-Kit version (v0.8.0), flag contract at the pinned version, bump procedure for future releases.
- **Test-location convention** in `03-EXECUTION-CONTEXT.skeleton.md` (SPEC-22) documenting `tests/scenario/scenario-N.test.ts` as the canonical scenario-reference anchor location + vitest include-glob guidance.
- **README hero** — license / works-with / engine / status badges + quick-start install block above the fold.
- **GitHub metadata** — repository description updated, 12 topic tags added, homepage URL set to the worked example.
- **Six merged features + three retrospectives** on the worked example repo, tagged v1.1 with Phase 2 closed (CS-002 RESOLVED).

### Changed

- **Spec-Kit invocation pinned** to `v0.8.0` with literal `SPECIFY_VERSION=` variable (was: dynamic-latest via bash `LATEST=$(git ls-remote ...)` substitution that silently failed under PowerShell).
- **Cursor integration flag corrected** from `--integration cursor` (errors with "Unknown integration") to `--integration cursor-agent` (verified against Spec-Kit v0.8.0).
- **README rewritten** pain-first: 5 failure modes named (PR review burden, merge conflicts, drift, flattening, one-shot vibe-coding) with the specific kit mechanism per pain. Spec-Kit named as "the engine"; agent-token-meter correctly positioned as dashboard companion.
- **CLAUDE.md Protocol A step 3** — now branches per adapter (template/ for Claude Code, adapters/cursor/payload/ for Cursor) + documents the tiged one-liner as primary path.
- **Tone scrub** — removed service-company branding ("AKD AUTOMATION SOLUTIONS") from user-facing docs. LICENSE copyright attribution kept (legitimate); legacy PROJECT_DNA.md reference kept (historical).

### Fixed

- **`--integration cursor` → `cursor-agent`** (4 locations: CURSOR.md step 4, CURSOR.md prose, adapters/cursor/README.md role-mapping table, misc references).
- **`LATEST=$(git ls-remote ...)`** pattern that fails silently under pwsh (replaced with literal `SPECIFY_VERSION`).
- **Orphan `src/ui/TaskCard.tsx`** in worked example (React JSX with no React dependency, never compiled, removed for cleanliness).

### Known gaps (deferred to next release)

- **SPEC-11c** — Cursor adapter has NOT been end-to-end dogfooded on a real Cursor feature. Payload was authored against the role contract and the Spec-Kit CLI surface was verified, but no feature has been built through the full 12-step workflow in Cursor. First Cursor adopters will be the validation cohort.
- **SPEC-02b** — `test/unfold-smoke.sh` harness not shipped. Manual smoke test during Spec-Kit bumps.
- **SPEC-11b** — Kit root `CLAUDE.md` Protocol A does not auto-detect Claude Code vs Cursor. Agent asks the human at step 3.
- **SPEC-03** — SKIP entry mode for fast-path unfolds without the full interview.
- **SPEC-20 / SPEC-21** — Ergonomic fixes from 2026-04-23 retrospective (test-gate heuristic tuning, convention-migration path for existing targets).

### Verified against

- Spec-Kit v0.8.0 (`specify --help`; manual smoke: `specify init . --integration claude` and `--integration cursor-agent` both produce the expected `.claude/` / `.cursor/` + `.specify/` trees).
- Three dogfood feature builds on the worked example (2026-04-22 `[W]`, 2026-04-23 `[D]` server, 2026-04-23 `[D]` client).
- Bias-firewall pattern: Pass-2 fresh-context verifier caught assertion gap Pass-1 missed (004 retrospective).
- Article-5 scope-deferral pattern: `dna-spec-validator` CLEAR + ADVISORY-01 on 005's partial delivery (005 retrospective).
- Phase-closure via Construction Site resolution: CS-002 closed at 006 merge (006 retrospective).

[0.9.0]: https://github.com/albertdobmeyer/agentic-dev-starter/releases/tag/v0.9.0
