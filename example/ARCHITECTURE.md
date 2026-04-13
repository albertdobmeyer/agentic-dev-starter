# ARCHITECTURE — agentic-bookmark-organizer

## Tech Stack

| Layer | Technology | Version | Rationale |
|---|---|---|---|
| Runtime | Python | 3.12 | Matches A5DS standard, already installed |
| LLM | Ollama (via agentic-ollama client) | local | Semantic categorization, title inference |
| Model | qwen3:8b | installed | Fast general-purpose, good for classification |
| HTTP | requests | 2.32 | URL liveness checks, Ollama API |
| HTML parsing | html.parser (stdlib) | built-in | Chrome bookmark HTML is simple NETSCAPE format |
| Concurrency | concurrent.futures | built-in | Parallel URL liveness checks |
| Output | Jinja2-style string templates | built-in | Generate Chrome-importable HTML |

## Module Boundaries

```
agentic-bookmark-organizer/
├── VISION.md              ← What we're building
├── ARCHITECTURE.md        ← This file
├── CONSTITUTION.md        ← Hard rules
├── SCOPE.md               ← What we're NOT building
├── organize.py            ← CLI entry point (argparse)
├── parser.py              ← Chrome HTML → Bookmark list
├── checker.py             ← URL liveness (concurrent HEAD requests)
├── categorizer.py         ← Ollama semantic categorization
├── reporter.py            ← Diff report generation (text + HTML)
├── exporter.py            ← Bookmark list → Chrome-importable HTML
├── models.py              ← Data classes (Bookmark, Folder, Report)
├── tests/
│   ├── test_parser.py
│   ├── test_checker.py
│   ├── test_categorizer.py
│   ├── test_reporter.py
│   └── test_exporter.py
├── CLAUDE.md              ← Agent instructions
├── .gitignore
└── README.md
```

## Data Model

```python
@dataclass
class Bookmark:
    url: str
    title: str
    add_date: int                    # Unix timestamp from HTML
    folder_path: list[str]           # ["MONEY", "Crypto", "BTC - Bitcoin"]
    is_alive: bool | None = None     # None = not checked yet
    http_status: int | None = None   # HTTP status code from check
    suggested_category: str | None = None  # Ollama's suggestion
    is_duplicate: bool = False

@dataclass
class Folder:
    name: str
    children: list[Folder | Bookmark]
    add_date: int
    last_modified: int

@dataclass
class Report:
    total_bookmarks: int
    dead_links: list[Bookmark]
    duplicates: list[tuple[Bookmark, Bookmark]]  # pairs
    recategorized: list[tuple[Bookmark, str]]     # bookmark + new category
    unchanged: int
```

## Data Flow

```
Input: Chrome bookmarks HTML file
  │
  ▼
parser.py ──► list[Bookmark] with folder_path preserved
  │
  ├──► checker.py ──► Bookmark.is_alive + http_status updated
  │    (concurrent HEAD requests, 5s timeout, max 20 workers)
  │
  ├──► categorizer.py ──► Bookmark.suggested_category set
  │    (batch Ollama calls: 20 bookmarks per prompt, qwen3:8b)
  │
  ▼
reporter.py ──► Report dataclass + human-readable text/HTML diff
  │
  ▼
exporter.py ──► Chrome-importable HTML (Netscape Bookmark format)
  │
  ▼
Output: report.txt + organized-bookmarks.html in same directory as input
```

## Infrastructure Decisions

- **No database**: Bookmarks are small enough to hold in memory. State is the HTML files themselves.
- **No web UI**: CLI tool. Point at file, get output. Review in any text editor or browser.
- **Ollama required**: Semantic categorization is the core value. Tool exits cleanly if Ollama unavailable.
- **Original file never modified**: Output is always a NEW file alongside the original.
- **Concurrent HTTP checks**: 20 workers, 5-second timeout per URL. Respectful rate limiting.
