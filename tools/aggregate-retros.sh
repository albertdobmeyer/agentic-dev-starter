#!/usr/bin/env bash
#
# aggregate-retros.sh — kit-level aggregator that collects every feature's
# retrospective across one or more target projects and produces a corpus
# file that makes the methodology's validation data visible.
#
# Turns "n=1 (the bookmark organizer)" into measured multi-feature data
# across every project using this kit.
#
# Usage:
#   tools/aggregate-retros.sh <target-project-path> [<target-project-path> ...]
#
# Output:
#   .exploration/retrospectives-corpus.md (in the kit repo)
#
# Exit codes:
#   0  Aggregation done (corpus file written).
#   1  No retrospectives found across provided targets.
#   2  Setup problem (no target paths, etc.)

set -u
KIT_ROOT="$(dirname "$(dirname "$(readlink -f "$0")")")"

if [ $# -eq 0 ]; then
  echo "Usage: $0 <target-project-path> [<target-project-path> ...]" >&2
  exit 2
fi

OUT="$KIT_ROOT/.exploration/retrospectives-corpus.md"
mkdir -p "$(dirname "$OUT")"

{
  echo "# Retrospectives Corpus"
  echo
  echo "_Aggregated by \`tools/aggregate-retros.sh\` on $(date +%Y-%m-%d). Each section is a raw retrospective from a feature that shipped through the methodology. Drop this file on the desk when someone asks 'is this methodology actually validated?'_"
  echo
  echo "---"
  echo
} > "$OUT"

FOUND=0

for target in "$@"; do
  # Accept either a full path or a basename that matches a sibling dir of the kit
  # (Protocol A default places targets at ../<name>/ relative to the kit).
  if [ ! -d "$target" ]; then
    if [ -d "$KIT_ROOT/../$target" ]; then
      target="$KIT_ROOT/../$target"
    elif [ -d "$KIT_ROOT/REPOS/$target" ]; then
      target="$KIT_ROOT/REPOS/$target"
    else
      echo "[aggregate-retros] SKIP — $target is not a directory (tried ../$target and REPOS/$target)" >&2
      continue
    fi
  fi

  # Find all retrospective files in this target's specs/ dir
  RETROS=$(find "$target/specs" -maxdepth 3 -name "retrospective.md" 2>/dev/null | sort)

  if [ -z "$RETROS" ]; then
    echo "[aggregate-retros] $target — no retrospective.md files found"
    continue
  fi

  PROJECT_NAME=$(basename "$target")
  {
    echo "## Project: $PROJECT_NAME"
    echo "_Path: \`$target\`_"
    echo
  } >> "$OUT"

  while IFS= read -r retro; do
    FEATURE_DIR=$(dirname "$retro")
    FEATURE_NAME=$(basename "$FEATURE_DIR")
    FOUND=$((FOUND+1))

    {
      echo "### Feature: $FEATURE_NAME"
      echo "_Source: \`$retro\`_"
      echo
      cat "$retro"
      echo
      echo "---"
      echo
    } >> "$OUT"
  done <<< "$RETROS"
done

if [ "$FOUND" -eq 0 ]; then
  echo "[aggregate-retros] No retrospectives found across any target." >&2
  echo "  Expected: <target>/specs/NNN-*/retrospective.md files (copied from template/blueprint/RETROSPECTIVE.skeleton.md during feature close-out)." >&2
  exit 1
fi

# ------------------------------------------------------------------
# Produce summary at top of corpus (after first paragraph)
# ------------------------------------------------------------------
SUMMARY_FILE=$(mktemp)
{
  echo
  echo "## Summary"
  echo "**Features aggregated**: $FOUND"
  echo
  echo "### Cross-feature aggregates"
  echo
  echo "(Best-effort grep over the corpus; numbers are indicative, not authoritative.)"
  echo

  # Construction Sites opened/closed
  OPENED=$(grep -c '| CS-' "$OUT" 2>/dev/null || echo 0)
  echo "- Construction Sites logged: $OPENED"

  # dna:verifier CONGRUENT vs DIVERGENT
  CONGRUENT=$(grep -c 'CONGRUENT' "$OUT" 2>/dev/null || echo 0)
  DIVERGENT=$(grep -c 'DIVERGENT' "$OUT" 2>/dev/null || echo 0)
  echo "- dna:verifier outcomes: CONGRUENT=$CONGRUENT, DIVERGENT=$DIVERGENT"

  # Pushback events
  REFUSED=$(grep -ci 'agent refused' "$OUT" 2>/dev/null || echo 0)
  ACCEPTED=$(grep -ci 'agent accepted' "$OUT" 2>/dev/null || echo 0)
  echo "- Pushback events: refused=$REFUSED, accepted=$ACCEPTED"

  echo
  echo "### Per-feature rollup"
  echo
  echo "| Project | Feature | Elapsed | Tokens | CS open at merge |"
  echo "|---|---|---|---|---|"

  for target in "$@"; do
    [ ! -d "$target" ] && continue
    PROJECT_NAME=$(basename "$target")
    RETROS=$(find "$target/specs" -maxdepth 3 -name "retrospective.md" 2>/dev/null | sort)
    while IFS= read -r retro; do
      [ -z "$retro" ] && continue
      FEATURE_NAME=$(basename "$(dirname "$retro")")
      ELAPSED=$(grep -E '^\| Total elapsed' "$retro" | head -1 | awk -F'|' '{print $3}' | sed 's/^ *//;s/ *$//' || echo "?")
      TOKENS=$(grep -E '^\| Tokens consumed' "$retro" | head -1 | awk -F'|' '{print $3}' | sed 's/^ *//;s/ *$//' || echo "?")
      CS_OPEN=$(grep -cE '^\| CS-.*OPEN' "$retro" 2>/dev/null || echo 0)
      echo "| $PROJECT_NAME | $FEATURE_NAME | $ELAPSED | $TOKENS | $CS_OPEN |"
    done <<< "$RETROS"
  done

  echo
  echo "---"
  echo
} > "$SUMMARY_FILE"

# Insert summary after the header (after line 3)
head -5 "$OUT" > "${OUT}.tmp"
cat "$SUMMARY_FILE" >> "${OUT}.tmp"
tail -n +6 "$OUT" >> "${OUT}.tmp"
mv "${OUT}.tmp" "$OUT"
rm -f "$SUMMARY_FILE"

echo "[aggregate-retros] Wrote $FOUND retrospective(s) to $OUT"
echo "[aggregate-retros] Next: \`cat $OUT | less\` or publish to docs/FIELD_NOTES.md for external readers."
exit 0
