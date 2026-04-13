# Worked Example: agentic-bookmark-organizer

This directory contains the **completed planning output** for a real project — an Ollama-powered CLI tool that organizes Chrome bookmark exports.

Use these files as a reference when filling out your own handoff documents. They demonstrate:

- **VISION.md** — Experience fidelity scenarios with negative assertions, behavioral variation, filmable success criteria, and depth tags
- **ARCHITECTURE.md** — Pinned tech stack, module boundaries, complete data model with Python dataclasses, data flow diagram
- **CONSTITUTION.md** — Full 9-article constitution with a customized Article 10 (project-specific rules)
- **SCOPE.md** — 10 explicit non-goals, each preventing a specific rabbit hole
- **CLAUDE.md** — What the generated CLAUDE.md looks like after being customized for the project

## About the Project

**agentic-bookmark-organizer** takes a Chrome bookmarks HTML export (1,067 bookmarks across 126 folders), checks each URL for liveness, uses Ollama to semantically categorize them, and produces a cleaned, reorganized file ready to re-import.

These handoff documents were produced by following the agentic-dev-starter planning methodology — specifically the PLANNING_INSTRUCTIONS.md guidance on experience fidelity scenarios and anti-flattening.
