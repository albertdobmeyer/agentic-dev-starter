# Adapters

> Each adapter maps the agent-agnostic kernel (`kernel/`) to one specific agent's conventions. The kit ships with a Claude-Code adapter today; stubs exist for Cursor, Amp, Codex.

## Available adapters

| Adapter | Status | Maps roles via | Source of payload |
|---|---|---|---|
| `claude-code/` | **Complete — reference adapter** | `.claude/skills/` + `.claude/agents/` + slash commands | `template/` at kit root (payload copied into target during Protocol A) |
| `cursor/` | **Stub — not implemented** | TBD | TBD |
| `amp/` | Stub | TBD | TBD |
| `codex/` | Stub | TBD | TBD |

## Adapter contract

An adapter is complete when:

1. Every role in `kernel/roles.md` has a mapping documented in the adapter's `README.md`.
2. The adapter ships a payload (equivalent of `template/`) that Protocol A can copy into a target.
3. The primary agent-instructions file (equivalent of `template/AGENT.md`) executes the 12-step workflow in `kernel/methodology.md` §"The workflow".
4. At least one target project has been unfolded with the adapter and passed the Bootstrap self-audit.

## Writing a new adapter

### Step 1 — Read the kernel

Read `kernel/README.md`, `kernel/methodology.md`, `kernel/roles.md`, `kernel/vocabulary.md` end to end. The vocabulary is fixed; the roles are fixed; the methodology invariants are fixed. Everything else is adapter freedom.

### Step 2 — Map the roles

In your adapter's `README.md`, fill in the role-mapping table (see `claude-code/README.md` for the reference). Every role gets a concrete mechanism: "in this adapter, the `verifier` role is implemented as `<path to agent file / configuration / skill>`."

### Step 3 — Author the payload

Create a directory that Protocol A can copy into a target project. Mirror `template/` but for your agent's conventions:
- Primary instruction file (equivalent of `template/AGENT.md`)
- Skill definitions (if your agent has skills)
- Subagent definitions (if your agent has subagents)
- The Blueprint skeletons from `template/blueprint/` — these are agent-agnostic; reuse verbatim
- The scripts from `template/skills/*/run.sh` — these are agent-agnostic bash; reuse verbatim

### Step 4 — Update Protocol A

In the kit's root `CLAUDE.md`, Protocol A step 3, add a branch that detects your agent and copies the right adapter's payload. The kit should always detect at bootstrap time, not require the team lead to configure.

### Step 5 — Dogfood

Unfold a real target with your adapter. Ship at least one feature end-to-end through the workflow. File a retrospective in your target's `specs/NNN-*/retrospective.md`. Run `tools/aggregate-retros.sh` across your adapter's targets and add the corpus to `docs/FIELD_NOTES.md` — this is how the adapter earns its "Complete" status in the table above.

## Why not just fork Claude-Code-flavored files

You could. But:
- Every future methodology change (new role, new invariant) would then require N forks to update in lockstep.
- Adapter contributors would have to reverse-engineer which parts are Claude-specific vs universal.

With kernel + adapter split, methodology evolves in one place (`kernel/`) and adapter changes are bounded to one directory. Contributors know exactly where their changes go.
