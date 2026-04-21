# 04-COORDINATION-HINTS — {PROJECT_NAME}

> **Purpose**: Layer 4 — in what ORDER. Phase dependencies, depth-tagged done criteria, experience audits per phase, production threshold, risk hotspots, seed data, timeline. **Not a procedural checklist** — a declarative ordering of what must exist before what.

## Phases

> Every phase has: "what exists after" (one sentence), "done when" (3–8 specific verifiable criteria each with depth tag), "correctness > speed" flags, and "Experience Audit" requirement.

### Phase 0 — Scaffolding

**What exists after**: The repo compiles, tests run green, infrastructure starts, health endpoint returns 200, CI passes.

**Done when**:
- `[E]` Monorepo / package structure builds (if applicable)
- `[E]` Docker Compose or equivalent starts the local stack
- `[E]` Health endpoint returns 200
- `[E]` CI passes lint + typecheck + test
- `[E]` `05-CONSTRUCTION-SITES.md` exists with header + empty Active sites table

**Correctness > speed**: Nothing — this is scaffolding.

**Experience Audit**: Not applicable (no scenarios touched).

---

### Phase 1 — {name, tied to principles/scenarios}

**What exists after**: {one sentence — what the world looks like after this phase}

**Done when**:
- `[E]` {criterion}
- `[W]` {criterion}
- `[D]` {criterion — must tie to a specific Experience Fidelity Scenario in `01-SYSTEM-INTENT.md`}

**Correctness > speed**: {subsystems where getting it right matters more than getting it fast — name them}

**Experience Audit**: After done-criteria are met, re-read affected scenarios. For each: verify negative assertions pass in current build; run fidelity checklist; log open construction sites. Phase does not close until `[D]` entries are resolved OR architect explicitly approves deferral with a concrete resolution plan.

---

### Phase 2 — {name}
_(Same structure.)_

---

## Production threshold

> Explicit ship-line. Answer: "What must work at full experience fidelity for the primary user to do their job?" Everything else is v1.1.

### Must close before production
| Scenario | Principle | Rationale |
|---|---|---|
| {Scenario name} | Principle {N} | {Why the user cannot do their core job without this at `[D]` depth} |

### Deferred to v1.1 (with rationale)
| Scenario | Principle | Rationale for deferral |
|---|---|---|
| {Scenario name} | Principle {N} | {Why this is optimization, not core workflow} |

**Rules**:
- Decided during specification, not discovered mid-build. If the agent discovers mid-build that a must-close scenario is harder than expected, it escalates — it doesn't silently defer.
- "Can the user do their job?" is the test, not "is the app complete?"
- Every deferred scenario has explicit rationale. "Nice to have" is not a rationale.

## Non-goals

> What this system is NOT. Each non-goal prevents a rabbit hole.

- No {feature} — {brief reason if not obvious}
- No {feature}
- No {feature}
- No {feature}
- No {feature}
- No {feature}
- No {feature}
- No {feature}

_(Minimum 8. See `CONSTITUTION.md` Article 2 and `docs/HANDOFF_FORMAT.md`.)_

## Risk hotspots

{FILL IN: Subsystems / scenarios where the team expects friction. Name the risk and the mitigation.}

- **Risk**: {e.g., "NLP parsing accuracy on regional dialects"}
  **Mitigation**: {e.g., "Seed with 500 real observations before Phase 3; measure baseline accuracy"}

## Seed data requirements

{FILL IN: What data must exist before certain phases can be tested or demoed.}

- Phase {N} requires: {dataset description, size, source}

## Timeline (rough)

{FILL IN: Calendar estimate, phase by phase. Not a commitment — a sanity check. If the timeline looks suspiciously short, something is under-specified.}

---

**Completion checks** (before `/speckit-implement` on any phase):
- [ ] Every phase touching a core principle has ≥1 `[D]` done-criterion
- [ ] Every `[D]` done-criterion references a specific Scenario Validation Matrix row
- [ ] Production threshold is explicitly defined — no scenario is silently deferred
- [ ] Architecture Impact items from `02-ARCHITECTURE.md` are reflected as requirements in at least one phase
- [ ] Every phase has an Experience Audit step before closure
