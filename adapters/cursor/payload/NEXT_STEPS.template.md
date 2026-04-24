# Next steps

> This file is your day-1 guide after Protocol A unfolded this project. It's temporary; **delete it when every `{FILL IN}` marker is resolved and every `SKIP-DEFAULT` tag has been reviewed.** Its presence signals "unfold is incomplete"; its absence signals "ready for `/speckit-specify`."

## You are here

- **Project**: `{PROJECT_NAME}`
- **Bootstrapped**: `{DATE}` via [agentic-dev-starter](https://github.com/albertdobmeyer/agentic-dev-starter) kit at tag `{KIT_VERSION}`
- **Adapter**: `{ADAPTER}` (Claude Code / Cursor)
- **Unfold mode**: `{MODE}` (YES / PARTIAL / NONE / SKIP)

## What's authored vs skeleton

| Doc | Status | Next action |
|---|---|---|
| `CONSTITUTION.md` (Article 10) | `{ART10_STATUS}` | `{ART10_ACTION}` |
| `docs/00-CORE-PRINCIPLES.md` | `{DOC00_STATUS}` | Fill in: problem, users, domain model, 3-7 principles |
| `docs/01-SYSTEM-INTENT.md` | `{DOC01_STATUS}` | Entities, state machines, ≥1 Experience Fidelity Scenario per principle with ≥3 negative assertions + Validation Matrix |
| `docs/02-ARCHITECTURE.md` | `{DOC02_STATUS}` | Module boundaries, API surface, Architecture Impact Assessment per scenario |
| `docs/03-EXECUTION-CONTEXT.md` | `{DOC03_STATUS}` | Pinned stack versions, testing philosophy, error handling |
| `docs/04-COORDINATION-HINTS.md` | `{DOC04_STATUS}` | Phase ordering with depth-tagged done criteria, Production Threshold, 8+ non-goals |
| `docs/05-CONSTRUCTION-SITES.md` | initialized empty | Maintained by `dna-construction-logger` at build time; no action now |

Status legend: `authored` = human-completed during unfold; `skeleton` = `{FILL IN}` markers remaining; `SKIP-default` = SKIP-mode defaults that must be reviewed before building.

## Your next action

Pick the one that matches your unfold mode:

**If `{MODE}` is `SKIP`**: Open `SKIP_DEFAULTS.md` at project root and review every field. Every default is opinionated: a reasonable starting point, not a commitment. Edit what doesn't match your project. Then either fill the `docs/*.md` skeletons manually, or say to the agent:

> *"Run the full interview now, promote this project from SKIP mode."*

The agent will re-interview only for fields still tagged `{DEFAULT}` or `SKIP-DEFAULT`, never overwriting your edits.

**If `{MODE}` is `NONE` or `PARTIAL` with skeletons**: Complete the `{FILL IN}` markers in this order:

1. `docs/00-CORE-PRINCIPLES.md`: what problem, for whom, the principles that generate scenarios
2. `docs/01-SYSTEM-INTENT.md`: the load-bearing doc; scenarios + Validation Matrix
3. `docs/02-ARCHITECTURE.md`: module boundaries + Impact Assessments
4. `docs/03-EXECUTION-CONTEXT.md`: pinned stack + coding standards
5. `docs/04-COORDINATION-HINTS.md`: phases + Production Threshold + non-goals

Run `dna-spec-auditor` (fresh chat in Cursor; subagent dispatch in Claude Code) at the end to verify the 20+ structural checks pass before the first `/speckit-specify`.

**If `{MODE}` is `YES` (fully authored during unfold)**: You're ready. Say:

> *"I'm ready for `/speckit-specify` on feature X."*

## What NOT to do

- **Don't run `/speckit-specify` while this file exists** with unresolved markers. The spec-audit gate will catch it, but you'll have wasted a round-trip.
- **Don't delete `{FILL IN}` markers to appear done.** Every marker encodes a structural requirement. Resolve or remove the whole containing section.
- **Don't edit `.specify/memory/constitution.md` directly.** That's a Spec-Kit-managed copy. Edit root `CONSTITUTION.md` and re-run `cp CONSTITUTION.md .specify/memory/constitution.md` after every change.
- **Don't commit secrets.** `.gitignore` excludes `.env*` by default; keep it that way.

## Recovery

Confused? Say to the agent:

> *"Re-read `{CLAUDE_OR_CURSOR_MD}` and re-orient me; walk me through what's authored and what's next."*

Broken state? Consult:
- `CONSTITUTION.md` Article 10 (project-specific quality gates)
- `docs/HANDOFF_FORMAT.md` in the kit (if you cloned it): required elements per doc
- The kit's worked example: [team-project-scheduler-example](https://github.com/albertdobmeyer/team-project-scheduler-example)

## Graduation

When every marker is resolved, every `SKIP-DEFAULT` tag is reviewed, and `dna-spec-auditor` returns CLEAR, delete this file:

```
rm NEXT_STEPS.md
```

Commit the deletion with message `chore: graduate from onboarding, handoff docs complete`.

The absence of this file is the signal to the agent that the project has left the onboarding phase.
