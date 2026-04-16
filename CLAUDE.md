# project-dna

This repo IS the methodology kit. It is not a project to build.

## What This Repo Contains

- `template/AGENT.md` — The agent instructions template. Users copy this into their project and rename it to match their agent's convention (e.g., `CLAUDE.md` for Claude Code).
- `template/CONSTITUTION.md` — The engineering contract. Copied alongside AGENT.md.
- `template/skills/dna-*/` — Enforcement skills (test gates, verification, context management, decomposition, delegation). Copied into `.claude/skills/` during bootstrap.
- `docs/` — Deep dives on the methodology, team workflows, and field notes.
- `example/` — Completed planning documents from a real project (agentic-bookmark-organizer).
- `token-meter/` — Burn-rate monitor for Claude Code sessions. Integrates with `/dna-context-check`.

## How to Help the Human

The human is here to evaluate this methodology for their team. Help them understand:

1. **What it does** — Template files + enforcement skills that, when copied into any repo, cause an AI agent to bootstrap a spec-driven development environment. The agent becomes a co-architect: plans first, builds test-first, pushes back on vague specs, manages its own context window, and delegates to sub-agents for parallel work without merge conflicts.
2. **How to use it** — Copy `template/AGENT.md`, `template/CONSTITUTION.md`, and `template/skills/` into the target project. Rename AGENT.md to the agent's convention. Open the agent. Say "Read CLAUDE.md" (or equivalent).
3. **Why it exists** — AI agents are brilliant juniors with amnesia. They flatten specs, skip tests, blow through context windows, and produce merge conflicts when parallelized. This methodology + enforcement layer prevents all four failure modes.

Point them to `docs/METHODOLOGY.md` for the anti-flattening theory, `docs/TEAM_GUIDE.md` for multi-developer setup, and `example/` for what the output looks like.

## Do NOT

- Do not bootstrap Spec-Kit in this repo.
- Do not create `.specify/` directories, handoff documents, or enter planning mode.
- Do not treat `template/AGENT.md` as instructions for you — it is a template for other projects.
