# Team Guide — Multi-Developer Workflow

> **Purpose:** Guide for a team lead managing multiple developers on feature branches using Claude Code + Spec-Kit + the anti-flattening methodology.

---

## 1. Overview

This guide is for a **team lead** setting up a project where 2-10 developers work concurrently on feature branches, each using Claude Code with Spec-Kit.

The model is simple: **main is the contract**. The lead owns the handoff documents on main (VISION, ARCHITECTURE, CONSTITUTION, SCOPE). Developers build features against that contract on numbered branches. PRs are reviewed against the constitution and vision before merging.

---

## 2. Lead Setup

Run once at the start of the project:

```bash
# 1. Copy the DNA files into your project
cp project-dna/template/AGENT.md ./my-project/CLAUDE.md
cp project-dna/template/CONSTITUTION.md ./my-project/

# 2. Open in Claude Code
cd my-project && claude
# Say: "Read CLAUDE.md"
```

The agent bootstraps Spec-Kit and creates handoff doc skeletons. Then complete the four handoff documents:

| Document | What the lead writes |
|----------|---------------------|
| **VISION.md** | Problem, users, experience fidelity scenarios with negative assertions |
| **ARCHITECTURE.md** | Tech stack (pinned versions), modules, data model, data flow |
| **CONSTITUTION.md** | Customize Article 10 with team rules (see below) |
| **SCOPE.md** | 8+ explicit non-goals |

### Article 10: Team-Specific Rules

This is where team policy goes. Examples:

```
- All PRs require at least 1 approval before merge
- Session budget: each feature implementation completes within 3 Claude Code sessions
- No direct pushes to main — all changes via PR
- Run full test suite locally before opening PR
- Handoff note required at end of every Claude Code session
- TypeScript strict mode everywhere — no `any` types
```

Commit everything to main and push:

```bash
git add -A && git commit -m "docs: complete handoff documents" && git push
```

**Main is now the contract.** Every developer builds against it.

---

## 3. Dev Onboarding

Steps for each developer joining the project:

1. **Clone the repo**
   ```bash
   git clone <repo-url> && cd my-project
   ```

2. **Read CLAUDE.md** — it points to everything else and sets the rules

3. **Read CONSTITUTION.md** — understand the rules before writing any code. Pay attention to Article 10 (team-specific rules)

4. **Read VISION.md and SCOPE.md** — understand what to build and what NOT to build

5. **Read ARCHITECTURE.md** — understand the technical shape

6. **Start first feature** (see section 4)

Developers should NOT modify handoff documents on their feature branches. If they find a gap or disagreement, they propose a change to main via PR (see section 9).

---

## 4. Feature Workflow Per Developer

Each feature follows the Spec-Kit progression:

```bash
# 1. Create feature spec (auto-creates numbered branch + spec directory)
/speckit-specify "Add user authentication with OAuth2"
# → Creates branch 001-user-auth
# → Creates specs/001-user-auth/spec.md

# 2. Clarify ambiguities (optional)
/speckit-clarify

# 3. Create technical plan
/speckit-plan
# → Creates plan.md, research.md, data-model.md

# 4. Break into tasks
/speckit-tasks
# → Creates tasks.md with test-first ordering

# 5. Implement
/speckit-implement
# → Build, test, commit on green

# 6. Open PR to main
gh pr create --title "feat: add OAuth2 authentication"
```

**Branch numbering:** Spec-Kit auto-assigns sequential numbers. Developer A gets `001-user-auth`, Developer B gets `002-payment-flow`, Developer C gets `003-notifications`. Each branch has its own isolated `specs/` directory.

**One feature per branch.** Clean, focused PRs. Don't bundle unrelated work.

---

## 5. PR Review Protocol

The lead reviews every PR against:

### Constitution Compliance
- **Article 1:** Tests written first? Full suite green?
- **Article 3:** Tasks derived from user behaviors, not feature names?
- **Article 5:** Any simplifications logged? If 3+ on one scenario, escalate — it's an architecture problem.
- **Article 10:** Team-specific rules followed?

### Vision Fidelity
- Do the Experience Fidelity Scenarios from VISION.md pass?
- Check `[D]` requirements specifically — these are the most vulnerable to flattening.
- Were negative assertions preserved? (These are the first things cut.)

### Scope Boundaries
- Did the developer build anything listed as a non-goal in SCOPE.md?

### Depth Tag Verification
- Are `[D]` requirements truly delivered (multi-component integration)?
- Or were they silently downgraded to `[W]` (works in isolation)?

### Implementation Debt
- Review any simplifications logged per Article 5.
- `[D]`→`[W]` downgrades need a resolution plan.

### Suggested PR Template

```markdown
## What this PR does
<!-- One paragraph -->

## Constitution checklist
- [ ] Tests written before implementation (Art. 1)
- [ ] All tests green
- [ ] Tasks derived from behaviors, not feature names (Art. 3)
- [ ] All simplifications logged (Art. 5)
- [ ] No scope violations (SCOPE.md)
- [ ] [D] requirements delivered, not downgraded to [W]
- [ ] Team rules followed (Art. 10)

## Spec artifacts
- specs/NNN-feature/spec.md
- specs/NNN-feature/plan.md
- specs/NNN-feature/tasks.md
```

---

## 6. Constitution Governance

- **Articles 1-9** are universal. They apply to every project built with this methodology. They are never changed.
- **Article 10** is project-specific. Changes require a PR to main, reviewed and approved by the lead.
- **The constitution is law.** Developers do not override it on feature branches. If a dev encounters a situation where the constitution seems wrong, they raise it with the lead — they do not work around it.
- **`.specify/memory/constitution.md`** is synced from CONSTITUTION.md on main. When main updates, devs pull and the memory copy updates automatically.

---

## 7. Cost Control

### Token Meter

Every developer should run the token meter in a split terminal pane:

```bash
npx agent-token-meter
```

It shows burn rate, context tax, and tells you when to write a handoff and `/clear`.

### Session Budget

Define a per-feature session budget in Article 10. Example:

```
- Each feature implementation should complete within 3 Claude Code sessions
- Write a handoff note before ending any session
```

### Handoff Discipline

At the end of each Claude Code session:
1. Write a handoff note in the spec directory (`specs/001-feature/handoff.md`)
2. Describe: what's done, what's next, what's blocked
3. `/clear` to reset context
4. Next session: Claude reads the handoff note and picks up where you left off

This prevents quadratic cost growth from bloated conversation history.

### When to Start New Sessions

Natural handoff points in the Spec-Kit workflow:
- After `/speckit-specify` completes → handoff, `/clear`
- After `/speckit-plan` completes → handoff, `/clear`
- After `/speckit-tasks` completes → handoff, `/clear`
- During `/speckit-implement` — after completing each phase of tasks

### Lead Monitoring

Periodically check team token usage for signs of spinning sessions (high token count, low commit count). The token meter makes this visible.

---

## 8. Shared vs Per-Dev Files

### Shared (on main, owned by lead)

| File | Purpose | Who changes it |
|------|---------|---------------|
| `CLAUDE.md` | Agent instructions and rules | Lead only |
| `VISION.md` | What to build and why | Lead only |
| `ARCHITECTURE.md` | Technical shape | Lead only (see section 9) |
| `CONSTITUTION.md` | Hard rules | Lead only (Art. 10 via PR) |
| `SCOPE.md` | What NOT to build | Lead only |
| `.specify/memory/constitution.md` | Spec-Kit memory copy | Synced from CONSTITUTION.md |

### Per-Dev (on feature branches)

| File | Purpose | Who changes it |
|------|---------|---------------|
| `specs/001-feature/spec.md` | Feature specification | Developer who owns the branch |
| `specs/001-feature/plan.md` | Technical plan | Developer |
| `specs/001-feature/tasks.md` | Task breakdown | Developer |
| `specs/001-feature/handoff.md` | Session handoff notes | Developer |
| Feature code + tests | Implementation | Developer |

When a feature branch merges to main, the `specs/NNN-feature/` directory comes along as a historical record. The shared docs on main are untouched by feature branches.

---

## 9. When Architecture Changes

Architecture evolution is inevitable. Handle it cleanly:

1. **Only the lead updates ARCHITECTURE.md on main.** Devs never edit it on their feature branches.

2. **If a dev discovers architecture needs changing:**
   - Do NOT change ARCHITECTURE.md on the feature branch
   - Create a separate PR to main proposing the change
   - Include: what changed, why, and what existing feature work is affected
   - Lead reviews and merges (or opens a discussion)

3. **After an architecture update on main:**
   - All active devs pull main into their feature branches
   - Re-read ARCHITECTURE.md to understand the change
   - Adjust in-progress work if affected

4. **Architecture PRs take priority over feature PRs.** They unblock the whole team.

---

## 10. When Feature Branches Conflict

Two developers building related features will eventually produce merge conflicts. Handle them cleanly:

### Prevention

- **Spec-Kit's numbered branches isolate spec directories.** Dev A's `specs/001-auth/` never conflicts with Dev B's `specs/002-payments/`. Spec artifacts merge cleanly.
- **Lead should sequence features with shared dependencies.** If two features touch the same data model or module, one should merge first. Plan this during feature assignment.
- **Small, focused PRs.** One feature per branch. Don't bundle unrelated work. Smaller surface = fewer conflicts.

### Resolution

When conflicts happen despite prevention:

1. **The second-to-merge developer resolves.** Whoever's PR is still open when the first one merges is responsible for rebasing and resolving.
2. **Rebase on updated main, don't merge main into the feature branch.** This keeps the commit history clean.
3. **If the conflict is architectural** (two features made incompatible design choices), escalate to the lead. Don't resolve by picking one side — the lead decides which pattern wins and may update ARCHITECTURE.md.
4. **Re-run the full test suite after conflict resolution.** Constitution Article 1 — never commit on red.
5. **If the conflict is in spec artifacts** (`specs/` directory): both specs are valid historical records. Merge both. The code is what needs reconciling, not the specs.

---

*Part of [project-dna](../README.md). See also: [METHODOLOGY.md](METHODOLOGY.md), [AGENT_SETUP.md](AGENT_SETUP.md), [CONSTITUTION.md](../template/CONSTITUTION.md).*
