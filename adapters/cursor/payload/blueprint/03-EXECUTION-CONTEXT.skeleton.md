# 03-EXECUTION-CONTEXT — {PROJECT_NAME}

> **Purpose**: Layer 3 — HOW to write code. Pinned versions, repo structure, coding standards, testing philosophy, error handling, infrastructure setup. The implementing agent reads this to act autonomously without asking.

## Tech stack (pinned)

> Pin every version to exact `major.minor`. Rationale column is not optional — it's what future devs read when a dep needs to change.

| Layer | Technology | Version | Rationale |
|---|---|---|---|
| Runtime | {e.g., Node.js} | {20.11} | {why this runtime} |
| Language | {e.g., TypeScript} | {5.4} | {why} |
| Framework | {e.g., Fastify / Next.js / FastAPI} | {x.y} | |
| Datastore | {e.g., PostgreSQL} | {16.2} | |
| ORM / Query layer | {e.g., Prisma / pg} | {x.y} | |
| Auth | {e.g., Auth.js / custom} | {x.y} | |
| Test runner | {e.g., Vitest / Jest / pytest} | {x.y} | |
| Linter / Formatter | {e.g., Biome / ESLint + Prettier} | {x.y} | |
| CI | {e.g., GitHub Actions} | {runner version} | |

## Repo structure

```
{root}/
├── src/                          (see `02-ARCHITECTURE.md` for module boundaries)
├── tests/
│   ├── unit/
│   └── integration/
├── docs/
│   ├── 00-CORE-PRINCIPLES.md
│   ├── 01-SYSTEM-INTENT.md
│   ├── 02-ARCHITECTURE.md
│   ├── 03-EXECUTION-CONTEXT.md   (this file)
│   ├── 04-COORDINATION-HINTS.md
│   └── 05-CONSTRUCTION-SITES.md  (living — agent maintains)
├── CONSTITUTION.md
├── CLAUDE.md                      (agent protocol)
└── {package.json / pyproject.toml / etc.}
```

## Coding standards

{FILL IN: Conventions the agent should default to — naming, file organization, type-strictness, comment policy. Example: "Files named by domain noun (`user.service.ts`), never by layer (`services/user.ts`). TypeScript strict mode. No implicit `any`."}

- {Standard 1}
- {Standard 2}
- {Standard 3}

## Error handling

{FILL IN: The house style for errors. Do you throw? Return Result types? Use error-first callbacks? What's the user-facing surface vs internal? What gets logged, what gets reported?}

- {Rule 1 — e.g., "All domain errors extend `AppError` with a typed `code` field"}
- {Rule 2 — e.g., "Never swallow errors silently. Log + rethrow OR handle explicitly."}

## Testing philosophy

{FILL IN: What tests are mandatory. Coverage threshold. Unit vs integration split. See also `CONSTITUTION.md` Article 1.}

- {Rule 1 — e.g., "Unit test for every pure function; integration test for every API route"}
- {Rule 2 — e.g., "≥80% line coverage on domain logic; 100% on state transitions"}
- Test-first is non-negotiable (Constitution Article 1).

## Environment / secrets

{FILL IN: Which env vars are required, which are optional, how they're validated at startup. No secrets committed. Where `.env.example` lives.}

## Infrastructure setup

{FILL IN: How a new developer gets from `git clone` to running tests. Should be ≤ 4 commands.}

```bash
{command 1}
{command 2}
{command 3}
```

---

**Completion checks** (before any implementation):
- [ ] Every row in the tech stack table has a pinned `major.minor` version
- [ ] Every row has a rationale (what future devs need when replacing it)
- [ ] Coding standards are specific, not "follow best practices"
- [ ] Testing coverage thresholds are numeric, not adjectival
- [ ] A new dev can get to running tests from `git clone` in ≤ 4 commands
