#!/usr/bin/env bash
#
# dna-spec-validate. mechanical layer for the spec ↔ Blueprint validator.
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
# Pre-condition (NOT programmatically checked. discipline only): dna:spec-auditor
# has reported CLEAR for the Blueprint. The auditor's report is an LLM artifact
# and not machine-readable. If you skip the auditor, this gate cannot warn you.
#
# Exit codes:
#   0  PASS. mechanical checks all green (or all WARN in advisory mode). Proceed to dna:spec-validator subagent.
#   1  FAIL. at least one BLOCKING check failed in blocking mode.
#   2  SETUP. no spec.md, no Blueprint, no feature directory, etc.
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
      [ "$#" -eq 0 ] && { echo "[dna-spec-validate] SETUP. --mode requires an argument (blocking|advisory)" >&2; exit 2; }
      MODE_CLI="$1"
      shift
      ;;
    --mode=*)
      MODE_CLI="${1#--mode=}"
      shift
      ;;
    -*)
      echo "[dna-spec-validate] SETUP. unknown flag: $1" >&2
      exit 2
      ;;
    *)
      FEATURE_DIR_ARG="$1"
      shift
      ;;
  esac
done

# Mode resolution: CLI > env > default. Default flipped to `blocking` in
# Stage 3 (was `advisory` in Stages 1-2 for trust-building).
MODE="${MODE_CLI:-${DNA_SPEC_VALIDATE_MODE:-blocking}}"
case "$MODE" in
  blocking|advisory) ;;
  *)
    echo "[dna-spec-validate] SETUP. invalid mode '$MODE'. Use blocking|advisory." >&2
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
  echo "[dna-spec-validate] SETUP. cannot locate feature directory. Pass as arg: run.sh specs/NNN-name" >&2
  exit 2
fi

SPEC_FILE="$FEATURE_DIR/spec.md"
PLAN_FILE="$FEATURE_DIR/plan.md"
TASKS_FILE="$FEATURE_DIR/tasks.md"

if [ ! -f "$SPEC_FILE" ]; then
  echo "[dna-spec-validate] SETUP. $SPEC_FILE not found. Run /speckit-specify first." >&2
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
    echo "[dna-spec-validate] SETUP. required Blueprint file $f not found. Run dna:spec-auditor first." >&2
    exit 2
  fi
done

# ------------------------------------------------------------------
# 4. Banner
# ------------------------------------------------------------------

echo "[dna-spec-validate] Feature: $FEATURE_DIR"
echo "[dna-spec-validate] Mode:    $MODE"
echo "[dna-spec-validate] Spec:    $SPEC_FILE"
[ -n "$PLAN_FILE" ]  && echo "[dna-spec-validate] Plan:    $PLAN_FILE"  || echo "[dna-spec-validate] Plan:    (absent. tolerated)"
[ -n "$TASKS_FILE" ] && echo "[dna-spec-validate] Tasks:   $TASKS_FILE" || echo "[dna-spec-validate] Tasks:   (absent. tolerated)"
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

# Parse a spec.md's "Files this feature will touch" section. Emits one line
# per file: <path>|<marker> where marker is new|SHARED|modify|unknown.
# Mirrors tools/parse-files-touched.sh; inlined here so the validator stays
# self-contained when shipped to targets via refresh-target.sh.
_parse_files_touched() {
  local spec="$1"
  [ -f "$spec" ] || return 0
  awk '
    /^## Files this feature will touch/ { in_section=1; next }
    in_section && /^## / { in_section=0 }
    in_section && match($0, /`[^`]+`/) {
      path = substr($0, RSTART+1, RLENGTH-2)
      marker = "unknown"
      if (match($0, /\((SHARED|new|modify)[^)]*\)/, m)) {
        marker = m[1]
      }
      print path "|" marker
    }
  ' "$spec"
}

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
# Every "Principle N" cited in spec.md must exist as `^### Principle N -` in
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
# 5.7 Depth-tag-matches-scenario  (BLOCK)
# ------------------------------------------------------------------
# Compare spec's MAX declared depth against the MAX depth of cited Scenarios.
# Asymmetric: spec depth > scenario depth → BLOCK ("you claim more than the
# Blueprint supports"). Spec depth < scenario depth is legitimate partial
# implementation; subagent decides if that's drift.
#
# Depth ordering: E < W < D.

CHECK_NAME="depth-tag-matches-scenario"
depth_rank() {
  case "$1" in E) echo 1 ;; W) echo 2 ;; D) echo 3 ;; *) echo 0 ;; esac
}
# Scope depth-tag extraction to the spec.md's "## Depth" section. Loose
# matching across the whole spec produces false positives on backticked tags
# in discussion prose (e.g., "not a new `[D]` surface"). If no Depth section,
# fall back to the first backticked tag found.
SPEC_DEPTHS=$(awk '
  /^## Depth\b/ { in_section=1; next }
  in_section && /^## / { in_section=0 }
  in_section { print }
' "$SPEC_FILE" | grep -oE '`\[[DEW]\]`' 2>/dev/null | grep -oE '[DEW]' | sort -u || true)
if [ -z "$SPEC_DEPTHS" ]; then
  SPEC_DEPTHS=$(grep -oE '`\[[DEW]\]`' "$SPEC_FILE" 2>/dev/null | head -1 | grep -oE '[DEW]' || true)
fi
SPEC_MAX_RANK=0
SPEC_MAX_LETTER=""
for d in $SPEC_DEPTHS; do
  r=$(depth_rank "$d")
  if [ "$r" -gt "$SPEC_MAX_RANK" ]; then SPEC_MAX_RANK=$r; SPEC_MAX_LETTER=$d; fi
done

CITED_SCENARIOS=$(grep -oE 'Scenario [0-9]+' "$SPEC_FILE" 2>/dev/null | grep -oE '[0-9]+' | sort -u || true)
DEPTH_MATCH_FINDINGS=0
if [ "$SPEC_MAX_RANK" -gt 0 ] && [ -n "$CITED_SCENARIOS" ]; then
  # For each cited scenario, find its DEPTH line in 01.
  for n in $CITED_SCENARIOS; do
    SCENARIO_DEPTH=$(awk -v n="$n" '
      /^#{2,4}[[:space:]]+Scenario[[:space:]]+/ {
        match($0, /Scenario[[:space:]]+([0-9]+)/, m)
        cur = m[1]
        in_scenario = (cur == n) ? 1 : 0
      }
      in_scenario && /\*\*DEPTH\*\*[[:space:]]*:[[:space:]]*`\[[DEW]\]`/ {
        match($0, /`\[([DEW])\]`/, d)
        print d[1]
        exit
      }
    ' "$BLUEPRINT_DIR/01-SYSTEM-INTENT.md")
    [ -z "$SCENARIO_DEPTH" ] && continue  # scenario has no DEPTH line; skip
    SCENARIO_RANK=$(depth_rank "$SCENARIO_DEPTH")
    if [ "$SPEC_MAX_RANK" -gt "$SCENARIO_RANK" ]; then
      LOC_SPEC=$(file_line_of "$SPEC_FILE" "\`\\[$SPEC_MAX_LETTER\\]\`")
      LOC_BP=$(file_line_of "$BLUEPRINT_DIR/01-SYSTEM-INTENT.md" "Scenario[[:space:]]+$n")
      add_block "depth-tag-matches-scenario: spec claims [$SPEC_MAX_LETTER] (at $LOC_SPEC) but cited Scenario $n is classified [$SCENARIO_DEPTH] (at $LOC_BP). claimed depth exceeds Blueprint."
      DEPTH_MATCH_FINDINGS=$((DEPTH_MATCH_FINDINGS + 1))
    fi
  done
fi
if [ "$DEPTH_MATCH_FINDINGS" -eq 0 ]; then
  mark_pass "$CHECK_NAME"
else
  mark_block "$CHECK_NAME" "$DEPTH_MATCH_FINDINGS"
fi

# ------------------------------------------------------------------
# 5.8 File-paths-inside-modules  (BLOCK)
# ------------------------------------------------------------------
# Every src/* path in spec.md's "Files this feature will touch" section must
# fall within a module declared in 02-ARCHITECTURE.md's `## Module paths`
# block. Tree-parse fallback for legacy 02 (with WARN that fallback engaged).
# Exempt: tools/**, tests/**, docs/**, scripts/**, .specify/**, .github/**.

CHECK_NAME="file-paths-inside-modules"
ARCH_FILE="$BLUEPRINT_DIR/02-ARCHITECTURE.md"
EXEMPT_PREFIXES='^(tools/|tests?/|docs/|scripts/|\.specify/|\.github/)'

# Try structured "## Module paths" block first.
MODULE_PATHS=$(awk '
  /^## Module paths[[:space:]]*$/ { in_section=1; next }
  in_section && /^## / { in_section=0 }
  in_section && /^[[:space:]]*path:[[:space:]]*/ {
    sub(/^[[:space:]]*path:[[:space:]]*/, "")
    sub(/[[:space:]].*$/, "")
    print
  }
' "$ARCH_FILE" 2>/dev/null || true)
USED_FALLBACK=0
if [ -z "$MODULE_PATHS" ]; then
  # Fallback: parse top-level module dirs from the ASCII tree.
  MODULE_PATHS=$(awk '
    /^```/ { in_code = 1 - in_code; next }
    in_code && /^[[:space:]]*[├└]──[[:space:]]+[a-z][a-zA-Z0-9_]*\/?[[:space:]]*←?/ {
      match($0, /[├└]──[[:space:]]+([a-z][a-zA-Z0-9_]*)/, m)
      print "src/" m[1] "/**"
    }
  ' "$ARCH_FILE")
  USED_FALLBACK=1
  add_warn "file-paths-inside-modules: $ARCH_FILE has no '## Module paths' block. using ASCII-tree parse fallback (less reliable). Add the structured block (see template/blueprint/02-ARCHITECTURE.skeleton.md)."
fi

PATH_FINDINGS=0
TOUCHED=$(_parse_files_touched "$SPEC_FILE")

# Pre-compute the set of module-path prefixes once (strips trailing `**` glob).
# Use `set -f` so the `for glob in $MODULE_PATHS` word-split doesn't filesystem-
# expand `src/calendar/**` to `src/calendar/view.ts` etc. when CWD has those files.
set -f
MODULE_PREFIXES=()
for glob in $MODULE_PATHS; do
  MODULE_PREFIXES+=("${glob%\*\*}")
done
set +f

while IFS='|' read -r p _marker; do
  [ -z "$p" ] && continue
  # Strip leading ./ if any
  p="${p#./}"
  # Match exempt prefixes
  if echo "$p" | grep -qE "$EXEMPT_PREFIXES"; then
    continue
  fi
  matched=0
  for prefix in "${MODULE_PREFIXES[@]}"; do
    case "$p" in
      "$prefix"*) matched=1; break ;;
    esac
  done
  if [ "$matched" -eq 0 ]; then
    LOC=$(file_line_of "$SPEC_FILE" "$(printf '%s' "$p" | sed 's:[]\\/.^$*[]:\\&:g')")
    add_block "file-paths-inside-modules: '$p' is not within any declared module in $ARCH_FILE and is not in the exempt set (at $LOC)"
    PATH_FINDINGS=$((PATH_FINDINGS + 1))
  fi
done <<EOF
$TOUCHED
EOF

if [ "$PATH_FINDINGS" -eq 0 ]; then
  if [ "$USED_FALLBACK" -eq 1 ]; then
    mark_warn "$CHECK_NAME" 1  # the fallback-engaged warning itself
  else
    mark_pass "$CHECK_NAME"
  fi
else
  mark_block "$CHECK_NAME" "$PATH_FINDINGS"
fi

# ------------------------------------------------------------------
# 5.9 Cross-spec-ownership  (BLOCK)
# ------------------------------------------------------------------
# Across all OPEN specs (NOT yet merged to main), no two specs may claim
# write access to the same path without (SHARED) markers on both. Reuses
# the merged-branch filter convention from dna:cross-checker (SPEC-18).

CHECK_NAME="cross-spec-ownership"
OPEN_SPECS=()
ALL_SPECS=$(ls -d specs/[0-9][0-9][0-9]-*/ 2>/dev/null | sed 's:/$::' || true)

# Merged-branch list (best-effort; missing git → treat all as open with WARN).
MERGED_BRANCHES=""
HAVE_GIT=0
if git rev-parse --git-dir >/dev/null 2>&1; then
  HAVE_GIT=1
  BASE_REF="${DNA_SPEC_VALIDATE_BASE:-main}"
  MERGED_BRANCHES=$(git branch --merged "$BASE_REF" 2>/dev/null | sed 's/^[* ] //' | grep -v "^${BASE_REF##*/}$" || true)
fi

for spec_dir in $ALL_SPECS; do
  spec_branch="${spec_dir#specs/}"
  if [ "$HAVE_GIT" -eq 1 ] && echo "$MERGED_BRANCHES" | grep -qx "$spec_branch"; then
    continue  # merged → skip
  fi
  OPEN_SPECS+=("$spec_dir")
done

CROSS_FINDINGS=0
if [ "${#OPEN_SPECS[@]}" -ge 2 ]; then
  # Build path → "spec_dir|marker spec_dir|marker ..." map.
  CLAIMS_FILE=$(mktemp)
  for sd in "${OPEN_SPECS[@]}"; do
    sf="$sd/spec.md"
    [ -f "$sf" ] || continue
    while IFS='|' read -r p marker; do
      [ -z "$p" ] && continue
      # Skip directory entries (trailing /) and non-src
      case "$p" in
        */) continue ;;
      esac
      printf '%s\t%s\t%s\n' "$p" "$sd" "$marker" >> "$CLAIMS_FILE"
    done < <(_parse_files_touched "$sf")
  done
  # Find paths claimed >1 time
  CONFLICTS=$(awk '{ count[$1]++ } END { for (p in count) if (count[p] > 1) print p }' "$CLAIMS_FILE" | sort -u)
  for p in $CONFLICTS; do
    # Get all (spec, marker) for this path
    MATCHES=$(awk -v p="$p" '$1 == p { print $2 "|" $3 }' "$CLAIMS_FILE")
    NON_SHARED_COUNT=$(echo "$MATCHES" | awk -F'|' '$2 != "SHARED" { c++ } END { print c+0 }')
    if [ "$NON_SHARED_COUNT" -gt 0 ]; then
      WHO=$(echo "$MATCHES" | awk -F'|' '{ printf "%s%s(%s)", (NR>1?", ":""), $1, $2 }')
      add_block "cross-spec-ownership: '$p' claimed by multiple OPEN specs without (SHARED) on all: $WHO"
      CROSS_FINDINGS=$((CROSS_FINDINGS + 1))
    fi
  done
  rm -f "$CLAIMS_FILE"
fi
if [ "$HAVE_GIT" -eq 0 ]; then
  add_warn "cross-spec-ownership: not in a git repo. cannot filter merged branches; treated all specs as open."
fi

if [ "$CROSS_FINDINGS" -eq 0 ]; then
  mark_pass "$CHECK_NAME"
else
  mark_block "$CHECK_NAME" "$CROSS_FINDINGS"
fi

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
    echo "[dna-spec-validate] PASS. all checks green. Proceed to dna:spec-validator subagent for semantic-drift audit."
  else
    echo "[dna-spec-validate] PASS (with warnings). review warnings above before proceeding to subagent."
  fi
  exit 0
fi

# Block findings exist.
if [ "$MODE" = "advisory" ]; then
  echo "[dna-spec-validate] PASS (advisory mode). $BLOCK_COUNT blocking finding(s) downgraded to advisory. Re-run with --mode blocking to enforce."
  exit 0
else
  echo "[dna-spec-validate] FAIL. $BLOCK_COUNT blocking finding(s) in blocking mode. Fix and re-run."
  exit 1
fi
