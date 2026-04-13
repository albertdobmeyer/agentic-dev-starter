# agentic-bookmark-organizer

An Ollama-powered CLI tool that parses Chrome bookmark HTML exports, checks URL liveness, semantically categorizes bookmarks via LLM, and produces a cleaned, reorganized, re-importable bookmark file.

## Quick Reference

- **Input**: Chrome bookmarks HTML export (Netscape Bookmark format)
- **Output**: Report (text) + reorganized bookmarks HTML in the same directory as input
- **LLM**: Ollama via `agentic-ollama/client.py` (qwen3:8b for categorization)
- **Python**: 3.12

## Architecture

```
organize.py      ← CLI entry point (argparse)
parser.py        ← Chrome HTML → list[Bookmark]
checker.py       ← Concurrent URL liveness (HEAD requests, 20 workers, 5s timeout)
categorizer.py   ← Ollama semantic categorization (batches of 20)
reporter.py      ← Diff report generation
exporter.py      ← list[Bookmark] → Chrome-importable HTML
models.py        ← Bookmark, Folder, Report dataclasses
tests/           ← pytest, small hand-crafted HTML fixtures only
```

## Rules

- Original input file is NEVER modified — output is always new files
- All Ollama calls go through `agentic-ollama/client.py` — never call the API directly
- Ollama prompt failures: retry once, then skip that bookmark
- No pip dependencies beyond `requests` (stdlib otherwise)
- Test data: hand-crafted fixtures, never the real bookmark file
- Bookmark folder hierarchy preserved unless user passes `--reorganize`
- Commit messages: `type: description` (feat, fix, test, docs, chore, refactor)

## Handoff Documents

- @VISION.md — what we're building and why
- @ARCHITECTURE.md — tech stack, modules, data model, data flow
- @CONSTITUTION.md — hard rules (anti-flattening, depth tags, testing discipline)
- @SCOPE.md — what we're NOT building

## Commands

```bash
# Full cleanup: parse → check → categorize → report → export
python organize.py input.html

# Dead link audit only
python organize.py input.html --check-only

# Dry run (parse and report, no output file)
python organize.py input.html --dry-run

# With reorganization (Ollama suggests new folder structure)
python organize.py input.html --reorganize
```

## Testing

```bash
python -m pytest tests/ -v
```
