---
name: doctor
description: Health-check the framework setup before running the pipeline — tooling, secrets, role accounts, config TBDs, SRS index freshness, hooks, and Playwright MCP.
---

# Skill: Doctor (setup health check)

Run a read-only check that the framework is ready, and report what to fix. Use this
before the first run, after setup changes, or when something behaves unexpectedly.

## Steps
1. Run the check script from the repo root:
   ```
   powershell -NoProfile -ExecutionPolicy Bypass -File scripts/doctor.ps1
   ```
2. Add the checks the script cannot do:
   - Confirm the **Playwright MCP** is available in your tools — execution depends on it.
   - Confirm the review-gate mode in `context.md` (`human`/`auto`) matches team intent.
3. Summarize for the user: list FAILs (block the pipeline) and WARNs (should fix), each
   with the exact remediation. Do NOT start the pipeline while any FAIL remains.

## What the script checks
- pandoc + git installed
- `AZURE_DEVOPS_PAT` set (value never printed)
- every role-account env var referenced in `test-data-policy.md` is set
- `context.md` / `devops-policy.md` `TBD`s still to fill
- baseline SRS present, indexed, and not stale
- `settings.json` valid JSON + all 5 hook scripts present

## Output
- A PASS / WARN / FAIL report plus a short, ordered fix list.
