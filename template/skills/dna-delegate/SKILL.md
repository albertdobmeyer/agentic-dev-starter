---
name: "dna-delegate"
description: "Spawn a sub-agent with scoped context, interface contracts, and merge-conflict-free file boundaries."
argument-hint: "Chunk name or task range to delegate (e.g., 'Chunk 2' or 'T010-T017')"
compatibility: "Requires decomposition from /dna-decompose. Works with Claude Code sub-agents."
metadata:
  author: "project-dna"
  source: "template/skills/dna-delegate"
user-invocable: true
disable-model-invocation: false
---

## User Input

```text
$ARGUMENTS
```

You **MUST** specify which chunk or task range to delegate.

## Purpose

Sub-agents are powerful but dangerous. Without scoping, two sub-agents will modify the same files and produce merge conflicts. This skill creates a **scoped delegation context** — everything the sub-agent needs to do its work, and hard boundaries on what it must NOT touch.

## Pre-dispatch safety check — run the script first

Before invoking the Agent tool to spawn sub-agents, verify preconditions:

```bash
bash .claude/skills/dna-delegate/run.sh
```

Checks:
- `dna-decompose` script passed (all `[P]` tasks have disjoint file sets)
- Working tree is clean (sub-agents operate on current state; unsaved changes cause confusion)
- `plan.md` has a "Shared Interfaces" / "Contracts" section (so sub-agents import shared types, never create competing definitions)
- Nudges toward running `dna:cross-checker` if other feature branches are open

Exit `0` = dispatch safely. Exit `1` = fix preconditions first. Exit `2` = setup problem.

Actual sub-agent spawning uses the Agent tool in main-agent context; the script only validates what a script CAN validate.

## Pre-Execution

1. Read the decomposition output from `/dna-decompose`. If no decomposition exists, tell the user to run `/dna-decompose` first.
2. Identify the chunk from user input. Match against chunk names or task ID ranges.
3. Verify the chunk has no file overlaps with currently active delegations.

## Delegation Context Assembly

### Step 1: Collect What the Sub-Agent Needs

For the target chunk, assemble:

**Files to READ (context):**
- `CLAUDE.md` — the agent protocol (always included)
- `CONSTITUTION.md` — the engineering contract (always included)
- `plan.md` — architecture and tech decisions (always included)
- `data-model.md` — entity schemas (if chunk uses shared models)
- Interface files from the foundation chunk (type definitions, shared contracts)

**Files to WRITE (the chunk's scope):**
- List every file this chunk creates or modifies
- These files belong exclusively to this sub-agent — no other agent may touch them

**Files that are OFF-LIMITS:**
- Every file NOT in the write list
- Explicitly list files that other chunks own (prevents "helpful" modifications)

### Step 2: Generate the Sub-Agent Briefing

Create a scoped instruction file for the sub-agent:

```markdown
# Sub-Agent Briefing: [CHUNK NAME]

## Your Scope
You are implementing [chunk description]. You own the following files — create and modify ONLY these:

[list of files]

## DO NOT TOUCH
These files belong to other chunks. Do not read them for implementation details, do not modify them, do not import from them unless they are listed in your interface contracts below.

[list of off-limits files]

## Interface Contracts
You depend on these interfaces from the foundation chunk. They exist (or will exist) exactly as specified:

[paste relevant type definitions, function signatures, API contracts]

Your code must import from these interfaces. Do not redefine them. If an interface is missing or wrong, STOP and report — do not work around it.

## Tasks
[paste the specific tasks from tasks.md for this chunk]

## Test-First
Write tests for every implementation task BEFORE implementing. Run /dna-test-gate to verify.

## When Done
1. All tests pass for your files
2. No modifications outside your file scope
3. Write a completion note: what you built, what interfaces you consumed, any issues
```

### Step 3: Execute Delegation

**For Claude Code sub-agents:**

```
Use the Agent tool to spawn a sub-agent with:
- prompt: the Sub-Agent Briefing content
- isolation: "worktree" (if available — gives the sub-agent its own copy of the repo)
```

**For multi-developer teams:**

Output the Sub-Agent Briefing as a file in the feature spec directory:
```
FEATURE_DIR/delegations/chunk-N-briefing.md
```

The developer assigned to this chunk reads the briefing and works within its boundaries.

### Step 4: Track Active Delegations

Maintain a delegation registry in the feature spec directory:

```markdown
# Active Delegations

| Chunk | Files Owned | Status | Agent/Developer |
|-------|-------------|--------|-----------------|
| Foundation | src/models/*, src/types/* | COMPLETE | main agent |
| Chunk 2: Auth | src/services/auth.*, tests/test_auth.* | IN PROGRESS | sub-agent-1 |
| Chunk 3: Payment | src/services/payment.*, tests/test_payment.* | IN PROGRESS | sub-agent-2 |
```

Before delegating a new chunk, verify no file overlaps with IN PROGRESS delegations.

### Step 5: Merge Validation

When a sub-agent completes:

1. **File scope check** — did the sub-agent modify any files outside its scope? If yes, reject.
2. **Interface compliance** — does the sub-agent's code use the interfaces as specified? If it redefined or worked around them, reject.
3. **Test suite** — run the full test suite (not just the chunk's tests). Any regressions → investigate.
4. **Update delegation registry** — mark chunk as COMPLETE.
5. **When all chunks complete** — run the full integration test suite. This is the `[D]` (Delivers) gate from the constitution.

## Rules

- Never delegate the foundation chunk. The main agent builds it — it defines the interfaces everyone else depends on.
- One file, one owner. If two chunks need to modify the same file, the decomposition is wrong. Go back to `/dna-decompose`.
- Sub-agents do NOT read other sub-agents' output. They work against interfaces, not implementations.
- The merge validation in Step 5 is mandatory. "It compiled" is not validation. "All tests pass including integration" is validation.
