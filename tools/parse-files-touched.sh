#!/usr/bin/env bash
#
# parse-files-touched.sh — extract structured file ownership from a spec.md.
#
# Reads the "## Files this feature will touch" section and emits one line
# per file in the format:
#
#   <path>|<marker>
#
# where <marker> is one of: new | SHARED | modify | unknown
#
# Trailing slashes on directory paths are preserved (callers must decide whether
# `src/calendar/` should be expanded with a glob).
#
# Reusable by dna-spec-validate (cross-spec ownership check, SPEC-19) and the
# dna:cross-checker subagent. Read-only — does not mutate any spec or Blueprint.
#
# Usage:
#   parse-files-touched.sh <path-to-spec.md>
#
# Exit codes:
#   0  parsed successfully (zero-or-more lines emitted on stdout)
#   1  no "Files this feature will touch" section in the spec
#   2  spec file does not exist

set -u

SPEC="${1:-}"

if [ -z "$SPEC" ]; then
  echo "[parse-files-touched] usage: parse-files-touched.sh <path-to-spec.md>" >&2
  exit 2
fi
if [ ! -f "$SPEC" ]; then
  echo "[parse-files-touched] spec file not found: $SPEC" >&2
  exit 2
fi

# Extract the section between "## Files this feature will touch" and the next "## " header.
SECTION=$(awk '
  /^## Files this feature will touch/ { in_section=1; next }
  in_section && /^## / { in_section=0 }
  in_section { print }
' "$SPEC")

if [ -z "$SECTION" ]; then
  exit 1
fi

# Per-line: extract backtick-quoted path + parenthesized marker (if any).
echo "$SECTION" | awk '
  match($0, /`[^`]+`/) {
    path = substr($0, RSTART+1, RLENGTH-2)
    marker = "unknown"
    if (match($0, /\((SHARED|new|modify)[^)]*\)/, m)) {
      marker = m[1]
    }
    print path "|" marker
  }
'
