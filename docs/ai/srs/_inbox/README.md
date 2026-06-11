# SRS Inbox (drop Word files here)

Drop your full **Word (.docx)** SRS into this folder, then run the **ingest-srs**
skill (or say "ingest the SRS"). It converts the document to Markdown with pandoc
and splits it into one file per use case (`####` headings) in `docs/ai/srs/`.

Convention: use cases are **level-4 headings (`####`)** in the Word document;
features/sections are higher levels (`#`, `##`, `###`).

Raw `.docx` files here are git-ignored — they are source material, not the
requirements the AI reads.
