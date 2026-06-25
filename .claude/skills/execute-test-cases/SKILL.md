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
   - PARALLELISM: ask the user how many parallel runners to use (default 1). Partition
     only independent cases across runners; keep dependency chains / shared-fixture /
     same-record cases together; isolate each runner by its own browser context/profile
     (NOT a separate account — the same role account can be reused) plus a
     `QA_<runid>_r<N>_` data tag. See "Parallel execution" in execution-policy.md.
   - Load credentials: dot-source `scripts/load_env.ps1` so each role's
     `QA_<ROLE>_USER` / `QA_<ROLE>_PASS` (from `.env`) is available; log in as the
     role each test case specifies (log out/in to switch roles; for concurrency cases
     drive a second session — see "Role switching" / "Multi-session" in execution-policy.md
     and the login path in app-map.md).
   - ORDER by dependency: from the `Depends on` column (and `docs/ai/system-graph.md`),
     run a use case's prerequisite cases BEFORE it (or establish the prerequisite
     end-state). The graph also resolves which entities/APIs to seed and in what order.
     Stop following a chain at a `TBD`/circular edge and report it.
   - FIXTURES: for any case tagged `needs-fixture: <name>`, use the fixture if it exists.
     If it is missing, BUILD the needed state via Admin (standing authorization) rather
     than blocking; only mark BLOCKED if even Admin can't create it.
   - Create a run folder: `.qa-state/runs/<runid>/`. Use a UNIQUE runid (date-time stamp)
     and create FRESH data this run, tagged `QA_<runid>_` — never reuse or depend on data
     from a previous run (fixtures are the persistent exception). See "Fresh data per run".

1b. PREPARE TEST DATA (fresh) — AUTOMATIC, before executing any case
   - Do this WITHOUT being asked — seeding is a default part of every execution run, not an
     on-request action. Never wait for the user to tell you to seed.
   - Scan all in-scope cases' "Test Data Preparation", `needs-fixture` / `needs-config`,
     and reference data. For each required datum:
       · fixture exists → reuse it;
       · else CREATE it FRESH this run — API by default (else Admin/UI) — tagged
         `QA_<runid>_`, assuming synthetic input values.
   - Do NOT pre-create the data a test must create as its OWN action-under-test — only
     prerequisites and reference data. (Lazy provisioning in step 2 still covers anything
     discovered missing mid-run.)
   - Write a DATA MANIFEST to `.qa-state/runs/<runid>/data-manifest.md`: each datum created
     (id/tag), which case(s) it serves, and anything that could NOT be created → mark those
     cases BLOCKED now (fail fast) or flag `needs-live-action` for confirmation.
   - Parallel runners start from this prepared, isolated data.

2. For each test case (chosen UC cases, then regression set)
   - Bring the app to the precondition state via Playwright MCP.
   - PROVISION to clear blocks (standing authorization — create what's needed):
       · REUSE only THIS RUN's own created data: check the data manifest (step 1b) /
         `QA_<runid>_` items and create only what's still missing or discovered at runtime —
         don't re-create what pre-prep already made. NEVER reuse pre-existing system records
         or prior-run data — always create new (see "Always create new data").
       · Use ADMIN to create/configure prerequisite data & state. SEED VIA THE API BY
         DEFAULT — for all the data a case needs, when a usable endpoint exists; discover
         endpoints from `docs/ai/api-map.md`; if one is missing, discover it (run map-api
         or observe the network calls), seed with it, and add it to `api-map.md`. Reuse the
         Admin session's auth. Fall back to the UI only when there's no usable API. For
         references that must pre-exist, create the entity via Admin or use a fixture.
       · ASSUME realistic synthetic values for any unspecified input (mobile, email,
         name…), tagged `QA_<runid>_` (plain alphanumeric where special chars are
         rejected). No real PII.
       · Perform the behaviour UNDER TEST as the case's role — not Admin.
       · BLOCKED only if even Admin can't create it (external system / missing capability /
         irreversible real-world action — `needs-live-action`; flag for confirmation).
     Record what you created (residue). See "Test Data Provisioning" in execution-policy.md.
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
4. Record results — STEP LEVEL
   - The test cases are step-per-row CSV. Per STEP, fill the execution columns:
     `Actual Result`, `Step Status` (PASS/FAIL/BLOCKED/INCONCLUSIVE), `Failure Notes`
     (reason if not PASS), with evidence path; set `Overall TC Status` on the case's first
     row. Save the executed copy under `.qa-state/runs/<runid>/`.
   - This pinpoints WHICH step failed, not just the case.
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
