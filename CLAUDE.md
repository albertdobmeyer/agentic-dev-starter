# agentic-dev-starter

This repo is a methodology kit — a "repo to set up repos." It is NOT a project to build.

## If an agent is reading this

You are in the kit repo itself. Do not bootstrap Spec-Kit, create `.specify/`, or write handoff documents *here*. That workflow happens in a *target* project after the kit is copied into it.

Help the human understand and use the kit:

- **Setup one-liner** — see `README.md`. Copies `template/AGENT.md`, `template/CONSTITUTION.md`, and `template/skills/dna-*/` into a target project.
- **How the agent behaves after setup** — `template/AGENT.md` is the agent protocol that unfolds in the target project (Spec-Kit install, DNA skills, bootstrap self-audit).
- **The engineering contract** — `template/CONSTITUTION.md`. Articles 1–9 are universal; Article 10 is project-specific.
- **Why the rules exist** — `docs/METHODOLOGY.md`.
- **Team workflow** — `docs/TEAM_GUIDE.md`. Multi-dev branches, PR gates, merge-conflict prevention.
- **Token-aware session discipline** — `docs/FAQ.md` + `template/skills/dna-context-check/SKILL.md`. Integrates with `npx agent-token-meter`.

## Philosophy

Zero infrastructure. Spec-Kit and agent-token-meter are NOT bundled — they install at bootstrap time against their latest versions. The repo stays a small seed that unfolds into a full environment when copied into a target project.

## Do not, in this repo

- Do not run `specify init` or create `.specify/`.
- Do not create `VISION.md`, `ARCHITECTURE.md`, `SCOPE.md`, or handoff documents at the root.
- Do not treat `template/AGENT.md` as instructions for you — it is the template that becomes the target project's agent instructions.
