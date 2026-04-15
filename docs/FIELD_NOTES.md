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

**Resulting changes:** [AGENT_SETUP.md](AGENT_SETUP.md) section 2, [PLANNING_INSTRUCTIONS.md](PLANNING_INSTRUCTIONS.md) VISION.md description, [FAQ.md](FAQ.md) methodology section.

---

## Finding 2: Commit-Per-Task Creates Artificial Fragmentation

**Observed friction:** 47 tasks would have required 47 commits. In practice, the agent batched by phase — 4 commits for 47 tasks. The constitution's original Article 8 ("commit after every completed task") was routinely violated because it was impractical.

**Root cause:** The rule optimized for traceability at the expense of meaningful version history. Micro-commits for 5-line changes create noise without adding review value.

**Revision:** Shifted commit granularity from task-level to milestone-level:
> *Commit per logical milestone, phase boundary, or independently reviewable work unit.*

This preserves traceability (every phase boundary is a commit) without forcing meaningless micro-commits. The rule now prevents the two real problems: going a full day without committing, and bundling unrelated changes across phases.

**Resulting changes:** [CONSTITUTION_TEMPLATE.md](CONSTITUTION_TEMPLATE.md) Article 8, [skeleton/CONSTITUTION.md.template](../skeleton/CONSTITUTION.md.template) Article 8.

---

## Finding 3: [P] Markers Without Execution Semantics

**Observed friction:** The task template correctly marked parallel-safe tasks with `[P]`, but the workflow never documented how to execute them in parallel. The agent independently discovered sub-agent delegation and reported it halved implementation time — but said "the workflow doesn't suggest spawning sub-agents."

**Root cause:** The `[P]` marker was a structural annotation without operational guidance. Its existence implied parallelization was possible, but the methodology didn't say how.

**Revision:** Added explicit parallelization semantics:
> *Tasks marked `[P]` in the same phase are candidates for delegated sub-agent execution. Each targets a different file with no dependencies on incomplete tasks. Spawn sub-agents in pairs or groups. Merge results when all complete, then validate integration with the full test suite.*

**Resulting changes:** [AGENT_SETUP.md](AGENT_SETUP.md) new "Agent Parallelization" section, [FAQ.md](FAQ.md) parallelization Q&A.

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
