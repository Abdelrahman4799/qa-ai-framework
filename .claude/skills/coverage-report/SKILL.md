---
name: coverage-report
description: Generate test-cases/coverage.md showing which use cases / requirements have test cases (and results) and which are gaps.
---

# Skill: Coverage Report

Turn traceability into a human-readable coverage view: what is covered, what is a gap.

## Inputs
- `test-cases/traceability.md`
- `docs/ai/srs/_index.md` and `docs/ai/new-feature-srs/_index.md` (the UC/REQ universe)
- `docs/ai/coverage-dimensions.md` (the dimension list)
- Latest run results in `.qa-state/runs/` (for the "executed?" status), if any.

## Steps
1. Build the universe — list all `UC-###` / `REQ-###` (+ `DEC-###`) from the indexes /
   decisions in scope (scope = "all", or a single use case + its related UCs).
2. For each, look up mapped test cases in `traceability.md`.
3. Classify requirement status:
   - COVERED — at least one test case exists AND was executed
   - PARTIAL — test case exists but not yet executed
   - GAP — no test case
4. Build the **dimension matrix**: per UC × each dimension in `coverage-dimensions.md`,
   mark Covered / N/A (reason) / Gap — so skipped dimensions (e.g. no localization or
   concurrency cases) are visible, not silent.
5. Regression coverage (for a new-feature UC): list each impacted related UC and whether
   it has (a) a core re-run AND (b) a targeted impact-point regression case. Flag any
   impacted UC with only a re-run, or with none.
6. Write `test-cases/coverage.md` (requirement table + dimension matrix + regression table
   + gap summary + scope + last-updated date).
7. Report the coverage figure (covered / total), the dimension gaps, the regression gaps,
   and the list of gaps.

## Rules
- Do not invent UCs/REQs/DECs — only those present in the indexes/decisions.
- Gaps are facts, not failures — list them plainly for the team to prioritize.
- A dimension marked N/A must carry a one-line reason.

## Output
- `coverage.md` written + a one-line coverage summary + the gaps list.
