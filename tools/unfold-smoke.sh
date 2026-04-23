#!/usr/bin/env bash
#
# unfold-smoke.sh — SPEC-02b smoke harness for Spec-Kit version bumps.
#
# Runs the canonical specify init invocation for both adapters into temporary
# directories, asserts the expected structure, and exits 0/nonzero.
#
# Run before every Spec-Kit version bump (see docs/SPEC_KIT_PINNING.md).
#
# Exit codes:
#   0  both adapters unfold successfully against the pinned Spec-Kit version
#   1  one or both adapters fail to unfold (flag renamed, integration removed, etc.)
#   2  setup problem (specify CLI missing, temp dir creation failed)

set -u

# Colors for readable output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASS() { echo -e "${GREEN}PASS${NC}  $1"; }
FAIL() { echo -e "${RED}FAIL${NC}  $1"; }
WARN() { echo -e "${YELLOW}WARN${NC}  $1"; }

# ------------------------------------------------------------------
# 1. Verify specify CLI is installed
# ------------------------------------------------------------------

if ! command -v specify >/dev/null 2>&1; then
  FAIL "specify CLI not found on PATH. Install: uv tool install specify-cli --from git+https://github.com/github/spec-kit.git@v0.8.0"
  exit 2
fi

echo "[unfold-smoke] specify CLI: $(command -v specify)"
echo

# ------------------------------------------------------------------
# 2. Prepare temp dirs
# ------------------------------------------------------------------

TMP_ROOT=$(mktemp -d -t unfold-smoke-XXXXXX 2>/dev/null || mktemp -d "${TMPDIR:-/tmp}/unfold-smoke-$$")
if [ ! -d "$TMP_ROOT" ]; then
  FAIL "could not create temp directory"
  exit 2
fi

CLAUDE_DIR="$TMP_ROOT/claude"
CURSOR_DIR="$TMP_ROOT/cursor"
mkdir -p "$CLAUDE_DIR" "$CURSOR_DIR"

cleanup() {
  if [ -n "${TMP_ROOT:-}" ] && [ -d "$TMP_ROOT" ]; then
    rm -rf "$TMP_ROOT"
    echo
    echo "[unfold-smoke] cleaned $TMP_ROOT"
  fi
}
trap cleanup EXIT

# ------------------------------------------------------------------
# 3. Claude Code adapter unfold
# ------------------------------------------------------------------

echo "[unfold-smoke] Testing --integration claude in $CLAUDE_DIR"

CLAUDE_ERRORS=0

(cd "$CLAUDE_DIR" && PYTHONIOENCODING=utf-8 specify init . --integration claude --script sh --force --offline --no-git >/dev/null 2>&1) || {
  FAIL "specify init --integration claude exited non-zero"
  CLAUDE_ERRORS=$((CLAUDE_ERRORS+1))
}

if [ -d "$CLAUDE_DIR/.specify" ]; then PASS ".specify/ created"; else FAIL ".specify/ missing"; CLAUDE_ERRORS=$((CLAUDE_ERRORS+1)); fi
if [ -d "$CLAUDE_DIR/.claude" ]; then PASS ".claude/ created"; else FAIL ".claude/ missing"; CLAUDE_ERRORS=$((CLAUDE_ERRORS+1)); fi

if [ -d "$CLAUDE_DIR/.specify/scripts" ]; then
  SCRIPT_COUNT=$(find "$CLAUDE_DIR/.specify/scripts" -name '*.sh' -o -name '*.ps1' 2>/dev/null | wc -l)
  if [ "$SCRIPT_COUNT" -gt 0 ]; then
    PASS ".specify/scripts/ populated ($SCRIPT_COUNT script(s))"
  else
    FAIL ".specify/scripts/ is empty — --script flag did not resolve"
    CLAUDE_ERRORS=$((CLAUDE_ERRORS+1))
  fi
else
  FAIL ".specify/scripts/ missing"
  CLAUDE_ERRORS=$((CLAUDE_ERRORS+1))
fi

echo

# ------------------------------------------------------------------
# 4. Cursor adapter unfold
# ------------------------------------------------------------------

echo "[unfold-smoke] Testing --integration cursor-agent in $CURSOR_DIR"

CURSOR_ERRORS=0

(cd "$CURSOR_DIR" && PYTHONIOENCODING=utf-8 specify init . --integration cursor-agent --script sh --force --offline --no-git >/dev/null 2>&1) || {
  FAIL "specify init --integration cursor-agent exited non-zero"
  CURSOR_ERRORS=$((CURSOR_ERRORS+1))
}

if [ -d "$CURSOR_DIR/.specify" ]; then PASS ".specify/ created"; else FAIL ".specify/ missing"; CURSOR_ERRORS=$((CURSOR_ERRORS+1)); fi
if [ -d "$CURSOR_DIR/.cursor" ]; then PASS ".cursor/ created"; else FAIL ".cursor/ missing"; CURSOR_ERRORS=$((CURSOR_ERRORS+1)); fi

echo

# ------------------------------------------------------------------
# 5. Guardrail: ensure `--integration cursor` (no -agent) still errors
# ------------------------------------------------------------------
# This catches a future rename silently becoming a correctness regression.

echo "[unfold-smoke] Guardrail: --integration cursor (without -agent suffix) should error"

GUARDRAIL_DIR="$TMP_ROOT/guardrail"
mkdir -p "$GUARDRAIL_DIR"

if (cd "$GUARDRAIL_DIR" && PYTHONIOENCODING=utf-8 specify init . --integration cursor --script sh --force --offline --no-git >/dev/null 2>&1); then
  WARN "--integration cursor succeeded — Spec-Kit may have added it as a synonym for cursor-agent. Review and update docs if intentional."
else
  PASS "--integration cursor errors as expected"
fi

echo

# ------------------------------------------------------------------
# 6. Verdict
# ------------------------------------------------------------------

TOTAL_ERRORS=$((CLAUDE_ERRORS + CURSOR_ERRORS))

echo "[unfold-smoke] Claude Code errors: $CLAUDE_ERRORS"
echo "[unfold-smoke] Cursor errors:      $CURSOR_ERRORS"
echo "[unfold-smoke] Total:              $TOTAL_ERRORS"

if [ "$TOTAL_ERRORS" -eq 0 ]; then
  echo
  echo -e "${GREEN}[unfold-smoke] PASS — both adapters unfold cleanly at the pinned Spec-Kit version.${NC}"
  exit 0
else
  echo
  echo -e "${RED}[unfold-smoke] FAIL — one or both adapters broke. Check docs/SPEC_KIT_PINNING.md for the bump procedure.${NC}"
  exit 1
fi
