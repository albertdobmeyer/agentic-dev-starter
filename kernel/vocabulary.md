# Vocabulary. shared terms

> The terms an adapter must preserve in documentation and agent instructions. Calling `dna:verifier` a "reviewer" in one adapter and a "checker" in another means practitioners talking across teams don't understand each other.

| Term | Definition | Source |
|---|---|---|
| **Blueprint Package** | The 7-doc spec for a project (00-CORE-PRINCIPLES through 05-CONSTRUCTION-SITES plus CONSTITUTION). | PROJECT_DNA §3.1 |
| **Experience Fidelity Scenario** | Concrete narrative of what the user experiences when a core principle is fully realized. Five mandatory sections: context, sensory narrative, negative assertions (≥3), behavioral variation (happy/edge/error), quantified rationale, filmable success criterion. | PROJECT_DNA §3.5 |
| **Negative Assertion** | Statement of the form "user NEVER has to X." The most powerful drift detector. first casualty of implementation shortcuts. Minimum 3 per scenario. | PROJECT_DNA §3.5.1 |
| **Scenario Validation Matrix** | Bidirectional table linking scenario assertions to implementation tasks. Mandatory deliverable per scenario. Both "Uncovered Assertions" and "Tasks Without Assertions" columns must be empty before planning proceeds. | PROJECT_DNA §3.5.4 |
| **Architecture Impact Assessment** | Per-scenario review of whether derived tasks fit existing patterns, require new infrastructure, or require subsystem redesign. Produced during specification, not implementation. | PROJECT_DNA §3.5.5 |
| **Coherence Check** | Two-test validation per scenario: Completeness (do all tasks together make the scenario filmable?) and Necessity (does removing any single task break the scenario?). | PROJECT_DNA §3.5.6 |
| **Depth Tag** | `[E]` exists / `[W]` works / `[D]` delivers. Classification of what "done" means for a requirement. Every requirement gets a tag. | PROJECT_DNA §3.4 |
| **Flattening** | The failure mode where a rich experiential principle decomposes into component tasks that each pass tests but never compose into the intended user experience. The primary enemy. | PROJECT_DNA Appendix A |
| **Construction Site** | A logged instance of implementation at a shallower depth than specified. Not a bug. the code works, just at a lower depth. Logged at the moment of simplification, not post-hoc. | PROJECT_DNA §5 |
| **Production Threshold** | The minimum set of scenarios that must pass at `[D]` depth before shipping. Everything else is v1.1. Decided during specification, not implementation. | PROJECT_DNA §3.6 |
| **Drift Remediation** | 6-step protocol for recovering from flattening discovered post-build without creating a Frankenstein app (bolted-on fixes). Diagnose → current-state walkthrough → new scenarios → task derivation → architecture review → implement as coherent mini-phase. | PROJECT_DNA §6 |
| **Audit Isolation** | The principle that the entity verifying a feature's fidelity must not carry context from the build conversation. Fresh read from disk. Avoids self-confirmation bias. | PROJECT_DNA §4.3 (reinforced) |
| **Current-State Walkthrough** | Numbered step-by-step documentation of what the user experiences today, used during drift remediation to make the gap between vision and reality concrete. | PROJECT_DNA §6.2 step 2 |
| **Filmable Success Criterion** | A scenario success criterion you can literally film. Observable behaviors, measurable outcomes, time constraints. "The system works correctly" is not filmable; "Video of user doing X in Y seconds without Z" is. | PROJECT_DNA §3.5.1 |
| **Load-Bearing Task** | A task whose removal breaks the scenario. Identified via the Necessity Test. Every load-bearing task is tagged `[D]`. | PROJECT_DNA §3.5.6 |
| **Seven Invariants** | The 7 things every adapter must preserve: Blueprint Package, Scenarios-with-negatives, Validation Matrix, Depth Tags, Construction Sites tracker, Audit Isolation, Pushback Contract. | `kernel/methodology.md` §"The six invariants" + §"Pushback contract" |

## Terms adapters may rename

Only these are allowed to vary per adapter (since they map to platform-specific constructs):

- "Subagent" → Cursor might call it "agent"; Amp might call it "role"; pick whatever the platform uses.
- "Skill" → adapters use their own skill / command / tool conventions.
- Slash command names (`/speckit-specify`, `/dna-test-gate`) → adapters may localize.

Everything else stays. Methodology vocabulary is not marketing copy.
