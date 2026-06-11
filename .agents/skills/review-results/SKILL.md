---
name: review-results
description: Quality gate. Review generated cases, run results, and defects. On pass, write the marker that authorizes a DevOps upload.
---

# Skill: Review Results (GATE)

This skill is the ONLY thing that may authorize an upload. On pass it writes
`.qa-state/review-passed.json`, which the guard_upload hook requires.

## Inputs
- Generated test cases + `test-cases/traceability.md`.
- Run results + evidence in `.qa-state/runs/<runid>/`.
- Defect reports.

## Checklist (all must pass)
- [ ] The chosen use case is fully covered; related/regression UCs covered or gaps listed.
      (Run the coverage-report skill and attach the coverage summary + gaps.)
- [ ] Each test case meets test-case-standards.md (fields, traceability, observable steps).
- [ ] Each executed result has evidence; FAILs have observed vs expected.
- [ ] Each defect contradicts the SRS (not assumption), is minimal, classified, de-duplicated.
- [ ] No real PII; no PAT anywhere.
- [ ] All `TBD - needs team confirmation` items are listed for the team.

## Human gate
- Read `context.md` "Review Gate". If `human`, present the summary and WAIT for
  explicit human approval before writing the marker. Only self-approve if it is
  set to `auto`.

## On pass
- Write `.qa-state/review-passed.json`:
  ```json
  {
    "approvedAt": "<date>",
    "approvedBy": "<human name or 'auto'>",
    "runId": "<runid>",
    "scope": "<chosen UC + related UCs>",
    "testCases": ["TC-..."],
    "defects": ["BUG-..."]
  }
  ```

## On fail
- Do NOT write the marker. List what must be fixed and stop.

## Output
- Review verdict, and on pass the written marker path.
