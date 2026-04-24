# 05-CONSTRUCTION-SITES. {PROJECT_NAME}

> **Living Implementation Debt Tracker.** Maintained by the agent during every implementation session. This file is **not** a bug tracker. bugs are things that don't work. Construction sites are things that work at a **shallower depth than specified** (`[D]` delivered as `[W]`, `[W]` delivered as `[E]`, data structure without its triggering behavior).
>
> **Zero entries at project end means one of two things**: no flattening ever happened (rare), or simplifications were silent (likely). Silent simplification is a spec violation. Every downgrade gets logged **at the moment it happens**, not weeks later in a code review.

## How to use this file

- The **agent** appends a row to the table whenever it simplifies a specified requirement during implementation. The `dna:construction-logger` subagent owns this responsibility. see `.claude/agents/dna-construction-logger.md`.
- The **human architect** reviews open entries at every phase boundary. `[D]` requirements with `OPEN` entries block phase completion unless the architect explicitly approves deferral with a concrete resolution plan.
- An entry is **closed** only when the specified depth is achieved. not when the code is "good enough."
- **Accumulation is a signal**: if 3+ entries accumulate on a single Experience Fidelity Scenario, the implementation approach needs rethinking. It's not a patching problem, it's an architecture problem. Escalate.

## Entry format

| Field | Description |
|---|---|
| **ID** | Sequential: `CS-001`, `CS-002`, ... |
| **Phase** | Which phase created the site |
| **Requirement** | The specific requirement that was shallowed (quote from spec) |
| **Specified** | `[E]` / `[W]` / `[D]`. what the spec says |
| **Implemented** | `[E]` / `[W]` / `[D]`. what was actually built |
| **Gap** | What's missing between specified and implemented |
| **Scenario Impact** | Which Experience Fidelity Scenario is affected; name the specific negative assertion or fidelity item that fails |
| **Reason** | Why the simplification happened (dependency not ready, time, complexity, scope) |
| **Resolution** | When and how the requirement will be brought to specified depth |
| **Status** | `OPEN` / `RESOLVED` / `DEFERRED` (with architect approval) |

## Severity guide

| Downgrade | Severity | Action |
|---|---|---|
| `[D]` → `[W]` | **HIGH. flattening event** | Resolution plan required. Name which negative assertions now fail. Blocks phase close unless architect approves deferral. |
| `[D]` → `[E]` | **CRITICAL. experience reduced to scaffolding** | Immediate escalation. Phase plan was wrong. |
| `[W]` → `[E]` | **MEDIUM. component exists but doesn't work** | Acceptable only if dependency isn't ready. Must resolve in current or next phase. |
| Data structure without its triggering behavior | **HIGH. schema without feature** | Often invisible. Check every model that implies scheduled / triggered / automated behavior. |
| Any downgrade with no entry logged | **SPEC VIOLATION** | Unlogged downgrades are how flattening becomes invisible. |

---

## Active sites

| ID | Phase | Requirement | Specified | Implemented | Gap | Scenario Impact | Reason | Resolution | Status |
|---|---|---|---|---|---|---|---|---|---|
| _(none yet. append rows here as simplifications happen)_ |

---

## Phase completion reports

_(Append the Experience Audit report produced at the end of each phase. Each report evaluates affected scenarios, enumerates negative-assertion pass/fail, fidelity checklist pass/fail, sites created/closed this phase, and the phase status. `COMPLETE` or `BLOCKED. requires architect review`.)_

### Phase 0. Scaffolding
_(pending)_
