---
name: upload-to-devops
description: Upload reviewed test cases and defects to Azure DevOps via the REST API using a PAT from the environment.
---

# Skill: Upload to Azure DevOps

## Preconditions (enforced by hooks)
- `.qa-state/review-passed.json` MUST exist (review gate). If missing, run
  review-results first.
- `AZURE_DEVOPS_PAT` must be set in the environment. Never inline the token.

## Inputs
- The reviewed test cases + defects.
- `docs/ai/devops-policy.md` (org / project / area / iteration, fields, endpoints).

## Steps
1. Load connection settings from devops-policy.md. Build the Basic auth header at
   runtime from `$env:AZURE_DEVOPS_PAT` (base64 of ":$PAT"). Do not print it.
2. De-duplicate first
   - WIQL query for existing work items matching each TC ID / defect title.
   - Decide create vs update for each item.
3. Dry-run
   - Print the exact JSON-patch payload and target fields per item. No secrets in output.
4. Create / update work items
   - Test cases → type `Test Case`; defects → type `Bug` (fields per devops-policy.md).
   - `POST .../_apis/wit/workitems/${type}?api-version=7.1`
     (Content-Type `application/json-patch+json`).
5. Attach evidence
   - Upload screenshots via `_apis/wit/attachments`, then link to the work item.
6. Link relations
   - Link test cases and bugs to their requirement / UC work items where IDs are known.

## Output (final response)
- Created / updated work item IDs + URLs (test cases and bugs).
- Items skipped as duplicates (with existing IDs).
- Any failures + reason.
- Confirm the PAT was never emitted.
