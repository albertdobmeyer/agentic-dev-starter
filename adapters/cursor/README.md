# Cursor adapter

> **Status**: In progress (SPEC-11 complete — payload authored 2026-04-23). Deferred to SPEC-11b: Protocol A auto-detection of Cursor vs Claude Code. Deferred to SPEC-11c: end-to-end dogfood on a Cursor-hosted target.

## What this adapter provides

A complete payload for unfolding the agentic-dev-starter methodology into a Cursor-hosted project. Every role in `kernel/roles.md` is mapped to a Cursor mechanism; every DNA skill/subagent has a corresponding `.cursor/rules/*.mdc` rule file that invokes the agent-agnostic `run.sh` script or contains a judgment prompt for fresh-chat execution.

## Payload location

`adapters/cursor/payload/`:

```
payload/
├── CURSOR.md                                ← primary instructions (copied to <target>/CURSOR.md)
├── CONSTITUTION.md                          ← copied from template/ (agent-agnostic, Article 10 customized during Bootstrap)
├── .cursor/
│   ├── rules/
│   │   ├── methodology-core.mdc             ← alwaysApply: true — invariants + workflow + pushback template
│   │   ├── dna-test-gate.mdc
│   │   ├── dna-verify.mdc
│   │   ├── dna-decompose.mdc
│   │   ├── dna-delegate.mdc
│   │   ├── dna-context-check.mdc
│   │   ├── dna-spec-validate.mdc
│   │   ├── dna-cross-checker.mdc            ← [New Chat] judgmental
│   │   ├── dna-spec-auditor.mdc             ← [New Chat] judgmental
│   │   ├── dna-spec-validator.mdc           ← [New Chat] judgmental
│   │   ├── dna-verifier.mdc                 ← [New Chat] judgmental
│   │   └── dna-construction-logger.mdc
│   └── scripts/
│       ├── dna-test-gate/run.sh             ← agent-agnostic bash, copied from template/
│       ├── dna-verify/run.sh
│       ├── dna-decompose/run.sh
│       ├── dna-delegate/run.sh
│       ├── dna-context-check/run.sh
│       └── dna-spec-validate/run.sh
├── blueprint/                               ← agent-agnostic skeletons, copied from template/
│   ├── 00-CORE-PRINCIPLES.skeleton.md
│   ├── 01-SYSTEM-INTENT.skeleton.md
│   ├── 02-ARCHITECTURE.skeleton.md
│   ├── 03-EXECUTION-CONTEXT.skeleton.md
│   ├── 04-COORDINATION-HINTS.skeleton.md
│   ├── 05-CONSTRUCTION-SITES.skeleton.md
│   └── RETROSPECTIVE.skeleton.md
└── workflows/
    └── dna.yml                              ← agent-agnostic CI (copied from template/)
```

## Role mapping

| Kernel role | Cursor mechanism | File / path |
|---|---|---|
| specifier | Spec-Kit slash command | `/speckit-specify` (installed via `specify init --integration cursor` during Bootstrap) |
| planner | Spec-Kit slash command | `/speckit-plan` |
| tasker | Spec-Kit slash command | `/speckit-tasks` |
| implementer | Cursor Composer (one file per focused prompt) | no dedicated file; Composer dispatched per task |
| test-gatekeeper | `.mdc` rule + `run.sh` | `.cursor/rules/dna-test-gate.mdc` + `.cursor/scripts/dna-test-gate/run.sh` |
| cross-checker | `.mdc` rule [New Chat] | `.cursor/rules/dna-cross-checker.mdc` — contains judgmental prompt; human clicks "New Chat" for isolation |
| decomposer | `.mdc` rule + `run.sh` | `.cursor/rules/dna-decompose.mdc` + `.cursor/scripts/dna-decompose/run.sh` |
| delegate-dispatcher | `.mdc` rule + `run.sh` | `.cursor/rules/dna-delegate.mdc` + `.cursor/scripts/dna-delegate/run.sh` |
| construction-logger | `.mdc` rule | `.cursor/rules/dna-construction-logger.mdc` |
| verifier (mechanical) | `.mdc` rule + `run.sh` | `.cursor/rules/dna-verify.mdc` + `.cursor/scripts/dna-verify/run.sh` |
| verifier (judgmental) | `.mdc` rule [New Chat] | `.cursor/rules/dna-verifier.mdc` — fresh-chat prompt |
| spec-auditor | `.mdc` rule [New Chat] | `.cursor/rules/dna-spec-auditor.mdc` |
| spec-validate (mechanical) | `.mdc` rule + `run.sh` | `.cursor/rules/dna-spec-validate.mdc` + `.cursor/scripts/dna-spec-validate/run.sh` |
| spec-validator (judgmental) | `.mdc` rule [New Chat] | `.cursor/rules/dna-spec-validator.mdc` |
| context-guardian | `.mdc` rule + `run.sh` | `.cursor/rules/dna-context-check.mdc` + `.cursor/scripts/dna-context-check/run.sh` |
| architecture-impact | (not yet dedicated; main chat produces during spec phase) | deferred — same as Claude Code adapter |
| coherence-gate | (not yet dedicated) | deferred |
| drift-remediator | (not yet dedicated) | deferred |
| pr-reviewer | (not yet dedicated; future `.mdc` rule [New Chat]) | deferred |
| kit-graduate | (not yet built) | deferred |

**12 of 17 roles have dedicated implementations** — parity with the Claude Code adapter.

## How this differs from the Claude Code adapter

| Concern | Claude Code | Cursor |
|---|---|---|
| Primary instructions file | `template/AGENT.md` → `<target>/CLAUDE.md` | `adapters/cursor/payload/CURSOR.md` → `<target>/CURSOR.md` |
| Skills convention | `.claude/skills/NAME/SKILL.md` | `.cursor/rules/NAME.mdc` |
| Subagents convention | `.claude/agents/NAME.md` (scriptable dispatch) | `.cursor/rules/NAME.mdc` tagged `[New Chat]` (human-triggered isolation) |
| Invocation | Slash commands + Agent tool | `@rule-name` mentions + auto-attach on globs + Composer for edits |
| Role isolation | Scriptable subagent spawn | Human clicks "New Chat" before invoking isolation-required rules |
| Model references | `sonnet`/`opus` frontmatter in subagents | No model pin — Cursor's user-selected model |
| CI workflow | `.github/workflows/dna.yml` | `.github/workflows/dna.yml` (identical — scripts are agent-agnostic) |

## Known limitations

- **Role isolation is human-triggered, not scriptable.** The judgmental roles (verifier, spec-validator, spec-auditor, cross-checker) rely on the human clicking "New Chat" before invoking them. A future Cursor API or convention could automate this; for now, discipline is the enforcement.
- **No dedicated pr-reviewer yet.** Shared with Claude Code adapter; deferred to a future SPEC.
- **Protocol A does not yet auto-detect Cursor.** The kit's root `CLAUDE.md` Protocol A step 3 copies `template/*` unconditionally. For Cursor users today, the flow is:
  1. `npx tiged albertdobmeyer/agentic-dev-starter/adapters/cursor/payload my-project` (or equivalent subpath copy)
  2. Open Cursor in `my-project/`, say "Read CURSOR.md — I'm setting up a new project"
  3. Agent runs the Bootstrap flow described in `CURSOR.md`
  SPEC-11b will add agent detection to Protocol A so Cursor users can use the same kit-root CLAUDE.md invocation.

## Delivery paths

**Recommended**: `npx tiged albertdobmeyer/agentic-dev-starter/adapters/cursor/payload my-new-project`

Alternative: clone the kit and copy the payload manually:
```bash
git clone https://github.com/albertdobmeyer/agentic-dev-starter.git
cp -r agentic-dev-starter/adapters/cursor/payload my-new-project
cd my-new-project
cursor .   # or open Cursor → Open Folder
```

## Refresh

When the kit publishes updates, run from the kit root:
```
bash tools/refresh-target.sh <target-path>
```

Refresh currently syncs `template/*` → `<target>/.claude/`. A future SPEC will extend refresh to detect Cursor targets and sync `adapters/cursor/payload/` → `<target>/.cursor/`.

## Dogfooding status

This adapter has NOT been end-to-end dogfooded on a Cursor-hosted project. SPEC-11c covers that validation. The payload is authored against the same contract as the Claude Code adapter (which has 3 dogfoods on record) + the role taxonomy in `kernel/roles.md`.

If you're a Cursor user adopting this — we want your retrospective. Open an issue on the kit repo with any friction you hit.

## Contract for "complete"

Matches the adapter contract in `adapters/README.md`:
- [x] Every role in `kernel/roles.md` (core 10 + applicable supplementary) has a Cursor mechanism assigned
- [x] Ships a payload that can be copied into a target
- [x] Primary instructions file (`CURSOR.md`) executes the 12-step workflow
- [ ] At least one Cursor-hosted target unfolded + passed Bootstrap self-audit (SPEC-11c)
- [ ] At least one feature shipped end-to-end with a retrospective filed (SPEC-11c)

Two of four met. The adapter is usable today; rigor-of-evidence pending SPEC-11c.
