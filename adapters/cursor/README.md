# Cursor adapter — STUB

> **Status**: Not implemented. This file is a seed for a future contributor to author the Cursor adapter.

## What this adapter needs to do

Map every role in `kernel/roles.md` to Cursor's conventions. As of 2026-04, Cursor uses:

- **`.cursor/rules/`** — markdown files with frontmatter, auto-loaded into context based on file-match globs. These are the rough equivalent of Claude Code skills.
- **Inline chat + composer agents** — Cursor doesn't yet have first-class subagent-definition files the way Claude Code does; role-separation is achieved by prompt engineering within a chat session.
- **Cursor's custom commands** — experimental / beta in some versions.

## Role mapping (TODO)

| Kernel role | Cursor mechanism | File / path |
|---|---|---|
| specifier | ? | TODO |
| planner | ? | TODO |
| test-gatekeeper | likely: `.cursor/rules/dna-test-gate.md` + the `run.sh` script (reused from claude-code adapter) | TODO |
| cross-checker | hard to isolate context; may need a separate composer session + rules | TODO |
| construction-logger | rule-file that fires on file changes in `src/` | TODO |
| verifier | requires isolated context; Cursor's "new chat" is the closest analog | TODO |

## Concrete work to do

1. Author `adapters/cursor/AGENT.md` equivalent — the primary instructions file. Cursor convention likely: `.cursor/CURSOR.md` or `.cursor/rules/core.md`.
2. Author Cursor-style rule files for each DNA skill. Each rule file references the corresponding `run.sh` script in `<kit-root>/template/skills/NAME/run.sh` (reusable verbatim).
3. Work out how to approximate role isolation for `verifier` and `pr-reviewer` — these need fresh context, which Cursor handles via "New Chat" button, not scripted subagent spawning.
4. Extend `CLAUDE.md` (kit root) Protocol A step 3 with a Cursor branch that detects the agent and copies this adapter's payload.
5. Dogfood on a real target.

## Contract

This stub becomes "Complete" when:
- All 10 core roles from `kernel/roles.md` have a mapped Cursor mechanism.
- A target unfolds via this adapter and passes the Bootstrap self-audit.
- At least one feature ships end-to-end with a retrospective filed.

Until then, Cursor users can read the kit's methodology and implement it manually, but the adapter-shaped automation does not yet exist.
