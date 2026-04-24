# Claude Code adapter. reference implementation

> **Status**: Complete. This is the reference adapter; the kit's `template/` directory IS this adapter's payload.

## Role mapping

| Kernel role | Claude Code mechanism | File / path |
|---|---|---|
| specifier | slash command + main-agent execution | `/speckit-specify`. provided by Spec-Kit, installed via `specify init` during Bootstrap |
| planner | slash command | `/speckit-plan`. Spec-Kit |
| tasker | slash command | `/speckit-tasks`. Spec-Kit |
| implementer | main agent calls Agent tool with `subagent_type: general-purpose` scoped to one file | no dedicated subagent file; main agent dispatches |
| test-gatekeeper | skill with `run.sh` | `.claude/skills/dna-test-gate/SKILL.md` + `run.sh` |
| cross-checker | subagent | `.claude/agents/dna-cross-checker.md` |
| decomposer | skill with `run.sh` (validator) | `.claude/skills/dna-decompose/SKILL.md` + `run.sh` |
| delegate-dispatcher | skill with `run.sh` (pre-dispatch safety) | `.claude/skills/dna-delegate/SKILL.md` + `run.sh` |
| construction-logger | subagent | `.claude/agents/dna-construction-logger.md` |
| verifier | subagent (judgmental) + skill `run.sh` (mechanical) | `.claude/agents/dna-verifier.md` + `.claude/skills/dna-verify/SKILL.md` + `run.sh` |
| spec-auditor | subagent | `.claude/agents/dna-spec-auditor.md` |
| context-guardian | skill with `run.sh` | `.claude/skills/dna-context-check/SKILL.md` + `run.sh` |
| architecture-impact | (not yet dedicated; main agent produces during spec phase per methodology) | TODO |
| coherence-gate | (not yet dedicated; main agent produces during spec phase) | TODO |
| drift-remediator | (not yet dedicated; main agent follows PROJECT_DNA §6 protocol) | TODO |
| pr-reviewer | (not yet dedicated; future subagent) | TODO |
| kit-graduate | (not yet built; future skill) | TODO |

**12 of 17 roles have dedicated implementations.** The remaining 5 are methodology-useful but not in the minimum-required-roster for shipping features.

## Payload location

The adapter's payload lives at `<kit-root>/template/`:

```
template/
├── AGENT.md                                     ← primary instructions; copied to <target>/CLAUDE.md
├── CONSTITUTION.md                              ← 10 articles; Article 10 customized during Protocol A
├── agents/
│   ├── dna-construction-logger.md
│   ├── dna-cross-checker.md
│   ├── dna-spec-auditor.md
│   └── dna-verifier.md
├── skills/
│   ├── dna-test-gate/    (SKILL.md + run.sh)
│   ├── dna-verify/       (SKILL.md + run.sh)
│   ├── dna-decompose/    (SKILL.md + run.sh)
│   ├── dna-delegate/     (SKILL.md + run.sh)
│   └── dna-context-check/ (SKILL.md + run.sh)
├── blueprint/
│   ├── 00-CORE-PRINCIPLES.skeleton.md           ← agent-agnostic
│   ├── 01-SYSTEM-INTENT.skeleton.md             ← agent-agnostic
│   ├── 02-ARCHITECTURE.skeleton.md              ← agent-agnostic
│   ├── 03-EXECUTION-CONTEXT.skeleton.md         ← agent-agnostic
│   ├── 04-COORDINATION-HINTS.skeleton.md        ← agent-agnostic
│   ├── 05-CONSTRUCTION-SITES.skeleton.md        ← agent-agnostic
│   └── RETROSPECTIVE.skeleton.md                ← agent-agnostic
└── defaults/                                    ← reserved for future SKIP mode
```

Anything marked "agent-agnostic" is reusable verbatim by future adapters.

## Dependencies at unfold time

A target using this adapter requires, at minimum:
- Claude Code installed.
- `uv` for Spec-Kit CLI installation.
- `git` for branch / spec-dir workflow.
- `node` 18+ for `agent-token-meter` (optional but recommended for `dna-context-check`).
- Bash or PowerShell 7+ for running the `run.sh` scripts (`pwsh` on Windows).

## Bootstrap protocol

Defined in `template/AGENT.md` §Bootstrap (copied into target as `CLAUDE.md`). 9 steps including `specify init`, constitution sync, DNA skill verification, subagent installation, Blueprint copy, self-audit.

## Known Claude-Code-specific assumptions

Things in this adapter that won't port cleanly to other platforms:

- `.claude/skills/NAME/SKILL.md` with frontmatter convention.
- `.claude/agents/NAME.md` with `name`/`description`/`tools`/`model` frontmatter.
- Slash commands (`/speckit-*`, `/dna-*`) as the primary invocation surface.
- Model references (`sonnet`, `opus`) in subagent frontmatter. adapter-specific naming.
- Spec-Kit's `--integration claude` flag (other agents have different integrations).

All of these are documented here so a future adapter contributor knows what needs translation.

## Dogfooding evidence

- `team-project-scheduler` (in `B:\A5DS-HQ\REPOS\`) unfolded via this adapter; 3 features shipped; migration to 7-doc Blueprint validated end-to-end 2026-04-21.
- `agentic-bookmark-organizer` (external). prior production build that informed PROJECT_DNA.

Two targets, four total features shipped through the workflow. Corpus visible via `tools/aggregate-retros.sh`.
