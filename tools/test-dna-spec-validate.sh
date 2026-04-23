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
  local tmp
  tmp=$(mktemp -d)
  mkdir -p "$tmp/docs"
  cp "$TARGET/docs/00-CORE-PRINCIPLES.md" "$tmp/docs/"
  cp "$TARGET/docs/01-SYSTEM-INTENT.md"   "$tmp/docs/"
  cp "$TARGET/docs/02-ARCHITECTURE.md"    "$tmp/docs/"
  cp "$TARGET/docs/04-COORDINATION-HINTS.md" "$tmp/docs/"
  cp "$TARGET/CONSTITUTION.md"            "$tmp/"
  # Inject a structured `## Module paths` block at the end of 02 so fixtures
  # don't trip the legacy-fallback WARN. The dogfood Blueprint is pre-Stage-0
  # and doesn't have this block; tests need the modern shape to avoid noise.
  cat >> "$tmp/docs/02-ARCHITECTURE.md" <<'EOF'

## Module paths

```yaml
modules:
  - name: api
    path: src/api/**
    purpose: HTTP route handlers
    owner-scenarios: []
  - name: models
    path: src/models/**
    purpose: entity types
    owner-scenarios: []
  - name: calendar
    path: src/calendar/**
    purpose: calendar composition
    owner-scenarios: [1]
  - name: notifications
    path: src/notifications/**
    purpose: outbound side-effects
    owner-scenarios: [2]
  - name: ui
    path: src/ui/**
    purpose: React components
    owner-scenarios: [3]
  - name: auth
    path: src/auth/**
    purpose: session verification
    owner-scenarios: []
  - name: db
    path: src/db/**
    purpose: pg connection
    owner-scenarios: []
```
EOF
  echo "$tmp"
}

run_fixture() {
  local fixture_dir="$1"
  local fixture_name
  fixture_name="$(basename "$fixture_dir")"
  local fixture_spec="$fixture_dir/spec.md"
  local fixture_setup="$fixture_dir/setup.sh"
  local expect_file="$fixture_dir/expect.txt"

  if [ ! -f "$expect_file" ]; then
    echo "[FAIL] $fixture_name — missing expect.txt"
    return 1
  fi
  if [ ! -f "$fixture_spec" ] && [ ! -f "$fixture_setup" ]; then
    echo "[FAIL] $fixture_name — missing both spec.md and setup.sh"
    return 1
  fi

  local expect
  expect="$(head -1 "$expect_file" | tr -d '[:space:]')"

  local tmp feature_dir
  tmp=$(setup_temp_target)

  if [ -f "$fixture_setup" ]; then
    # Custom setup: setup.sh runs inside tmp dir, echoes the feature dir on stdout.
    feature_dir=$(cd "$tmp" && bash "$fixture_setup" 2>/dev/null)
    if [ -z "$feature_dir" ]; then
      echo "[FAIL] $fixture_name — setup.sh emitted no feature dir on stdout"
      rm -rf "$tmp"
      return 1
    fi
  else
    # Default: drop spec.md into specs/test/.
    mkdir -p "$tmp/specs/test"
    cp "$fixture_spec" "$tmp/specs/test/spec.md"
    feature_dir="specs/test"
  fi

  local out rc
  set +e
  out=$(cd "$tmp" && bash "$SCRIPT" --mode advisory "$feature_dir" 2>&1)
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
