# Frequently Asked Questions

## Getting Started

**Q: Do I need to install Spec-Kit CLI (`specify-cli`)?**
A: No. `init.py` bundles all Spec-Kit assets — commands, templates, and scripts. Everything is copied locally into your project. The Spec-Kit CLI is optional; if you have it installed, it works alongside the bundled assets.

**Q: Do I need Claude Desktop AND Claude Code?**
A: No. You need Claude Code for building. For planning, you can either use Claude Code directly ("Read CLAUDE.md, help me plan this project") or use Claude Desktop with the planning instructions pasted into Custom Instructions for a more structured planning experience. Both work.

**Q: What if my project is small? Do I need all four handoff documents?**
A: CONSTITUTION.md and VISION.md are the minimum. They give Claude Code enough to spec and build correctly. ARCHITECTURE.md adds value for any project with a tech stack decision. SCOPE.md prevents rabbit holes. For a quick prototype, you can also run `init.py` with `--no-speckit` to get just the handoff skeletons and CLAUDE.md.

**Q: Can I use this with an existing project that already has code?**
A: Yes. Run `init.py` with `--force` to initialize in a non-empty directory. **Warning:** `--force` will overwrite existing handoff documents (VISION.md, ARCHITECTURE.md, CONSTITUTION.md, SCOPE.md) and CLAUDE.md with fresh skeletons. Back up any customized files first. Your source code, tests, and other project files are not touched.

## Planning Phase

**Q: The planning session keeps asking questions instead of producing documents. Is that normal?**
A: Yes. The methodology eliminates ambiguity before producing handoff docs. If Claude is asking questions, your project description has gaps that would become wrong assumptions during the build. Answer them. The docs come once there's enough clarity.

**Q: How long should planning take?**
A: For a straightforward project, 30-45 minutes. For complex projects with multiple user types, 1-2 hours.

**Q: Can I write the handoff docs myself without Claude?**
A: Yes. Use [HANDOFF_FORMAT.md](HANDOFF_FORMAT.md) as your structural reference and the [example/](../example/) directory as a model. Key requirements: VISION.md needs experience fidelity scenarios with 3+ negative assertions, CONSTITUTION.md needs a customized Article 10, SCOPE.md needs explicit non-goals.

## Building Phase

**Q: How does init.py differ from `specify init`?**
A: `init.py` produces the same project structure as `specify init --ai claude` but without requiring the Spec-Kit CLI, network access, or any pip packages. It bundles the assets locally and copies them. If you already have Spec-Kit CLI installed, everything is compatible — the slash commands and scripts are identical.

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

## Token Meter

**Q: What is the token meter and why is it recommended?**
A: [agent-token-meter](https://github.com/albertdobmeyer/agent-token-meter) monitors your Claude Code session's context growth and cost in real-time. It tells you when to write a handoff and `/clear`. Long sessions accumulate cost quadratically — the meter makes that visible.

**Q: Do I have to use the token meter?**
A: No. The methodology works without it.
