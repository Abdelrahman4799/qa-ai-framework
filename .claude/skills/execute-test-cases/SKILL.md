---
name: execute-test-cases
description: Execute a use case's test cases (plus its regression set) against the running app via Playwright MCP, capturing evidence.
---

# Skill: Execute Test Cases

## Inputs
- The test cases for the chosen UC + its regression set (from `test-cases/`).
- `docs/ai/execution-policy.md`, `docs/ai/context.md` (environment + accounts).

## Steps
1. Pre-flight
   - Confirm the target environment from `context.md` (NEVER production).
   - Load credentials: dot-source `scripts/load_env.ps1` so each role's
     `QA_<ROLE>_USER` / `QA_<ROLE>_PASS` (from `.env`) is available; log in as the
     role each test case specifies.
   - ORDER by dependency: from the `Depends on` column, run a use case's
     prerequisite cases BEFORE it (or establish the prerequisite end-state as the
     precondition). Stop following a chain at a `TBD`/circular edge and report it.
   - Create a run folder: `.qa-state/runs/<runid>/`.
2. For each test case (chosen UC cases, then regression set)
   - Bring the app to the precondition state via Playwright MCP.
   - PROVISION missing prerequisites/data (don't just block): if a precondition is
     not met or required data is missing, CREATE it before testing —
       · preferred: run the prerequisite use case's create flow (from `Depends on`)
         using the role that is allowed to create it;
       · otherwise create the minimal data directly through the app UI (or a
         documented API), using SYNTHETIC, clearly tagged values
         (e.g. prefix `QA-<runid>-`). No real PII.
     Record what you created, then proceed with the test case.
     Only mark BLOCKED if provisioning is genuinely impossible (no create path, needs
     a privilege no available role has, or the requirement is ambiguous → `TBD`).
     See "Test Data Provisioning" in execution-policy.md for limits.
   - Execute steps exactly as written, one action per step.
   - For each asserting step: capture a screenshot + observed result;
     mark PASS / FAIL / BLOCKED.
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
   - Totals (pass / fail / blocked / flaky), the list of FAILs (→ triage-defect),
     FLAKY cases (human attention), and BLOCKED reasons.
   - Write `.qa-state/runs/<runid>/RUN-REPORT.md` per execution-policy.md.

## Rules
- Do not modify the app or skip steps to force a pass.
- Provisioning setup data is allowed; faking the result under test is NOT — the
  assertion's expected result still comes from the SRS.
- Use only test data/accounts; no real PII; tag created data and clean it up when
  feasible (note anything left behind in the run report).
- Provision only on the environment named in `context.md` (never production); do not
  run destructive setup on shared envs unless `context.md` authorizes it.

## Output
- Run summary + per-case results + evidence references.
- Do NOT upload — FAILs go to triage-defect, then review-results, then upload.
