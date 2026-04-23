# Spec-Kit version pinning

The kit pins a specific Spec-Kit tag rather than tracking `latest`. Reproducibility of unfolds is more valuable than freshness — when Spec-Kit renames a flag or changes init behavior, the kit should handle that migration in one deliberate bump, not let every user's unfold silently break on the day a breaking change ships.

## Current pin

| Field | Value |
|---|---|
| Pinned tag | `v0.8.0` |
| Last verified | 2026-04-23 |
| Verified against | `template/AGENT.md`, `adapters/cursor/payload/CURSOR.md` |
| Install command | `uv tool install specify-cli --force --from "git+https://github.com/github/spec-kit.git@v0.8.0"` |

## Flag contract at v0.8.0

These are the flags used by the kit's canonical `specify init` invocation. A bump that renames any of them is a breaking change; update this table and bump the pin in the same commit.

| Flag | Purpose | Kit usage |
|---|---|---|
| `--integration claude` | Installs Claude Code AI assistant files (`.claude/`) | Claude Code unfold |
| `--integration cursor-agent` | Installs Cursor AI assistant files (`.cursor/`) | Cursor unfold |
| `--script sh` \| `--script ps` | Which shell script suite to install (bash/pwsh) | Prevents interactive prompt that blocks agents |
| `--no-git` | Skip Spec-Kit's internal `git init` | Kit's own git init runs at Protocol A step 9 |
| `--force` | Allow init into a non-empty directory | Kit payload has already been copied before this step |
| `--offline` | Use bundled assets, skip GitHub download | Avoids network + proxy issues |
| `--here` or `.` (arg) | Initialize in current directory | Target is already the working directory |

`--integration <name>` is mutually exclusive with `--ai <name>`. Both accept the same integration names (run `specify init --help` for the full list at the pinned version). The kit consistently uses `--integration`.

**Cursor gotcha**: the integration name is `cursor-agent`, not `cursor`. `--integration cursor` errors with "Unknown integration: 'cursor'". Every `CURSOR.md` / `README.md` reference must say `cursor-agent`.

## Bump procedure

When a new Spec-Kit tag ships and you want to adopt it:

1. Install the candidate version locally:
   ```
   uv tool install specify-cli --force --from "git+https://github.com/github/spec-kit.git@vX.Y.Z"
   ```
2. Test the canonical invocations in a throwaway directory:
   ```
   mkdir -p /tmp/speckit-test-claude && cd /tmp/speckit-test-claude
   PYTHONIOENCODING=utf-8 specify init . --integration claude --script sh --force --offline --no-git
   ```
   Verify: `.claude/` exists, `.specify/` exists with populated `scripts/`.
3. Same for Cursor:
   ```
   mkdir -p /tmp/speckit-test-cursor && cd /tmp/speckit-test-cursor
   PYTHONIOENCODING=utf-8 specify init . --integration cursor-agent --script sh --force --offline --no-git
   ```
   Verify: `.cursor/` exists, `.specify/` exists.
4. If any flag has been renamed or removed, update the Flag Contract table above AND every occurrence in:
   - `template/AGENT.md`
   - `adapters/cursor/payload/CURSOR.md`
   - `CLAUDE.md` (kit root, Protocol A)
   - `adapters/cursor/README.md`
5. Update the pinned version in three places (to match):
   - `template/AGENT.md` — `SPECIFY_VERSION=vX.Y.Z`
   - `adapters/cursor/payload/CURSOR.md` — `SPECIFY_VERSION=vX.Y.Z`
   - This doc — "Current pin" table
6. Update the "Last verified" date in this doc.
7. Run `tools/refresh-target.sh` (dry-run first) against any known target project to confirm the refresh propagates correctly.
8. Commit with message `chore(spec-kit): bump to vX.Y.Z`. Include any flag-contract changes in the commit body.

## Why not track `latest`

A kit is a seed. Seeds ship reproducibly. If the kit installs whatever Spec-Kit tag is latest when the target is bootstrapped, then two teams onboarding on different days get different tooling. When Spec-Kit introduces a breaking change (as happens with all actively developed tools), every unfold that day silently breaks. A pinned tag turns this into one deliberate migration event handled by the kit maintainer.

## Why not vendor Spec-Kit

The kit's zero-infrastructure philosophy (`CLAUDE.md` §Philosophy) forbids bundling external tools. Spec-Kit is the engine, maintained by GitHub. The kit installs it on demand at the pinned version.

## History

| Date | Pinned to | Changed by | Reason |
|---|---|---|---|
| 2026-04-23 | v0.8.0 | Session 8 productization sprint | Initial pin (prior state was dynamic-latest via `LATEST=$(git ls-remote...)` substitution, which fails under PowerShell and breaks silently on Spec-Kit breaking changes). Paired with the correction of `--integration cursor` → `--integration cursor-agent` after verification against the real CLI. |
