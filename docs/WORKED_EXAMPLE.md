# Worked Example: team-project-scheduler

A real project built through `agentic-dev-starter`. The methodology becomes legible when you see it on a concrete artifact. This is that artifact.

**Repo**: [github.com/albertdobmeyer/team-project-scheduler-example](https://github.com/albertdobmeyer/team-project-scheduler-example)
**Snapshot at kit commit**: [`53cc0fb`](../.git-placeholder-link) (2026-04-23)
**Example tag**: [v1.0](https://github.com/albertdobmeyer/team-project-scheduler-example/releases/tag/v1.0) = example commit [`c084166`](https://github.com/albertdobmeyer/team-project-scheduler-example/commit/c084166)

Links below are SHA-pinned to `c084166` so they remain stable as the example evolves. Updated in lockstep with kit releases.

---

## Why it exists

A team lead (call him Denis) evaluating `agentic-dev-starter` naturally asks: *"can you show me this on a real project?"* The `docs/` tree in this kit explains the rules; this worked example demonstrates them. Without a concrete artifact, "the methodology catches drift" is unsupported; with one, you can see it happening.

## What it contains

A small team-scheduler project (Node 20 + TypeScript 5.5 + Vitest) with:

- Full 7-document Blueprint Package authored via the Protocol A interview
- Five specified-decomposed-tested-implemented-merged features
- Two dogfood validation sessions, where the kit's author used the kit to build features against this project
- A real `[D]`-depth Construction Site (CS-002) left **open** intentionally
- 26/26 tests green, 81% branch-diff coverage

## Reading path (45-minute evaluator pass)

A team lead with 45 minutes can form an informed opinion by reading these seven pieces in order:

1. **[Example README](https://github.com/albertdobmeyer/team-project-scheduler-example/blob/c084166/README.md)** (5 min): what the repo is, what it demonstrates, what it's not.
2. **[CONSTITUTION.md](https://github.com/albertdobmeyer/team-project-scheduler-example/blob/c084166/CONSTITUTION.md)** (5 min): Article 10 customized for this project (Node/TS, single-lead team). Compare against the kit's [template/CONSTITUTION.md](../template/CONSTITUTION.md) to see what "customization" looks like.
3. **[01-SYSTEM-INTENT.md](https://github.com/albertdobmeyer/team-project-scheduler-example/blob/c084166/docs/01-SYSTEM-INTENT.md)** (10 min): three Experience Fidelity Scenarios, each with ≥3 negative assertions, filmable success statements, and the Scenario Validation Matrix with bidirectional assertion↔task linkage. This is the single most load-bearing document; if you only read one, make it this.
4. **[05-CONSTRUCTION-SITES.md](https://github.com/albertdobmeyer/team-project-scheduler-example/blob/c084166/docs/05-CONSTRUCTION-SITES.md)** (5 min): CS-001 RESOLVED (merge-conflict caught by dna-cross-checker subagent), CS-002 OPEN (UI deferred to 006 under Article 5). Open sites in a "demo" repo are the point, not a failure.
5. **[004 retrospective](https://github.com/albertdobmeyer/team-project-scheduler-example/blob/c084166/specs/004-task-status-transitions/retrospective.md)** (10 min): first full 12-step dogfood. What the kit felt like to use, what gates caught, what friction was worth fixing.
6. **[005 retrospective](https://github.com/albertdobmeyer/team-project-scheduler-example/blob/c084166/specs/005-calendar-week-grid/retrospective.md)** (5 min): second dogfood, `[D]` depth, partial-delivery pattern. Nine rough edges catalogued as SPEC candidates.
7. **[DOGFOOD-NOTES-2026-04-23](https://github.com/albertdobmeyer/team-project-scheduler-example/blob/c084166/dogfood-evidence/DOGFOOD-NOTES-2026-04-23.md)** §"Phase 5: dna-spec-validate + dna-spec-validator" (5 min): the strongest single evidence that the enforcement layer isn't rubber-stamping. The mechanical gate + LLM judge both cleared a real partial-delivery with ADVISORY-01, correctly distinguishing legitimate scoping from production-threshold drift.

## What to observe in each artifact

### Blueprint Package (7 docs)

| Document | What to notice |
|---|---|
| [00-CORE-PRINCIPLES](https://github.com/albertdobmeyer/team-project-scheduler-example/blob/c084166/docs/00-CORE-PRINCIPLES.md) | Three principles, each generating ≥1 scenario; satisfies kit's [HANDOFF_FORMAT.md](HANDOFF_FORMAT.md) §"Principle → Scenario" requirement |
| [01-SYSTEM-INTENT](https://github.com/albertdobmeyer/team-project-scheduler-example/blob/c084166/docs/01-SYSTEM-INTENT.md) | Scenario Validation Matrix with real task IDs mapping to assertions; "Uncovered Assertions" is empty; depth classification per scenario |
| [02-ARCHITECTURE](https://github.com/albertdobmeyer/team-project-scheduler-example/blob/c084166/docs/02-ARCHITECTURE.md) | Architecture Impact Assessment per scenario; forces an explicit paragraph preventing silent drift at design time |
| [03-EXECUTION-CONTEXT](https://github.com/albertdobmeyer/team-project-scheduler-example/blob/c084166/docs/03-EXECUTION-CONTEXT.md) | Pinned stack versions; testing philosophy; error handling; not abstract generalities |
| [04-COORDINATION-HINTS](https://github.com/albertdobmeyer/team-project-scheduler-example/blob/c084166/docs/04-COORDINATION-HINTS.md) | Phase ordering with depth-tagged done criteria; Production Threshold; 10 non-goals |
| [05-CONSTRUCTION-SITES](https://github.com/albertdobmeyer/team-project-scheduler-example/blob/c084166/docs/05-CONSTRUCTION-SITES.md) | Living tracker; CS-002 shows legitimate Article 5 scope-deferral with logged entry + committed sibling + phase-not-closed |

### Enforcement layer

| Layer | Where to look |
|---|---|
| Six enforcement skills | [.claude/skills/dna-*/](https://github.com/albertdobmeyer/team-project-scheduler-example/tree/c084166/.claude/skills); all have executable `run.sh` |
| Five subagents | [.claude/agents/dna-*.md](https://github.com/albertdobmeyer/team-project-scheduler-example/tree/c084166/.claude/agents); each a fresh-context judge |
| CI workflow | [.github/workflows/dna.yml](https://github.com/albertdobmeyer/team-project-scheduler-example/blob/c084166/.github/workflows/dna.yml); dna-decompose + dna-verify + dna-spec-validate; no LLM subagents (those are dev-time only, no headless path) |

### Retrospectives

See the [RETROSPECTIVE_INDEX](https://github.com/albertdobmeyer/team-project-scheduler-example/blob/c084166/RETROSPECTIVE_INDEX.md) for all five in merge order. 001 and 002 are honest skeletons (those features shipped before retrospectives were part of the kit); 003 is a retroactive fill; 004 and 005 are the full dogfood retros.

### Dogfood evidence

The [dogfood-evidence/](https://github.com/albertdobmeyer/team-project-scheduler-example/tree/c084166/dogfood-evidence) folder is this example's distinctive feature; most worked examples would stop at specs + retros. Two session-wide walkthroughs document how the kit was *used* to build features on this project, and the aggregated retrospective corpus flattens all five retros so cross-feature patterns become visible.

## What this example does NOT address

- **Non-Claude-Code agents**: the example was built with Claude Code. Future adapters (Cursor, Amp, Codex) need their own worked examples or adapter-specific notes.
- **Large teams**: Article 10 is customized for a small team (1 lead + ~5 developers). A 20-developer team will want different Article 10 rules.
- **Non-Node stacks**: the example's stack is TypeScript + Vitest + ESM. The methodology is stack-agnostic; the example's choices are illustrative, not prescriptive.
- **Production load**: this is demo-scale. Real-scale production concerns (rate limiting, observability, disaster recovery) are out of scope.

## Keeping the example current

The example is a snapshot. As the kit evolves, the example may not reflect every change until it's re-synced. Re-sync schedule:

- **On every kit semver bump**: refresh this doc's commit pin + validate the example's gates still pass (run `tools/refresh-target.sh` with `--dry-run` against the example as-if-target to see what would drift).
- **On every merged SPEC that changes `template/*`**: add an entry in the example's own CHANGELOG describing the change; optionally run Protocol E against the example.
- **If CS-002 ever closes**: the example gets a 006-calendar-ui feature merged, a third dogfood retro, and Phase 2 closure. When that happens, tag `v1.1-phase2-closed`.

This doc will always name the kit commit the snapshot was taken against + the example tag the SHA-pinned links point to.

## Follow the links

- Evaluator start: [example README](https://github.com/albertdobmeyer/team-project-scheduler-example#readme)
- Full kit: [agentic-dev-starter](https://github.com/albertdobmeyer/agentic-dev-starter)
- Methodology deep dive: [kernel/methodology.md](../kernel/methodology.md) and [docs/METHODOLOGY.md](METHODOLOGY.md)
