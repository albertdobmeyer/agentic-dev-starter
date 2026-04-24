# Amp adapter. STUB

> **Status**: Not implemented. This file is a seed for a future contributor to author the Amp adapter.

## What this adapter needs to do

Map every role in `kernel/roles.md` to [Amp](https://ampcode.com) (Sourcegraph's coding agent) conventions. Key Amp primitives as of 2026-04:

- **`AGENT.md`**. primary instructions file; already a cross-agent convention Amp supports.
- **Agent commands / custom tools**. Amp's extensibility surface.
- **Thread isolation**. Amp spawns new threads for sub-work, which is a natural fit for the `verifier` role (fresh context).

## Role mapping (TODO)

| Kernel role | Amp mechanism | File / path |
|---|---|---|
| specifier | likely via Spec-Kit integration if available; else prompt pattern in AGENT.md | TODO |
| test-gatekeeper | Amp custom tool invoking the reusable `run.sh` | TODO |
| verifier | **natural fit**. Amp's thread spawning gives fresh context by default | TODO |
| construction-logger | custom tool + rule for detecting depth-downgrade intent | TODO |

## Concrete work to do

1. Author `adapters/amp/AGENT.md`. Amp-flavored primary instructions.
2. Map each DNA skill's `SKILL.md` to Amp's tool/command convention.
3. Reuse the `run.sh` scripts verbatim from `template/skills/*/run.sh`.
4. Verify thread-isolation semantics for `verifier` role. does a new Amp thread have zero carryover? If yes, that's our audit-isolation mechanism.
5. Extend kit root `CLAUDE.md` Protocol A to detect Amp and copy this adapter's payload.
6. Dogfood on a real target.

## Contract

Same as other adapters. role mapping complete, payload shipped, target unfolded, feature shipped, retrospective filed. Until then, manual methodology adoption is the fallback.

## Note. `AGENT.md` is agent-neutral in principle but `template/AGENT.md` is Claude-flavored

The current `template/AGENT.md` file in the kit uses `AGENT.md` as a filename (good. cross-agent convention) but its body assumes Claude Code idioms (skills, `.claude/`, `--integration claude`). This adapter's equivalent would strip those Claude-specific bits and substitute Amp equivalents.
