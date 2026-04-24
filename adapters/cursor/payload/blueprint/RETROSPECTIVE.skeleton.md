# Retrospective: feature {NNN-name}

> One retrospective per feature, written at the moment the feature merges to `main`. Lives at `specs/{NNN-name}/retrospective.md`. Appended into the kit's aggregate corpus by `tools/aggregate-retros.sh` so the methodology becomes **measured** instead of anecdotal.
>
> Fill each section honestly. A retrospective that says "everything went fine" on every feature is a methodology failure: either nothing is being surfaced, or the data is being sanitized. The point is to capture what the spec didn't anticipate.

## Meta

| Field | Value |
|---|---|
| Feature | `{NNN-name}` |
| Principle(s) served | Principle {N} / Scenario {N} |
| Shipped on | {YYYY-MM-DD} |
| Total elapsed (wall-clock, spec to merge) | {N days} |
| Session count | {N sessions} |
| Tokens consumed (if measured) | {N tokens} |
| PRs to main | {N} |

## What the scenario required vs what shipped

- **Specified depth**: `[E]` / `[W]` / `[D]`
- **Implemented depth**: `[E]` / `[W]` / `[D]` (as verified by `dna:verifier` subagent)
- **Construction Sites opened during this feature**: {N}
- **Construction Sites closed during this feature**: {N}
- **Negative assertions that passed `dna:verifier`**: {N/total}
- **Negative assertions that required a Construction Site entry**: {N}

## Simplifications logged (from Construction Sites)

| CS-ID | Severity | Why | Resolution status |
|---|---|---|---|
| CS-{NNN} | HIGH / MEDIUM / CRITICAL | {one sentence} | OPEN / RESOLVED / DEFERRED |

_(Leave empty if none.)_

## DNA checks fired

| Check | Outcome | Notes |
|---|---|---|
| `dna-test-gate` (pre-impl) | PASS / FAIL / not run | |
| `dna-cross-checker` (pre-spec) | CLEAR / WARN / BLOCK | |
| `dna-spec-auditor` (end of spec) | CLEAR / WARN / BLOCK | |
| `dna-decompose` (merge-safety validator) | PASS / FAIL | |
| `dna-delegate` (pre-dispatch) | PASS / FAIL | |
| `dna-verify` script (mechanical floor) | PASS / FAIL | |
| `dna:verifier` subagent (judgmental ceiling) | CONGRUENT / PARTIAL / DIVERGENT | |
| `dna-context-check` handoff events | {N triggered} | |

## Spec drift

- **Spec changes during build** (how many times `spec.md`, `plan.md`, or `tasks.md` were edited after the first commit on this branch): {N}
- **Cause of each drift**: {one line per event, e.g., "missed an edge case in Scenario 2", "architecture assumption about X was wrong", "ambiguity surfaced during implementation"}
- **Could the drift have been caught by `dna:spec-auditor`?**: yes / no / partially; {explain}

## Agent pushback

Did the agent push back on any human direction during this feature? (CONSTITUTION Article 8 and `template/AGENT.md` "Critical Pushback Protocol"). Examples:

- Human asked to skip tests → agent refused / accepted / negotiated
- Human asked to "just make it work" → agent refused / accepted / negotiated
- Human wanted to merge with failing tests → agent refused / accepted / negotiated
- Human overrode a `[D]` requirement → agent logged construction site / accepted silently / refused

If zero pushback: either the spec was unambiguous (good) or the agent is please-seeking (bad). Which was it?

## What surprised us

{Free text: the spec said X, reality was Y. Future specs should account for this.}

## What the methodology would have caught earlier

{Free text: if we had a `dna:Z-checker` subagent, it would have flagged this at spec time. Name it; it becomes a SPEC candidate for the kit.}

## Follow-ups

- [ ] Construction Sites still open after merge: {list CS-IDs}
- [ ] Spec sections that need rewriting for future features: {list}
- [ ] New SPEC candidates for the kit repo: {list}

---

_This retrospective is aggregated into `<kit-root>/.exploration/retrospectives-corpus.md` by `tools/aggregate-retros.sh` for cross-feature methodology measurement. Do not sanitize; raw findings compound._
