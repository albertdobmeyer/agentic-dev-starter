#!/usr/bin/env bash
#
# dna-delegate — pre-dispatch safety check for parallel sub-agent delegation.
# Actual delegation uses the Agent tool, which lives in agent runtime.
# This script validates the preconditions before delegation is attempted.
#
# Exit codes:
#   0  Safe to delegate — dna-decompose passed, shared interfaces exist, working tree clean.
#   1  Unsafe — one or more preconditions fail.
#   2  Setup problem.

set -u
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$REPO_ROOT"

FEATURE_DIR="${1:-}"
if [ -z "$FEATURE_DIR" ]; then
  BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
  [ -n "$BRANCH" ] && [ -d "specs/$BRANCH" ] && FEATURE_DIR="specs/$BRANCH"
fi
if [ -z "$FEATURE_DIR" ] || [ ! -d "$FEATURE_DIR" ]; then
  echo "[dna-delegate] SETUP — locate feature dir. Pass: run.sh specs/NNN-name" >&2
  exit 2
fi

echo "[dna-delegate] Pre-dispatch safety check for $FEATURE_DIR"
echo

FAILS=0

# ------------------------------------------------------------------
# 1. dna-decompose must have passed
# ------------------------------------------------------------------
DECOMPOSE_SCRIPT=".claude/skills/dna-decompose/run.sh"
if [ -x "$DECOMPOSE_SCRIPT" ]; then
  if bash "$DECOMPOSE_SCRIPT" "$FEATURE_DIR" >/dev/null 2>&1; then
    echo "  ✅ decomposition is merge-safe (dna-decompose passed)"
  else
    echo "  ❌ decomposition has overlaps or uninspectable tasks — run bash $DECOMPOSE_SCRIPT $FEATURE_DIR for details"
    FAILS=$((FAILS+1))
  fi
else
  echo "  ⚠️  $DECOMPOSE_SCRIPT not found — cannot verify decomposition safety"
  FAILS=$((FAILS+1))
fi

# ------------------------------------------------------------------
# 2. Working tree must be clean on the feature branch
# ------------------------------------------------------------------
if [ -z "$(git status --porcelain 2>/dev/null)" ]; then
  echo "  ✅ working tree clean"
else
  echo "  ❌ uncommitted changes present — commit or stash before delegating to sub-agents"
  echo "    (sub-agents will operate on the current state; unsaved changes cause confusion)"
  git status --short | head -5 | sed 's/^/    /'
  FAILS=$((FAILS+1))
fi

# ------------------------------------------------------------------
# 3. plan.md should declare shared interfaces / types before delegation
# ------------------------------------------------------------------
# PROJECT_DNA Section 3.5.5 and CONSTITUTION.md Art 8: shared interfaces
# defined BEFORE delegation so sub-agents import, never create, shared models.

PLAN_FILE="$FEATURE_DIR/plan.md"
if [ -f "$PLAN_FILE" ]; then
  # Heuristic: look for an Interfaces / Contracts / Shared types section.
  if grep -qiE '^(##|###)\s+(shared (interfaces|types|contracts)|interface contracts|contracts)' "$PLAN_FILE"; then
    echo "  ✅ plan.md has a shared-interfaces section"
  else
    echo "  ⚠️  plan.md has no 'Shared Interfaces' or 'Contracts' section — sub-agents may create competing definitions"
    echo "    Add a dedicated section listing every interface sub-agents will consume."
    # Soft warning, not a fail
  fi
else
  echo "  ❌ plan.md not found — run /speckit-plan before delegating"
  FAILS=$((FAILS+1))
fi

# ------------------------------------------------------------------
# 4. Cross-checker verdict (if other features are open)
# ------------------------------------------------------------------
# Simple proxy: if any other specs/NNN-*/ exists (open branch), nudge toward
# running the cross-checker subagent. Script does not invoke the subagent;
# that requires the Agent tool.
OTHER_SPECS=$(ls -d specs/[0-9][0-9][0-9]-*/ 2>/dev/null | grep -v "$FEATURE_DIR/" | wc -l)
if [ "$OTHER_SPECS" -gt 0 ]; then
  echo "  ℹ️  $OTHER_SPECS other open spec(s) detected — run the dna:cross-checker subagent before delegating if you haven't already"
fi

# ------------------------------------------------------------------
# Verdict
# ------------------------------------------------------------------
echo
if [ $FAILS -eq 0 ]; then
  echo "[dna-delegate] PASS — preconditions met. Main agent may now invoke the Agent tool to spawn sub-agents per the decomposed [P] tasks."
  echo "  Remember: each sub-agent gets ONE file or ONE module. Shared interfaces defined in plan.md; sub-agents import, never create."
  exit 0
else
  echo "[dna-delegate] FAIL — $FAILS precondition(s) failed. Do NOT dispatch sub-agents until resolved."
  exit 1
fi
