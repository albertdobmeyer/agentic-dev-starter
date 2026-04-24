#!/usr/bin/env bash
#
# dna-verify. mechanical verification layer.
# Pairs with the dna:verifier subagent (which does the judgmental scenario-walk).
# This script checks the things you CAN check mechanically:
#   - test coverage threshold from CONSTITUTION Article 10
#   - every [D] requirement in docs/01-SYSTEM-INTENT.md has ≥1 integration test
#   - every Experience Fidelity Scenario has at least one test file referencing it
#
# Exit codes:
#   0  PASS. mechanical checks all green. Main agent may proceed to dna:verifier subagent for scenario walk.
#   1  FAIL. mechanical floor not met; subagent audit is premature.
#   2  Setup problem (no Blueprint, no tests dir, etc.)

set -u
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$REPO_ROOT"

# ------------------------------------------------------------------
# 1. Structural prerequisites
# ------------------------------------------------------------------
for f in docs/01-SYSTEM-INTENT.md CONSTITUTION.md; do
  if [ ! -f "$f" ]; then
    echo "[dna-verify] SETUP. required file $f not found. Run dna:spec-auditor first." >&2
    exit 2
  fi
done

TESTS_DIR=""
for d in tests test __tests__; do
  [ -d "$d" ] && TESTS_DIR="$d" && break
done
if [ -z "$TESTS_DIR" ]; then
  # Also check for co-located tests
  if ls src/**/*.test.* src/**/*.spec.* 2>/dev/null | head -1 >/dev/null; then
    TESTS_DIR="src (co-located)"
  else
    echo "[dna-verify] SETUP. no tests/ directory and no co-located *.test.* / *.spec.* files found." >&2
    exit 2
  fi
fi

echo "[dna-verify] Tests location: $TESTS_DIR"

# ------------------------------------------------------------------
# 2. Extract coverage threshold from CONSTITUTION Article 10
# ------------------------------------------------------------------
# Looks for a line like "coverage: ≥80%" or "80% line coverage" under Article 10.

COVERAGE_THRESHOLD=$(grep -oE '[0-9]+ ?%' CONSTITUTION.md | head -1 | tr -d ' %')
if [ -z "$COVERAGE_THRESHOLD" ]; then
  COVERAGE_THRESHOLD=80  # methodology default
  echo "[dna-verify] No coverage threshold found in CONSTITUTION.md. using methodology default: 80%"
else
  echo "[dna-verify] Coverage threshold from CONSTITUTION.md: ${COVERAGE_THRESHOLD}%"
fi

# ------------------------------------------------------------------
# 3. Compute changed-file set (for branch-diff-scoped coverage, SPEC-16)
# ------------------------------------------------------------------
# Rule: the threshold applies to files touched by the current branch, not
# the whole project. Predecessor-feature debt should not block a new
# feature that is itself well-tested. Falls back to project-wide aggregate
# when the branch has no changes vs main (or when running on main).

CHANGED_FILES=""
BASE_BRANCH="${DNA_VERIFY_BASE:-main}"

if git rev-parse --verify "$BASE_BRANCH" >/dev/null 2>&1; then
  # Three-dot diff: files touched in this branch that aren't on $BASE_BRANCH.
  CHANGED_FILES=$(git diff --name-only "$BASE_BRANCH"...HEAD 2>/dev/null \
    | grep -E '^(src|lib|app|packages/.+/src)/.*\.(ts|tsx|js|jsx)$' \
    | grep -vE '\.(test|spec)\.' || true)
fi

if [ -n "$CHANGED_FILES" ]; then
  CHANGED_COUNT=$(echo "$CHANGED_FILES" | wc -l | tr -d ' ')
  echo "[dna-verify] Branch-diff mode: $CHANGED_COUNT source file(s) changed vs $BASE_BRANCH"
else
  echo "[dna-verify] No source-file diff vs $BASE_BRANCH. falling back to project-wide coverage"
fi

# ------------------------------------------------------------------
# 4. Run test suite with coverage
# ------------------------------------------------------------------
COVERAGE_PCT=""
COVERAGE_RUNNER=""
COVERAGE_CHECK=""
PER_FILE_FAILS=""

if [ -f "package.json" ]; then
  if grep -q '"vitest"' package.json; then
    COVERAGE_RUNNER="vitest"
    if command -v npx >/dev/null 2>&1; then
      set +e
      # json-summary writes coverage/coverage-summary.json for per-file lookup.
      OUTPUT=$(npx vitest run --coverage --coverage.reporter=text --coverage.reporter=json-summary --reporter=basic 2>&1)
      RC=$?
      set -e
      if [ $RC -ne 0 ]; then
        echo "[dna-verify] FAIL. test suite did not pass (vitest exit $RC)"
        echo "$OUTPUT" | tail -20
        exit 1
      fi

      if [ -n "$CHANGED_FILES" ] && [ -f "coverage/coverage-summary.json" ]; then
        # Per-file mode. For each changed file, look up its per-file pct.
        # Keys in coverage-summary.json are absolute paths; on Windows they
        # contain escaped backslashes. Normalize in the lookup itself.
        PY=""
        for p in python3 python; do
          if command -v "$p" >/dev/null 2>&1; then PY="$p"; break; fi
        done

        while IFS= read -r rel; do
          [ -z "$rel" ] && continue
          pct="MISSING"

          if command -v jq >/dev/null 2>&1; then
            pct=$(jq -r --arg suffix "/$rel" '
              to_entries
              | map(select((.key | gsub("\\\\"; "/")) | endswith($suffix)))
              | if length > 0 then (.[0].value.lines.pct | tostring) else "MISSING" end
            ' coverage/coverage-summary.json 2>/dev/null)
          elif [ -n "$PY" ]; then
            pct=$("$PY" -c "
import json, sys
try:
    with open('coverage/coverage-summary.json') as f:
        data = json.load(f)
    rel = sys.argv[1]
    for key, val in data.items():
        if key == 'total':
            continue
        norm = key.replace('\\\\', '/')
        if norm.endswith('/' + rel):
            print(val['lines']['pct'])
            sys.exit(0)
    print('MISSING')
except Exception as e:
    print('MISSING')
" "$rel" 2>/dev/null)
          else
            echo "  [dna-verify] WARN. neither jq nor python available; cannot parse per-file coverage. Falling back to project-wide."
            COVERAGE_PCT=$(echo "$OUTPUT" | grep -E "^All files" | awk -F'|' '{gsub(/ /,"",$2); print $2}' | head -1)
            break
          fi

          if [ "$pct" = "MISSING" ] || [ "$pct" = "null" ]; then
            echo "  $rel: no coverage data (file not imported by any test)"
            PER_FILE_FAILS="$PER_FILE_FAILS\n  - $rel: no coverage data"
            continue
          fi

          pct_int=${pct%.*}
          if [ "${pct_int:-0}" -ge "$COVERAGE_THRESHOLD" ]; then
            echo "  $rel: ${pct}% ≥ ${COVERAGE_THRESHOLD}% ✅"
          else
            echo "  $rel: ${pct}% < ${COVERAGE_THRESHOLD}% ❌"
            PER_FILE_FAILS="$PER_FILE_FAILS\n  - $rel: ${pct}% < ${COVERAGE_THRESHOLD}%"
          fi
        done <<< "$CHANGED_FILES"

        if [ -z "$PER_FILE_FAILS" ]; then
          echo "[dna-verify] Coverage: all $CHANGED_COUNT changed file(s) ≥ ${COVERAGE_THRESHOLD}% ✅"
          COVERAGE_CHECK="PASS"
        else
          echo "[dna-verify] Coverage: one or more changed files below ${COVERAGE_THRESHOLD}% ❌"
          COVERAGE_CHECK="FAIL"
        fi
      else
        # No diff or no json report → project-wide aggregate (legacy behavior).
        COVERAGE_PCT=$(echo "$OUTPUT" | grep -E "^All files" | awk -F'|' '{gsub(/ /,"",$2); print $2}' | head -1)
      fi
    fi
  elif grep -q '"jest"' package.json; then
    COVERAGE_RUNNER="jest"
    set +e
    OUTPUT=$(npx jest --coverage --silent 2>&1)
    RC=$?
    set -e
    COVERAGE_PCT=$(echo "$OUTPUT" | grep -E "All files" | awk -F'|' '{gsub(/ /,"",$2); print $2}' | head -1)
    if [ $RC -ne 0 ]; then
      echo "[dna-verify] FAIL. test suite did not pass (jest exit $RC)"
      exit 1
    fi
  fi
fi

if [ -z "$COVERAGE_PCT" ] && [ -z "$COVERAGE_CHECK" ] && [ -f "pyproject.toml" ]; then
  COVERAGE_RUNNER="pytest"
  set +e
  OUTPUT=$(pytest --cov --cov-report=term 2>&1)
  RC=$?
  set -e
  COVERAGE_PCT=$(echo "$OUTPUT" | grep -E "^TOTAL" | awk '{print $NF}' | tr -d '%')
  if [ $RC -ne 0 ]; then
    echo "[dna-verify] FAIL. test suite did not pass (pytest exit $RC)"
    exit 1
  fi
fi

# If per-file mode didn't set COVERAGE_CHECK, apply the legacy aggregate check.
if [ -z "$COVERAGE_CHECK" ]; then
  if [ -z "$COVERAGE_PCT" ]; then
    echo "[dna-verify] WARN. could not measure coverage (no supported runner or coverage tooling). Skipping coverage check; sub-agent audit should still run."
    COVERAGE_CHECK="SKIPPED"
  else
    COVERAGE_INT=${COVERAGE_PCT%.*}
    if [ "$COVERAGE_INT" -ge "$COVERAGE_THRESHOLD" ]; then
      echo "[dna-verify] Coverage (project-wide): ${COVERAGE_PCT}% ≥ ${COVERAGE_THRESHOLD}% ✅"
      COVERAGE_CHECK="PASS"
    else
      echo "[dna-verify] Coverage (project-wide): ${COVERAGE_PCT}% < ${COVERAGE_THRESHOLD}% ❌"
      COVERAGE_CHECK="FAIL"
    fi
  fi
fi

# ------------------------------------------------------------------
# 4. Every [D] requirement has ≥1 integration test
# ------------------------------------------------------------------
# Heuristic: parse "| ... | [D] | ..." rows in docs/01-SYSTEM-INTENT.md depth summary.
# For each, grep tests/integration/ (or equivalent) for the requirement's keyword.

D_REQUIREMENTS=$(grep -E '^\|[^|]+\|\s*`?\[D\]`?\s*\|' docs/01-SYSTEM-INTENT.md | awk -F'|' '{print $2}' | sed 's/^ *//;s/ *$//' || true)

D_COUNT=0
D_WITH_TEST=0
D_MISSING=()

while IFS= read -r req; do
  [ -z "$req" ] && continue
  D_COUNT=$((D_COUNT+1))
  # Extract significant keywords (nouns, 4+ chars) from the requirement
  KEYWORDS=$(echo "$req" | tr -c '[:alnum:]' ' ' | tr '[:upper:]' '[:lower:]' | tr ' ' '\n' | awk 'length($0) >= 5' | head -3 | tr '\n' '|' | sed 's/|$//')
  if [ -n "$KEYWORDS" ]; then
    if grep -rEl "$KEYWORDS" tests/integration tests/e2e tests/ 2>/dev/null | head -1 >/dev/null; then
      D_WITH_TEST=$((D_WITH_TEST+1))
    else
      D_MISSING+=("$req")
    fi
  fi
done <<< "$D_REQUIREMENTS"

echo
echo "[dna-verify] [D] requirements: $D_WITH_TEST/$D_COUNT have a matching integration test"
if [ ${#D_MISSING[@]} -gt 0 ]; then
  echo "  Missing integration tests for:"
  for m in "${D_MISSING[@]}"; do echo "    - $m"; done
  D_CHECK="FAIL"
else
  D_CHECK="PASS"
fi

# ------------------------------------------------------------------
# 5. Every Experience Fidelity Scenario has at least one referenced test
# ------------------------------------------------------------------
# Parse scenario names from 01-SYSTEM-INTENT.md (headings containing "Scenario N. ..."),
# grep tests/ for any file that mentions the scenario name.

SCENARIO_NAMES=$(grep -E '^### Scenario [0-9]+ -' docs/01-SYSTEM-INTENT.md | sed -E 's/^### Scenario [0-9]+. //;s/,.*//' || true)

S_COUNT=0
S_WITH_TEST=0
S_MISSING=()

while IFS= read -r scenario; do
  [ -z "$scenario" ] && continue
  S_COUNT=$((S_COUNT+1))
  # Normalize scenario name for searching (first 2-3 significant words)
  SEARCH=$(echo "$scenario" | head -c 40 | tr '[:upper:]' '[:lower:]' | tr -c '[:alnum:]' '.')
  if grep -rEl -i "$SEARCH" tests/ 2>/dev/null | head -1 >/dev/null; then
    S_WITH_TEST=$((S_WITH_TEST+1))
  else
    S_MISSING+=("$scenario")
  fi
done <<< "$SCENARIO_NAMES"

echo
echo "[dna-verify] Scenarios: $S_WITH_TEST/$S_COUNT have at least one referencing test"
if [ ${#S_MISSING[@]} -gt 0 ]; then
  echo "  Scenarios without referencing test:"
  for m in "${S_MISSING[@]}"; do echo "    - $m"; done
  S_CHECK="FAIL"
else
  S_CHECK="PASS"
fi

# ------------------------------------------------------------------
# 6. Overall verdict
# ------------------------------------------------------------------
echo
echo "[dna-verify] Mechanical check summary:"
echo "  Coverage:             $COVERAGE_CHECK"
echo "  [D] integration tests: $D_CHECK"
echo "  Scenario tests:        $S_CHECK"

if [ "$COVERAGE_CHECK" = "FAIL" ] || [ "$D_CHECK" = "FAIL" ] || [ "$S_CHECK" = "FAIL" ]; then
  echo
  echo "[dna-verify] FAIL. mechanical floor not met. Fix the above before invoking dna:verifier subagent."
  echo "  (The subagent's scenario-walk cannot credibly audit fidelity on a broken test floor.)"
  exit 1
fi

echo
echo "[dna-verify] PASS. mechanical floor met. Now invoke dna:verifier subagent for the judgmental scenario walk."
echo "  The subagent reads spec + code in FRESH context and produces the CONGRUENT/DIVERGENT verdict."
exit 0
