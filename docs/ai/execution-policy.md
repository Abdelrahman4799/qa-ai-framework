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
- BLOCKED — could not execute even after creating data/state as Admin: it needs an
  external system, a capability no role has, or an irreversible real-world action. Name
  exactly what's missing. (Last resort — see Test Data Provisioning.)
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

## Test Data Provisioning (create what's needed — minimise BLOCKED)
Standing authorization: **create the data and state a case needs rather than blocking.**
- **Control/setup as ADMIN:** by default use the Admin account to create, configure, and
  clean up prerequisite data and system state (Admin can control anything in the system).
  Perform the behaviour UNDER TEST as the role the case specifies — e.g. a "Viewer cannot
  delete" case still attempts the delete **as Viewer**; only the setup is done as Admin.
- **Assume input VALUES:** for any unspecified free-input field (mobile number, email,
  name, address, description…), generate a realistic SYNTHETIC value — never block for want
  of an input value. Tag created data `QA_<runid>_`; no real PII; use safe test ranges
  (reserved test phone numbers / test email domains).
- **References must exist:** for a field that must reference an EXISTING entity/option
  (a group, a region, a parent record), do NOT invent a value that may not exist — create
  the entity first (via Admin) or use a fixture, then reference it.
- **Seed via the API by DEFAULT.** Whenever a usable endpoint exists (or can be discovered —
  see below), seed ALL the data a case needs through the API rather than the UI; it's faster
  and more reliable. Fall back to the UI only when there is no usable API for that data. A
  named fixture is still preferred for expensive/irreversible state; if none exists, build
  it via Admin.
- **Use the API map:** seed from `docs/ai/api-map.md` — the reusable endpoint catalog built
  by the **map-api** skill. If an endpoint you need isn't there yet, discover it (run
  map-api, or observe the network calls during the equivalent UI action), seed with it
  (reusing the Admin session's auth — never a hardcoded token), and add it to `api-map.md`
  so future runs reuse it.
- **BLOCKED is a last resort** — only when even Admin cannot create the state: it needs an
  external system, a capability no role has, or a genuinely irreversible real-world action
  (e.g. a real payment, a real message to a real person). Flag `needs-live-action` cases for
  confirmation; everything else, build it.
- Provisioning sets up state; it must NOT fabricate the RESULT under test — the expected
  result still comes from the SRS / a `DEC-###`. (Assume input *values*, never expected
  *outcomes*.)
- Boundaries: only on the environment in `context.md` (never production); tag everything and
  record residue (and anything not cleanly removable) in the run report.

## Pre-execution data preparation
This runs **automatically and unprompted** at the start of every execution run — the agent
seeds required data by default; the user should not have to ask. Before executing any case,
run a data-prep pass that GUARANTEES every in-scope case has its prerequisite/reference
data ready (fresh):
- Scan all cases' Test Data Preparation + `needs-fixture`/`needs-config` + reference data;
  reuse fixtures, else create fresh (API by default), tagged `QA_<runid>_`.
- Only pre-seed prerequisites and reference data — NOT the data a test creates as its own
  action-under-test (lazy provisioning still covers anything found missing mid-run).
- Write a **data manifest** (`.qa-state/runs/<runid>/data-manifest.md`): what was created,
  ids/tags, which case it serves, and anything un-creatable → those cases BLOCKED up front
  (fail fast) or `needs-live-action` flagged.
- Benefits: fail-fast on blockers, efficient batch seeding, and parallel runners start from
  ready, isolated data.

## Always create new data
- **ALWAYS CREATE the data a test needs — never reuse or act on PRE-EXISTING records.** Do
  not pick an existing row from a list, do not use demo/seed data left by others, and do not
  reuse data from a previous run. Create your own.
- Tag everything `QA_<runid>_` with a **unique run id** (date-time stamp) so values never
  collide with earlier runs (important for unique fields — names, emails, codes).
- "Existing data" = anything THIS run did not create. **Reusing data THIS run already
  created** (the data manifest / `QA_<runid>_` items) across its own cases is fine — that's
  still new data, created once this run.
- For a field that references another entity, **create that entity new too** — don't select
  an existing one.
- **Only exception — fixtures:** named deep/irreversible shared state (`test-fixtures.md`).
  Create it fresh where feasible; otherwise reuse the fixture and note it.
- Clean up created data when feasible; record residue.

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

## Parallel execution (runners)
- At the start of a run, **ask the user how many parallel runners** to use (default 1).
- Partition only INDEPENDENT cases across runners. Keep together (same runner / serial):
  cases with a `Depends on` chain, cases sharing a fixture or mutating the same record,
  and ordered steps — so runners don't collide.
- Isolate each runner by its **own browser context / profile** (NOT a separate account)
  plus a per-runner data tag (e.g. `QA_<runid>_r<N>_`) so created data never clashes. The
  SAME role account can be reused across runners — each logs in independently in its own
  isolated context. Stay within the environment's capacity / rate limits.
- Concurrency test cases (multi-session, below) are their own thing — don't conflate
  them with runner parallelism.
- Aggregate all runners' results into one run report; evidence stays under the run folder.

### How to actually run N browsers (Playwright MCP)
- **Same role, multiple pages** → use the MCP tab tools (`browser_tabs`: new / select /
  close). Tabs share ONE browser context (cookies/auth) — fine for parallel pages of the
  SAME login, but NOT for different roles.
- **Different roles / true isolation** → tabs won't work (shared auth). Use either:
  - **Multiple Playwright MCP server instances**, each with its own profile, configured in
    your Claude Code MCP settings, e.g.
    `playwright_admin → npx @playwright/mcp@latest --user-data-dir=<dir-admin>` and
    `playwright_viewer → ... --user-data-dir=<dir-viewer>` (or `--isolated` for an
    ephemeral profile). Each instance = one isolated browser/driver.
  - **Multiple worker subagents**, each with its own browser instance — best for genuine
    concurrency.
- **Reality check:** a single agent issues tool calls SEQUENTIALLY, so multiple tabs/
  contexts driven by one agent are *interleaved* (you save on overlapping waits, not true
  parallelism). Real speedup comes from multiple MCP instances or multiple worker subagents.
- Map **one runner → one MCP instance / subagent (its own browser context/profile) + the
  `QA_<runid>_r<N>_` data tag**. Isolation is per browser context, NOT per account — the
  same role account may be reused across runners (each logs in independently in its own
  context). Use different accounts only if the app forbids concurrent sessions for one user.
  If only one browser/instance is available, fall back to 1 runner and say so — and prefer
  API data prep to recover the time.

## Role switching (login-as)
- To test a case as a given role, log out and log in with that role's account
  (`QA_<ROLE>_USER` / `QA_<ROLE>_PASS` from `.env`). Don't assume a single session
  carries across roles.
- Use the login path and any UI quirks recorded in `docs/ai/app-map.md` (e.g. a menu
  that only renders at a wide viewport) so role coverage isn't re-derived each run.
- Group cases by role where possible to minimise re-logins.

## Multi-session / concurrency
- SUPPORTED for concurrency cases (pick-lock, first-wins, concurrent create/edit of the
  same record). Run a **second independent session** alongside the first, isolated by its
  own **browser context/profile** (or a second Playwright MCP instance) — NOT necessarily a
  second account: use the same user in two sessions, or two different users, as the test
  requires. Tabs in one context share auth, so they won't work for this.
- Drive the sessions in the required ORDER (session A acts → session B acts → assert) and
  read the contended outcome from the persisted state (reload first). A single agent
  interleaves the two sessions in a controlled sequence — fine for orchestrated
  concurrency; true millisecond-level races need genuine parallel workers.
- Use distinct, self-created data; clean up after.

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
  - Data manifest: link to `data-manifest.md` (pre-seeded data + anything un-creatable)
  - Residue: anything left behind or not cleanly removable
  - Evidence folder path

## Output
- The `RUN-REPORT.md` path + a run summary (counts), per-case results, evidence
  refs, and the list of FAILs to feed into triage-defect.
