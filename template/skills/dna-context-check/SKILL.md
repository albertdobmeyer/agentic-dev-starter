---
name: "dna-context-check"
description: "Token-aware workflow management. Monitors context depth and triggers handoff before the dumb zone."
argument-hint: "Optional: 'status' for a quick check, 'handoff' to force a handoff now"
compatibility: "Works with any Claude Code project. Enhanced with agent-token-meter if running."
metadata:
  author: "project-dna"
  source: "template/skills/dna-context-check"
user-invocable: true
disable-model-invocation: false
---

## User Input

```text
$ARGUMENTS
```

## Purpose

AI agents have a context window. Even at 1M tokens, there is a "dumb zone". a region past ~100k tokens where response quality degrades and costs grow quadratically. This skill manages the agent's working memory:

- **Detect** when context is growing dangerously deep
- **Trigger** structured handoffs at natural workflow boundaries
- **Preserve** continuity across sessions via handoff documents
- **Integrate** with agent-token-meter for precise burn-rate data

## Execution. run the script

```bash
bash .claude/skills/dna-context-check/run.sh
```

The script reads `agent-token-meter` output (if running) and emits:

- Exit `0` → SAFE (< 70k tokens used). Continue.
- Exit `1` → WARNING (70k-100k). Plan to finish current logical unit; write handoff within next ~30k tokens.
- Exit `2` → HANDOFF_REQUIRED (> 100k). Write session handoff NOW before continuing. Required artifact is outlined in the script's output.
- Exit `3` → UNMEASURED (token-meter not running). Start it: `npx agent-token-meter` in a split pane. Without it, the 100k handoff rule is on the honor system; main agent must self-estimate.

Handoff thresholds come from `CONSTITUTION.md` Article 10 if declared (grep for "session budget: Nk"); otherwise the methodology default of 100k.

## Context Assessment

### Step 1: Estimate Context Depth

Check for agent-token-meter output:

```bash
# Check if token meter is running and has output
# Look for .token-meter-output or similar in project root
```

If token meter data is available, read it for precise numbers. If not, estimate based on conversation length and files read.

**Context zones:**

| Zone | Token Range | Action |
|------|-------------|--------|
| **Green** | 0. 60k | Continue working. No action needed. |
| **Yellow** | 60k. 100k | Awareness. Finish current task, then consider handoff. |
| **Red** | 100k. 150k | **Handoff now.** Complete the immediate task, write handoff, `/clear`. |
| **Critical** | 150k+ | **Emergency handoff.** Stop, write handoff immediately, `/clear`. Quality is degrading. |

### Step 2: Identify Natural Handoff Boundaries

The best time to handoff aligns with spec-kit workflow phases:

- After `/speckit-specify` completes → handoff, `/clear`
- After `/speckit-plan` completes → handoff, `/clear`
- After `/speckit-tasks` completes → handoff, `/clear`
- During `/speckit-implement` → after completing each phase of tasks
- After `/dna-test-gate` passes → good handoff point before implementation

### Step 3: Report

**If user input is "status":**

Output a one-line status:
```
Context: [GREEN/YELLOW/RED/CRITICAL] | Estimated: ~Nk tokens | Recommendation: [continue/finish task then handoff/handoff now]
```

**If user input is "handoff" or context is RED/CRITICAL:**

Proceed to handoff protocol (Step 4).

**If context is GREEN/YELLOW:**

Output status and continue. No interruption.

## Handoff Protocol (Step 4)

When a handoff is triggered:

1. **Write handoff note** to the active spec directory:

   File: `FEATURE_DIR/handoff.md` (append if exists, create if not)

   ```markdown
   ## Handoff. [TIMESTAMP]

   ### Done
   - [List completed tasks with IDs from tasks.md]

   ### In Progress
   - [Current task, what's done, what remains]

   ### Next
   - [Next tasks to pick up]

   ### Blocked
   - [Any blockers or decisions needed]

   ### Context
   - [Key decisions made this session that the next session needs]
   - [Files modified, tests written, tests passing/failing]
   ```

2. **Update tasks.md**. mark completed tasks as `[X]`.

3. **Tell the user:**
   ```
   Handoff written to [path]. Run `/clear` to reset context.
   Next session: "Read CLAUDE.md, then read [FEATURE_DIR]/handoff.md and continue."
   ```

## Auto-Trigger Integration

This skill should be invoked automatically by the agent at these points:
- Before starting any new spec-kit phase
- After completing a phase of implementation tasks
- When the agent notices degraded response quality (repeating itself, losing track of requirements, hallucinating file contents)

The agent does not need the user to invoke `/dna-context-check`. it should self-monitor and trigger when needed. The skill exists for manual invocation and as a reference for the auto-trigger behavior.
