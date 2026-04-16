# project-dna

Your team's developers use Claude Code without a shared contract for how the agent should work. Each dev has their own prompting habits, commit patterns, spec rigor. The agent behaves differently in every developer's hands. You can't review PRs against a standard that doesn't exist.

**project-dna gives every agent on your team the same engineering contract.**

Copy the template files into any repo. Your AI agent reads them and bootstraps a complete spec-driven development environment — Spec-Kit workflow, handoff documents, constitution, test enforcement, context management, and sub-agent orchestration. Same rules, every branch, every developer.

## Setup

```bash
# Copy the DNA files into your project
cp project-dna/template/AGENT.md ./my-project/CLAUDE.md    # rename to your agent's convention
cp project-dna/template/CONSTITUTION.md ./my-project/
cp -r project-dna/template/skills/dna-* ./my-project/.claude/skills/

# Open in Claude Code (or your agent of choice)
cd my-project && claude
# Say: "Read CLAUDE.md"
```

The agent reads CLAUDE.md, installs Spec-Kit, sets up enforcement skills, creates handoff document skeletons, and enters planning mode. You discuss what to build. It pushes for experience fidelity scenarios, negative assertions, depth tags, and filmable success criteria. Then it builds — test-first (enforced by `/dna-test-gate`), with token-aware handoffs (`/dna-context-check`), complexity decomposition (`/dna-decompose`), and scoped sub-agent delegation (`/dna-delegate`).

## What the Agent Becomes

| Without project-dna | With project-dna |
|---|---|
| Starts coding immediately | Plans first, builds second |
| Guesses when unclear | Stops and asks |
| Pleases the human | Pushes back when specs are violated |
| Tests are "optional" | `/dna-test-gate` — tests must exist and fail before implementation |
| "Done" without proof | `/dna-verify` — built matches specced, or divergences are listed |
| Blows past context limits | `/dna-context-check` — auto-handoff before the dumb zone |
| Merge conflicts from parallel work | `/dna-decompose` + `/dna-delegate` — scoped sub-agents, zero file overlap |

## Deep Dives

For humans who want to understand why the rules exist:

[Methodology](docs/METHODOLOGY.md) | [Team Guide](docs/TEAM_GUIDE.md) | [Field Notes](docs/FIELD_NOTES.md) | [Planning Instructions](docs/PLANNING_INSTRUCTIONS.md) | [Handoff Format](docs/HANDOFF_FORMAT.md) | [FAQ](docs/FAQ.md)

[Worked example](example/) — completed planning documents from a real project.

---

> Created by Albert Dobmeyer & Claude (Anthropic) — AKD AUTOMATION SOLUTIONS
> Built on [Spec-Kit](https://github.com/github/spec-kit) (MIT) + Claude Code best practices by Boris Cherny (Anthropic)
> Licensed under [CC BY-SA 4.0](LICENSE) | Companion: [agent-token-meter](https://github.com/albertdobmeyer/agent-token-meter)
