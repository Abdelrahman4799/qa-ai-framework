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
- `docs/ai/test-case-standards.md` and `docs/ai/coverage-dimensions.md`.
- `docs/ai/test-fixtures.md` (named prerequisite states) and `docs/ai/app-map.md`
  (navigation/role paths to reference in Test Data Preparation).
- `docs/ai/decisions.md` (BA/product rulings not in the SRS — a valid source to cite).

## Steps

1. SELECT
   - If the user named a UC, use it. Otherwise list the use-case catalog from the
     relevant `_index.md` and ask which one. Confirm the single scope.

2. UNDERSTAND the chosen UC (read its `Section` in full)
   - Read the chosen UC's `Section` from the index IN FULL (not the whole SRS).
   - Build a clear model before writing any case — extract:
     · actors / roles · preconditions & postconditions
     · the MAIN (happy) flow, every ALTERNATE flow, every EXCEPTION / error path
     · business rules, validation rules, data entities & their states
     · inputs/outputs and what is observable in the UI
   - Note ambiguities as `TBD - needs team confirmation` (or cite a `DEC-###`).

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

6. UNDERSTAND the related UCs (read the confirmed sections)
   - Read each confirmed related UC `Section` from `docs/ai/srs/`.
   - Model the INTERACTIONS with the chosen UC: shared data/entities and their states,
     ordering/prerequisite effects (`Depends on`), and what the chosen UC's changes do
     downstream (reverse edges). This is what cross-feature/integration cases test.

7. GENERATE
   - SCENARIOS: cover the MAIN flow, EVERY alternate flow, and EVERY exception/error
     path identified in steps 2 & 6 — not just happy/negative/boundary.
   - COVERAGE DIMENSIONS: walk `docs/ai/coverage-dimensions.md` for the UC and, per
     dimension, decide Covered / N/A (one-line reason) / Gap — so nothing is silently
     skipped. Generate cases for each applicable dimension: functional, negative,
     boundary, RBAC, cross-feature integration, concurrency/multi-session, list
     operations, soft-delete+confirmation, audit; and (if the app has UI of that kind)
     localization+RTL/LTR, theme, basic a11y. Record the per-dimension verdict for the
     coverage report.
   - Write cases per test-case-standards.md (TC-IDs, observable steps, expected results
     cited from the SRS section or a `DEC-###`).
   - DECISIONS: if a needed rule isn't in the SRS, check `docs/ai/decisions.md`; cite
     the `DEC-###` as the source. If neither SRS nor a decision covers it, mark
     `TBD - needs team confirmation` — do not invent the rule.
   - TEST DATA PREPARATION: give each case an explicit build/navigation path (cite
     `app-map.md` routes, reference a `test-fixtures.md` fixture, or values the steps
     create). No hardcoded/invented dummy data; no real PII.
   - CONSOLIDATE: merge redundant validation into one case (e.g. all mandatory-field
     combinations together) rather than one trivial case per field.
   - DEPENDENCIES (`Depends on`): each case's preconditions must state the
     prerequisite UC(s) and the state they leave behind (e.g. "an order exists —
     UC-01"). The setup either runs the prerequisite first or asserts its end-state.
     Follow chains only as far as needed; stop at a `TBD`/circular edge and flag it.
   - PRECONDITION-FEASIBILITY TAG: tag every case so execution knows how its setup is
     obtained —
       · `self-serviceable` — the case can build its own data with the available
         accounts (create your own, prefix `QA_<runid>_`).
       · `needs-fixture: <name>` — depends on a deep/irreversible/compound state;
         reference a named fixture from `docs/ai/test-fixtures.md` (e.g. a parent record
         WITH a dependent) instead of inlining the build steps.
       · `needs-config` — requires an app configuration that must pre-exist; name what
         must be configured.
       · `needs-live-action` — needs an outward-facing/irreversible action; flag for
         explicit authorization.
     Surfacing these upfront makes "blocked-by-design" cases visible before a run.
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
    - GOAL: for the chosen UC, EVERY flow (main / alternate / exception), EVERY acceptance
      criterion, and EVERY applicable coverage dimension (coverage-dimensions.md) is
      Covered or explicitly N/A — including
      permission (each actor positive + each non-actor denied), dependencies, and (where
      the app has them) localization/RTL, theme, list ops, concurrency. Every case meets
      test-case-standards.md with a Test Data Preparation path and no dummy data;
      traceability (UC + REQ/DEC) is complete; expected results cited (not assumed); no PII.
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
