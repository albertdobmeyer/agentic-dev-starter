# 02-ARCHITECTURE. {PROJECT_NAME}

> **Purpose**: Layer 2. system SHAPE. Module boundaries, interface contracts, API surface, data flows, event flows. This doc is stack-specific but should stay declarative ("the system accepts X and produces Y"), not procedural ("create file foo.ts with function bar").
>
> **Architecture Impact Assessments** (per PROJECT_DNA Section 3.5.5) live at the bottom of this file. one per scenario. They are produced during specification, not discovered during implementation.

## Module boundaries

```
src/ (or equivalent)
├── {module}/              ← {one-line purpose}
├── {module}/
└── {module}/

tests/
├── unit/
└── integration/
```

{FILL IN: Directory tree showing module structure. Annotate each top-level module with its purpose.}

## Module paths

> **Why this section exists**: deterministic path globs let `dna-spec-validate` and other gates check whether a feature's `## Files this feature will touch` list lives within a declared module without re-parsing the ASCII tree above. Mirrors the `shared-code-glob:` precedent in `CONSTITUTION.md` Article 10.
>
> One row per top-level module. Globs are bash `**`-style. Add new rows when you add a module; the tree above and the table below must agree.

```yaml
modules:
  # name: <module-id>           # short, kebab-case, matches the directory under src/
  # path: <glob>                # bash glob (e.g., src/api/routes/**)
  # purpose: <one-liner>        # what code lives here, what does NOT
  # owner-scenarios: [N, ...]   # scenario numbers from 01-SYSTEM-INTENT.md this module primarily serves; [] for infrastructure

  - name: {module-id}
    path: src/{module}/**
    purpose: {one-line purpose}
    owner-scenarios: []

  - name: {another-module}
    path: src/{another}/**
    purpose: {one-line purpose}
    owner-scenarios: [1, 2]
```

**Exempt paths** (always allowed, never need a module): `tools/**`, `tests/**`, `docs/**`, `scripts/**`, `.specify/**`, `.github/**`. Feature spec.md files may list paths in these locations without triggering a module-boundary failure.

**Authoring rule**: a file path that does not match any `path:` glob and is not in the exempt set is "homeless". either a missing module declaration above, or a sign the file belongs in a different module. Resolve before `/speckit-plan`.

## Interface contracts

{FILL IN: The public interfaces between modules. Declarative. Example: "The `auth` module exposes `verifySession(token) → User | null` and `startSession(credentials) → Token`."}

## API surface

| Method | Path | Auth | Purpose | Scenario ref |
|---|---|---|---|---|
| {GET} | {/path} | {public/session/admin} | {one-liner} | {Scenario N or "infrastructure"} |

## Data flows

{FILL IN: How data moves through the system. Entry points → validation → storage → read paths → exit points. Diagram or narrative.}

## Event / sync flows

{FILL IN: Scheduled jobs, event-driven pipelines, external integrations. For every data structure that implies automatic behavior (reports, notifications, scheduled deliveries), name the trigger mechanism here. Data structures without their triggering flow become inert features. this is a PROJECT_DNA "data-structure-without-behavior" failure mode.}

- {Trigger 1. e.g., "Monthly report batch job. BullMQ scheduled at 10 PM UTC on last day of month"}
- {Trigger 2}

## Infrastructure decisions

### Chosen
- **Hosting**: {e.g., Fly.io / DigitalOcean / Vercel}. {why}
- **Database**: {e.g., managed Postgres}. {why}
- **Observability**: {e.g., OpenTelemetry → Honeycomb}. {why}

### Rejected
- **{alternative}**: {why not}

---

## Architecture Impact Assessments

> One block per Experience Fidelity Scenario in `01-SYSTEM-INTENT.md`. Catches cases where closing a scenario gap requires structural changes that can't be patched component-by-component. **Produced during specification, not implementation.**

### Impact: Scenario 1. {name}

**Fits existing patterns**
- {task or component}. {why it fits}

**Requires new infrastructure**
- {new service / queue / pipeline}. {what it does, which existing subsystem it plugs into}

**Requires subsystem redesign**
- {subsystem}. {what changes, who must approve (architect escalation)}

**Cross-scenario conflicts**
- {describe any conflict with another scenario, OR "none identified"}

### Impact: Scenario 2. {name}
_(Same structure.)_

---

**Completion checks** (before `/speckit-plan`):
- [ ] Every entity in `01-SYSTEM-INTENT.md` has a clear storage home in the data flow
- [ ] Every API route has a scenario reference OR is tagged as infrastructure
- [ ] Every data structure that implies automatic behavior has its trigger in Event / sync flows
- [ ] Every scenario has an Architecture Impact Assessment above
- [ ] "Requires new infrastructure" items have been added as prerequisite requirements in `04-COORDINATION-HINTS.md`
