---
name: coverage-report
description: Generate test-cases/coverage.md showing which use cases / requirements have test cases (and results) and which are gaps.
---

# Skill: Coverage Report

Turn traceability into a human-readable coverage view: what is covered, what is a gap.

## Inputs
- `test-cases/traceability.md`
- `docs/ai/srs/_index.md` and `docs/ai/new-feature-srs/_index.md` (the UC/REQ universe)
- Latest run results in `.qa-state/runs/` (for the "executed?" status), if any.

## Steps
1. Build the universe — list all `UC-###` / `REQ-###` from the indexes in scope
   (scope = "all", or a single use case + its related UCs to match a run).
2. For each, look up mapped test cases in `traceability.md`.
3. Classify status:
   - COVERED — at least one test case exists AND was executed
   - PARTIAL — test case exists but not yet executed
   - GAP — no test case
4. Write `test-cases/coverage.md` (table + gap summary + scope + last-updated date).
5. Report the coverage figure (covered / total) and the list of gaps.

## Rules
- Do not invent UCs/REQs — only those present in the indexes.
- Gaps are facts, not failures — list them plainly for the team to prioritize.

## Output
- `coverage.md` written + a one-line coverage summary + the gaps list.
