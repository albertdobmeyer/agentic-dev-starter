# 00-CORE-PRINCIPLES: {PROJECT_NAME}

> **Purpose**: the "why" of this system. Domain knowledge, design philosophy, the principles that generate every scenario downstream. Principles without a corresponding Experience Fidelity Scenario (in `01-SYSTEM-INTENT.md`) will be **flattened** during implementation. Every principle here must later produce at least one scenario and at least one `[D]` requirement.

## Problem statement

{FILL IN: One paragraph. Who has the pain? What is the pain? Why is today's solution inadequate? Be specific; naming the user and the cost of the status quo makes downstream specs sharper.}

## Target users

{FILL IN: 2-3 segments. For each: role name, typical context (time of day, environment, what they're doing before they touch the app), what they care about, what frustrates them today, approximate percentage of user base.}

**Segment 1 - {role}**: {context, pain, %}
**Segment 2 - {role}**: {context, pain, %}

## Domain model (nouns, not features)

{FILL IN: The core **things** in this domain: entities, not feature names. Capture relationships, hierarchies, and ownership. Example: "A Project contains Tasks. A Task is assigned to one User and has a Status." Keep it declarative.}

## Core principles

> Each principle is a load-bearing statement about how the system behaves. Each must produce one Experience Fidelity Scenario in `01-SYSTEM-INTENT.md`. Principles without scenarios are wishes.

### Principle 1: {name}
{FILL IN: One paragraph. The design commitment. What this principle rules IN and rules OUT.}

### Principle 2: {name}
{FILL IN.}

### Principle 3: {name}
{FILL IN.}

_(Add more as needed. Keep the count small; 3-7 principles is typical. Too many principles produce a diluted spec.)_

## Business model

{FILL IN: How this makes money / justifies effort. Subscription, internal tool, product line, etc. What's the pricing anchor? What differentiates free vs paid tiers (if applicable)? What's the competitive landscape?}

## Hard constraints

{FILL IN: Regulatory, compliance, privacy, performance, integration, platform. These are invariants: the system does not function correctly if any of these are violated.}

- {Constraint 1, e.g., "HIPAA-grade data retention required"}
- {Constraint 2, e.g., "Must work offline for field use"}
- {Constraint 3}

## Anti-principles (what this system is NOT)

{FILL IN: Explicit negatives. See also `04-COORDINATION-HINTS.md` non-goals.}

- Not a {category}: {why}
- Not a {category}

---

**Next**: When every principle has a corresponding Experience Fidelity Scenario in `01-SYSTEM-INTENT.md` with 3+ negative assertions and a filmable success criterion, this document is complete. Until then, it's unfinished; do not start `/speckit-specify`.
