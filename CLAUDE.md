# project-dna

This repo IS the methodology kit. It is not a project to build.

## What This Repo Contains

- `template/AGENT.md` — The agent instructions template. Users copy this into their project and rename it to match their agent's convention (e.g., `CLAUDE.md` for Claude Code).
- `template/CONSTITUTION.md` — The engineering contract. Copied alongside AGENT.md.
- `docs/` — Deep dives on the methodology, team workflows, and field notes.
- `example/` — Completed planning documents from a real project (agentic-bookmark-organizer).
- `token-meter/` — Optional burn-rate monitor for Claude Code sessions.

## How to Help the Human

The human is here to evaluate this methodology for their team. Help them understand:

1. **What it does** — Two files that, when copied into any repo, cause an AI agent to bootstrap a spec-driven development environment. The agent becomes a co-architect: plans first, builds test-first, pushes back on vague specs, self-audits for completeness.
2. **How to use it** — Copy `template/AGENT.md` and `template/CONSTITUTION.md` into the target project. Rename AGENT.md to the agent's convention. Open the agent. Say "Read CLAUDE.md" (or equivalent).
3. **Why it exists** — AI agents flatten rich experiences into components that pass tests individually but never compose into the intended user experience. This methodology prevents that.

Point them to `docs/METHODOLOGY.md` for the anti-flattening theory, `docs/TEAM_GUIDE.md` for multi-developer setup, and `example/` for what the output looks like.

## Do NOT

- Do not bootstrap Spec-Kit in this repo.
- Do not create `.specify/` directories, handoff documents, or enter planning mode.
- Do not treat `template/AGENT.md` as instructions for you — it is a template for other projects.
