# VISION — agentic-bookmark-organizer

## Problem Statement

Browser bookmarks accumulate over years into an unmanageable mess. 1,000+ bookmarks across 100+ folders, many dead links, inconsistent naming, duplicate entries, and folders that made sense once but no longer reflect how you think. Manual cleanup takes hours and nobody does it. The bookmarks stay broken.

## Target Users

**Primary (100%): Albert** — power user with 1,067 Chrome bookmarks across 126 folders spanning finance, crypto, AI, code, health, media, work, and personal. Exports bookmarks as HTML. Wants them cleaned up, reorganized semantically, and re-importable.

## Core Value Proposition

For Albert: point this tool at a Chrome bookmarks HTML export, and get back a cleaned, reorganized, de-duplicated bookmark file ready to re-import — with dead links flagged, semantic categories applied by Ollama, and a human-reviewable diff before anything changes.

## Experience Fidelity Scenarios

### Scenario 1: Full Bookmark Cleanup [D]

**CONTEXT:** Albert exports his Chrome bookmarks to HTML. He drops the file into the tool's input folder. He wants a clean, reorganized set of bookmarks he can re-import.

**WHAT HE EXPERIENCES:**
He runs a single command. The tool parses all 1,067 bookmarks. It checks each URL for liveness (HEAD request). It sends bookmark titles + URLs to Ollama in batches for semantic categorization. It produces a report: X dead links found, Y duplicates found, Z bookmarks recategorized. It writes a new HTML file in Chrome-importable format with the proposed reorganization. Albert opens the report, reviews the changes, approves or edits, then imports the clean file into Chrome.

**WHAT HE NEVER HAS TO DO:**
- Never manually visit each bookmark to check if it's alive
- Never decide folder-by-folder which category a bookmark belongs to
- Never lose his original bookmarks — the tool never modifies the input file
- Never re-import without reviewing what changed

**BEHAVIORAL VARIATION:**
- Happy path: 1,067 bookmarks → report + clean export in under 5 minutes
- Edge case: bookmark has no title (just a URL) → Ollama infers a title from the URL/domain
- Error flow: Ollama is not running → clear error message, tool exits, no partial output

**WHY IT MATTERS:**
Manual bookmark cleanup of 1,067 bookmarks: 4-6 hours of mind-numbing work. With this tool: 5 minutes of automated processing + 10 minutes of human review = 15 minutes total.

**SUCCESS CRITERION:**
Video of Albert running the tool on his 1,067-bookmark export, reviewing the HTML diff report, and re-importing the cleaned bookmarks into Chrome — total time under 15 minutes.

### Scenario 2: Dead Link Audit Only [W]

**CONTEXT:** Albert doesn't want a full reorganization — he just wants to know which bookmarks are dead.

**WHAT HE EXPERIENCES:**
He runs the tool with a `--check-only` flag. The tool checks every URL (concurrent HEAD requests). It produces a report listing dead links grouped by folder, with HTTP status codes. No reorganization, no new file — just a report.

**WHAT HE NEVER HAS TO DO:**
- Never click each bookmark manually to see if it loads
- Never guess whether a timeout means dead or just slow
- Never lose context on where the dead link lives in the folder tree

**BEHAVIORAL VARIATION:**
- Happy path: 50 dead links found, report generated
- Edge case: URL returns 403 (blocked but exists) → marked as "restricted", not "dead"
- Error flow: network is down → tool detects, reports "network unavailable", exits clean

**WHY IT MATTERS:**
Dead links are invisible clutter. You only discover them when you need the bookmark — the worst time.

**SUCCESS CRITERION:**
Tool correctly identifies 90%+ of dead links with no false positives on live sites.

## Depth Summary

| Requirement | Depth | Rationale |
|---|---|---|
| Parse Chrome HTML export | [W] | Single component, well-defined input format |
| Check URL liveness | [W] | HTTP HEAD requests, isolated function |
| Ollama semantic categorization | [W] | Ollama call with title+URL, returns category |
| Full pipeline: parse → check → categorize → report → export | [D] | Multi-component integration delivering the user experience |
| Human-reviewable diff report | [W] | Single component, renders comparison |
| Chrome-importable HTML output | [W] | Single component, well-defined output format |
| --check-only dead link audit | [W] | Subset of full pipeline |
