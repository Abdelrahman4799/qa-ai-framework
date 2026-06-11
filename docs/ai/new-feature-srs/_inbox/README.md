# New-Feature SRS Inbox (drop Word files here)

Drop the **new feature's** Word (.docx) spec here, then run the **ingest-srs**
skill for this target (or say "ingest the new-feature SRS"). It converts the
document with pandoc and splits it into one file per use case in
`docs/ai/new-feature-srs/`.

Convention: use cases are headings at the configured level (default `####`).
If your document uses a different level, run with `-UseCaseLevel <n>`.

Raw `.docx` files here are git-ignored — source material, not the requirements
the AI reads.
