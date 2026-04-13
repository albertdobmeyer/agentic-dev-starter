# SCOPE — agentic-bookmark-organizer

## What This Project Is NOT

- No web UI — CLI only, output reviewed in browser or text editor
- No browser extension — this processes exported HTML files, not live browser state
- No bookmark syncing — one-shot processing, not a continuous service
- No Firefox/Safari/Edge-specific parsing — Chrome HTML export format only (other browsers can export to this format)
- No bookmark content scraping — we check if URLs are alive, we don't download page content
- No machine learning training — Ollama classifies using existing models, no fine-tuning
- No user accounts or multi-user support — single-user CLI tool
- No recursive dead link monitoring — one-time check, not a cron job
- No automatic Chrome re-import — tool produces the file, user imports manually
- No bookmark deduplication auto-delete — duplicates are flagged in the report, user decides
