---
name: generate-test-cases
description: For ONE chosen use case, discover related existing use cases (confirm with the user), then generate traceable test cases plus the regression set.
---

# Skill: Generate Test Cases (per chosen use case)

Scope is a SINGLE chosen use case plus the related existing use cases you confirm.
Never generate for the whole SRS.

## Inputs
- The chosen use case (by ID, or picked from a catalog).
- `docs/ai/new-feature-srs/_index.md`, `docs/ai/srs/_index.md` (tiny).
- `docs/ai/test-case-standards.md`.

## Steps

1. SELECT
   - If the user named a UC, use it. Otherwise list the use-case catalog from the
     relevant `_index.md` and ask which one. Confirm the single scope.

2. READ (minimal)
   - Read only the chosen UC's `Section` (from the index) in full.
   - Do NOT read the whole file or the whole SRS.

3. DISCOVER related + dependent use cases
   - From `_index.md`, read the chosen UC's `Depends on` (its prerequisites) and
     its `Related UCs`. Also find the REVERSE depends-on edges — UCs that list this
     one as a prerequisite (the impact set).
   - Match the chosen UC against the index summaries to propose any further UCs it
     touches (shared entities, flows, screens).

4. CONFIRM with the user
   - "This use case relates to: UC-02, UC-11 — correct?"
   - Do not silently widen or narrow scope. If unsure, mark
     `TBD - needs team confirmation` and ask.

5. PERSIST pointers
   - Write the confirmed relationships into `new-feature-srs/_index.md`
     ("Relates to existing" column) so future runs reuse them.

6. READ related sections (only the confirmed ones)
   - Read just those related UC `Section`s from `docs/ai/srs/`.

7. GENERATE
   - For the chosen UC: derive scenarios (happy path, negative, boundary,
     cross-UC interaction) and write test cases per test-case-standards.md
     (TC-IDs, observable steps, expected results cited from the SRS section).
   - DEPENDENCIES (`Depends on`): each case's preconditions must state the
     prerequisite UC(s) and the state they leave behind (e.g. "an order exists —
     UC-01"). The setup either runs the prerequisite first or asserts its end-state.
     Follow chains only as far as needed; stop at a `TBD`/circular edge and flag it.
   - ROLE-BASED coverage (multi-role system). The allowed roles come from the
     `Actors` column of the use case in `_index.md` (and `permission-matrix.md`):
       · allowed = the UC's Actors  → POSITIVE cases (each actor can do it)
       · denied  = all known roles − Actors  → DENIED cases (each is blocked cleanly)
     State the role in each case's preconditions and use that role's test account.
     If `Actors` is empty / `TBD`, mark `TBD - needs team confirmation` — do not guess.
     For data-scoped rules (e.g. "Manager — own team only"), add a positive case
     in-scope and a negative case out-of-scope where the matrix flags it.

8. SELECT the regression set
   - From `test-cases/traceability.md`, collect existing TCs covering the related
     UCs AND the impact set (UCs that depend on the chosen one — reverse edges).
     Where such a UC has no cases yet, generate them too.

9. WRITE
   - Save cases under `test-cases/<UC-ID>/`.
   - Update `test-cases/traceability.md` (UC/REQ → TC).

10. GOAL LOOP (/goal) — iterate to the best coverage
    - GOAL: for the chosen UC, EVERY acceptance criterion and scenario type is covered —
      happy, negative, boundary, permission (each actor positive + each non-actor denied),
      and dependency preconditions; every case meets test-case-standards.md; traceability
      is complete; expected results are cited from the SRS (not assumed); no real PII.
    - ITERATE (max 3 rounds, or stop early when a round adds nothing new):
      1. Self-critique the current cases against the GOAL — list missing ACs / scenarios /
         roles / edge cases / weak assertions.
      2. Add or strengthen cases to close each gap; re-save and update traceability.
      3. Re-check. Stop when no new gap is found or after 3 rounds.
    - Report final coverage vs the GOAL and any residual gaps (as `TBD` / known limits).

## Output
- New test cases + the regression set (TC IDs).
- Updated traceability + persisted relationship pointers.
- Open TBDs.
- Do NOT upload — that is upload-to-devops, after the review gate.
