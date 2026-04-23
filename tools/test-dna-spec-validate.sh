#!/usr/bin/env bash
#
# test-dna-spec-validate.sh — regression suite for the dna-spec-validate gate.
#
# For each fixture under tools/dna-spec-validate-fixtures/{pass,fail}/<name>/,
# constructs a temp target (dogfood Blueprint + the fixture's spec.md), runs
# template/skills/dna-spec-validate/run.sh against it, and compares the output
# to the fixture's expect.txt.
#
# expect.txt grammar:
#   PASS                          — script must exit 0 and emit no WARN/BLOCK
#   WARN:<check-name>             — output must contain "<check-name>:" in a WARN line
#   BLOCK:<check-name>            — output must contain "<check-name>:" in a BLOCK line
#
# Pre-condition: $TARGET points at a valid 7-doc Blueprint target (default:
# B:/A5DS-HQ/REPOS/team-project-scheduler). Override via env var.
#
# This file lives in tools/ and is NOT shipped to refresh-target.sh-managed
# directories (see tools/refresh-target.sh — only template/* sync).

set -u

KIT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TARGET="${TARGET:-/b/A5DS-HQ/REPOS/team-project-scheduler}"
SCRIPT="$KIT_ROOT/template/skills/dna-spec-validate/run.sh"
FIXTURES_DIR="$KIT_ROOT/tools/dna-spec-validate-fixtures"

if [ ! -d "$TARGET" ]; then
  echo "[test-dna-spec-validate] SETUP — TARGET not found: $TARGET" >&2
  echo "                          Set TARGET=<path-to-target-with-7-doc-Blueprint> and re-run." >&2
  exit 2
fi
if [ ! -x "$SCRIPT" ] && [ ! -f "$SCRIPT" ]; then
  echo "[test-dna-spec-validate] SETUP — script not found: $SCRIPT" >&2
  exit 2
fi
if [ ! -d "$FIXTURES_DIR" ]; then
  echo "[test-dna-spec-validate] SETUP — fixtures dir not found: $FIXTURES_DIR" >&2
  exit 2
fi

setup_temp_target() {
  local fixture_spec="$1"
  local tmp
  tmp=$(mktemp -d)
  mkdir -p "$tmp/docs" "$tmp/specs/test"
  cp "$TARGET/docs/00-CORE-PRINCIPLES.md" "$tmp/docs/"
  cp "$TARGET/docs/01-SYSTEM-INTENT.md"   "$tmp/docs/"
  cp "$TARGET/docs/02-ARCHITECTURE.md"    "$tmp/docs/"
  cp "$TARGET/docs/04-COORDINATION-HINTS.md" "$tmp/docs/"
  cp "$TARGET/CONSTITUTION.md"            "$tmp/"
  cp "$fixture_spec"                      "$tmp/specs/test/spec.md"
  echo "$tmp"
}

run_fixture() {
  local fixture_dir="$1"
  local fixture_name
  fixture_name="$(basename "$fixture_dir")"
  local fixture_spec="$fixture_dir/spec.md"
  local expect_file="$fixture_dir/expect.txt"

  if [ ! -f "$fixture_spec" ]; then
    echo "[FAIL] $fixture_name — missing spec.md"
    return 1
  fi
  if [ ! -f "$expect_file" ]; then
    echo "[FAIL] $fixture_name — missing expect.txt"
    return 1
  fi

  local expect
  expect="$(head -1 "$expect_file" | tr -d '[:space:]')"

  local tmp
  tmp=$(setup_temp_target "$fixture_spec")
  local out rc
  set +e
  out=$(cd "$tmp" && bash "$SCRIPT" --mode advisory specs/test 2>&1)
  rc=$?
  set -e
  rm -rf "$tmp"

  case "$expect" in
    PASS)
      if [ "$rc" -ne 0 ]; then
        echo "[FAIL] $fixture_name — expected exit 0, got $rc"
        echo "$out" | sed 's/^/        /'
        return 1
      fi
      if echo "$out" | grep -qE '^\[dna-spec-validate\]   (WARN|BLOCK) '; then
        echo "[FAIL] $fixture_name — expected no findings, got:"
        echo "$out" | grep -E '^\[dna-spec-validate\]   (WARN|BLOCK) ' | sed 's/^/        /'
        return 1
      fi
      echo "[ OK ] $fixture_name → PASS"
      return 0
      ;;
    WARN:*|BLOCK:*)
      local sev="${expect%%:*}"
      local check="${expect#*:}"
      if ! echo "$out" | grep -q "${check}:"; then
        echo "[FAIL] $fixture_name — expected $sev for '$check', validator output:"
        echo "$out" | grep -E '^\[dna-spec-validate\]   (WARN|BLOCK|PASS) ' | sed 's/^/        /'
        return 1
      fi
      echo "[ OK ] $fixture_name → $sev:$check"
      return 0
      ;;
    *)
      echo "[FAIL] $fixture_name — unrecognized expect.txt content: '$expect'"
      return 1
      ;;
  esac
}

failures=0
total=0

for class in pass fail; do
  if [ -d "$FIXTURES_DIR/$class" ]; then
    for f in "$FIXTURES_DIR/$class"/*/; do
      [ -d "$f" ] || continue
      total=$((total + 1))
      run_fixture "${f%/}" || failures=$((failures + 1))
    done
  fi
done

echo
echo "[test-dna-spec-validate] $((total - failures))/$total fixture(s) green"

if [ "$failures" -gt 0 ]; then
  exit 1
fi
exit 0
