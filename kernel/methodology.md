# Methodology — agent-agnostic kernel

> **Source**: this is the extracted methodology from `PROJECT_DNA.md` (root of the kit), stripped of Claude-Code-specific idioms. Every adapter implements these rules through its own conventions.

## The core insight

> The gap between "all components pass their tests" and "the user has the intended experience" is where every spec-driven build fails. The methodology exists to close that gap structurally.

## The six invariants

Every adapter must preserve these. They're what make the methodology work regardless of which agent executes it.

### Invariant 1 — Seven-document Blueprint Package per project

Every project produces, before any code is written:

1. `00-CORE-PRINCIPLES` — problem, users, domain model, 3–7 principles.
2. `01-SYSTEM-INTENT` — entities, state machines, Experience Fidelity Scenarios, **Scenario Validation Matrices**, depth-classified requirements.
3. `02-ARCHITECTURE` — modules, API surface, data flows, **Architecture Impact Assessments**.
4. `03-EXECUTION-CONTEXT` — pinned stack, coding standards, testing philosophy, infrastructure setup.
5. `04-COORDINATION-HINTS` — phases with depth-tagged done criteria, **Production Threshold**, non-goals.
6. `05-CONSTRUCTION-SITES` — living debt tracker, appended throughout the build.
7. `CONSTITUTION` — 9 universal articles + Article 10 customized per project.

Exact directory layout is adapter-specific. The 7 documents and their contents are not.

### Invariant 2 — Experience Fidelity Scenarios with ≥3 negative assertions each

Every core principle produces at least one scenario with:
- Context (when/where/carrying/time budget)
- Sensory narrative (see/hear/do)
- ≥3 **negative assertions** ("user NEVER has to ...")
- Behavioral variation (happy + edge + error)
- Quantified "why it matters"
- Filmable success criterion

Negative assertions are the highest-priority drift detector. A scenario with only positive assertions ("user can X") produces tasks that each pass tests but never compose into the intended experience — flattening.

### Invariant 3 — Scenario Validation Matrix as a required deliverable

Per scenario, a bidirectional table:
- Every scenario assertion → the task(s) that satisfy it.
- Every task → the assertion(s) it serves.
- "Uncovered Assertions" column must be empty before planning proceeds.
- "Tasks Without Assertions" column must be empty before planning proceeds.

Without the matrix, coverage is assumed. With the matrix, gaps are visible as rows.

### Invariant 4 — Depth classification `[E]` / `[W]` / `[D]` on every requirement

- `[E]` Exists — present, not functional (scaffolding).
- `[W]` Works — correct in isolation (unit-testable).
- `[D]` Delivers — integrated user experience (multi-component; only verifiable by walking the scenario).

Rules:
- Every core principle has ≥1 `[D]` requirement (emergent-behavioral principles may have `[W]` with explicit rationale).
- No `[D]` is satisfiable by a single component.
- Data structures that imply automatic behavior (scheduled reports, notifications) need `[W]` for the structure AND `[D]` for the triggering automation.

### Invariant 5 — Living Construction Sites tracker, appended at the moment of simplification

Every `[D]→[W]` or `[W]→[E]` downgrade gets logged when it happens — not weeks later. The tracker captures: requirement, gap, scenario impact, reason, resolution plan, status.

Rules:
- Silent simplification is a spec violation. Every downgrade has an entry.
- Accumulation of 3+ entries on one scenario = architecture problem, not patching problem; escalate.
- Entries close only when the specified depth is achieved.

### Invariant 6 — Audit isolation: builder should not grade its own work

The entity (human or subagent) that verifies a feature's fidelity must not carry context from the build conversation. Fresh read from disk: spec, code, tests. This is the bias firewall.

Concretely: the judgmental post-implementation verifier (PROJECT_DNA Section 4.3) runs in a separate context with zero carryover from implementation. The mechanical layer (coverage %, test presence) is OK to run inline.

## The workflow (invariant sequence)

Every feature, regardless of adapter:

```
1. Check existing material / entry mode
2. Blueprint Package present + complete (run spec-auditor role)
3. Run cross-check across other open features (run cross-checker role)
4. /speckit-specify equivalent — produces spec.md referencing scenarios
5. Verify test floor — tests exist AND fail before implementation (run test-gate)
6. Decompose into merge-safe parallel chunks (run decomposer validator)
7. Implement — solo or via delegated sub-agents (run delegate safety check before dispatch)
8. Mechanical verification floor (run verify-mechanical)
9. Judgmental verification ceiling (run verifier subagent, FRESH CONTEXT)
10. Log any simplifications to construction sites tracker
11. Write per-feature retrospective
12. Merge
```

Adapter-specific: how step 4's spec is written, where tests live, what "sub-agent" looks like in this platform's runtime. Non-adapter-specific: that each step happens and in this order.

## The pushback contract (invariant 7, reserved)

The agent refuses:
- Requests to skip tests → cite Article 1.
- Requests to "just make it work" without spec → cite Article 2.
- Requests to merge with failing tests → cite Article 8.
- Requests to silently downgrade `[D]` to `[W]` → cite Article 5, log Construction Site instead.

The agent accepts and logs:
- Human has domain knowledge the agent lacks → defer, log decision.
- Human explicitly overrides with rationale → accept, log as Article 5 simplification.

This contract is prose-only today (critique: "depends on the model's compliance tendency"). Future: checkable via per-session audit against this list.

## Relationship to the full PROJECT_DNA document

This file is a compressed contract. The authoritative reference is `PROJECT_DNA.md` at the kit root, especially:
- Section 3.5 (Scenario format + Validation Matrix + Architecture Impact Assessment + Coherence Check)
- Section 4 (Phase structure + Testing Contract + Experience Audit)
- Section 5 (Construction Site Tracking)
- Section 6 (Drift Remediation — anti-Frankenstein protocol)
- Appendix D (Quick reference: depth tags + 20-item flattening detection checklist)

When a contradiction arises between this file and PROJECT_DNA, PROJECT_DNA wins.
