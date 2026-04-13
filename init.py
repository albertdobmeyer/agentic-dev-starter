#!/usr/bin/env python3
"""Initialize a new project for spec-driven, test-first agentic development.

This script replaces `specify init` by bundling all necessary Spec-Kit assets
(commands, templates, scripts) and creating handoff document skeletons.

Usage:
    python init.py /path/to/new-project --name "My Project" --describe "What it does"
    python init.py ./my-app --name "My App" --describe "A web app" --no-git
    python init.py ./my-tool --name "CLI Tool" --describe "A CLI" --no-speckit
"""

import argparse
import json
import os
import shutil
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path


STARTER_DIR = Path(__file__).resolve().parent
SKELETON_DIR = STARTER_DIR / "skeleton"
SPECKIT_ASSETS = STARTER_DIR / "speckit-assets"


def substitute(text: str, variables: dict[str, str]) -> str:
    """Replace {{KEY}} placeholders in text."""
    for key, value in variables.items():
        text = text.replace("{{" + key + "}}", value)
    return text


def copy_template(template_name: str, dest: Path, variables: dict[str, str]) -> None:
    """Read a skeleton template, substitute variables, write to dest."""
    src = SKELETON_DIR / template_name
    if not src.exists():
        print(f"  [warn] Template not found: {src}", file=sys.stderr)
        return
    content = src.read_text(encoding="utf-8")
    content = substitute(content, variables)
    dest.write_text(content, encoding="utf-8")


def copy_tree(src_dir: Path, dest_dir: Path) -> int:
    """Copy all files from src_dir to dest_dir, preserving structure. Returns count."""
    count = 0
    for src_file in src_dir.rglob("*"):
        if src_file.is_file():
            rel = src_file.relative_to(src_dir)
            dest_file = dest_dir / rel
            dest_file.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(src_file, dest_file)
            count += 1
    return count


def init_project(
    target: Path,
    name: str,
    description: str,
    init_git: bool = True,
    include_speckit: bool = True,
    force: bool = False,
) -> None:
    """Initialize a new project at the target directory."""

    # --- Validate ---
    if target.exists() and any(target.iterdir()) and not force:
        print(
            f"[error] Directory is not empty: {target}\n"
            f"[error] Use --force to initialize anyway, or choose a different path.",
            file=sys.stderr,
        )
        sys.exit(1)

    variables = {
        "PROJECT_NAME": name,
        "PROJECT_DESCRIPTION": description,
        "DATE": datetime.now(timezone.utc).strftime("%Y-%m-%d"),
    }

    # --- Create target ---
    target.mkdir(parents=True, exist_ok=True)
    print(f"[init] Setting up project at {target}")

    # --- Git init ---
    if init_git:
        try:
            subprocess.run(
                ["git", "init"],
                cwd=str(target),
                capture_output=True,
                timeout=10,
            )
            print("  [ok] Initialized git repository")
        except FileNotFoundError:
            print("  [skip] git not found — skipping git init", file=sys.stderr)
        except Exception as e:
            print(f"  [warn] git init failed: {e}", file=sys.stderr)

    # --- .gitignore ---
    copy_template("gitignore.template", target / ".gitignore", variables)
    print("  [ok] .gitignore")

    # --- Handoff document skeletons ---
    for doc in ["VISION", "ARCHITECTURE", "CONSTITUTION", "SCOPE"]:
        template_name = f"{doc}.md.template"
        copy_template(template_name, target / f"{doc}.md", variables)
    print("  [ok] Handoff documents (VISION, ARCHITECTURE, CONSTITUTION, SCOPE)")

    # --- CLAUDE.md ---
    copy_template("CLAUDE.md.template", target / "CLAUDE.md", variables)
    print("  [ok] CLAUDE.md")

    # --- Spec-Kit assets ---
    if include_speckit:
        if not SPECKIT_ASSETS.exists():
            print(
                "  [warn] speckit-assets/ not found — skipping Spec-Kit setup",
                file=sys.stderr,
            )
        else:
            # Templates
            templates_dest = target / ".specify" / "templates"
            templates_src = SPECKIT_ASSETS / "templates"
            if templates_src.exists():
                count = copy_tree(templates_src, templates_dest)
                print(f"  [ok] .specify/templates/ ({count} files)")

            # Scripts
            scripts_src = SPECKIT_ASSETS / "scripts"
            scripts_dest = target / ".specify" / "scripts"
            if scripts_src.exists():
                count = copy_tree(scripts_src, scripts_dest)
                # Set execute permissions on bash scripts
                bash_dest = scripts_dest / "bash"
                if bash_dest.exists():
                    for sh in bash_dest.glob("*.sh"):
                        sh.chmod(sh.stat().st_mode | 0o111)
                print(f"  [ok] .specify/scripts/ ({count} files)")

            # Memory and specs directories
            (target / ".specify" / "memory").mkdir(parents=True, exist_ok=True)
            (target / ".specify" / "specs").mkdir(parents=True, exist_ok=True)

            # Copy constitution into spec-kit memory
            constitution_src = target / "CONSTITUTION.md"
            constitution_dest = target / ".specify" / "memory" / "constitution.md"
            if constitution_src.exists():
                shutil.copy2(constitution_src, constitution_dest)
            print("  [ok] .specify/memory/constitution.md")

            # Slash commands
            commands_src = SPECKIT_ASSETS / "commands"
            commands_dest = target / ".claude" / "commands"
            if commands_src.exists():
                commands_dest.mkdir(parents=True, exist_ok=True)
                count = 0
                for cmd_file in commands_src.glob("*.md"):
                    dest_name = f"speckit.{cmd_file.name}"
                    shutil.copy2(cmd_file, commands_dest / dest_name)
                    count += 1
                print(f"  [ok] .claude/commands/ ({count} slash commands)")

            # Init options metadata
            init_options = {
                "initialized_by": "agentic-dev-starter",
                "date": variables["DATE"],
                "project_name": name,
                "ai": "claude",
                "branch_numbering": "sequential",
            }
            options_path = target / ".specify" / "init-options.json"
            options_path.write_text(
                json.dumps(init_options, indent=2, ensure_ascii=False),
                encoding="utf-8",
            )
            print("  [ok] .specify/init-options.json")

    # --- Summary ---
    print(f"\n{'=' * 60}")
    print(f"  Project initialized: {target}")
    print(f"  Name: {name}")
    print(f"{'=' * 60}")
    print()
    print("  Next steps:")
    print()
    print("  1. Open the project in Claude Code (or your IDE with Claude Code):")
    print(f"     cd {target}")
    print("     claude")
    print()
    print("  2. Tell Claude:")
    print('     "Read CLAUDE.md. Help me plan this project and complete')
    print('      the handoff documents."')
    print()
    print("  3. Once planning is done, tell Claude:")
    print('     "Start building. Follow the Spec-Kit workflow."')
    print()
    print("  See example/ in agentic-dev-starter for a worked example")
    print("  of completed handoff documents.")
    print()


def main():
    parser = argparse.ArgumentParser(
        description="Initialize a new project for spec-driven agentic development.",
        epilog="Part of agentic-dev-starter: https://github.com/albertdobmeyer/agentic-dev-starter",
    )

    parser.add_argument(
        "target",
        help="Path to the new project directory",
    )
    parser.add_argument(
        "--name",
        required=True,
        help="Project name (used in document headers)",
    )
    parser.add_argument(
        "--describe",
        required=True,
        help="One-line project description",
    )
    parser.add_argument(
        "--no-git",
        action="store_true",
        help="Skip git init",
    )
    parser.add_argument(
        "--no-speckit",
        action="store_true",
        help="Skip .specify/ and .claude/commands/ (just handoff skeletons + CLAUDE.md)",
    )
    parser.add_argument(
        "--force",
        action="store_true",
        help="Allow initialization in a non-empty directory",
    )

    args = parser.parse_args()

    init_project(
        target=Path(args.target).resolve(),
        name=args.name,
        description=args.describe,
        init_git=not args.no_git,
        include_speckit=not args.no_speckit,
        force=args.force,
    )


if __name__ == "__main__":
    main()
