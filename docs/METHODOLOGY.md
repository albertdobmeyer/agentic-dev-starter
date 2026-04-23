# Methodology: The Five Original Contributions

> Part of [agentic-dev-starter](../README.md)
> Licensed under CC BY-SA 4.0
>
> **Canonical source**: This doc is a compressed summary of the full methodology. The authoritative reference is [`../PROJECT_DNA.md`](../PROJECT_DNA.md) — the original methodology document with all six artifacts (7-doc Blueprint Package, Scenario Validation Matrix, Architecture Impact Assessment, Coherence Check, Production Threshold, Construction Sites tracker, Drift Remediation Protocol) and a worked example in Appendix E.

This document explains the *why* behind Articles 3-7 of the constitution template. Each article addresses a specific, documented failure mode in spec-driven AI-assisted development. For the full operational mechanisms that prevent each failure mode, read `PROJECT_DNA.md`.

---

## Article 3: Anti-Flattening

### The Failure Mode

You spec a feature: "Users receive a weekly summary email with their activity stats, personalized recommendations, and a motivational message based on their progress."

The agent decomposes this into tasks. Every task passes its test. But the email arrives with generic stats, recommendations that don't reference the user's actual behavior, and a motivational message that feels like it was written for someone else. Each component *works* — but the experience is flat.

**Flattening** is when a rich user experience gets decomposed into component tasks that each pass tests individually but never compose into the intended experience.

### The Prevention

**Experience Fidelity Scenarios** force the spec to describe what the user *experiences*, not what the system *does*. Each scenario includes:

- **Negative assertions** ("what the user NEVER has to do") — the most powerful drift detectors because they're the first things cut during implementation
- **Behavioral variation** (happy path + edge case + error flow) — prevents single-path implementations
- **Filmable success criteria** — "Video of user doing X in Y seconds without Z"
- **Quantified impact** — becomes a regression threshold

---

## Article 4: Depth Classification

### The Failure Mode

The agent builds a notification system. The database schema exists `[E]`. The notification function works when called `[W]`. But nobody specified the trigger, so notifications never fire automatically. The feature "exists" and "works" but never *delivers*.

### The Three Depths

| Tag | Name | Meaning |
|-----|------|---------|
| `[E]` | Exists | Scaffolding. Present but not functional. |
| `[W]` | Works | Functions correctly in isolation. Tests pass. |
| `[D]` | Delivers | Participates in the intended user experience. Requires multi-component integration. |

The gap between `[W]` and `[D]` is where all flattening happens. Every core feature needs at least one `[D]` requirement. `[D]` is never satisfied by a single component.

---

## Article 5: Implementation Debt Tracking

### The Failure Mode

The agent simplifies a `[D]` requirement to `[W]`. The test passes. Nobody logs the downgrade. Three weeks later, the experience is hollow and nobody can trace when it happened.

### The Prevention

Every `[D]`→`[W]` downgrade is logged at the moment it happens — with the specific negative assertions that now fail. 3+ downgrades on one scenario means the implementation approach needs rethinking — it's an architecture problem, not a patching problem.

**Unlogged downgrades are the mechanism by which flattening becomes invisible.**

---

## Article 6: Data-Without-Behavior Detection

### The Failure Mode

The spec says "Monthly reports for each client." The agent builds the report schema, template, and API endpoint. Everything works. But the reports never generate because nobody specified the cron job or trigger event. Perfectly structured inert data.

### The Prevention

Every data structure implying automatic behavior must have a **behavior specification**: what triggers it, when it fires, what the user experiences without manually initiating it.

The planning instructions include the question: *"What makes this happen without the user triggering it manually?"*

---

## Article 7: Drift Remediation

### The Failure Mode

QA finds 12 gaps. The team fixes them top-to-bottom. Each fix is correct in isolation, but they interact poorly. Frankenstein code.

### The Prevention

Don't patch gap-by-gap. Write scenarios for the gaps first, derive tasks from those scenarios, run the coherence check, classify against the production threshold, then implement as a coherent phase — not a patch list.

---

## How They Work Together

```
Article 6 catches → missing behavior specs before the build
Article 3 catches → flattened specs before tasks are derived
Article 4 catches → ambiguous depth expectations before implementation
Article 5 catches → silent downgrades during implementation
Article 7 catches → incoherent remediation after gaps are found
```

Each article addresses a different stage. Together, they create structural pressure against flattening at every point where it typically occurs.

**Parallel execution.** Tasks marked `[P]` in the task breakdown are candidates for delegated sub-agent execution. After parallel tasks complete, run the full test suite as merge validation before proceeding. This pattern halved implementation time in the first e2e validation run. See [FIELD_NOTES.md](FIELD_NOTES.md) for details.

---

*Every article exists because its absence caused a specific, documented failure in a production build.*
