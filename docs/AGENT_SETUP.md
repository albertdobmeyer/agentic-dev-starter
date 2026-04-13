# Agent Setup — Build Phase

> **Created by:** Albert Dobmeyer & Claude (Anthropic)
> **AKD AUTOMATION SOLUTIONS** — Licensed under CC BY-SA 4.0
> **Purpose:** Claude Code reads this document to understand how to use the handoff documents and Spec-Kit workflow to build the project.

---

## FOR CLAUDE CODE: READ THIS FIRST

You are the **co-engineer**. The human (or a planning session) has produced a **handoff bundle** — four documents describing WHAT to build, WHY, and under what constraints:

| Document | Purpose | Required |
|----------|---------|----------|
| **CONSTITUTION.md** | Hard rules — project axioms. | Yes |
| **VISION.md** | What to build and why. Users, journeys, acceptance criteria. | Yes |
| **ARCHITECTURE.md** | Tech stack, system shape, data model. | Yes |
| **SCOPE.md** | What the project is NOT. | Recommended |

Your job:
1. Read all four handoff documents thoroughly before proceeding
2. Build test-first, commit on green, log every simplification
3. Never improvise architecture — the handoff documents define the vision
4. When something is unclear, ask the human — don't guess

---

## SETUP: WHAT'S ALREADY DONE

If this project was initialized by `init.py` from [agentic-dev-starter](https://github.com/albertdobmeyer/agentic-dev-starter), the following is already in place:

- `.specify/templates/` — Spec-Kit templates for specs, plans, tasks, checklists
- `.specify/scripts/` — Shell scripts for branch and spec file management
- `.specify/memory/constitution.md` — Constitution loaded into Spec-Kit memory
- `.claude/commands/speckit.*.md` — Slash commands for the full Spec-Kit workflow

**No additional installation is needed.** Skip directly to "Feed the Handoff Documents" below.

### Optional: Token Meter

A burn-rate monitor that tracks context growth and cost. Run in a split terminal pane:

```bash
npx claude-code-token-meter
```

Source: https://github.com/albertdobmeyer/claude-code-token-meter

---

## FEED THE HANDOFF DOCUMENTS

### 1. Constitution

The constitution is already in `.specify/memory/constitution.md`. If the human has updated CONSTITUTION.md since initialization, re-copy it:

```bash
cp CONSTITUTION.md .specify/memory/constitution.md
```

### 2. Specify

Read VISION.md and SCOPE.md. Use their contents as input for the specify step.

If the human invokes `/speckit.specify` — provide the vision and scope as context.

If working autonomously — read `.claude/commands/speckit.specify.md` and follow its instructions, using VISION.md as the feature description and SCOPE.md as boundaries.

### 3. Clarify (Optional for Thorough Handoff Bundles)

If the handoff documents are thorough (experience fidelity scenarios with negative assertions, complete data model, explicit non-goals), clarification may be minimal. Run it, but don't block on it.

If a question CANNOT be answered from the handoff docs, ask the human.

### 4. Plan

Read ARCHITECTURE.md. Use its contents as technical context — tech stack, module boundaries, data flow, infrastructure decisions.

### 5. Analyze (Optional for Well-Specified Projects)

Cross-artifact consistency check. Run it. If issues trace back to handoff doc gaps, flag them for the human.

### 6. Tasks

Generate the task breakdown. Tasks that can run in parallel are marked `[P]`. Test tasks are ordered before implementation tasks.

### 7. Implement

Build. Test-first. Commit on green. Log every simplification per Article 5 of the constitution.

---

## MINIMUM VIABLE PATH (Small Projects)

For solo devs or demos where the full workflow feels heavy:

1. Ensure CONSTITUTION.md is in `.specify/memory/constitution.md`
2. Run specify with VISION.md
3. Run plan with ARCHITECTURE.md
4. Run tasks
5. Implement

Skip clarify and analyze if the handoff docs have complete schemas, explicit non-goals, and experience fidelity scenarios with negative assertions. The Pre-Implementation Gate Checklist in the constitution is the right "ready to build?" test.

---

## ONGOING: DEVELOPMENT PRACTICES

### Agent Best Practices

**Plan Mode for spec work.** When running specify, clarify, and plan steps — use read-only exploration. Switch to active mode for implementation.

**Keep CLAUDE.md lean.** Use `@path/to/file.md` imports to reference the constitution and specs without inlining them. Keep CLAUDE.md under 200 lines.

**Capture decisions in files.** Conversation context is lost on `/compact` or new sessions. CLAUDE.md and `.specify/` files survive.

### When Handoff Docs Are Updated

The human may place revised documents in the repo after a planning session.

1. Diff updated files against previous versions
2. Re-run the appropriate Spec-Kit step with updated contents
3. Run analyze to verify consistency
4. Update CLAUDE.md "Current State" if applicable

### CLAUDE.md Maintenance

| Trigger | Action |
|---------|--------|
| Repeated mistake | Add a prevention rule to CLAUDE.md |
| CLAUDE.md exceeds 200 lines | Move detail to docs/, keep CLAUDE.md as index |
| Tech stack changes | Update CLAUDE.md immediately |

---

## REFERENCE: DOCUMENT FLOW

```
HANDOFF DOCUMENTS                    SPEC-KIT WORKFLOW                    OUTPUT
────────────────                     ─────────────────                    ──────
CONSTITUTION.md ───────────────────► .specify/memory/constitution.md
VISION.md + SCOPE.md ──────────────► /speckit.specify ─────────────────► .specify/specs/001-*/spec.md
                                     /speckit.clarify (optional) ──────► clarifications in spec
ARCHITECTURE.md ───────────────────► /speckit.plan ────────────────────► plan.md, research.md, data-model.md
                                     /speckit.analyze (optional) ──────► consistency validation
                                     /speckit.tasks ───────────────────► tasks.md (test-first ordered)
                                     /speckit.implement ───────────────► working, tested code
```

---

*Built on GitHub's Spec-Kit (MIT License), the PROJECT DNA methodology by AKD AUTOMATION SOLUTIONS, and Claude Code best practices by Boris Cherny (Anthropic).*
