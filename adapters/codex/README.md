# Codex adapter. STUB

> **Status**: Not implemented. Stub for a future contributor authoring the Codex adapter. ("Codex" here refers to coding agents using OpenAI's Codex-style CLI / SDK.)

## Role mapping (TODO)

| Kernel role | Codex mechanism | Notes |
|---|---|---|
| All | Codex function calling + tool-use API | Codex's API-driven nature means roles map to tool definitions, not file-based subagents |

## Concrete work to do

1. Author `adapters/codex/AGENT.md`. primary instructions + system prompt template for a Codex-based agent runtime.
2. Map each DNA skill's `run.sh` to a Codex tool definition (function-calling schema).
3. Figure out context-isolation for `verifier`. Codex API doesn't have threads/sessions by default; likely means explicit new API call with empty context.
4. Extend kit root `CLAUDE.md` Protocol A to detect Codex and copy this adapter's payload.
5. Dogfood.

## Contract

Same. Until complete, Codex users implement the methodology manually.
