# E2E Validation Findings

> **Project:** agentic-bookmark-organizer (CLI tool, Python, Ollama)
> **Build date:** 2026-04-13
> **Scope:** Full workflow — handoff docs → /specify → /plan → /tasks → /implement
> **Result:** 47 tasks, 259 tests, 4 phases, working pipeline

These findings were captured during the first complete end-to-end build using this methodology. Each finding led to a specific revision in the framework. A methodology that demonstrates self-correction under production use is more trustworthy than one presented as static doctrine.

---

## Finding 1: Handoff Docs → /specify Transition Gap

**Observed friction:** VISION.md already contained user scenarios, depth tags, and success criteria. The /specify step asked for the same information in a different format. The agent was "largely restating what VISION.md already said."

**Root cause:** The relationship between handoff documents and Spec-Kit spec artifacts was undefined. Both claimed to be the source of truth for requirements.

**Revision:** Established explicit supersession rules:
- VISION.md captures product intent and strategic framing
- /specify converts intent into testable contracts (Given/When/Then)
- Once generated, the specification is the operational source of truth
- The /specify prompt was reframed from "describe the feature" to "translate your design into testable contracts"

**Resulting changes:** [PLANNING_INSTRUCTIONS.md](PLANNING_INSTRUCTIONS.md) VISION.md description, [FAQ.md](FAQ.md) methodology section, kit's target `AGENT.md` specify-step framing.

---

## Finding 2: Commit-Per-Task Creates Artificial Fragmentation

**Observed friction:** 47 tasks would have required 47 commits. In practice, the agent batched by phase — 4 commits for 47 tasks. The constitution's original Article 8 ("commit after every completed task") was routinely violated because it was impractical.

**Root cause:** The rule optimized for traceability at the expense of meaningful version history. Micro-commits for 5-line changes create noise without adding review value.

**Revision:** Shifted commit granularity from task-level to milestone-level:
> *Commit per logical milestone, phase boundary, or independently reviewable work unit.*

This preserves traceability (every phase boundary is a commit) without forcing meaningless micro-commits. The rule now prevents the two real problems: going a full day without committing, and bundling unrelated changes across phases.

**Resulting changes:** [template/CONSTITUTION.md](../template/CONSTITUTION.md) Article 8.

---

## Finding 3: [P] Markers Without Execution Semantics

**Observed friction:** The task template correctly marked parallel-safe tasks with `[P]`, but the workflow never documented how to execute them in parallel. The agent independently discovered sub-agent delegation and reported it halved implementation time — but said "the workflow doesn't suggest spawning sub-agents."

**Root cause:** The `[P]` marker was a structural annotation without operational guidance. Its existence implied parallelization was possible, but the methodology didn't say how.

**Revision:** Added explicit parallelization semantics:
> *Tasks marked `[P]` in the same phase are candidates for delegated sub-agent execution. Each targets a different file with no dependencies on incomplete tasks. Spawn sub-agents in pairs or groups. Merge results when all complete, then validate integration with the full test suite.*

**Resulting changes:** kit's target `AGENT.md` parallel sub-agent guidance, [FAQ.md](FAQ.md) parallelization Q&A, `dna-decompose` + `dna-delegate` skills.

---

## Finding 4: Solo vs Team Template Weight

**Observed friction:** The Spec-Kit tasks template included "Parallel Team Strategy" and "Developer A / Developer B" sections that were irrelevant for a 1-human + 1-agent project. The agent called this "noise."

**Root cause:** Spec-Kit templates are designed for multi-developer teams. The project-dna methodology doesn't distinguish between solo and team usage modes at the template level.

**Revision:** Documented that team-oriented template sections can be skipped for solo projects. The methodology now explicitly acknowledges both modes rather than assuming team usage.

**Resulting changes:** [FAQ.md](FAQ.md) solo vs team Q&A.

---

## Finding 5: Constitution Checks Catch Real Problems

**Observed value:** The constitution gate check during /plan caught a real architectural deviation — the agent had silently changed a core dependency (swapping `agentic-ollama/client.py` for a project-specific `llm.py`). Without the formal constitution check, the deviation would have shipped undocumented.

**Observation:** The constitution check is the most underrated phase in the workflow. It's where structural problems surface — not formatting issues, but genuine violations of project axioms. The agent noted: "Without the gate, I would have just made the change silently. The formal check forced me to document the justification."

**No revision needed.** This validates the existing design. The constitution check works exactly as intended.

---

## What Stayed the Same

These aspects of the methodology required no revision after e2e testing:

- **Handoff document structure** (VISION, ARCHITECTURE, CONSTITUTION, SCOPE) — provided excellent agent onboarding
- **Anti-flattening Articles 3-7** — depth classification and experience fidelity scenarios drove real engineering decisions
- **Test-first mandate** (Article 1) — produced 259 tests that caught real issues, including integration wiring problems
- **Spec-Kit workflow progression** (specify → plan → tasks → implement) — each phase produced useful artifacts
- **CLAUDE.md as quick reference** — short, scannable, immediately oriented the agent

---

## Summary

Five findings. Three methodology revisions. Two validations. Zero showstoppers.

The methodology refines itself. Every rule that changed was changed because live execution revealed a better formulation — not because the rule was wrong in principle, but because its expression was imprecise. The framework is now tighter than before the build.

*Every rule exists because it was tested. The methodology evolves by its own use.*

---

# Second validation — team-project-scheduler (2026-04-22 → 2026-04-23)

> **Project:** team-project-scheduler (worked-example published at [github.com/albertdobmeyer/team-project-scheduler-example](https://github.com/albertdobmeyer/team-project-scheduler-example))
> **Build dates:** 2026-04-22 (feature 004, `[W]`-depth dogfood) + 2026-04-23 (feature 005, `[D]`-depth dogfood)
> **Scope:** Both dogfood runs exercised the full enforcement layer (6 skills + 5 subagents + CI) on real features. Second validation raises n from 1 (bookmark-organizer) to 2.

Raw session walkthroughs preserved at [dogfood-evidence/](https://github.com/albertdobmeyer/team-project-scheduler-example/tree/c084166/dogfood-evidence) in the example repo. Aggregated retrospective corpus at [dogfood-evidence/retrospectives-corpus.md](https://github.com/albertdobmeyer/team-project-scheduler-example/blob/c084166/dogfood-evidence/retrospectives-corpus.md).

---

## Finding 6: Pass-2 independent-context verifier catches what Pass-1 misses

**Observed value:** On feature 004 (`[W]`-depth), the Pass-1 `dna-verifier` subagent passed the feature. A Pass-2 invocation with a fresh context (no build-conversation history) caught a subtle scenario-assertion gap that the in-context Pass-1 missed. Evidence preserved at [DOGFOOD-NOTES-2026-04-22.md §Pass 2](https://github.com/albertdobmeyer/team-project-scheduler-example/blob/c084166/dogfood-evidence/DOGFOOD-NOTES-2026-04-22.md).

**Observation:** Build-conversation context carries implicit trust — the verifier "knows what we meant." A fresh-context pass strips that trust. The bias firewall only works when the verifier is genuinely independent.

**No revision needed.** This validates the design of running verifier + validator in fresh-context isolation. The pattern was hypothesized; 004 proved it.

---

## Finding 7: Judgmental subagent correctly distinguishes scope-deferral from drift

**Observed value:** On feature 005 (`[D]`-depth), the spec deliberately deferred the UI layer to a committed sibling feature (006-calendar-ui). SPEC-19's `dna-spec-validator` subagent was invoked to assess whether this was legitimate Article 5 scoping or production-threshold drift. It returned CLEAR + ADVISORY-01 correctly identifying it as legitimate — and named the required Construction Site entry before merge. Evidence at [DOGFOOD-NOTES-2026-04-23.md §Phase 5](https://github.com/albertdobmeyer/team-project-scheduler-example/blob/c084166/dogfood-evidence/DOGFOOD-NOTES-2026-04-23.md).

**Observation:** The ruleset encoded in the subagent's prompt actually reasons about the pattern rather than rubber-stamping. A subagent that returned CLEAR without ADVISORY would be indistinguishable from a stub; one that returned BLOCK would force false positives. ADVISORY-01 is the mark of a judgment call being made.

**No revision needed.** Validates SPEC-19's design. The pattern-match-then-classify prompt structure holds under real-feature load.

---

## Finding 8: Construction Sites prevent silent phase closure

**Observed value:** CS-002 was logged at merge time (not post-hoc) for feature 005's partial-delivery. The entry in [docs/05-CONSTRUCTION-SITES.md](https://github.com/albertdobmeyer/team-project-scheduler-example/blob/c084166/docs/05-CONSTRUCTION-SITES.md) explicitly blocks Phase 2 closure until 006 ships. Without the logged entry, the gap between "server read path shipped" and "filmable user experience achievable" would have been invisible.

**Observation:** Construction Sites are not a post-implementation debt tracker — they're a *phase-closure gate*. An unresolved CS blocks Production Threshold. This makes Article 5 scope-deferral safe because the consequences stay visible.

**No revision needed.** Validates the invariant added to HANDOFF-2026-04-23 §invariants #11: partial-delivery of `[D]` is legitimate only with (a) explicit out-of-scope statement, (b) committed sibling feature, (c) merge-time CS entry, (d) phase remains open.

---

## Finding 9: Refresh-target.sh mechanism works across kit evolution

**Observed value:** Between sessions 6 and 7 (2026-04-22 → 2026-04-23), the kit gained SPEC-19 artifacts (`dna-spec-validate` skill + `dna-spec-validator` subagent + CI step). The existing target was brought current via `tools/refresh-target.sh` with no manual file-shuffling. One DRIFT was surfaced (a pre-existing target customization) and resolved with `--force` at the human's direction; rest was ADD-only.

**Observation:** The kit-to-target sync mechanism is the only way this worked-example stays in step with kit evolution over time. Without it, targets become snapshot-only and adoption friction compounds.

**No revision needed.** Validates SPEC-15's design. Protocol E is load-bearing.

---

## Cross-validation summary

| Finding | Bookmark-organizer (n=1) | Team-project-scheduler (n=2) |
|---|---|---|
| Test-first mandate drives real test coverage | ✅ 259 tests | ✅ 26 tests, 81% branch-diff coverage |
| Constitution checks catch architectural drift | ✅ caught silent LLM-client swap | ✅ `dna-cross-checker` caught shared-model merge-conflict (CS-001) |
| Commit-per-milestone granularity works | ✅ 4 commits for 47 tasks | ✅ 1-commit-per-merged-feature + intermediate phase commits |
| `[P]` parallelization via subagents | ✅ halved implementation time | ✅ `dna-delegate` used for 003 and 005; merge-conflict-free |
| Fresh-context verifier as bias firewall | _not tested_ | ✅ caught Pass-1-missed assertion gap in 004 |
| Construction Sites prevent flattening | _not tested_ | ✅ CS-001 resolved, CS-002 open + phase-blocked |
| Spec-validator distinguishes scope-vs-drift | _not tested_ | ✅ CLEAR + ADVISORY-01 on 005 partial delivery |

The second validation exercises dimensions the first couldn't (because the enforcement layer was still being built). The methodology now has evidence at two depths across two projects; recurring patterns are what `tools/aggregate-retros.sh` surfaces.

*The framework is now tighter than before the second build. The same refinement loop applies: live execution reveals better formulations; formulations stabilize with each validation.*
