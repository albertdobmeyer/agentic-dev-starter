# Roles — subagent role taxonomy

> What roles exist in the methodology, what they do, what they read, what they return. **Agent-agnostic.** Each adapter maps these to its own subagent / command / skill system.

A role is a **bounded responsibility** with its own context. Roles matter because the builder should not grade its own work (Invariant 6); different roles need different contexts.

## The core 10 roles

| # | Role | Bounded responsibility | Called by / when |
|---|---|---|---|
| 1 | **specifier** | Reads the Blueprint's `00-CORE-PRINCIPLES.md` + `01-SYSTEM-INTENT.md`; writes the per-feature `spec.md` with Given/When/Then acceptance criteria mapped to scenarios. | Main agent at `/speckit-specify` equivalent. |
| 2 | **planner** | Reads `spec.md` + the Blueprint; writes `plan.md` with module decomposition, shared-interface contracts, phase mapping. | Main agent at `/speckit-plan`. |
| 3 | **tasker** | Reads `plan.md` + `01-SYSTEM-INTENT.md`'s Validation Matrix; writes `tasks.md` with task-to-assertion references and `[P]` parallelism markers. | Main agent at `/speckit-tasks`. |
| 4 | **implementer** | One file / one module per instance. Reads its scoped task + the shared interfaces from `plan.md`; writes code. Forbidden from reading unrelated code. | Spawned in parallel via delegate role after decompose. |
| 5 | **test-gatekeeper** | Verifies every implementation task has a test file that is RED before implementation proceeds. Zero-trust; cannot be overridden. | Runs before implementer dispatch. |
| 6 | **cross-checker** | Parses "Files this feature will touch" across every open spec; blocks branches claiming the same shared file. | Runs before new-feature-branch creation and before any PR to main. |
| 7 | **decomposer** | Validates that `[P]` parallel tasks have zero file overlap. The split itself is agentic work; the validation is mechanical. | Runs between tasker and delegate. |
| 8 | **delegate-dispatcher** | Pre-dispatch safety check: decompose passed, working tree clean, shared interfaces declared. Does not spawn — validates that spawning is safe. | Runs before implementer dispatch. |
| 9 | **construction-logger** | Owns `05-CONSTRUCTION-SITES.md`; appends a row for every depth downgrade at the moment it happens; enforces phase-closure rules around open `[D]` entries. | Called proactively during implementation when any simplification is considered. |
| 10 | **verifier** | Fresh-context audit. Walks every Experience Fidelity Scenario against current code; verifies every negative assertion holds; emits CONGRUENT / PARTIAL / DIVERGENT. | Runs after implementer phase completes. MUST have zero carryover from build context. |

## Supplementary roles (methodology-useful, not minimally required)

| # | Role | Responsibility |
|---|---|---|
| 11 | **spec-auditor** | Runs the 20+ quality checks from `HANDOFF_FORMAT.md` against the Blueprint before `/speckit-specify`. |
| 12 | **architecture-impact** | Produces Architecture Impact Assessment per scenario (during spec phase, not build). |
| 13 | **coherence-gate** | Runs the Completeness + Necessity tests on the task list per scenario. |
| 14 | **drift-remediator** | Handles PROJECT_DNA §6 remediation protocol when flattening is discovered post-build. 6-step recovery. |
| 15 | **context-guardian** | Monitors token-meter output; triggers session handoff before ~100k tokens. Has the authority to say STOP. |
| 16 | **pr-reviewer** | Reads PR diff against Blueprint + CONSTITUTION + `dna-cross-checker` report + `dna-verifier` verdict. Blind to the build conversation. |
| 17 | **kit-graduate** | Deletes `NEXT_STEPS.md` scaffold file when all `{FILL IN}` / `SKIP-DEFAULT` markers are resolved. |

## Invariants roles must satisfy

- **Bounded responsibility**: one role = one job. "Generic assistant" is not a role.
- **Declared context source**: every role names where it reads from. No implicit knowledge.
- **Declared return type**: verdict (CLEAR/WARN/BLOCK), artifact (a specific file written), or mutation (file appended).
- **Isolation when it matters**: roles 10, 16 (verifier, pr-reviewer) MUST run in isolated context. Others may share main-agent context.
- **Refusal contract**: each role names what it must refuse to do. Example: `verifier` refuses to accept main-agent self-assessment; `construction-logger` refuses vague resolutions.

## Adapter mapping

Each adapter maps each role to its platform's idiom:

| Role | Claude-Code adapter | Cursor adapter | Amp adapter | Codex adapter |
|---|---|---|---|---|
| specifier | slash command `/speckit-specify` + main-agent execution | TODO | TODO | TODO |
| test-gatekeeper | skill `.claude/skills/dna-test-gate/` + `run.sh` | TODO | TODO | TODO |
| cross-checker | subagent `.claude/agents/dna-cross-checker.md` | TODO | TODO | TODO |
| construction-logger | subagent `.claude/agents/dna-construction-logger.md` | TODO | TODO | TODO |
| verifier | subagent `.claude/agents/dna-verifier.md` | TODO | TODO | TODO |
| ... | ... | | | |

(Full mapping in each adapter's README.)

## The portability promise

If every role in this file has a mapping in an adapter's README, that adapter implements the methodology. If even one role is unmapped, the adapter is incomplete and methodology gaps will surface as implementation gaps.
