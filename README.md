# agentic-dev-starter

**The #1 failure mode in AI-assisted development:** you describe a rich user experience. The agent decomposes it into tasks. Each task passes its test. But the result feels hollow — every component *works* in isolation, none of them *compose* into what you envisioned.

This is called **flattening**, and it happens every time a spec gets decomposed without structural safeguards.

**agentic-dev-starter** prevents it. It sets up your project with a constitution, handoff documents, and a build workflow that keeps the agent on track from spec to ship — so what gets built matches what you described.

> Created by Albert Dobmeyer & Claude (Anthropic)
> AKD AUTOMATION SOLUTIONS — Licensed under CC BY-SA 4.0
> Built on GitHub's [Spec-Kit](https://github.com/github/spec-kit) (MIT), Claude Code best practices by Boris Cherny (Anthropic)

---

## How It Works

**Two tools, symbiotic:**

- **[GitHub Spec-Kit](https://github.com/github/spec-kit)** is the build workflow engine — feature branches, spec directories, quality gates, and the `specify → clarify → plan → tasks → implement` progression. Supports 25+ AI agents.
- **agentic-dev-starter** is the methodology layer on top — anti-flattening (Articles 3-7), experience fidelity scenarios, depth classification, handoff documents (VISION, ARCHITECTURE, CONSTITUTION, SCOPE), and a constitution template that Spec-Kit doesn't provide.

This repo is a **tool that sets up OTHER repos**. Run `init.py` once — it calls `specify init` for the Spec-Kit engine, then layers on the anti-flattening methodology. If Spec-Kit CLI isn't installed yet, bundled assets keep things working until you install it.

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

The [`example/`](example/) directory contains completed **planning** documents for a real project (agentic-bookmark-organizer). Use the handoff docs as a reference when filling out your own.

---

## Status

The methodology and tooling are production-ready. The [agentic-bookmark-organizer](https://github.com/albertdobmeyer/agentic-bookmark-organizer) is currently going through the full build cycle — from the handoff docs in `example/` through the Spec-Kit workflow to working, tested code. When it completes, the example will be updated to show the complete planning-to-code story with git history, logged simplifications, and lessons learned.

**Windows note:** The Spec-Kit CLI has a known Rich library rendering issue on some Windows terminal configurations. `init.py` detects this and auto-activates bundled assets as a fallback. Your team won't lose functionality — expect a warning message on first run, not an error.

---

## The Five Anti-Flattening Articles

The constitution enforces five structural safeguards at every stage where flattening typically occurs:

| Article | What It Catches | When |
|---|---|---|
| **3: Anti-Flattening** | Specs that describe system mechanics instead of user experience | Before tasks are derived |
| **4: Depth Classification** | Ambiguous "done" definitions — `[E]` Exists / `[W]` Works / `[D]` Delivers | Before implementation |
| **5: Debt Tracking** | Silent `[D]`→`[W]` downgrades that make flattening invisible | During implementation |
| **6: Data-Without-Behavior** | Schemas that exist but never fire (no trigger specified) | Before the build |
| **7: Drift Remediation** | Gap-by-gap patching that produces Frankenstein code | After gaps are found |

Every article exists because its absence caused a specific, documented failure in a production build. Full deep-dive: [docs/METHODOLOGY.md](docs/METHODOLOGY.md)

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
