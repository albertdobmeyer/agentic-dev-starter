#!/usr/bin/env bash
#
# dna-spec-validate — mechanical layer for the spec ↔ Blueprint validator.
# Pairs with the dna:spec-validator subagent (which does the judgmental
# semantic-drift detection: negative-assertion violations, behavioral fidelity,
# non-goal violations, production-threshold consistency).
#
# This script checks the things you CAN check mechanically:
#   - depth tag in spec.md matches the cited Scenario's depth in 01-SYSTEM-INTENT.md
#   - file paths under "Files this feature will touch" lie within a declared module in 02-ARCHITECTURE.md
#   - all `Principle N` / `Scenario N` / `Phase N` / entity-name references resolve to real Blueprint entries
#   - cited `docs/NN-X.md:line` line refs exist and look like the expected pattern
#   - cross-spec file ownership: no two OPEN specs claim write access to the same path without (SHARED)
#
# Pre-condition (NOT programmatically checked — discipline only): dna:spec-auditor
# has reported CLEAR for the Blueprint. The auditor's report is an LLM artifact
# and not machine-readable. If you skip the auditor, this gate cannot warn you.
#
# Exit codes:
#   0  PASS — mechanical checks all green (or all WARN in advisory mode). Proceed to dna:spec-validator subagent.
#   1  FAIL — at least one BLOCKING check failed in blocking mode.
#   2  SETUP — no spec.md, no Blueprint, no feature directory, etc.
#
# Usage:
#   run.sh                                  # auto-detect feature dir from branch name
#   run.sh specs/004-task-status            # explicit feature dir
#   run.sh --mode advisory                  # downgrade all BLOCKING to WARN, exit 0 unless SETUP
#   run.sh --mode blocking specs/004-foo    # explicit blocking mode
#   run.sh --help                           # print this docstring and exit 0
#
# Environment variables:
#   DNA_SPEC_VALIDATE_MODE   blocking|advisory   default: advisory (Stage 1; flips to blocking in Stage 3)
#   DNA_SPEC_VALIDATE_BASE   git ref             default: main      (used for cross-spec ownership scoping; SPEC-19 Stage 3)
#
# CLI > env > default.

set -u

# ------------------------------------------------------------------
# 0. Argument parsing
# ------------------------------------------------------------------

usage() {
  sed -n '2,/^$/p' "$0" | sed 's/^# \{0,1\}//'
  exit "${1:-0}"
}

MODE_CLI=""
FEATURE_DIR_ARG=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --help|-h)
      usage 0
      ;;
    --mode)
      shift
      [ "$#" -eq 0 ] && { echo "[dna-spec-validate] SETUP — --mode requires an argument (blocking|advisory)" >&2; exit 2; }
      MODE_CLI="$1"
      shift
      ;;
    --mode=*)
      MODE_CLI="${1#--mode=}"
      shift
      ;;
    -*)
      echo "[dna-spec-validate] SETUP — unknown flag: $1" >&2
      exit 2
      ;;
    *)
      FEATURE_DIR_ARG="$1"
      shift
      ;;
  esac
done

# Mode resolution: CLI > env > default
MODE="${MODE_CLI:-${DNA_SPEC_VALIDATE_MODE:-advisory}}"
case "$MODE" in
  blocking|advisory) ;;
  *)
    echo "[dna-spec-validate] SETUP — invalid mode '$MODE'. Use blocking|advisory." >&2
    exit 2
    ;;
esac

# ------------------------------------------------------------------
# 1. Repo discovery
# ------------------------------------------------------------------

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$REPO_ROOT"

# ------------------------------------------------------------------
# 2. Feature directory discovery
# ------------------------------------------------------------------
# Same precedence as dna-test-gate: explicit arg > branch-name > most-recent.

FEATURE_DIR="$FEATURE_DIR_ARG"

if [ -z "$FEATURE_DIR" ]; then
  BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
  if [ -n "$BRANCH" ] && [ -d "specs/$BRANCH" ]; then
    FEATURE_DIR="specs/$BRANCH"
  else
    FEATURE_DIR=$(ls -td specs/[0-9][0-9][0-9]-*/ 2>/dev/null | head -1 | sed 's:/$::')
  fi
fi

if [ -z "$FEATURE_DIR" ] || [ ! -d "$FEATURE_DIR" ]; then
  echo "[dna-spec-validate] SETUP — cannot locate feature directory. Pass as arg: run.sh specs/NNN-name" >&2
  exit 2
fi

SPEC_FILE="$FEATURE_DIR/spec.md"
PLAN_FILE="$FEATURE_DIR/plan.md"
TASKS_FILE="$FEATURE_DIR/tasks.md"

if [ ! -f "$SPEC_FILE" ]; then
  echo "[dna-spec-validate] SETUP — $SPEC_FILE not found. Run /speckit-specify first." >&2
  exit 2
fi

# plan.md and tasks.md are tolerated-if-absent (validator runs as early as
# post-/speckit-specify; later runs cover plan + tasks too).
[ -f "$PLAN_FILE" ]  || PLAN_FILE=""
[ -f "$TASKS_FILE" ] || TASKS_FILE=""

# ------------------------------------------------------------------
# 3. Blueprint discovery
# ------------------------------------------------------------------

BLUEPRINT_DIR="docs"
REQUIRED_BLUEPRINT=(
  "$BLUEPRINT_DIR/00-CORE-PRINCIPLES.md"
  "$BLUEPRINT_DIR/01-SYSTEM-INTENT.md"
  "$BLUEPRINT_DIR/02-ARCHITECTURE.md"
  "$BLUEPRINT_DIR/04-COORDINATION-HINTS.md"
  "CONSTITUTION.md"
)

for f in "${REQUIRED_BLUEPRINT[@]}"; do
  if [ ! -f "$f" ]; then
    echo "[dna-spec-validate] SETUP — required Blueprint file $f not found. Run dna:spec-auditor first." >&2
    exit 2
  fi
done

# ------------------------------------------------------------------
# 4. Banner
# ------------------------------------------------------------------

echo "[dna-spec-validate] Feature: $FEATURE_DIR"
echo "[dna-spec-validate] Mode:    $MODE"
echo "[dna-spec-validate] Spec:    $SPEC_FILE"
[ -n "$PLAN_FILE" ]  && echo "[dna-spec-validate] Plan:    $PLAN_FILE"  || echo "[dna-spec-validate] Plan:    (absent — tolerated)"
[ -n "$TASKS_FILE" ] && echo "[dna-spec-validate] Tasks:   $TASKS_FILE" || echo "[dna-spec-validate] Tasks:   (absent — tolerated)"
echo "[dna-spec-validate] Reminder: this gate assumes dna:spec-auditor has reported CLEAR. It cannot verify that."
echo

# ------------------------------------------------------------------
# 5. Check execution (Stage 1: all stubbed; Stages 2–3 implement them)
# ------------------------------------------------------------------
# Each check appends to FINDINGS_BLOCK or FINDINGS_WARN. Verdict is computed
# from those at the end. In advisory mode, BLOCK findings get logged but the
# script still exits 0; only SETUP errors exit nonzero.

FINDINGS_BLOCK=()
FINDINGS_WARN=()
CHECKS_RUN=0
CHECKS_STUBBED=0

run_check() {
  # Marker for Stage 2/3 to replace. Right now every check is a stub.
  local check_name="$1"
  CHECKS_RUN=$((CHECKS_RUN + 1))
  CHECKS_STUBBED=$((CHECKS_STUBBED + 1))
  echo "[dna-spec-validate]   STUB   $check_name (impl lands in Stage 2/3)"
}

echo "[dna-spec-validate] Mechanical checks:"
run_check "depth-tag-matches-scenario"
run_check "file-paths-inside-modules"
run_check "principle-references-resolve"
run_check "scenario-references-resolve"
run_check "phase-references-resolve"
run_check "entity-references-resolve"
run_check "doc-line-citations-exist"
run_check "cross-spec-ownership"
echo

# ------------------------------------------------------------------
# 6. Verdict
# ------------------------------------------------------------------

BLOCK_COUNT=${#FINDINGS_BLOCK[@]}
WARN_COUNT=${#FINDINGS_WARN[@]}

echo "[dna-spec-validate] Summary:"
echo "  Checks run:       $CHECKS_RUN"
echo "  Stubbed (no-op):  $CHECKS_STUBBED"
echo "  Blocking findings: $BLOCK_COUNT"
echo "  Warnings:          $WARN_COUNT"
echo

if [ "$BLOCK_COUNT" -gt 0 ]; then
  echo "[dna-spec-validate] Blocking findings:"
  for f in "${FINDINGS_BLOCK[@]}"; do echo "  - $f"; done
  echo
fi
if [ "$WARN_COUNT" -gt 0 ]; then
  echo "[dna-spec-validate] Warnings:"
  for f in "${FINDINGS_WARN[@]}"; do echo "  - $f"; done
  echo
fi

if [ "$BLOCK_COUNT" -eq 0 ]; then
  if [ "$WARN_COUNT" -eq 0 ]; then
    echo "[dna-spec-validate] PASS — all checks green. Proceed to dna:spec-validator subagent for semantic-drift audit."
  else
    echo "[dna-spec-validate] PASS (with warnings) — review warnings above before proceeding to subagent."
  fi
  exit 0
fi

# Block findings exist.
if [ "$MODE" = "advisory" ]; then
  echo "[dna-spec-validate] PASS (advisory mode) — $BLOCK_COUNT blocking finding(s) downgraded to advisory. Re-run with --mode blocking to enforce."
  exit 0
else
  echo "[dna-spec-validate] FAIL — $BLOCK_COUNT blocking finding(s) in blocking mode. Fix and re-run."
  exit 1
fi
