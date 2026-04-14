# agentic-dev-starter

**The #1 failure mode in AI-assisted development:** you describe a rich user experience. The agent decomposes it into tasks. Each task passes its test. But the result feels hollow — every component *works* in isolation, none of them *compose* into what you envisioned.

This is **flattening**. This tool prevents it.

Run `init.py` on any project directory. It generates a CLAUDE.md that encodes the full anti-flattening methodology — decision boundaries, depth classification, workflow phases, failure protocols — plus a constitution, handoff document skeletons, and [Spec-Kit](https://github.com/github/spec-kit) integration. Your agent reads CLAUDE.md and knows exactly how to work.

```bash
# Install Spec-Kit CLI (recommended)
uv tool install specify-cli

# Clone this repo (one time)
git clone --recurse-submodules https://github.com/albertdobmeyer/agentic-dev-starter.git

# Initialize your project
python agentic-dev-starter/init.py ./my-project \
  --name "My Project" --describe "What it does"

# Open in Claude Code
cd my-project && claude
```

The generated project is self-contained. Your agent never needs to come back here.

---

**For teams:** [Team Guide](docs/TEAM_GUIDE.md) — lead setup, feature branches, PR review against constitution, cost control.

**How it was tested:** [Field Notes](docs/FIELD_NOTES.md) — 47 tasks, 259 tests, 5 methodology revisions from the first e2e build.

**Deep dives:** [Methodology](docs/METHODOLOGY.md) | [Constitution Template](docs/CONSTITUTION_TEMPLATE.md) | [Handoff Format](docs/HANDOFF_FORMAT.md) | [Planning Instructions](docs/PLANNING_INSTRUCTIONS.md) | [Agent Setup](docs/AGENT_SETUP.md) | [FAQ](docs/FAQ.md)

**Worked example:** [`example/`](example/) — completed planning documents from a real project.

**Options:** `--no-git` `--no-speckit` `--force` | **Requires:** Python 3.10+ | **Platforms:** Windows, macOS, Linux

**Windows note:** Spec-Kit CLI has a known Rich rendering issue on some terminals. `init.py` auto-activates bundled assets as fallback — no functionality lost.

---

> Created by Albert Dobmeyer & Claude (Anthropic) — AKD AUTOMATION SOLUTIONS
> Built on GitHub's [Spec-Kit](https://github.com/github/spec-kit) (MIT) and Claude Code best practices by Boris Cherny (Anthropic)
> Licensed under [CC BY-SA 4.0](LICENSE) | Companion tool: [agent-token-meter](https://github.com/albertdobmeyer/agent-token-meter) (bundled as `token-meter/` submodule)
