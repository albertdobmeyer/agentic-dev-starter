#!/usr/bin/env bash
#
# dna-decompose. overlap validator for parallel task chunks.
# The creative work (how to split tasks) is agentic; this script validates
# the result. no two [P] (parallel) tasks may touch the same file.
#
# Exit codes:
#   0  Decomposition is safe. all [P] chunks have zero file overlap.
#   1  Decomposition is unsafe. named tasks overlap; fix before delegating.
#   2  Setup problem (no tasks.md, unexpected format).
#
# Usage:
#   run.sh                       # validates current feature's tasks.md
#   run.sh specs/NNN-feature     # explicit feature dir

set -u
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$REPO_ROOT"

FEATURE_DIR="${1:-}"
if [ -z "$FEATURE_DIR" ]; then
  BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
  [ -n "$BRANCH" ] && [ -d "specs/$BRANCH" ] && FEATURE_DIR="specs/$BRANCH"
fi
if [ -z "$FEATURE_DIR" ] || [ ! -f "$FEATURE_DIR/tasks.md" ]; then
  echo "[dna-decompose] SETUP. could not locate tasks.md. Pass: run.sh specs/NNN-name" >&2
  exit 2
fi

TASKS_FILE="$FEATURE_DIR/tasks.md"
echo "[dna-decompose] Validating $TASKS_FILE"

# ------------------------------------------------------------------
# Parse [P] tasks and their file references.
# A parallel task line looks like:
#   - [ ] T012 [P] Add src/models/user.ts with email validation
# We extract task ID + every src/... or tests/... path mentioned.
# ------------------------------------------------------------------

declare -A TASK_FILES   # task_id → space-separated file list

# SPEC-20 / RE-16: tasks may use backtick-wrapped `[P]` (Markdown-safe inline
# code) instead of bare [P]. Accept both. Escaped backticks are optional -
# the pattern `\`?\[P\]\`?` matches `[P]`, `\`[P]\``, and even weird half-wrapped forms.
PARALLEL_TASKS=$(grep -E '^- \[[ x]\] T[0-9]+ `?\[P\]`?' "$TASKS_FILE" || true)

if [ -z "$PARALLEL_TASKS" ]; then
  echo "[dna-decompose] No [P] tasks in $TASKS_FILE. Decomposition is trivially safe (serial)."
  exit 0
fi

while IFS= read -r line; do
  TASK_ID=$(echo "$line" | grep -oE 'T[0-9]+' | head -1)
  FILES=$(echo "$line" | grep -oE '(src|lib|app|tests|packages/[^/]+/(src|tests))/[A-Za-z0-9_/.-]+\.(ts|tsx|js|jsx|py|go|sql)' | sort -u | tr '\n' ' ')
  TASK_FILES[$TASK_ID]="$FILES"
done <<< "$PARALLEL_TASKS"

# ------------------------------------------------------------------
# Find overlaps between every pair of [P] tasks.
# ------------------------------------------------------------------

OVERLAPS=0
declare -A SEEN  # "pair-key" → overlapping files

for t1 in "${!TASK_FILES[@]}"; do
  for t2 in "${!TASK_FILES[@]}"; do
    [ "$t1" = "$t2" ] && continue
    # Lexicographic ordering avoids counting each pair twice
    if [ "$t1" \< "$t2" ]; then
      # Find intersection
      INTERSECTION=""
      for f in ${TASK_FILES[$t1]}; do
        if [[ " ${TASK_FILES[$t2]} " == *" $f "* ]]; then
          INTERSECTION="$INTERSECTION $f"
        fi
      done
      if [ -n "$INTERSECTION" ]; then
        OVERLAPS=$((OVERLAPS+1))
        echo "  OVERLAP: $t1 ⟷ $t2 share:${INTERSECTION}"
      fi
    fi
  done
done

# ------------------------------------------------------------------
# Uninspectable tasks (no file references at all)
# ------------------------------------------------------------------

UNINSPECTABLE=0
for t in "${!TASK_FILES[@]}"; do
  if [ -z "${TASK_FILES[$t]// }" ]; then
    echo "  UNINSPECTABLE: $t has no file references in its description. cannot verify parallelism is safe"
    UNINSPECTABLE=$((UNINSPECTABLE+1))
  fi
done

# ------------------------------------------------------------------
# Verdict
# ------------------------------------------------------------------
echo
echo "[dna-decompose] [P] tasks checked: ${#TASK_FILES[@]}"
echo "[dna-decompose] Overlaps found:     $OVERLAPS"
echo "[dna-decompose] Uninspectable:      $UNINSPECTABLE"

if [ $OVERLAPS -gt 0 ] || [ $UNINSPECTABLE -gt 0 ]; then
  echo
  echo "[dna-decompose] FAIL. decomposition is not merge-safe."
  if [ $OVERLAPS -gt 0 ]; then
    echo "  Remove [P] from one of each overlapping pair, or split the shared file's"
    echo "  changes into a serial prerequisite task."
  fi
  if [ $UNINSPECTABLE -gt 0 ]; then
    echo "  Add explicit file references to uninspectable task descriptions so this"
    echo "  validator can check them."
  fi
  exit 1
fi

echo
echo "[dna-decompose] PASS. all [P] tasks have disjoint file sets. Safe to /dna-delegate."
exit 0
