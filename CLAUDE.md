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

5. **Run the target's Bootstrap** verbatim per `<target>/CLAUDE.md` §Bootstrap (steps 1–9). The canonical `specify init` invocation and its required flags live there — do not reconstruct them. Bootstrap handles Spec-Kit install, token-meter, `specify init`, constitution sync, DNA skill verification, handoff skeletons, and self-audit. Block on any self-audit failure before proceeding to step 6.

6. **Customize Article 10 interactively.** Using the quality-risk answers from step 1, draft 4–8 project-specific rules (test coverage threshold, language strictness, auth pattern, PR approval count, session budget, etc.). Show to the human, accept edits, write into `<target>/CONSTITUTION.md`, re-sync to `.specify/memory/constitution.md`.

7. **Author the 7-doc Blueprint Package with the human** (restored from original PROJECT_DNA methodology). The target now expects six linked docs under `docs/` plus `CONSTITUTION.md` at root:
   - `docs/00-CORE-PRINCIPLES.md` — problem, users, domain model, core principles (each generates ≥1 scenario)
   - `docs/01-SYSTEM-INTENT.md` — entities, state machines, Experience Fidelity Scenarios (3+ neg assertions each, behavioral variation, filmable success), **Scenario Validation Matrix** (mandatory — bidirectional assertion↔task linkage, "Uncovered Assertions" must be empty), depth classification
   - `docs/02-ARCHITECTURE.md` — module boundaries, API surface, data flows, event/sync flows, **Architecture Impact Assessment** per scenario
   - `docs/03-EXECUTION-CONTEXT.md` — pinned stack versions, coding standards, error handling, testing philosophy
   - `docs/04-COORDINATION-HINTS.md` — phase ordering with depth-tagged done criteria, **Production Threshold** (must-close vs v1.1), risk hotspots, non-goals (8+)
   - `docs/05-CONSTRUCTION-SITES.md` — living tracker (initialized empty at bootstrap; the `dna-construction-logger` subagent appends entries during build)

   Depth of authoring depends on what existed from step 1:
   - **Complete material existed**: ~30–45 min gap-filling pass per doc. Map content into the 7 files. Verify each required element.
   - **Partial material**: ~60–90 min. Author missing docs; keep and adapt what exists.
   - **No prior material**: full 90–120 min interview using `docs/PLANNING_INSTRUCTIONS.md` as methodology and the skeleton files themselves as the structural spec. Each skeleton names what "complete" means via `{FILL IN: ...}` markers and trailing completion checks.

   Do not shortcut. This is where the human's thinking becomes binding contract. Skeletons at `docs/` with remaining `{FILL IN}` markers are NOT production-ready — Bootstrap self-audit will pass with skeletons present (step 8 allows skeletons day-1), but `/speckit-specify` must NOT run until markers are resolved.

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
- A target unfold delivers: Spec-Kit installed (pinned), 5 DNA enforcement skills (4 with executable `run.sh`), 4 subagents (construction-logger, cross-checker, spec-auditor, verifier), token-meter running, 7-doc Blueprint Package authored with human input, git initialized, remote pushed.
- The human's job is vision + Article 10 customization + Blueprint content. The agent handles installs, scaffolding, audits, git.

### Architecture — kernel + adapters (added 2026-04-21)

The kit is split into two layers:

- **`kernel/`** — agent-agnostic methodology. Invariants, vocabulary, role taxonomy. Read first: `kernel/README.md`.
- **`adapters/`** — agent-specific wiring. `claude-code/` is complete (it's what `template/` implements today); `cursor/`, `amp/`, `codex/` are stubs.

Protocol A currently uses the Claude Code adapter implicitly (because `template/` is Claude-Code-shaped). Future adapters: new contributors read `adapters/README.md` + `kernel/`, author a new adapter directory, extend Protocol A step 3 with agent detection.

**If the team lead is using a non-Claude-Code agent**, tell them: "the Claude-Code adapter is the only complete one today. Either (a) use Claude Code, (b) implement the methodology manually from `kernel/methodology.md`, or (c) author the adapter for your agent per `adapters/README.md` and contribute it back."

Offer to run Protocol A / B / C next based on where the human wants to go.

### Protocol E — Refresh an existing target with kit updates

Trigger: *"refresh my kit"*, *"pull kit updates into my project"*, *"sync my subagents / scripts"*, *"my kit repo has new gates, update my target"*.

The kit evolves after targets unfold. New `run.sh` scripts, new subagents, updated `SKILL.md` files land in `template/` and `template/agents/` but don't flow back into existing targets automatically. Protocol E fixes that.

1. Ask the human for the target project's filesystem path.
2. From this kit repo, run `bash tools/refresh-target.sh <target-path> --dry-run`.
3. Surface the output: `ADDED`, `IDENTICAL`, `DRIFT` counts per file.
4. If DRIFT is reported on any file, open each diff with the human and ask whether to keep the target's version or adopt the kit's. Default: keep local.
5. Re-run without `--dry-run` (or with `--force` if the human chose to adopt DRIFT).
6. Confirm the target's working tree compiles / tests pass (ask the human to run their suite before committing).

The target-side counterpart is documented in `template/AGENT.md` §Refresh Protocol — so a team lead running inside their target says the same phrases and the agent invokes `<kit-path>/tools/refresh-target.sh` from there. Either direction works; both converge on `tools/refresh-target.sh`.

Do NOT refresh `CONSTITUTION.md`, `CLAUDE.md`, or `docs/*.md` in the target — those are Article-10 customizations and team-authored Blueprint content. The refresher is scoped to `.claude/skills/dna-*/` and `.claude/agents/` only.

## Philosophy

**Zero infrastructure, agent-orchestrated.** Spec-Kit and agent-token-meter are NOT bundled — they install at unfold time against their latest versions. The repo is a small seed of templates + protocols. No scaffolder scripts, no manual shell commands for the human, no OS-specific setup instructions. The CLI agent interprets the protocols above and handles execution on whatever platform it's running on.

## Do not, in this repo

- Do not `specify init` or create `.specify/` here.
- Do not create `VISION.md`, `ARCHITECTURE.md`, `SCOPE.md` at the kit root.
- Do not treat `template/AGENT.md` as YOUR bootstrap — it is the template that becomes the target project's agent instructions (renamed to `CLAUDE.md` or equivalent) when Protocol A runs.
- Do not modify `template/*` without confirming with the human — those files are the kit's payload; every change propagates to every future unfold.
