# project-dna

Your team's developers use Claude Code without a shared contract for how the agent should work. Each dev has their own prompting habits, commit patterns, spec rigor. The agent behaves differently in every developer's hands. You can't review PRs against a standard that doesn't exist.

**project-dna gives every agent on your team the same engineering contract.**

Copy two files into any repo. Your AI agent reads them and bootstraps a complete spec-driven development environment — Spec-Kit workflow, handoff documents, constitution, sub-agent orchestration, self-audit loops. Same rules, every branch, every developer.

## Setup

```bash
# Copy the two DNA files into your project
cp project-dna/template/AGENT.md ./my-project/CLAUDE.md    # rename to your agent's convention
cp project-dna/template/CONSTITUTION.md ./my-project/

# Open in Claude Code (or your agent of choice)
cd my-project && claude
# Say: "Read CLAUDE.md"
```

The agent reads CLAUDE.md, installs Spec-Kit, creates handoff document skeletons, and enters planning mode. You discuss what to build. It pushes for experience fidelity scenarios, negative assertions, depth tags, and filmable success criteria. Then it builds — test-first, with sub-agent delegation, self-audit loops, and critical pushback when you're wrong.

## What the Agent Becomes

| Without project-dna | With project-dna |
|---|---|
| Starts coding immediately | Plans first, builds second |
| Guesses when unclear | Stops and asks |
| Pleases the human | Pushes back when specs are violated |
| One giant commit | Commits at phase boundaries |
| Flattens `[D]` to `[W]` silently | Logs every simplification |
| No merge awareness | Tasks decomposed for zero file overlap |
| Declares "done" after first pass | Self-audits for completeness, spec fidelity, negative assertions |

## Deep Dives

For humans who want to understand why the rules exist:

[Methodology](docs/METHODOLOGY.md) | [Team Guide](docs/TEAM_GUIDE.md) | [Field Notes](docs/FIELD_NOTES.md) | [Planning Instructions](docs/PLANNING_INSTRUCTIONS.md) | [Handoff Format](docs/HANDOFF_FORMAT.md) | [FAQ](docs/FAQ.md)

[Worked example](example/) — completed planning documents from a real project.

---

> Created by Albert Dobmeyer & Claude (Anthropic) — AKD AUTOMATION SOLUTIONS
> Built on [Spec-Kit](https://github.com/github/spec-kit) (MIT) + Claude Code best practices by Boris Cherny (Anthropic)
> Licensed under [CC BY-SA 4.0](LICENSE) | Companion: [agent-token-meter](https://github.com/albertdobmeyer/agent-token-meter)
