# Existing SRS (baseline)

Two ways to populate this folder:

**A. From Word (.docx)** — drop the file into `_inbox/` and run the **ingest-srs**
skill. pandoc converts it and splits it into one file per use case (`####`
headings). This is the recommended path for a full SRS.

**B. By hand** — drop the SRS here as Markdown/text, one feature per file where
practical (e.g. `login.md`, `checkout.md`).

Guidelines:
- Give each use case a heading and a stable ID, e.g. `## UC-05 — Checkout with saved card`.
- Give requirements stable IDs, e.g. `REQ-112`.
- Keep one feature per file so the AI reads only what is in scope.

After adding files, run the **index-srs** skill once to build `_index.md`
(the use-case catalog). Re-run it only when the baseline SRS changes.

This folder ships empty. Nothing here is invented — provide the real SRS.
