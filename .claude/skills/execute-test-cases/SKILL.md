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
     precondition). If a prerequisite FAILED or is BLOCKED, mark the dependent
     case BLOCKED (don't test on a broken precondition). Stop following a chain at
     a `TBD`/circular edge and report it.
   - Create a run folder: `.qa-state/runs/<runid>/`.
2. For each test case (chosen UC cases, then regression set)
   - Bring the app to the precondition state via Playwright MCP.
   - Execute steps exactly as written, one action per step.
   - For each asserting step: capture a screenshot + observed result;
     mark PASS / FAIL / BLOCKED.
   - On a timing-looking failure: re-confirm state and retry the step ONCE.
     Passed on retry → FLAKY (record both attempts); failed again → FAIL.
     (See Flaky Handling in execution-policy.md.)
   - On FAIL: capture URL + visible error + observed-vs-expected.
3. Record results
   - Write a result record per case into the run folder
     (TC ID, status, evidence paths, notes).
4. Summarize + write the run report
   - Totals (pass / fail / blocked / flaky), the list of FAILs (→ triage-defect),
     FLAKY cases (human attention), and BLOCKED reasons.
   - Write `.qa-state/runs/<runid>/RUN-REPORT.md` per execution-policy.md.

## Rules
- Do not modify the app or skip steps to force a pass.
- Use only test data/accounts; no real PII; reversible actions on shared envs.

## Output
- Run summary + per-case results + evidence references.
- Do NOT upload — FAILs go to triage-defect, then review-results, then upload.
