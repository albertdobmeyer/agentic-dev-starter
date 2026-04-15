# Frequently Asked Questions

## Getting Started

**Q: Do I need to install Spec-Kit CLI (`specify-cli`)?**
A: Not manually. The agent instructions in AGENT.md tell the agent to install Spec-Kit CLI via `uv tool install specify-cli` during bootstrap. If it's already installed, it just uses it.

**Q: Do I need Claude Desktop AND Claude Code?**
A: No. You need Claude Code for building. For planning, you can either use Claude Code directly ("Read CLAUDE.md, help me plan this project") or use Claude Desktop with the planning instructions pasted into Custom Instructions for a more structured planning experience. Both work.

**Q: What if my project is small? Do I need all four handoff documents?**
A: CONSTITUTION.md and VISION.md are the minimum. They give the agent enough to spec and build correctly. ARCHITECTURE.md adds value for any project with a tech stack decision. SCOPE.md prevents rabbit holes. The agent creates skeleton handoff docs during bootstrap if they don't exist.

**Q: Can I use this with an existing project that already has code?**
A: Yes. Copy `template/AGENT.md` and `template/CONSTITUTION.md` into your project. The agent's bootstrap step only creates handoff doc skeletons if they don't already exist — your source code, tests, and other project files are not touched.

## Planning Phase

**Q: The planning session keeps asking questions instead of producing documents. Is that normal?**
A: Yes. The methodology eliminates ambiguity before producing handoff docs. If Claude is asking questions, your project description has gaps that would become wrong assumptions during the build. Answer them. The docs come once there's enough clarity.

**Q: How long should planning take?**
A: For a straightforward project, 30-45 minutes. For complex projects with multiple user types, 1-2 hours.

**Q: Can I write the handoff docs myself without Claude?**
A: Yes. Use [HANDOFF_FORMAT.md](HANDOFF_FORMAT.md) as your structural reference and the [example/](../example/) directory as a model. Key requirements: VISION.md needs experience fidelity scenarios with 3+ negative assertions, CONSTITUTION.md needs a customized Article 10, SCOPE.md needs explicit non-goals.

## Building Phase

**Q: How does the bootstrap differ from `specify init`?**
A: The agent runs `specify init` as part of bootstrap. If Spec-Kit CLI isn't installed, the agent installs it via `uv tool install specify-cli`. If `specify init` fails (known Windows issue with Rich library), the agent tells you — the workflow still functions with manual branch management.

**Q: Claude Code tries to plan instead of build. How do I stop it?**
A: Make sure Claude Code reads [AGENT_SETUP.md](AGENT_SETUP.md), not the planning instructions. AGENT_SETUP.md explicitly frames Claude Code as the co-engineer: "Never improvise architecture. The handoff documents define the vision."

**Q: Can I skip steps in the Spec-Kit workflow?**
A: Yes. For well-specified handoff bundles, skip `/speckit.clarify` and `/speckit.analyze`. The minimum path: constitution → specify → plan → tasks → implement. The Pre-Implementation Gate Checklist in the constitution is the "ready to build?" test.

## The Methodology

**Q: What's the difference between a negative assertion and a regular test?**
A: A regular test says "this works." A negative assertion says "the user NEVER has to do X." Regular tests verify presence of functionality. Negative assertions verify absence of friction. They catch different failure modes — and negative assertions are the first things cut during implementation, which is why they're the most valuable to specify.

**Q: How do I know if something is `[W]` or `[D]`?**
A: Ask: "Can a single component satisfy this?" If yes, it's `[W]`. If it requires multiple components working together to deliver a user experience, it's `[D]`. A function that returns correct data is `[W]`. A user who sees correct, timely, personalized data without requesting it is `[D]`.

**Q: Is this only for AI-assisted development?**
A: The methodology works for human teams too. Flattening happens whenever a rich experience is decomposed into tasks — by AI agents or by developers following a ticket board.

**Q: My VISION.md already has scenarios and depth tags. Why does /specify ask for the same things?**
A: VISION.md captures product intent — what the user experiences, aspirational scenarios, depth classifications. The /specify step translates that into testable contracts — Given/When/Then scenarios, measurable acceptance criteria, concrete success thresholds. VISION.md is the input; the spec is the output. Where they conflict on testable requirements, the spec wins. If you find yourself restating VISION.md verbatim in the spec, you're not refining enough — push for assertions an automated test suite can verify.

**Q: The commit-per-task rule feels too granular. Can I batch commits?**
A: Article 8 says "commit per logical milestone, phase boundary, or independently reviewable work unit." Committing per-phase or per logical group is fine. The rule prevents: (a) going a full day without committing, and (b) bundling unrelated changes across phases. A commit that covers 3 related tasks in the same phase is fine. A commit that spans two phases is not.

**Q: How do I use the [P] markers on tasks?**
A: Tasks marked `[P]` in the same phase are candidates for delegated sub-agent execution. Each targets a different file with no dependencies on incomplete tasks. In Claude Code, spawn sub-agents for `[P]` tasks in pairs or groups. Each agent writes to its assigned file independently, then you merge and run the test suite. This can halve implementation time for large phases.

**Q: The Spec-Kit templates have "Developer A / Developer B" sections but I'm working solo. Can I skip those?**
A: Yes. Team-oriented sections in Spec-Kit templates are designed for multi-developer coordination. For solo or 1-human + 1-agent projects, skip team strategy sections and focus on the task list and phase checkpoints.

## Token Meter

**Q: What is the token meter and why is it recommended?**
A: [agent-token-meter](https://github.com/albertdobmeyer/agent-token-meter) monitors your Claude Code session's context growth and cost in real-time. It tells you when to write a handoff and `/clear`. Long sessions accumulate cost quadratically — the meter makes that visible.

**Q: Do I have to use the token meter?**
A: No. The methodology works without it.
