---
name: "dna-decompose"
description: "Break down work that exceeds a single agent context into independent, merge-conflict-free chunks."
argument-hint: "Optional: 'analyze' to assess without modifying, or specific phase to decompose"
compatibility: "Requires spec-kit project structure with tasks.md and plan.md"
metadata:
  author: "project-dna"
  source: "template/skills/dna-decompose"
user-invocable: true
disable-model-invocation: false
---

## User Input

```text
$ARGUMENTS
```

## Purpose

A single agent context cannot reliably build an entire application. This skill decomposes work into **chunks** — independent slices of the project that can each be completed in one agent session with no merge conflicts between them.

This is complexity management: the agent applies abstraction principles to partition the work so that sub-agents (or the same agent across sessions) can work on different chunks without stepping on each other.

## After agent proposes decomposition — validate with the script

The decomposition itself is agentic work (creative task-splitting). But the RESULT must be merge-safe: no two `[P]` parallel tasks may touch the same file. Validate mechanically:

```bash
bash .claude/skills/dna-decompose/run.sh
```

- Exit `0` → decomposition is merge-safe. Proceed to `/dna-delegate`.
- Exit `1` → overlaps detected. Fix by removing `[P]` from one of each overlapping pair, or by extracting the shared file's changes into a serial prerequisite task.
- Exit `2` → setup problem (no tasks.md).

This turns CONSTITUTION Article 8's "[P] tasks must have ZERO file overlap" rule from prose into a check with an exit code.

## Analysis

### Step 1: Load Project Shape

1. Read `tasks.md` — full task list with phases, `[P]` markers, and file paths.
2. Read `plan.md` — architecture, module boundaries, file structure.
3. Read `ARCHITECTURE.md` — tech stack, data model, data flow.
4. If `data-model.md` exists, read it for entity relationships.

### Step 2: Build the File Dependency Graph

For every task in tasks.md, extract:
- **Target file** — the file the task creates or modifies
- **Dependencies** — other files this task reads from or imports
- **Phase** — which phase the task belongs to

Build a map:
```
File → [tasks that touch it] → [files those tasks depend on]
```

### Step 3: Identify Chunk Boundaries

A **chunk** is a set of tasks that:
1. **Share no files** with tasks in other chunks (zero merge conflict guarantee)
2. **Can be completed in one session** (~30-50 tasks max, depending on complexity)
3. **Have a clear interface** — the chunk's output is consumed by other chunks via defined contracts (function signatures, API endpoints, data schemas), not via shared mutable state
4. **Are independently testable** — the chunk's tests pass without other chunks being implemented

**Chunking algorithm:**
- Start with the file dependency graph
- Group tasks that share files into the same chunk (they MUST be sequential)
- Tasks that touch isolated files with no cross-dependencies become independent chunks
- Shared data models, interfaces, and type definitions go into a **foundation chunk** that must be completed first

### Step 4: Size Each Chunk

Estimate each chunk's context cost:
- Each source file: ~200-500 tokens to read, ~500-2000 tokens to write
- Each test file: ~300-800 tokens
- Overhead per chunk: ~5000 tokens for context loading (CLAUDE.md, plan, spec)
- Target: each chunk should fit comfortably in the **green zone** (<60k tokens of work)

If a chunk exceeds ~40k tokens of estimated work, split it further along module or layer boundaries.

## Output

### If user input is "analyze":

Report the decomposition without modifying anything:

```markdown
## Decomposition Analysis

**Total tasks:** N
**Estimated total context:** ~Nk tokens
**Recommended chunks:** N

### Chunk 1: Foundation (must be first)
- Tasks: T001-T009
- Files: src/models/*, src/types/*
- Est. context: ~25k tokens
- Produces: data models, type definitions, shared interfaces

### Chunk 2: [User Story 1]
- Tasks: T010-T017
- Files: src/services/auth.*, src/routes/auth.*, tests/test_auth.*
- Est. context: ~30k tokens
- Depends on: Chunk 1 (imports models)
- Produces: auth service, auth routes, auth tests

### Chunk 3: [User Story 2] — can run PARALLEL with Chunk 2
- Tasks: T018-T023
- Files: src/services/payment.*, src/routes/payment.*, tests/test_payment.*
- Est. context: ~25k tokens
- Depends on: Chunk 1 (imports models)
- Produces: payment service, payment routes, payment tests

### File Overlap Check
| File | Touched by chunks |
|------|-------------------|
| src/models/user.py | Chunk 1 only — SAFE |
| src/app.py | Chunk 2, Chunk 3 — CONFLICT: merge route registration |

### Recommendations
- Chunks 2 and 3 can run in parallel IF app.py route registration is moved to Chunk 1
- [Other recommendations]
```

### If user input is a phase or is empty:

1. Output the decomposition analysis (as above)
2. Ask the user: "Should I create delegation files for each chunk? This will generate scoped AGENT files for sub-agents."
3. If user confirms, invoke `/dna-delegate` for each chunk.

## Rules

- The foundation chunk always runs first. It defines the interfaces that other chunks implement against.
- If ANY file appears in more than one chunk, the decomposition is wrong. Fix it before proceeding.
- Chunks must be testable independently. If a chunk's tests require another chunk's code, the boundary is wrong.
- Prefer chunking by **user story** (vertical slices) over chunking by **layer** (horizontal slices). A vertical slice (model + service + route + test for one feature) is independently testable. A horizontal slice (all models, then all services) is not.
