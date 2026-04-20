# agentic-dev-starter

A meta repo — a "repo to set up repos." Team leads point their CLI agent at this directory to create fully-configured agentic dev projects for their teams. The kit is a TOOL that generates TARGET projects; it is not a project to build.

## For the human

Open Claude Code (or any compatible CLI agent) with this directory as the working directory, then say one of:

- **"Set up a new project for my team"** — full automated unfold: interview, scaffolding, bootstrap, handoff docs, git init, remote push, per-dev onboarding brief.
- **"Explain the methodology"** — guided tour of the *why* (Articles 3–7, anti-flattening, depth classification).
- **"Show me the team workflow"** — multi-dev coordination, PR gates, merge-conflict prevention.
- **"Help me understand the kit"** — general orientation.

Do not run setup shell commands manually. Everything is agent-orchestrated.

## For the agent

You are in the **meta repo**. You do NOT bootstrap Spec-Kit, create `.specify/`, or write handoff documents *in this directory*. Pick the protocol that matches the human's intent.

### Protocol A — New target project setup

Trigger phrases: *"set up a new project"*, *"create a new repo for my team"*, *"start a new project"*, similar.

1. **Check for existing material, then interview.** First ask: *"Before I interview you — do you already have a VISION, architecture, PRD, or planning document for this project?"*

   - **YES (complete or substantial)**: Accept the material (paste or file path). Read it. Later, in step 7, do a **gap-filling pass** — map content into `docs/HANDOFF_FORMAT.md` structure and interview only for missing required elements (3+ negative assertions per scenario, depth tags, non-goals, behavior specs for automatic-behavior data, pinned versions). Skip the long interview.
   - **PARTIAL**: Accept what exists. In step 7, interview only for the missing artifacts (e.g., has VISION, needs ARCHITECTURE + SCOPE).
   - **NONE**: Run the full greenfield interview — ask in one message:
     - Project name (kebab-case, 1–3 words)
     - One-paragraph description of what it does
     - Target team size and tech-literacy range (e.g., "3 juniors + 2 mids")
     - Primary tech stack (language + framework + datastore)
     - Output type (web app / API / CLI / library / service)
     - 3–5 biggest quality risks or team pain points (feeds Article 10)

2. **Confirm target location.** Propose a sibling directory at `../<project-name>/` (NOT inside this kit repo). Let the human override.

3. **Copy the kit payload into the target**:
   - `template/AGENT.md` → `<target>/CLAUDE.md` (renamed to the target agent's convention)
   - `template/CONSTITUTION.md` → `<target>/CONSTITUTION.md`
   - `template/skills/dna-*/` → `<target>/.claude/skills/dna-*/`

   Use platform-appropriate copy (`cp -r` on Unix/Git-Bash, `Copy-Item -Recurse` on PowerShell). Detect the shell from the environment.

4. **Switch working directory to the target.** All subsequent commands run there. From here on, `<target>/CLAUDE.md` is the primary instruction file — it's the kit's `template/AGENT.md` renamed and governs the target-project unfold.

5. **Run the target's Bootstrap** per `<target>/CLAUDE.md` §Bootstrap: Spec-Kit install (latest tag), start token-meter in split pane, `specify init . --integration claude --force --offline`, sync constitution, verify 5 DNA skills, create handoff doc skeletons.

6. **Customize Article 10 interactively.** Using the quality-risk answers from step 1, draft 4–8 project-specific rules (test coverage threshold, language strictness, auth pattern, PR approval count, session budget, etc.). Show to the human, accept edits, write into `<target>/CONSTITUTION.md`, re-sync to `.specify/memory/constitution.md`.

7. **Author handoff docs with the human.** Depth depends on what existed from step 1:
   - **Complete material existed**: ~15–30 min gap-filling pass. Format into `docs/HANDOFF_FORMAT.md` structure. Verify each required element (3+ negative assertions per scenario, depth tags, non-goals, behavior specs, pinned versions). Ask only about gaps.
   - **Partial material**: ~30–60 min. Author the missing documents via interview; keep and adapt what exists.
   - **No prior material**: full 60–90 min interview using `docs/PLANNING_INSTRUCTIONS.md` as methodology and `docs/HANDOFF_FORMAT.md` as the structural spec. Do not shortcut — this is where the human's thinking becomes binding contract.

8. **Run the target's Bootstrap self-audit.** Block and fix any failures (uncustomized Article 10, missing handoff docs, Spec-Kit stub constitution, missing DNA skills).

9. **Initialize git.** In the target: `git init`, create a stack-appropriate `.gitignore`, `git add -A`, commit with message `chore: bootstrap agentic-dev-starter methodology kit`.

10. **Offer to push to a remote.** Ask the human for org/repo name. Prefer `gh repo create <name> --public|--private --source . --push`. If `gh` is unavailable, give the exact `git remote add` + `git push` commands.

11. **Generate the dev-onboarding brief** — a single message the team lead sends to each dev:
    > Clone `<repo-url>`, `cd` into it, open Claude Code. Say: *"Read CLAUDE.md — I'm a new dev, onboard me."* The agent handles installs and walks you through the handoff docs. Requires: Claude Code, `uv`, `git`, Node.js 18+.

### Protocol B — Methodology tour

Trigger: *"explain the methodology"*, *"why these rules"*, etc.

Walk the human through, citing article numbers from `template/CONSTITUTION.md`:
1. `docs/METHODOLOGY.md` — the five original contributions (Articles 3–7).
2. `docs/FIELD_NOTES.md` — validation evidence from real production builds.
3. `docs/FAQ.md` — answers to common adoption questions.

Do not invent rules not present in `template/CONSTITUTION.md`.

### Protocol C — Team workflow tour

Trigger: *"team workflow"*, *"multi-dev setup"*, *"PR review"*, etc.

Walk through `docs/TEAM_GUIDE.md` section by section. Emphasize:
- "main is the contract" model
- Spec-Kit's numbered branches → isolated spec directories → merge-conflict prevention
- `/dna-decompose` + `/dna-delegate` for parallel sub-agent work without file overlap
- PR review gate against constitution compliance + vision fidelity

### Protocol D — General orientation

Trigger: *"help me understand"*, *"what is this"*, *"show me around"*.

Summarize in 3 bullets:
- The kit is a seed that unfolds into a fully-configured target project.
- A target unfold delivers: Spec-Kit installed (latest), 5 DNA enforcement skills, token-meter running, handoff docs authored with human input, git initialized, remote pushed.
- The human's job is vision + Article 10 customization + handoff-doc content. The agent handles installs, file scaffolding, audits, git.

Offer to run Protocol A / B / C next based on where the human wants to go.

## Philosophy

**Zero infrastructure, agent-orchestrated.** Spec-Kit and agent-token-meter are NOT bundled — they install at unfold time against their latest versions. The repo is a small seed of templates + protocols. No scaffolder scripts, no manual shell commands for the human, no OS-specific setup instructions. The CLI agent interprets the protocols above and handles execution on whatever platform it's running on.

## Do not, in this repo

- Do not `specify init` or create `.specify/` here.
- Do not create `VISION.md`, `ARCHITECTURE.md`, `SCOPE.md` at the kit root.
- Do not treat `template/AGENT.md` as YOUR bootstrap — it is the template that becomes the target project's agent instructions (renamed to `CLAUDE.md` or equivalent) when Protocol A runs.
- Do not modify `template/*` without confirming with the human — those files are the kit's payload; every change propagates to every future unfold.
