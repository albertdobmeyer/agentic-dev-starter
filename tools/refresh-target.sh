#!/usr/bin/env bash
#
# refresh-target.sh — sync kit payload into an existing unfolded target.
#
# Solves the SPEC-10-dogfood problem: every new run.sh, new subagent, or
# updated SKILL.md shipped in the kit after the target's unfold is orphaned
# until someone manually copies it. This script gives the team lead one
# composable command to pull kit updates forward.
#
# Default mode is ADD-ONLY + WARN-ON-DIFF. Local customizations are never
# clobbered unless the team lead passes --force.
#
# Usage:
#   bash tools/refresh-target.sh <target-path> [--force] [--dry-run]
#                                [--scope skills|agents|all]
#
# Exit codes:
#   0  Refresh completed cleanly (all files IDENTICAL or ADDED).
#   1  Drift detected — target has files that differ from kit. Inspect
#      before using --force.
#   2  Setup problem (target not a directory, missing .claude/, bad args).

set -u

# ------------------------------------------------------------------
# Arg parsing
# ------------------------------------------------------------------

TARGET=""
FORCE=0
DRY_RUN=0
SCOPE="all"

usage() {
  # Print the docstring (lines 3-21: name, blurb, usage, exit codes).
  local rc="${1:-2}"
  sed -n '3,21p' "$0" | sed 's/^# \{0,1\}//' >&2
  exit "$rc"
}

while [ $# -gt 0 ]; do
  case "$1" in
    --force) FORCE=1; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    --scope)
      SCOPE="${2:-}"
      if [ "$SCOPE" != "skills" ] && [ "$SCOPE" != "agents" ] && [ "$SCOPE" != "all" ]; then
        echo "[refresh] SETUP — --scope must be one of: skills, agents, all" >&2
        exit 2
      fi
      shift 2
      ;;
    --help|-h) usage 0 ;;
    -*)
      echo "[refresh] SETUP — unknown flag: $1" >&2
      usage
      ;;
    *)
      if [ -z "$TARGET" ]; then
        TARGET="$1"
      else
        echo "[refresh] SETUP — unexpected extra argument: $1" >&2
        usage
      fi
      shift
      ;;
  esac
done

if [ -z "$TARGET" ]; then
  echo "[refresh] SETUP — <target-path> is required." >&2
  usage
fi

# ------------------------------------------------------------------
# Locate kit root + validate target
# ------------------------------------------------------------------

KIT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

if [ ! -d "$KIT_ROOT/template" ]; then
  echo "[refresh] SETUP — kit root $KIT_ROOT missing template/. Is this script in tools/ of the kit?" >&2
  exit 2
fi

if [ ! -d "$TARGET" ]; then
  echo "[refresh] SETUP — target $TARGET is not a directory." >&2
  exit 2
fi

TARGET="$(cd "$TARGET" && pwd)"

if [ ! -d "$TARGET/.claude" ]; then
  echo "[refresh] SETUP — target $TARGET has no .claude/ directory. Was this target unfolded by Protocol A?" >&2
  exit 2
fi

KIT_HEAD=$(git -C "$KIT_ROOT" rev-parse --short HEAD 2>/dev/null || echo "unknown")

echo "[refresh] Kit:    $KIT_ROOT (commit $KIT_HEAD)"
echo "[refresh] Target: $TARGET"
echo "[refresh] Scope:  $SCOPE"
if [ $DRY_RUN -eq 1 ]; then echo "[refresh] Mode:   DRY-RUN (no writes)"; fi
if [ $FORCE -eq 1 ];   then echo "[refresh] Mode:   FORCE (overwrite on drift)"; fi
echo

# ------------------------------------------------------------------
# Counters
# ------------------------------------------------------------------

ADDED=0
DRIFT=0
IDENTICAL=0
OVERWROTE=0

# ------------------------------------------------------------------
# Core: refresh one source file into its target location
# ------------------------------------------------------------------

refresh_file() {
  local src="$1"        # absolute path under $KIT_ROOT/template
  local dest="$2"       # absolute path under $TARGET
  local rel="$3"        # display label

  local dest_dir
  dest_dir="$(dirname "$dest")"

  if [ ! -e "$dest" ]; then
    if [ $DRY_RUN -eq 0 ]; then
      mkdir -p "$dest_dir"
      cp "$src" "$dest"
      case "$dest" in *.sh) chmod +x "$dest" ;; esac
    fi
    printf "  %-40s ADDED\n" "$rel"
    ADDED=$((ADDED+1))
    return
  fi

  if cmp -s "$src" "$dest"; then
    printf "  %-40s IDENTICAL\n" "$rel"
    IDENTICAL=$((IDENTICAL+1))
    return
  fi

  # Exists and differs
  if [ $FORCE -eq 1 ]; then
    if [ $DRY_RUN -eq 0 ]; then
      cp "$src" "$dest"
      case "$dest" in *.sh) chmod +x "$dest" ;; esac
    fi
    printf "  %-40s OVERWROTE (was drift)\n" "$rel"
    OVERWROTE=$((OVERWROTE+1))
  else
    printf "  %-40s DRIFT (use --force to overwrite, or inspect: diff %s %s)\n" "$rel" "$src" "$dest"
    DRIFT=$((DRIFT+1))
  fi
}

# ------------------------------------------------------------------
# Skills: template/skills/<name>/{run.sh, SKILL.md}
# ------------------------------------------------------------------

if [ "$SCOPE" = "skills" ] || [ "$SCOPE" = "all" ]; then
  echo "## Skills"
  # Only refresh dna-* skills (speckit-* live elsewhere and are not kit payload).
  while IFS= read -r src; do
    rel="${src#$KIT_ROOT/template/}"
    dest="$TARGET/.claude/$rel"
    refresh_file "$src" "$dest" "$rel"
  done < <(find "$KIT_ROOT/template/skills" -type f \( -name 'run.sh' -o -name 'SKILL.md' \) -path '*/dna-*/*' | sort)
  echo
fi

# ------------------------------------------------------------------
# Agents: template/agents/*.md
# ------------------------------------------------------------------

if [ "$SCOPE" = "agents" ] || [ "$SCOPE" = "all" ]; then
  echo "## Agents"
  if [ -d "$KIT_ROOT/template/agents" ]; then
    while IFS= read -r src; do
      rel="${src#$KIT_ROOT/template/}"
      dest="$TARGET/.claude/$rel"
      refresh_file "$src" "$dest" "$rel"
    done < <(find "$KIT_ROOT/template/agents" -type f -name '*.md' | sort)
  else
    echo "  (no template/agents/ in kit)"
  fi
  echo
fi

# ------------------------------------------------------------------
# Summary + verdict
# ------------------------------------------------------------------

echo "[refresh] Summary: $ADDED added, $OVERWROTE overwrote, $DRIFT drift, $IDENTICAL identical"

if [ $DRIFT -gt 0 ]; then
  echo "[refresh] DRIFT — $DRIFT file(s) differ between kit and target."
  echo "  Inspect each with: diff <kit-path> <target-path>"
  echo "  Keep target version: do nothing."
  echo "  Adopt kit version: re-run with --force (overwrites all drift)."
  exit 1
fi

if [ $DRY_RUN -eq 1 ]; then
  echo "[refresh] DRY-RUN complete — no changes written. Re-run without --dry-run to apply."
else
  echo "[refresh] PASS — target synced to kit (commit $KIT_HEAD)."
fi
exit 0
