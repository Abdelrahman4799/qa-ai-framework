---
name: upload-to-devops
description: Upload reviewed test cases and defects to Azure DevOps via the REST API using a PAT from the environment.
---

# Skill: Upload to Azure DevOps

## Preconditions (enforced by hooks)
- `.qa-state/review-passed.json` MUST exist (review gate). If missing, run
  review-results first.
- `AZURE_DEVOPS_PAT` must be available — set in `.env` (loaded via
  `scripts/load_env.ps1`) or already in the environment. Never inline the token.

## Inputs
- The reviewed test cases + defects.
- `docs/ai/devops-policy.md` (org / project / area / iteration, fields, endpoints).

## Steps
1. Load credentials + settings. In the SAME PowerShell command, dot-source the
   loader then build auth, e.g.:
   `. scripts/load_env.ps1; $pat = $env:AZURE_DEVOPS_PAT; ...`
   Build the Basic auth header (base64 of ":$pat") at runtime. Never print the PAT.
   Read org/project/area/iteration from devops-policy.md.
2. De-duplicate first
   - WIQL query for existing work items matching each TC ID / defect title.
   - Decide create vs update for each item.
3. Dry-run
   - Print the exact JSON-patch payload and target fields per item. No secrets in output.
4. Create / update TEST CASES first
   - Test cases → type `Test Case` (fields per devops-policy.md).
   - `POST .../_apis/wit/workitems/$Test Case?api-version=7.1`
     (Content-Type `application/json-patch+json`). Keep a map: TC-ID → work item ID.
5. Create BUGS and link each to its test case
   - For each bug, find its source test case (the TC it came from):
     · if that test case work item already exists (created in step 4 or found via WIQL)
       → create the Bug, then **link it to that test case**;
     · if the source test case does NOT exist yet → create the test case first
       (step 4 flow), then create the Bug and link it.
   - Link type per `devops-policy.md` (e.g. Bug ↔ Test Case "Related", or "Tested By").
   - A bug must never be uploaded unlinked when it has a known source test case.
6. Attach evidence + remaining relations
   - Upload screenshots via `_apis/wit/attachments`, link to the work item.
   - Link test cases (and bugs) to their requirement / UC / `DEC` work items where the
     IDs are known.
   - NEW-FEATURE ↔ BASELINE: link a new-feature use case's test cases to their
     "Related baseline TCs" (from traceability.md) so the regression relationship is
     visible in DevOps (use the Related link type per devops-policy.md).

## Output (final response)
- Created / updated work item IDs + URLs (test cases and bugs).
- Items skipped as duplicates (with existing IDs).
- Any failures + reason.
- Confirm the PAT was never emitted.
