---
name: execute-test-cases
description: Execute a use case's test cases (plus its regression set) against the running app via Playwright MCP, capturing evidence.
---

# Skill: Execute Test Cases

## Inputs
- The test cases for the chosen UC + its regression set (from `test-cases/`).
- `docs/ai/execution-policy.md`, `docs/ai/context.md` (environment + accounts).
- `docs/ai/test-fixtures.md` (named prerequisite states) and `docs/ai/app-map.md`
  (navigation / role / known-UI-behavior map — read to avoid re-deriving it).

## Steps
1. Pre-flight
   - Confirm the target environment from `context.md` (NEVER production).
   - Load credentials: dot-source `scripts/load_env.ps1` so each role's
     `QA_<ROLE>_USER` / `QA_<ROLE>_PASS` (from `.env`) is available; log in as the
     role each test case specifies.
   - ORDER by dependency: from the `Depends on` column, run a use case's
     prerequisite cases BEFORE it (or establish the prerequisite end-state as the
     precondition). Stop following a chain at a `TBD`/circular edge and report it.
   - FIXTURES: for any case tagged `needs-fixture: <name>`, confirm that fixture
     exists and is in the expected state (per `docs/ai/test-fixtures.md`). If it is
     missing, mark the case **BLOCKED — "seed fixture `<name>`"**. Do NOT build deep /
     irreversible prerequisite state live unless the user explicitly authorizes it for
     this run.
   - Create a run folder: `.qa-state/runs/<runid>/`.
2. For each test case (chosen UC cases, then regression set)
   - Bring the app to the precondition state via Playwright MCP.
   - PROVISION by precondition-feasibility (don't just block):
       · `self-serviceable` → CREATE the data before testing — run the prerequisite
         use case's create flow (from `Depends on`) with an allowed role, or create the
         minimal data via the app UI / documented API. SYNTHETIC, tagged `QA_<runid>_`
         (plain alphanumeric where special chars are rejected). No real PII. Then proceed.
       · `needs-fixture` / `needs-config` / `needs-live-action` → do NOT build deep or
         irreversible state live. Require the named fixture (checked at pre-flight); if
         absent, BLOCKED with the fixture/capability name, unless the user authorizes
         building it for this run.
     Record what you created. See "Test Data Provisioning" in execution-policy.md.
   - Execute steps exactly as written, one action per step.
   - For each asserting step: capture a screenshot + observed result;
     mark PASS / FAIL / BLOCKED / INCONCLUSIVE.
   - Confirm create/edit/delete results from the PERSISTED state — many lists do not
     auto-refresh, so reload (or re-sort) before asserting. If the UI cannot confirm the
     expected state, use a reasonable fallback (scroll, `browser_evaluate`, read-only
     API check); otherwise mark INCONCLUSIVE with the reason — never guess PASS.
     (See Verification in execution-policy.md.)
   - On a timing-looking failure: re-confirm state and retry the step ONCE.
     Passed on retry → FLAKY (record both attempts); failed again → FAIL.
     (See Flaky Handling in execution-policy.md.)
   - On FAIL: capture URL + visible error + observed-vs-expected.
3. GOAL LOOP (/goal) — iterate to definitive results
   - GOAL: every in-scope case reaches a definitive PASS or FAIL with evidence;
     BLOCKED is minimised; prerequisites are provisioned; FLAKY is resolved or flagged.
   - ITERATE (max 3 rounds, or stop early when a round resolves nothing new) over every
     case NOT yet at a definitive PASS/FAIL:
     · BLOCKED → provision the missing prerequisite (step 2) and re-run;
     · evidence missing → recapture; transient/timing → apply the one controlled retry;
     · cases that became runnable after provisioning → run them now.
   - Stop when all are definitive or no further progress; report what remains and why.
4. Record results
   - Write a result record per case into the run folder
     (TC ID, status, evidence paths, notes).
5. Summarize + write the run report
   - Totals (pass / fail / blocked / inconclusive / flaky), the list of FAILs
     (→ triage-defect), INCONCLUSIVE + FLAKY cases (human attention), BLOCKED reasons.
   - Write `.qa-state/runs/<runid>/RUN-REPORT.md` per execution-policy.md.

## Rules
- Do not modify the app or skip steps to force a pass.
- Provisioning setup data is allowed; faking the result under test is NOT — the
  assertion's expected result still comes from the SRS.
- Create your own disposable data (prefix `QA_<runid>_`); NEVER edit/delete records you
  did not create. Negative/destructive cases run against self-created data or a fixture.
- Use only test data/accounts; no real PII. Record residue (anything left behind or not
  cleanly removable) in the run report.
- Provision only on the environment named in `context.md` (never production); do not
  run destructive setup on shared envs unless `context.md` authorizes it.

## Output
- Run summary + per-case results + evidence references.
- Do NOT upload — FAILs go to triage-defect, then review-results, then upload.
