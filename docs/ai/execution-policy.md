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
- BLOCKED — could not execute (missing prerequisite/fixture, environment, data, or
  capability). Name the missing fixture/capability — see `docs/ai/test-fixtures.md`.
- INCONCLUSIVE — executed, but the UI could not confirm the expected state (e.g. a
  lazy-loaded dropdown can't prove a value is absent). Record the reason and a suggested
  follow-up check. NEVER record PASS when the state was not actually observed.
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

## Test Data Provisioning (self-setup)
When a test case's precondition isn't met, decide by its precondition-feasibility:
- **Self-serviceable (shallow, reversible):** CREATE it rather than blocking — run the
  prerequisite use case's create flow (from `Depends on`) with a role allowed to create
  it, or create the minimal data through the app UI / a documented API. Use SYNTHETIC,
  tagged values, then re-attempt the case.
- **Deep / irreversible / compound state** (e.g. a parent with dependents, workflow or
  conversion config, an outward/irreversible action): do NOT build it live. Use a named
  fixture from `docs/ai/test-fixtures.md`; if it is missing, mark the case
  **BLOCKED — "seed fixture `<name>`"**. Build such state only when the user explicitly
  authorizes it for the run, and log the residue.
- Provisioning sets up state; it must NOT fabricate the result under test — the expected
  result still comes from the SRS.
- Boundaries: provision only on the environment in `context.md` (never production); no
  destructive setup on shared environments unless `context.md` authorizes it.

## Data & Safety
- Use only designated test accounts / data. No real PII.
- **Create your own disposable test data; never edit or delete records you did not
  create.** Mutating another tester's existing records on a shared environment is not
  allowed. Negative/destructive cases (e.g. "delete is blocked when X exists") must
  target a **self-created record or a named fixture** — never a pre-existing shared one.
- **Naming:** prefix data you create with a run tag, e.g. `QA_<runid>_` (use plain
  alphanumeric such as `QA<runid>` where the field rejects special characters), so it is
  traceable and removable.
- Clean up created/provisioned data when feasible. Record anything left behind — and
  anything **not cleanly removable** — in the run report's residue list.

## Verification (confirming the expected state)
- Confirm results from the actual persisted state, not the un-refreshed UI. Many lists
  do NOT auto-refresh after Add/Update/Delete — **reload (or re-sort) before asserting**.
- When the UI cannot confirm an expected state (e.g. a lazy-loaded dropdown can't prove
  a value is absent; a value is on an unloaded page), try a reasonable alternative:
  scroll to load, a scripted DOM check (Playwright `browser_evaluate`), or a read-only
  network/API check. If still unconfirmable, record **INCONCLUSIVE** with the reason and
  a suggested follow-up — do not guess PASS.
- Consult `docs/ai/app-map.md` first to avoid re-deriving navigation/role/behavior facts.

## Role switching (login-as)
- To test a case as a given role, log out and log in with that role's account
  (`QA_<ROLE>_USER` / `QA_<ROLE>_PASS` from `.env`). Don't assume a single session
  carries across roles.
- Use the login path and any UI quirks recorded in `docs/ai/app-map.md` (e.g. a menu
  that only renders at a wide viewport) so role coverage isn't re-derived each run.
- Group cases by role where possible to minimise re-logins.

## Multi-session / concurrency
- For concurrency cases (pick-lock, first-wins, concurrent create/edit of the same
  record), run a **second independent session** alongside the first — e.g. a separate
  browser profile / incognito / second Playwright context — each logged in as its own
  account.
- Drive the two sessions in the required order and assert the contended outcome from
  the persisted state (reload first). Use distinct, self-created data; clean up after.

## Evidence Storage
- All run artifacts under `.qa-state/runs/<runid>/` (screenshots + result log).
- One result record per test case: TC ID, status, evidence path(s),
  observed vs expected, notes.

## Run Report
- Write a human-readable `RUN-REPORT.md` into `.qa-state/runs/<runid>/`:
  - Date, environment, app URL, scope (UC + regression)
  - Totals: PASS / FAIL / BLOCKED / INCONCLUSIVE / FLAKY
  - Failures: TC — observed vs expected — evidence path
  - Inconclusive: TC — reason the state couldn't be confirmed + suggested follow-up
  - Flaky: TC — both attempts
  - Blocked: TC — reason (missing fixture/capability; what provisioning was attempted)
  - Provisioned data: what was created (tag), where, by which role, cleaned up? (y/n)
  - Residue: anything left behind or not cleanly removable
  - Evidence folder path

## Output
- The `RUN-REPORT.md` path + a run summary (counts), per-case results, evidence
  refs, and the list of FAILs to feed into triage-defect.
