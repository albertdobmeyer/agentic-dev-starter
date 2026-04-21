#!/usr/bin/env bash
#
# dna-test-gate — executable enforcement of CONSTITUTION.md Article 1
# (write tests BEFORE implementation, and they must fail before you write code).
#
# Exit codes:
#   0  Gate PASSED — every implementation task has a test file that exists and fails.
#   1  Gate FAILED — tests missing, or tests already pass before implementation.
#   2  Setup problem — can't locate tasks.md, can't detect test runner, etc.
#
# Usage:
#   run.sh                        # auto-detect current feature from tasks.md in repo
#   run.sh specs/001-foo          # explicit feature directory
#   run.sh specs/001-foo "T012"   # gate-check a specific task ID

set -u  # treat unset vars as errors

# ------------------------------------------------------------------
# 1. Locate the feature directory and tasks.md
# ------------------------------------------------------------------

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$REPO_ROOT"

FEATURE_DIR="${1:-}"
TASK_FILTER="${2:-}"

if [ -z "$FEATURE_DIR" ]; then
  # Try to infer from current branch name (Spec-Kit convention: NNN-slug)
  BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
  if [ -n "$BRANCH" ] && [ -d "specs/$BRANCH" ]; then
    FEATURE_DIR="specs/$BRANCH"
  else
    # Fall back to most-recently-modified spec dir
    FEATURE_DIR=$(ls -td specs/[0-9][0-9][0-9]-*/ 2>/dev/null | head -1 | sed 's:/$::')
  fi
fi

if [ -z "$FEATURE_DIR" ] || [ ! -d "$FEATURE_DIR" ]; then
  echo "[dna-test-gate] SETUP — cannot locate feature directory. Pass as arg: run.sh specs/NNN-name" >&2
  exit 2
fi

TASKS_FILE="$FEATURE_DIR/tasks.md"
if [ ! -f "$TASKS_FILE" ]; then
  echo "[dna-test-gate] SETUP — $TASKS_FILE not found. Run /speckit-tasks first." >&2
  exit 2
fi

echo "[dna-test-gate] Checking $FEATURE_DIR"
echo

# ------------------------------------------------------------------
# 2. Detect test runner
# ------------------------------------------------------------------

RUNNER=""
RUNNER_CMD=""

if [ -f "package.json" ]; then
  if grep -q '"vitest"' package.json; then
    RUNNER="vitest"; RUNNER_CMD="npx vitest run --reporter=verbose --no-coverage"
  elif grep -q '"jest"' package.json; then
    RUNNER="jest"; RUNNER_CMD="npx jest --silent"
  elif grep -q '"mocha"' package.json; then
    RUNNER="mocha"; RUNNER_CMD="npx mocha"
  fi
fi

if [ -z "$RUNNER" ] && [ -f "pyproject.toml" ] && grep -q '\[tool\.pytest' pyproject.toml; then
  RUNNER="pytest"; RUNNER_CMD="pytest -q"
fi

if [ -z "$RUNNER" ] && [ -f "go.mod" ]; then
  RUNNER="go"; RUNNER_CMD="go test"
fi

if [ -z "$RUNNER" ]; then
  echo "[dna-test-gate] SETUP — no test runner detected in package.json / pyproject.toml / go.mod" >&2
  echo "  Supported: vitest, jest, mocha, pytest, go test." >&2
  echo "  Configure one per docs/03-EXECUTION-CONTEXT.md Testing section." >&2
  exit 2
fi

echo "[dna-test-gate] Runner: $RUNNER ($RUNNER_CMD)"
echo

# ------------------------------------------------------------------
# 3. Parse tasks.md for unchecked implementation tasks
# ------------------------------------------------------------------
# A task line looks like:  - [ ] T012 [P] Implement src/models/user.ts
# or:                       - [ ] T012 Add /api/users route
# We extract: task ID, optional [P] parallel marker, the body.
# Exclude tasks whose body starts with "Test" or "test" (those are test-writing tasks
# that produce the test files; they aren't themselves gate-able).

MAPFILE_TASKS=$(grep -En '^- \[ \] T[0-9]+' "$TASKS_FILE" | \
  grep -Evi '^\s*-.*\b(test|tests|spec)\s*:' | \
  grep -v '^\s*- \[ \] T[0-9]+ \[P\]\? Test ' || true)

if [ -z "$MAPFILE_TASKS" ]; then
  echo "[dna-test-gate] No unchecked implementation tasks in $TASKS_FILE."
  echo "  Either all implementation is complete, or tasks.md uses unexpected format."
  exit 0
fi

# ------------------------------------------------------------------
# 4. For each task, infer the test file path and check it
# ------------------------------------------------------------------

MISSING=0
WRONG_GREEN=0
RED_COUNT=0
TOTAL=0

echo "[dna-test-gate] Results:"
echo

while IFS= read -r line; do
  TASK_ID=$(echo "$line" | grep -oE 'T[0-9]+' | head -1)

  if [ -n "$TASK_FILTER" ] && [ "$TASK_ID" != "$TASK_FILTER" ]; then
    continue
  fi

  TOTAL=$((TOTAL+1))

  # Extract file path hints from the task body: anything matching src/…, lib/…, app/…
  IMPL_PATH=$(echo "$line" | grep -oE '(src|lib|app|packages/[^/]+/src)/[A-Za-z0-9_/.-]+\.(ts|tsx|js|jsx|py|go)' | head -1 || true)

  if [ -z "$IMPL_PATH" ]; then
    echo "  $TASK_ID  UNINSPECTABLE (no impl path in task body) — add explicit file reference"
    MISSING=$((MISSING+1))
    continue
  fi

  # Infer test file path
  CANDIDATES=()
  case "$IMPL_PATH" in
    *.ts|*.tsx|*.js|*.jsx)
      BASE="${IMPL_PATH%.*}"
      EXT="${IMPL_PATH##*.}"
      CANDIDATES+=("${BASE}.test.${EXT}")
      CANDIDATES+=("${BASE}.spec.${EXT}")
      # tests/ mirror
      SUB="${IMPL_PATH#src/}"; SUB="${SUB#lib/}"; SUB="${SUB#app/}"
      BASE_SUB="${SUB%.*}"
      CANDIDATES+=("tests/${BASE_SUB}.test.${EXT}")
      CANDIDATES+=("tests/unit/${BASE_SUB}.test.${EXT}")
      ;;
    *.py)
      SUB="${IMPL_PATH#src/}"
      BASE_SUB="${SUB%.py}"
      CANDIDATES+=("tests/test_${BASE_SUB##*/}.py")
      CANDIDATES+=("tests/$(dirname "$BASE_SUB")/test_${BASE_SUB##*/}.py")
      ;;
    *.go)
      BASE="${IMPL_PATH%.go}"
      CANDIDATES+=("${BASE}_test.go")
      ;;
  esac

  TEST_FILE=""
  for c in "${CANDIDATES[@]}"; do
    if [ -f "$c" ]; then TEST_FILE="$c"; break; fi
  done

  if [ -z "$TEST_FILE" ]; then
    echo "  $TASK_ID  MISSING     $IMPL_PATH  → expected one of: ${CANDIDATES[*]}"
    MISSING=$((MISSING+1))
    continue
  fi

  # Run the test file, check it FAILS (non-zero exit)
  set +e
  TEST_OUTPUT=$($RUNNER_CMD "$TEST_FILE" 2>&1)
  TEST_EXIT=$?
  set -e

  if [ $TEST_EXIT -ne 0 ]; then
    echo "  $TASK_ID  RED (ok)    $TEST_FILE  → test fails before impl (as required)"
    RED_COUNT=$((RED_COUNT+1))
  else
    echo "  $TASK_ID  GREEN (bad) $TEST_FILE  → test passes WITHOUT impl — test is trivial, wrong, or impl already exists"
    WRONG_GREEN=$((WRONG_GREEN+1))
  fi
done <<< "$MAPFILE_TASKS"

# ------------------------------------------------------------------
# 5. Verdict
# ------------------------------------------------------------------

echo
echo "[dna-test-gate] Summary: total=$TOTAL  red(ok)=$RED_COUNT  green(bad)=$WRONG_GREEN  missing=$MISSING"

if [ $MISSING -eq 0 ] && [ $WRONG_GREEN -eq 0 ] && [ $RED_COUNT -gt 0 ]; then
  echo "[dna-test-gate] PASS — all implementation tasks have red tests. Proceed to /speckit-implement."
  exit 0
else
  echo "[dna-test-gate] FAIL — Article 1 violation. Write tests first; verify they fail; then implement."
  if [ $MISSING -gt 0 ]; then
    echo "  $MISSING task(s) have no test file. Write the tests before /speckit-implement."
  fi
  if [ $WRONG_GREEN -gt 0 ]; then
    echo "  $WRONG_GREEN task(s) have tests that pass before implementation. Either the test is trivial, the test targets something the impl already provides, or the impl already exists. Review each."
  fi
  exit 1
fi
