# agentic-dev-starter

**Set up any project for spec-driven, test-first, anti-flattening agentic development.**

A tool that initializes new project repos with handoff document skeletons, a constitution, Spec-Kit integration, and Claude Code slash commands — so you start building with a methodology, not a blank file.

> Created by Albert Dobmeyer & Claude (Anthropic)
> AKD AUTOMATION SOLUTIONS — Licensed under CC BY-SA 4.0
> Built on GitHub's [Spec-Kit](https://github.com/github/spec-kit) (MIT), Claude Code best practices by Boris Cherny (Anthropic)

---

## What This Is

This repo is a **tool that sets up OTHER repos**. You don't copy it into your project. You run `init.py` once, it creates your project directory with everything you need, and you never touch this repo again.

**What it replaces:** `specify init` (which requires the Spec-Kit CLI, downloads from GitHub, and fails on many Windows setups). This bundles everything locally — no network, no installs, no dependencies beyond Python.

---

## Quick Start

```bash
# Step 1: Clone this repo (one time)
git clone https://github.com/albertdobmeyer/agentic-dev-starter.git

# Step 2: Initialize your project
python agentic-dev-starter/init.py ./my-project \
  --name "My Project" \
  --describe "A web app that does X for Y"

# Step 3: Open in Claude Code and start working
cd my-project
claude
```

That's it. Claude Code reads CLAUDE.md and knows the methodology, the rules, and how to help you plan.

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

The [`example/`](example/) directory contains completed handoff documents for a real project (agentic-bookmark-organizer). Use it as a reference when filling out your own documents.

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
- That's it. No Spec-Kit CLI, no npm, no uv, no network access.

---

## Compatibility

**Platforms:** Windows, macOS, Linux

**AI agents:** Optimized for Claude Code. Also works with GitHub Copilot, Cursor, Windsurf, and any Spec-Kit-compatible agent (change the slash command directory convention as needed).

**Using with Spec-Kit CLI:** If you already have `specify-cli` installed, everything still works. The bundled assets are identical to what `specify init` installs. You can use either the bundled slash commands or Spec-Kit's CLI — they produce the same results.

---

## Documentation

| Document | Purpose |
|----------|---------|
| [METHODOLOGY.md](docs/METHODOLOGY.md) | Deep-dive on the five anti-flattening articles |
| [PLANNING_INSTRUCTIONS.md](docs/PLANNING_INSTRUCTIONS.md) | System prompt for the planning phase |
| [CONSTITUTION_TEMPLATE.md](docs/CONSTITUTION_TEMPLATE.md) | Full template with all 9 articles |
| [HANDOFF_FORMAT.md](docs/HANDOFF_FORMAT.md) | Reference for what good handoff docs look like |
| [AGENT_SETUP.md](docs/AGENT_SETUP.md) | How Claude Code uses the handoff docs to build |
| [FAQ.md](docs/FAQ.md) | Common questions |

---

## Attribution & License

**Methodology (Articles 3-7):** Albert Dobmeyer, AKD AUTOMATION SOLUTIONS. Licensed under [CC BY-SA 4.0](LICENSE).

**Codified from:** Test-first development and CLAUDE.md best practices by Boris Cherny (Anthropic). Spec-driven workflow by GitHub's [Spec-Kit](https://github.com/github/spec-kit) (MIT License).

**Companion tool:** [claude-code-token-meter](https://github.com/albertdobmeyer/claude-code-token-meter) — burn-rate monitor that tells you when to write a handoff and `/clear`.
