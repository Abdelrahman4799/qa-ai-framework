# Azure DevOps Policy (Upload via REST + PAT)

## Connection
- Organization URL: `https://dev.azure.com/<org>`   `TBD - confirm`
- Project: `TBD - confirm`
- Area Path: `TBD`
- Iteration Path: `TBD`
- API version: `7.1`

## Authentication
- The PAT is read from the environment variable `AZURE_DEVOPS_PAT` at runtime.
- NEVER hardcode, echo, log, or paste the PAT. (Enforced by the scan_secrets hook.)
- Auth header is Basic with `":<PAT>"` base64-encoded, built at runtime from the
  env var.
- Required PAT scopes: Work Items (Read & Write); Test Management (Read & Write)
  if using Test Plans.

## What Gets Uploaded
- Test cases → work item type **Test Case**
  - Fields: `System.Title`, `System.AreaPath`, `System.IterationPath`,
    steps (`Microsoft.VSTS.TCM.Steps`), links to the requirement/UC work items.
- Defects → work item type **Bug**
  - Fields: `System.Title`, `Microsoft.VSTS.Common.Severity`, `System.AreaPath`,
    repro steps (`Microsoft.VSTS.TCM.ReproSteps`), `System.Description`,
    evidence attachments.

## Endpoints (API 7.1)
- Create work item:
  `POST {org}/{project}/_apis/wit/workitems/${type}?api-version=7.1`
  Content-Type: `application/json-patch+json`
  Body: JSON Patch array of `{"op":"add","path":"/fields/<field>","value":...}`
- Attach evidence:
  `POST {org}/{project}/_apis/wit/attachments?fileName=...&api-version=7.1`
  then link the returned URL to the work item.
- Find existing (de-dup) via WIQL:
  `POST {org}/{project}/_apis/wit/wiql?api-version=7.1`
- Link work items (test case ↔ requirement/bug): use `relations` in the patch body.

## Upload Rules (hard-gated)
- Do NOT upload until `.qa-state/review-passed.json` exists (review gate).
  (Enforced by the guard_upload hook.)
- Idempotency: before creating, WIQL-query for an existing work item with the
  same TC ID / defect title; update instead of duplicating.
- Dry-run first: print the exact payload(s) and target fields, then create.
- After upload: report created/updated work item IDs + URLs.
