---
name: promote-to-srs
description: Fold an accepted new use case from the new-feature SRS into the baseline SRS so it becomes living source of truth.
---

# Skill: Promote to SRS

Run after a NEW use case has been tested and accepted as delivered behavior.
This keeps the baseline SRS current so future relationship discovery can find it.

## Inputs
- The accepted new use case (from `docs/ai/new-feature-srs/`).
- Its generated test cases + `test-cases/traceability.md`.

## Steps
1. Create or update `docs/ai/srs/<feature>.md`:
   - Add the use case as a section with a stable `UC-###` and `REQ-###` IDs,
     derived from its acceptance criteria.
2. Update `docs/ai/srs/_index.md`:
   - Add a row (UC, file, section, REQ refs, summary, related UCs).
3. Update `test-cases/traceability.md`:
   - Point the new REQ/UC IDs at the test cases already generated.
4. Mark the new-feature SRS entry as promoted (note the new baseline UC ID).

## Rules
- Do not duplicate an existing baseline use case — update it instead.
- Do not invent acceptance criteria; derive only from the accepted spec.
  Mark gaps `TBD - needs team confirmation`.

## Output
- The new/updated baseline SRS file + index row + traceability update.
