# agentic-dev-starter

**Set up any project for spec-driven, test-first, anti-flattening agentic development.**

A tool that initializes new project repos with handoff document skeletons, a constitution, Spec-Kit integration, and Claude Code slash commands — so you start building with a methodology, not a blank file.

> Created by Albert Dobmeyer & Claude (Anthropic)
> AKD AUTOMATION SOLUTIONS — Licensed under CC BY-SA 4.0
> Built on GitHub's [Spec-Kit](https://github.com/github/spec-kit) (MIT), Claude Code best practices by Boris Cherny (Anthropic)

---

## What This Is

**Two tools, symbiotic:**

- **[GitHub Spec-Kit](https://github.com/github/spec-kit)** is the build workflow engine — it manages feature branches, spec directories, quality gates, and the `specify → clarify → plan → tasks → implement` progression. It supports 25+ AI agents and has an extension/preset ecosystem.
- **agentic-dev-starter** is the planning methodology layer — it adds anti-flattening (Articles 3-7), experience fidelity scenarios, depth classification, handoff documents (VISION, ARCHITECTURE, CONSTITUTION, SCOPE), and a constitution template that Spec-Kit doesn't provide.

This repo is a **tool that sets up OTHER repos**. You run `init.py` once — it calls `specify init` for the Spec-Kit engine, then layers on the anti-flattening methodology. If Spec-Kit CLI isn't installed yet, bundled assets keep things working until you install it.

---

## Quick Start

```bash
# Step 0: Install Spec-Kit CLI (recommended — the build workflow engine)
uv tool install specify-cli

# Step 1: Clone this repo (one time)
git clone --recurse-submodules https://github.com/albertdobmeyer/agentic-dev-starter.git

# Step 2: Initialize your project
python agentic-dev-starter/init.py ./my-project \
  --name "My Project" \
  --describe "A web app that does X for Y"

# Step 3: Open in Claude Code and start working
cd my-project
claude
```

`init.py` calls `specify init` under the hood for the Spec-Kit engine, then adds the handoff documents and constitution. If `specify` isn't installed yet, bundled assets are used as a fallback — but **installing Spec-Kit CLI is recommended** for the full workflow with branch management, quality gates, and the extension/preset ecosystem.

**Don't have `uv`?** Install it: `curl -LsSf https://astral.sh/uv/install.sh | sh` (macOS/Linux) or `powershell -c "irm https://astral.sh/uv/install.ps1 | iex"` (Windows).

---

## What init.py Creates

```
my-project/
├── CLAUDE.md                          # Agent instructions (rules, references)
├── VISION.md                          # Skeleton: what you're building and why
├── ARCHITECTURE.md                    # Skeleton: tech stack, modules, data model
├── CONSTITUTION.md                    # 9 universal articles + your project rules
├── SCOPE.md                           # Skeleton: what you're NOT building
├── .gitignore
│
├── .specify/                          # Spec-Kit workspace
│   ├── templates/                     # Spec, plan, task templates
│   ├── scripts/                       # Branch and spec management scripts
│   │   ├── bash/
│   │   └── powershell/
│   ├── memory/
│   │   └── constitution.md            # Constitution loaded into Spec-Kit memory
│   └── specs/                         # Feature specs go here
│
└── .claude/
    └── commands/                      # Spec-Kit slash commands
        ├── speckit.specify.md         # /speckit.specify — create feature specs
        ├── speckit.plan.md            # /speckit.plan — technical planning
        ├── speckit.tasks.md           # /speckit.tasks — task breakdown
        ├── speckit.implement.md       # /speckit.implement — build phase
        └── ...                        # clarify, analyze, checklist, constitution
```

---

## The Workflow

### Phase 1: Planning

Complete the four handoff documents. Claude helps you if you ask.

| Document | Purpose |
|----------|---------|
| **VISION.md** | What you're building and why. User scenarios with negative assertions. |
| **ARCHITECTURE.md** | Tech stack with pinned versions. Module boundaries. Data model. |
| **CONSTITUTION.md** | Hard rules. Articles 1-9 are universal; customize Article 10. |
| **SCOPE.md** | What you're explicitly NOT building. Each line prevents a rabbit hole. |

**Tip:** Tell Claude: *"Read CLAUDE.md. Help me plan this project and complete the handoff documents."* It will ask the right questions — pushing for experience fidelity scenarios, negative assertions, depth classifications, and filmable success criteria.

For a deeper planning experience, paste [docs/PLANNING_INSTRUCTIONS.md](docs/PLANNING_INSTRUCTIONS.md) into Claude Desktop's Custom Instructions and plan there before handing off to Claude Code.

### Phase 2: Building

Once handoff docs are complete, tell Claude: *"Start building. Follow the Spec-Kit workflow."*

The workflow runs through the slash commands:

```
/speckit.constitution → /speckit.specify → /speckit.clarify → /speckit.plan → /speckit.tasks → /speckit.implement
```

Each step reads the handoff documents, generates the appropriate artifacts, and enforces the constitution's anti-flattening rules.

---

## Worked Example

The [`example/`](example/) directory contains completed **planning** documents for a real project (agentic-bookmark-organizer). The project is currently going through the full build cycle; the example will be updated with the complete planning-to-code story when it finishes. Use the handoff docs as a reference when filling out your own.

---

## The Anti-Flattening Methodology

The #1 failure mode in AI-assisted development: you describe a rich user experience, the agent decomposes it into tasks, each task passes its test, but the experience feels hollow. Every component *works* in isolation; none of them *compose* into what you envisioned.

This methodology prevents flattening through five structural articles in the constitution:

- **Article 3: Anti-Flattening** — Experience fidelity scenarios with negative assertions
- **Article 4: Depth Classification** — `[E]` Exists / `[W]` Works / `[D]` Delivers
- **Article 5: Implementation Debt Tracking** — Every simplification logged at the moment it happens
- **Article 6: Data-Without-Behavior Detection** — Every schema needs a trigger specification
- **Article 7: Drift Remediation** — Don't patch gap-by-gap; write scenarios first

Full deep-dive: [docs/METHODOLOGY.md](docs/METHODOLOGY.md)

---

## Options

```
python init.py <target-dir> --name "Name" --describe "Description"

Required:
  target              Path to the new project directory
  --name NAME         Project name (used in document headers)
  --describe TEXT     One-line project description

Optional:
  --no-git            Skip git init
  --no-speckit        Skip .specify/ and .claude/commands/ (just handoff docs + CLAUDE.md)
  --force             Allow initialization in a non-empty directory
```

---

## Requirements

- **Python 3.10+** (no pip packages needed — stdlib only)
- **git** (optional, for `git init`)
- **Spec-Kit CLI** (recommended): `uv tool install specify-cli` — provides the full workflow engine with branch management, quality gates, extensions, and presets. Without it, bundled assets provide the core workflow but you miss the broader ecosystem.

---

## Compatibility

**Platforms:** Windows, macOS, Linux

**AI agents:** Optimized for Claude Code. Also works with GitHub Copilot, Cursor, Windsurf, and any Spec-Kit-compatible agent (change the slash command directory convention as needed).

**Using with Spec-Kit CLI (recommended):** `init.py` automatically detects and uses `specify init` when the CLI is installed. This gives you the full Spec-Kit engine: auto-numbered feature branches, 4-level template resolution (overrides → presets → extensions → core), quality gate checklists, and support for the extension/preset ecosystem. The bundled assets are a fallback for environments where the CLI can't be installed.

---

## Teams

Using this with a team of developers on feature branches? See the [Team Guide](docs/TEAM_GUIDE.md) for:

- Lead setup and developer onboarding
- Feature branch workflow with Spec-Kit's numbered branches
- PR review protocol against constitution and vision
- Constitution governance (who can change what)
- Cost control with token meters and session budgets
- Shared vs per-dev file ownership

---

## Documentation

| Document | Purpose |
|----------|---------|
| [METHODOLOGY.md](docs/METHODOLOGY.md) | Deep-dive on the five anti-flattening articles |
| [PLANNING_INSTRUCTIONS.md](docs/PLANNING_INSTRUCTIONS.md) | System prompt for the planning phase |
| [CONSTITUTION_TEMPLATE.md](docs/CONSTITUTION_TEMPLATE.md) | Full template with all 9 articles |
| [HANDOFF_FORMAT.md](docs/HANDOFF_FORMAT.md) | Reference for what good handoff docs look like |
| [AGENT_SETUP.md](docs/AGENT_SETUP.md) | How Claude Code uses the handoff docs to build |
| [TEAM_GUIDE.md](docs/TEAM_GUIDE.md) | Multi-developer workflow and team lead guide |
| [FAQ.md](docs/FAQ.md) | Common questions |

---

## Attribution & License

**Methodology (Articles 3-7):** Albert Dobmeyer, AKD AUTOMATION SOLUTIONS. Licensed under [CC BY-SA 4.0](LICENSE).

**Codified from:** Test-first development and CLAUDE.md best practices by Boris Cherny (Anthropic). Spec-driven workflow by GitHub's [Spec-Kit](https://github.com/github/spec-kit) (MIT License).

**Companion tool:** [agent-token-meter](https://github.com/albertdobmeyer/agent-token-meter) (bundled as `token-meter/` submodule) — burn-rate monitor that tells you when to write a handoff and `/clear`.
