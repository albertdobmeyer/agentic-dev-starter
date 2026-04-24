# Kernel. Agent-Agnostic Methodology

> **The kernel is what every adapter shares.** Methodology, vocabulary, role taxonomy, invariants. Pure prose rules; zero agent-specific wiring.

The kit is organized in two layers:

```
agentic-dev-starter/
├── kernel/                        ← THIS DIRECTORY: agent-agnostic methodology
│   ├── methodology.md             ← the rules (from PROJECT_DNA)
│   ├── vocabulary.md              ← the shared terms (depth tags, scenarios, ...)
│   └── roles.md                   ← the subagent role taxonomy (specifier, verifier, ...)
│
├── adapters/                      ← agent-specific wiring
│   ├── claude-code/               ← current reference adapter. used by template/
│   ├── cursor/                    ← stub. TODO, see roles.md for what to map
│   ├── amp/                       ← stub
│   └── codex/                     ← stub
│
└── template/                      ← the payload copied into target projects
                                     (currently Claude-Code-shaped; maps to adapters/claude-code/)
```

## Why split kernel from adapters

The methodology (what to do) is stable. The agent-specific execution (how to dispatch a subagent, where to install skills, what file paths exist) is platform-specific. Mixing them meant every Claude-Code-specific decision leaked into the methodology.

With this split:
- **Kernel changes** = methodology evolves (rare; well-considered).
- **Adapter changes** = one specific agent's wiring updates (frequent; isolated blast radius).
- **New adapter for a new agent** = read the kernel, map each role + skill + artifact to the agent's conventions, done.

## What currently lives where (status at 2026-04-21)

| Concept | Canonical location | Status |
|---|---|---|
| Methodology (PROJECT_DNA, Articles, 7-doc Blueprint) | `kernel/methodology.md` + `PROJECT_DNA.md` (root, unchanged) | present |
| Vocabulary (depth tags, scenarios, matrices, construction sites, flattening) | `kernel/vocabulary.md` | present |
| Role taxonomy (10+ subagent roles) | `kernel/roles.md` | present |
| Claude-Code wiring (`.claude/skills/`, `.claude/agents/`, slash commands) | `adapters/claude-code/README.md` + `template/` | **template/ IS the adapter today** |
| Cursor wiring | `adapters/cursor/README.md` | **stub. not implemented** |
| Amp wiring | `adapters/amp/README.md` | stub |
| Codex wiring | `adapters/codex/README.md` | stub |

## The promise this enables

The 2026-04-21 critique noted: *"Cross-agent portability. AGENT.md is styled neutral but every protocol assumes Claude Code idioms."* That's true today because `template/` IS the Claude-Code adapter. The kernel/adapter split makes the Claude-Code-ness explicit and bounded. Porting to Cursor / Amp / Codex means authoring the adapter, not rewriting the kit.

Once two adapters exist, the kernel's invariants become visible: "any agent that can dispatch sub-agents, run shell commands, and read files from disk can implement the methodology." The kit becomes a true framework instead of a Claude-Code preset.

## Writing a new adapter

See `adapters/README.md`. Briefly:
1. Read `kernel/methodology.md`, `kernel/vocabulary.md`, `kernel/roles.md` end to end.
2. For each role in `roles.md`, map to your agent's subagent / command / skill convention.
3. For each subagent definition in `template/agents/`, rewrite for your agent (frontmatter format, system prompt conventions).
4. For each skill in `template/skills/`, mirror the SKILL.md content in your agent's skill format; the `run.sh` scripts are agent-agnostic. reuse them verbatim.
5. Author the agent's primary instruction file (the thing equivalent to `template/AGENT.md` for Claude Code).
6. Wire the adapter into Protocol A (the kit's root `CLAUDE.md`) so `"set up a new project"` can copy the right adapter's payload.

The kernel tells you WHAT. The adapter tells you HOW on your platform.
