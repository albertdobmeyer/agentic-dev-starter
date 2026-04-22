#!/usr/bin/env bash
#
# dna-verify — mechanical verification layer.
# Pairs with the dna:verifier subagent (which does the judgmental scenario-walk).
# This script checks the things you CAN check mechanically:
#   - test coverage threshold from CONSTITUTION Article 10
#   - every [D] requirement in docs/01-SYSTEM-INTENT.md has ≥1 integration test
#   - every Experience Fidelity Scenario has at least one test file referencing it
#
# Exit codes:
#   0  PASS — mechanical checks all green. Main agent may proceed to dna:verifier subagent for scenario walk.
#   1  FAIL — mechanical floor not met; subagent audit is premature.
#   2  Setup problem (no Blueprint, no tests dir, etc.)

set -u
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$REPO_ROOT"

# ------------------------------------------------------------------
# 1. Structural prerequisites
# ------------------------------------------------------------------
for f in docs/01-SYSTEM-INTENT.md CONSTITUTION.md; do
  if [ ! -f "$f" ]; then
    echo "[dna-verify] SETUP — required file $f not found. Run dna:spec-auditor first." >&2
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
    echo "[dna-verify] SETUP — no tests/ directory and no co-located *.test.* / *.spec.* files found." >&2
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
  echo "[dna-verify] No coverage threshold found in CONSTITUTION.md — using methodology default: 80%"
else
  echo "[dna-verify] Coverage threshold from CONSTITUTION.md: ${COVERAGE_THRESHOLD}%"
fi

# ------------------------------------------------------------------
# 3. Run test suite with coverage
# ------------------------------------------------------------------
COVERAGE_PCT=""
COVERAGE_RUNNER=""

if [ -f "package.json" ]; then
  if grep -q '"vitest"' package.json; then
    COVERAGE_RUNNER="vitest"
    if command -v npx >/dev/null 2>&1; then
      set +e
      OUTPUT=$(npx vitest run --coverage --reporter=basic 2>&1)
      RC=$?
      set -e
      # Vitest coverage line looks like: "All files | 87.5 | ..."
      COVERAGE_PCT=$(echo "$OUTPUT" | grep -E "^All files" | awk -F'|' '{gsub(/ /,"",$2); print $2}' | head -1)
      if [ $RC -ne 0 ]; then
        echo "[dna-verify] FAIL — test suite did not pass (vitest exit $RC)"
        echo "$OUTPUT" | tail -20
        exit 1
      fi
    fi
  elif grep -q '"jest"' package.json; then
    COVERAGE_RUNNER="jest"
    set +e
    OUTPUT=$(npx jest --coverage --silent 2>&1)
    RC=$?
    set -e
    # Jest coverage: "All files    |  87.5  | ..."
    COVERAGE_PCT=$(echo "$OUTPUT" | grep -E "All files" | awk -F'|' '{gsub(/ /,"",$2); print $2}' | head -1)
    if [ $RC -ne 0 ]; then
      echo "[dna-verify] FAIL — test suite did not pass (jest exit $RC)"
      exit 1
    fi
  fi
fi

if [ -z "$COVERAGE_PCT" ] && [ -f "pyproject.toml" ]; then
  COVERAGE_RUNNER="pytest"
  set +e
  OUTPUT=$(pytest --cov --cov-report=term 2>&1)
  RC=$?
  set -e
  COVERAGE_PCT=$(echo "$OUTPUT" | grep -E "^TOTAL" | awk '{print $NF}' | tr -d '%')
  if [ $RC -ne 0 ]; then
    echo "[dna-verify] FAIL — test suite did not pass (pytest exit $RC)"
    exit 1
  fi
fi

if [ -z "$COVERAGE_PCT" ]; then
  echo "[dna-verify] WARN — could not measure coverage (no supported runner or coverage tooling). Skipping coverage check; sub-agent audit should still run."
  COVERAGE_CHECK="SKIPPED"
else
  # Integer-compare (strip decimal)
  COVERAGE_INT=${COVERAGE_PCT%.*}
  if [ "$COVERAGE_INT" -ge "$COVERAGE_THRESHOLD" ]; then
    echo "[dna-verify] Coverage: ${COVERAGE_PCT}% ≥ ${COVERAGE_THRESHOLD}% ✅"
    COVERAGE_CHECK="PASS"
  else
    echo "[dna-verify] Coverage: ${COVERAGE_PCT}% < ${COVERAGE_THRESHOLD}% ❌"
    COVERAGE_CHECK="FAIL"
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
# Parse scenario names from 01-SYSTEM-INTENT.md (headings containing "Scenario N — ..."),
# grep tests/ for any file that mentions the scenario name.

SCENARIO_NAMES=$(grep -E '^### Scenario [0-9]+ —' docs/01-SYSTEM-INTENT.md | sed -E 's/^### Scenario [0-9]+ — //;s/,.*//' || true)

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
  echo "[dna-verify] FAIL — mechanical floor not met. Fix the above before invoking dna:verifier subagent."
  echo "  (The subagent's scenario-walk cannot credibly audit fidelity on a broken test floor.)"
  exit 1
fi

echo
echo "[dna-verify] PASS — mechanical floor met. Now invoke dna:verifier subagent for the judgmental scenario walk."
echo "  The subagent reads spec + code in FRESH context and produces the CONGRUENT/DIVERGENT verdict."
exit 0
