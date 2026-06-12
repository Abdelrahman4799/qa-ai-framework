# Execution Policy (Playwright MCP)

How to execute test cases against the running app via the Playwright MCP.

## Before Execution
- Confirm the target environment matches `docs/ai/context.md`. NEVER production.
- Load the test case(s) and required test data / accounts (from `.env` via
  `scripts/load_env.ps1`).
- Start from a known clean state (logged out / known landing page).
- Create a run folder: `.qa-state/runs/<runid>/`.

## During Execution
- Execute steps exactly as written. Do not "fix" the app or skip a failing step.
- For each asserting step, capture EVIDENCE:
  - Screenshot (Playwright MCP) saved into the run folder
  - Observed result (text)
  - Status: PASS / FAIL / BLOCKED
- On FAIL: also capture current URL + any visible error, then continue with the
  remaining independent steps where safe.

## Result States
- PASS — observed == expected
- FAIL — observed != expected (candidate defect → triage-defect skill)
- BLOCKED — could not execute (precondition / environment / data issue)
- FLAKY — failed then passed on a single controlled retry (see Flaky Handling)

## Flaky Handling
- Use explicit waits for elements/conditions; do NOT rely on fixed sleeps.
- If a step fails on what looks like timing (element not ready, transient
  network), re-confirm state and retry that single step ONCE.
- Passed on retry → mark the case FLAKY (not PASS, not FAIL); record both attempts.
- Failed again → it is a FAIL (candidate defect).
- Never retry more than once automatically. Never retry to "force" a pass on a
  real failure.
- Report FLAKY cases separately — they need human attention, not a bug report by
  default.

## Data & Safety
- Use only designated test accounts / data. No real PII.
- Prefer read-only / reversible actions. No destructive actions on shared
  environments unless `context.md` authorizes it.
- Clean up created test data when feasible; note anything left behind.

## Evidence Storage
- All run artifacts under `.qa-state/runs/<runid>/` (screenshots + result log).
- One result record per test case: TC ID, status, evidence path(s),
  observed vs expected, notes.

## Run Report
- Write a human-readable `RUN-REPORT.md` into `.qa-state/runs/<runid>/`:
  - Date, environment, app URL, scope (UC + regression)
  - Totals: PASS / FAIL / BLOCKED / FLAKY
  - Failures: TC — observed vs expected — evidence path
  - Flaky: TC — both attempts
  - Blocked: TC — reason
  - Evidence folder path

## Output
- The `RUN-REPORT.md` path + a run summary (counts), per-case results, evidence
  refs, and the list of FAILs to feed into triage-defect.
