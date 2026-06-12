---
name: triage-defect
description: Turn a failed test result into a clean, classified, reproducible defect report.
---

# Skill: Triage Defect

## Inputs
- The failing result record + evidence (from execute-test-cases).
- `docs/ai/defect-policy.md`, the linked SRS / new-feature SRS section.

## Steps
1. Confirm it is a real defect
   - Does the actual result contradict the SRS / new-feature SRS? If the spec is
     silent or ambiguous, mark `TBD - needs team confirmation` instead of filing
     a confirmed bug.
2. Reproduce minimally
   - Re-run via Playwright MCP to confirm. Reduce to the smallest repro steps.
   - Note reproducibility (always / intermittent / once).
3. Classify
   - Severity per the scale (S1–S4). Priority — set with the team or mark TBD.
4. Write the report
   - Use the defect template in defect-policy.md. Cite expected from the SRS.
   - Attach evidence paths. No PII, no PAT.
5. De-duplicate
   - Check existing defects (and, later, DevOps) for the same symptom;
     merge / reference instead of duplicating.

## Output
- One defect report per distinct symptom, ready for review-results.
- Do NOT upload yet.
