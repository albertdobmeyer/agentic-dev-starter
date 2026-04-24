#!/usr/bin/env bash
#
# dna-context-check. reads the companion agent-token-meter output and emits
# a handoff-readiness verdict. The methodology's rule: handoff BEFORE
# ~100k tokens. Past that, agent response quality degrades (PROJECT_DNA's
# "dumb zone").
#
# The agent-token-meter tool (npx agent-token-meter) writes a JSON status
# file that this script reads. If the status file is missing, we can't
# enforce; emit a warning and let the main agent self-monitor.
#
# Exit codes:
#   0  SAFE (< 70k tokens used in current session)
#   1  WARNING (70k-100k; plan handoff soon)
#   2  HANDOFF_REQUIRED (> 100k; write session handoff NOW before continuing)
#   3  UNMEASURED (token-meter not running)

set -u

METER_FILES=(
  ".agent-token-meter.json"
  ".claude/token-meter.json"
  "$HOME/.agent-token-meter/latest.json"
)

METER_FILE=""
for f in "${METER_FILES[@]}"; do
  if [ -f "$f" ]; then METER_FILE="$f"; break; fi
done

if [ -z "$METER_FILE" ]; then
  echo "[dna-context-check] UNMEASURED. token-meter output not found."
  echo "  Start it in a split pane: npx agent-token-meter"
  echo "  Without it, the 100k-token handoff rule (PROJECT_DNA §4 / Article 3) is enforced on the honor system."
  echo "  Main agent should manually estimate and trigger handoff if the conversation feels long."
  exit 3
fi

# ------------------------------------------------------------------
# Extract current token count.
# Expected JSON shape (agent-token-meter contract):
#   { "session": { "tokens_used": 82340, "budget": 200000 }, "timestamp": "..." }
# ------------------------------------------------------------------
if command -v jq >/dev/null 2>&1; then
  TOKENS=$(jq -r '.session.tokens_used // .tokens_used // empty' "$METER_FILE" 2>/dev/null)
  BUDGET=$(jq -r '.session.budget // .budget // 200000' "$METER_FILE" 2>/dev/null)
else
  # Fallback: grep pattern (fragile, but we'll try)
  TOKENS=$(grep -oE '"tokens_used"\s*:\s*[0-9]+' "$METER_FILE" | head -1 | grep -oE '[0-9]+')
  BUDGET=200000
fi

if [ -z "$TOKENS" ]; then
  echo "[dna-context-check] UNMEASURED. could not parse $METER_FILE. Expected JSON with .session.tokens_used field."
  exit 3
fi

# ------------------------------------------------------------------
# Thresholds (can be overridden by CONSTITUTION.md Article 10; look for
# a line like "session budget: 100k tokens" or "handoff at 100k")
# ------------------------------------------------------------------
HANDOFF_THRESHOLD=100000
WARNING_THRESHOLD=70000

if [ -f "CONSTITUTION.md" ]; then
  # Accept "100k", "100 000", "100000"
  CUSTOM=$(grep -oEi '(handoff|session)[^.]{0,40}[0-9]{2,3}\s*k' CONSTITUTION.md | head -1 | grep -oE '[0-9]+\s*k' | tr -d 'k ')
  if [ -n "$CUSTOM" ]; then
    HANDOFF_THRESHOLD=$((CUSTOM * 1000))
    WARNING_THRESHOLD=$((HANDOFF_THRESHOLD * 7 / 10))
  fi
fi

# ------------------------------------------------------------------
# Verdict
# ------------------------------------------------------------------
PCT=$((TOKENS * 100 / BUDGET))
echo "[dna-context-check] Session: ${TOKENS} tokens used (${PCT}% of ${BUDGET} budget)"
echo "                    Warning at ${WARNING_THRESHOLD}, handoff required at ${HANDOFF_THRESHOLD}"

if [ "$TOKENS" -ge "$HANDOFF_THRESHOLD" ]; then
  echo
  echo "[dna-context-check] HANDOFF_REQUIRED. write a session handoff NOW before continuing."
  echo "  Required artifact (appended to $FEATURE_DIR/handoff.md if feature-scoped, else .exploration/HANDOFF-\$(date +%F).md):"
  echo "    - Done: (what shipped this session)"
  echo "    - Next: (if the next prompt is X, do Y)"
  echo "    - Blocked: (open questions, decisions awaiting user)"
  echo "    - Files touched: (so the next instance knows where to read)"
  exit 2
elif [ "$TOKENS" -ge "$WARNING_THRESHOLD" ]; then
  echo
  echo "[dna-context-check] WARNING. approaching handoff threshold. Plan to finish current logical unit and write handoff within the next ~30k tokens."
  exit 1
else
  echo
  echo "[dna-context-check] SAFE. plenty of context budget remaining."
  exit 0
fi
