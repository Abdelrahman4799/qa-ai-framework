---
name: ingest-srs
description: Convert a dropped Word (.docx) SRS to Markdown with pandoc and split it into one file per use case (level-4 #### headings), ready for index-srs.
---

# Skill: Ingest SRS

Turn a Word SRS into the per-use-case Markdown files the framework needs. Works for
the **baseline** SRS and the **new-feature** SRS. For the baseline, run this BEFORE
index-srs.

## Prerequisite
- pandoc installed and on PATH.
  `winget install JohnMacFarlane.Pandoc` — or https://pandoc.org/installing.html

## Input & convention
- A Word file dropped into the target's `_inbox/` (or an explicit path):
  - baseline → `docs/ai/srs/_inbox/`
  - new feature → `docs/ai/new-feature-srs/_inbox/`
- USE CASES are headings at the **configured level** — default level 4 (`####`).
  Headings ABOVE that level are kept as a context breadcrumb; headings BELOW it
  stay as body inside the use-case file.

## Steps
1. Confirm pandoc is available. If not, stop and tell the user how to install it.
2. Confirm the heading level your document uses for use cases (default `####`).
   Ask the user if unsure.
3. Run the ingest script for the right target / level:
   ```
   # baseline SRS, use cases at #### (default)
   powershell -NoProfile -ExecutionPolicy Bypass -File scripts/ingest_srs.ps1

   # new-feature SRS
   powershell -NoProfile -ExecutionPolicy Bypass -File scripts/ingest_srs.ps1 -Target new-feature

   # different use-case heading level (e.g. ### )
   powershell -NoProfile -ExecutionPolicy Bypass -File scripts/ingest_srs.ps1 -UseCaseLevel 3
   ```
   (optionally `-DocxPath "<path-to.docx>"`). It:
   - converts the `.docx` to Markdown (gfm), extracting images to `<target>/_media/`;
   - splits at each use-case heading into one file per use case, named
     `<UC-ID>-<slug>.md` in the target folder;
   - reuses a `UC-##` id found in the heading, else assigns a sequential `UC-00n`;
   - adds the parent headings as a `<!-- context: ... -->` breadcrumb.
4. Review the result with the user:
   - sanity-check a couple of splits (heading captured, body intact, images linked);
   - if zero files were produced, the level is probably wrong — re-run with the
     correct `-UseCaseLevel`;
   - flag use cases with no real ID as `TBD - needs team confirmation` and offer to
     rename to the team's real UC IDs.
5. Next step:
   - baseline → run **index-srs** to build the catalog + fingerprint.
   - new feature → the split files are ready for **generate-test-cases** to select
     from; it can also refresh `new-feature-srs/_index.md` from them.

## Rules
- Do not edit requirement text while splitting — preserve content verbatim.
- Do not invent use cases. If `####` headings are missing, report it; the document
  may use a different heading level (adjust the source or confirm the convention).
- Raw `.docx` files in `_inbox/` are source material, not requirements — they are
  git-ignored.

## Output
- One Markdown file per use case in `docs/ai/srs/`, images in `_media/`.
- A list of created files + any TBDs. Next step: index-srs.
