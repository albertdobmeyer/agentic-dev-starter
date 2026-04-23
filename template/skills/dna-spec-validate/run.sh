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
# 5. Check execution
# ------------------------------------------------------------------
# Each check appends to FINDINGS_BLOCK (severity: must-fix) or FINDINGS_WARN
# (severity: investigate). Verdict computed at the end. In advisory mode,
# BLOCK findings get logged but the script still exits 0; only SETUP errors
# exit nonzero.
#
# Stages 2+ implement these. Stages 3+ add depth-match, file-paths-inside-modules,
# and cross-spec-ownership and flip default mode to blocking.

FINDINGS_BLOCK=()
FINDINGS_WARN=()
CHECKS_RUN=0
CHECKS_STUBBED=0

add_warn()  { FINDINGS_WARN+=("$*"); }
add_block() { FINDINGS_BLOCK+=("$*"); }

# Helper: find first line in a file matching a pattern; emit "<file>:<lineno>"
# (or just "<file>" if no match found).
file_line_of() {
  local file="$1"
  local pattern="$2"
  local lineno
  lineno=$(grep -nE "$pattern" "$file" 2>/dev/null | head -1 | cut -d: -f1)
  if [ -n "$lineno" ]; then
    echo "$file:$lineno"
  else
    echo "$file"
  fi
}

mark_stub() {
  local check_name="$1"
  CHECKS_RUN=$((CHECKS_RUN + 1))
  CHECKS_STUBBED=$((CHECKS_STUBBED + 1))
  echo "[dna-spec-validate]   STUB   $check_name (impl lands in Stage 3)"
}

mark_pass() {
  local check_name="$1"
  CHECKS_RUN=$((CHECKS_RUN + 1))
  echo "[dna-spec-validate]   PASS   $check_name"
}

mark_warn() {
  local check_name="$1"
  local count="$2"
  CHECKS_RUN=$((CHECKS_RUN + 1))
  echo "[dna-spec-validate]   WARN   $check_name ($count finding(s))"
}

mark_block() {
  local check_name="$1"
  local count="$2"
  CHECKS_RUN=$((CHECKS_RUN + 1))
  echo "[dna-spec-validate]   BLOCK  $check_name ($count finding(s))"
}

echo "[dna-spec-validate] Mechanical checks:"

# ------------------------------------------------------------------
# 5.1 Depth-tag presence
# ------------------------------------------------------------------
# Spec.md must declare a depth tag somewhere. Backtick-wrapped form `[D]`,
# `[W]`, or `[E]` per the convention in 01-SYSTEM-INTENT.md.

CHECK_NAME="depth-tag-presence"
DEPTH_HITS=$(grep -cE '`\[[DEW]\]`' "$SPEC_FILE" || true)
if [ "$DEPTH_HITS" -gt 0 ]; then
  mark_pass "$CHECK_NAME"
else
  WARN_MSG="depth-tag-presence: spec.md has no \`[D]\`/\`[W]\`/\`[E]\` tag. Every feature must declare its depth (at $SPEC_FILE)."
  add_warn "$WARN_MSG"
  mark_warn "$CHECK_NAME" 1
fi

# ------------------------------------------------------------------
# 5.2 Principle references resolve
# ------------------------------------------------------------------
# Every "Principle N" cited in spec.md must exist as `^### Principle N —` in
# 00-CORE-PRINCIPLES.md. Undefined → WARN (could be roadmap, not drift).

CHECK_NAME="principle-references-resolve"
CITED=$(grep -oE 'Principle [0-9]+' "$SPEC_FILE" 2>/dev/null | grep -oE '[0-9]+' | sort -u || true)
DEFINED=$(grep -oE '^### Principle [0-9]+' "$BLUEPRINT_DIR/00-CORE-PRINCIPLES.md" 2>/dev/null | grep -oE '[0-9]+' | sort -u || true)
PRINCIPLE_FINDINGS=0
for n in $CITED; do
  if ! echo "$DEFINED" | grep -qx "$n"; then
    LOC=$(file_line_of "$SPEC_FILE" "Principle $n\b")
    add_warn "principle-references-resolve: spec cites Principle $n but no such principle defined in $BLUEPRINT_DIR/00-CORE-PRINCIPLES.md (at $LOC)"
    PRINCIPLE_FINDINGS=$((PRINCIPLE_FINDINGS + 1))
  fi
done
if [ "$PRINCIPLE_FINDINGS" -eq 0 ]; then
  mark_pass "$CHECK_NAME"
else
  mark_warn "$CHECK_NAME" "$PRINCIPLE_FINDINGS"
fi

# ------------------------------------------------------------------
# 5.3 Scenario references resolve
# ------------------------------------------------------------------
# Permissive heading regex per Plan agent: H2-H4, em-dash/hyphen/colon variants.

CHECK_NAME="scenario-references-resolve"
CITED=$(grep -oE 'Scenario [0-9]+' "$SPEC_FILE" 2>/dev/null | grep -oE '[0-9]+' | sort -u || true)
DEFINED=$(grep -oE '^#{2,4}[[:space:]]+Scenario[[:space:]]+[0-9]+' "$BLUEPRINT_DIR/01-SYSTEM-INTENT.md" 2>/dev/null | grep -oE '[0-9]+' | sort -u || true)
SCENARIO_FINDINGS=0
for n in $CITED; do
  if ! echo "$DEFINED" | grep -qx "$n"; then
    LOC=$(file_line_of "$SPEC_FILE" "Scenario $n\b")
    add_warn "scenario-references-resolve: spec cites Scenario $n but no such scenario defined in $BLUEPRINT_DIR/01-SYSTEM-INTENT.md (at $LOC)"
    SCENARIO_FINDINGS=$((SCENARIO_FINDINGS + 1))
  fi
done
if [ "$SCENARIO_FINDINGS" -eq 0 ]; then
  mark_pass "$CHECK_NAME"
else
  mark_warn "$CHECK_NAME" "$SCENARIO_FINDINGS"
fi

# ------------------------------------------------------------------
# 5.4 Phase references resolve
# ------------------------------------------------------------------

CHECK_NAME="phase-references-resolve"
CITED=$(grep -oE 'Phase [0-9]+' "$SPEC_FILE" 2>/dev/null | grep -oE '[0-9]+' | sort -u || true)
DEFINED=$(grep -oE '^### Phase [0-9]+' "$BLUEPRINT_DIR/04-COORDINATION-HINTS.md" 2>/dev/null | grep -oE '[0-9]+' | sort -u || true)
PHASE_FINDINGS=0
for n in $CITED; do
  if ! echo "$DEFINED" | grep -qx "$n"; then
    LOC=$(file_line_of "$SPEC_FILE" "Phase $n\b")
    add_warn "phase-references-resolve: spec cites Phase $n but no such phase defined in $BLUEPRINT_DIR/04-COORDINATION-HINTS.md (at $LOC)"
    PHASE_FINDINGS=$((PHASE_FINDINGS + 1))
  fi
done
if [ "$PHASE_FINDINGS" -eq 0 ]; then
  mark_pass "$CHECK_NAME"
else
  mark_warn "$CHECK_NAME" "$PHASE_FINDINGS"
fi

# ------------------------------------------------------------------
# 5.5 Entity references resolve
# ------------------------------------------------------------------
# Field-form references like `Task.status`, `User.email`. Filters out file-
# extension matches (CONSTITUTION.md, TaskCard.tsx, etc.) by suffix blacklist.
# Entity (left of `.`) must appear as `interface <Entity>` in 01-SYSTEM-INTENT.md.

CHECK_NAME="entity-references-resolve"
EXT_BLACKLIST='^(md|tsx?|jsx?|py|sh|json|ya?ml|toml|sql|html|css|txt|tsbuildinfo|map|lock)$'
CITED=$(grep -oE '\b[A-Z][a-zA-Z0-9]+\.[a-z][a-zA-Z0-9_]+\b' "$SPEC_FILE" 2>/dev/null \
  | awk -F. -v ext="$EXT_BLACKLIST" '$2 !~ ext { print $1 }' \
  | sort -u || true)
DEFINED=$(grep -oE 'interface[[:space:]]+[A-Z][a-zA-Z0-9]+' "$BLUEPRINT_DIR/01-SYSTEM-INTENT.md" 2>/dev/null \
  | awk '{print $NF}' | sort -u || true)
ENTITY_FINDINGS=0
for e in $CITED; do
  if ! echo "$DEFINED" | grep -qx "$e"; then
    LOC=$(file_line_of "$SPEC_FILE" "\\b$e\\.")
    add_warn "entity-references-resolve: spec cites entity $e but no such interface defined in $BLUEPRINT_DIR/01-SYSTEM-INTENT.md (at $LOC)"
    ENTITY_FINDINGS=$((ENTITY_FINDINGS + 1))
  fi
done
if [ "$ENTITY_FINDINGS" -eq 0 ]; then
  mark_pass "$CHECK_NAME"
else
  mark_warn "$CHECK_NAME" "$ENTITY_FINDINGS"
fi

# ------------------------------------------------------------------
# 5.6 Doc line citations exist
# ------------------------------------------------------------------
# `docs/NN-X.md:LINE` or `docs/NN-X.md:LINE-LINE`. Line(s) must exist.
# Stale ranges → WARN (Blueprint edits will move line numbers; this is
# intrinsic to citing line numbers, hence WARN not BLOCK).

CHECK_NAME="doc-line-citations-exist"
CITES=$(grep -oE 'docs/[0-9]{2}-[A-Z][A-Z-]*\.md:[0-9]+(-[0-9]+)?' "$SPEC_FILE" 2>/dev/null | sort -u || true)
LINE_FINDINGS=0
for cite in $CITES; do
  doc="${cite%%:*}"
  range="${cite#*:}"
  end="${range#*-}"
  start="${range%%-*}"
  if [ ! -f "$doc" ]; then
    add_warn "doc-line-citations-exist: cited doc $doc does not exist (in $SPEC_FILE)"
    LINE_FINDINGS=$((LINE_FINDINGS + 1))
    continue
  fi
  total=$(wc -l < "$doc" | tr -d ' ')
  if [ "$end" -gt "$total" ]; then
    LOC=$(file_line_of "$SPEC_FILE" "${cite//\//\\/}")
    add_warn "doc-line-citations-exist: cited line $cite exceeds $doc length ($total lines) (at $LOC)"
    LINE_FINDINGS=$((LINE_FINDINGS + 1))
  fi
done
if [ "$LINE_FINDINGS" -eq 0 ]; then
  mark_pass "$CHECK_NAME"
else
  mark_warn "$CHECK_NAME" "$LINE_FINDINGS"
fi

# ------------------------------------------------------------------
# 5.7 (Stage 3) — depth-tag-matches-scenario, file-paths-inside-modules,
#                cross-spec-ownership. Stubbed in Stage 2.
# ------------------------------------------------------------------

mark_stub "depth-tag-matches-scenario"
mark_stub "file-paths-inside-modules"
mark_stub "cross-spec-ownership"
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
