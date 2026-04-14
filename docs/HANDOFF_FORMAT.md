# Handoff Document Format Reference

> Use this as a structural guide when writing handoff documents — whether Claude helps you write them or you write them yourself. See [example/](../example/) for completed examples.

---

## The Four Documents

Every project needs these four documents before building starts. Together they tell Claude Code + Spec-Kit: what to build, how it's shaped, what rules to follow, and what NOT to build.

---

## VISION.md

**Purpose:** What you're building, for whom, and what the user experiences.

**Required sections:**

### Problem Statement
Who has the pain? What is the pain? One paragraph.

### Target Users
2-3 user segments with: role name, context (when/where they use it), what they care about, what frustrates them, approximate percentage of user base.

### Core Value Proposition
One sentence per user segment. "For {user}: {what they get}."

### Experience Fidelity Scenarios (1 per core feature, minimum 2 total)

Each scenario follows this structure:

```
**CONTEXT:** When, where, what the user is doing before they touch the app.

**WHAT THEY EXPERIENCE:**
Narrative of the user's journey through the feature. Concrete, sensory,
step-by-step. What do they see? What do they tap/click? What appears?

**WHAT THEY NEVER HAVE TO DO:**
- Negative assertion 1 (minimum 3)
- Negative assertion 2
- Negative assertion 3

**BEHAVIORAL VARIATION:**
- Happy path: (as described above)
- Edge case: (unusual but valid input or state)
- Error flow: (something goes wrong — what does the user experience?)

**WHY IT MATTERS:**
Quantified comparison. "Currently takes X minutes, with this app takes Y seconds."

**SUCCESS CRITERION:**
Filmable. "Video of user doing X, completing in Y seconds, without doing Z."

**DEPTH:** [D] — requires {list of components that must work together}.
```

### Depth Summary
Table mapping every requirement to `[E]`/`[W]`/`[D]` with one-line rationale.

**Relationship to Spec-Kit specs:** VISION.md is the pre-spec. It feeds into `/speckit.specify`, which produces a formal specification with testable acceptance scenarios (Given/When/Then). Once the spec exists, it supersedes VISION.md for implementation decisions. VISION.md remains the strategic reference for "why we're building this."

---

## ARCHITECTURE.md

**Purpose:** Technical shape of the system. No ambiguity.

**Required sections:**

### Tech Stack
Table: Layer | Technology | Version (pinned major.minor) | Rationale

### Module Boundaries
Directory tree showing file/folder structure with brief annotations.

### Data Model
Complete TypeScript interfaces (or equivalent) for every entity. All fields, all types, all constraints. Never "add fields as needed."

### Data Flow
How data moves through the system. Entry points, storage, exit points. Diagram or narrative.

### API Surface (if applicable)
Table: Method | Path | Auth | Purpose

### Infrastructure Decisions
Hosting, database, auth approach. Include what you chose AND what you didn't choose and why.

---

## CONSTITUTION.md

**Purpose:** Hard rules that are never negotiated during implementation.

**Structure:** Start from [CONSTITUTION_TEMPLATE.md](CONSTITUTION_TEMPLATE.md). Articles 1-9 are universal. Customize Article 10 with project-specific rules.

**Article 10 examples:**
```
- TypeScript strict mode everywhere. No `any` types.
- All colors from constants file — no hardcoded hex in components.
- Mobile-first. Test at 375px minimum.
- No confirmation dialogs for frequent actions. Use undo instead.
```

**Pre-Implementation Gate Checklist:** Include at the bottom. All boxes must be checkable before building starts.

---

## SCOPE.md

**Purpose:** What the project is NOT. One line per non-goal.

**Format:**
```
- No {feature} — {brief reason if not obvious}
- No {feature}
- No {feature} — {what to do instead if applicable}
```

**Good non-goals are specific:**
- "No user accounts" (clear)
- "No dark mode for v1" (clear, implies v2 possibility)
- "Keep it simple" (too vague — not a useful fence)

---

## Quality Checks

Before handing off to Claude Code, verify:

- [ ] VISION.md has 2+ experience fidelity scenarios with 3+ negative assertions each
- [ ] Every scenario has behavioral variation (happy + edge + error)
- [ ] Every scenario has a filmable success criterion
- [ ] ARCHITECTURE.md has pinned versions for every dependency
- [ ] ARCHITECTURE.md has complete data model (no "TBD" fields)
- [ ] CONSTITUTION.md has a customized Article 10
- [ ] SCOPE.md has 8+ explicit non-goals
- [ ] Total word count across all four docs is under 3000 words
- [ ] No implementation code in any document (patterns and schemas are fine, logic is not)
