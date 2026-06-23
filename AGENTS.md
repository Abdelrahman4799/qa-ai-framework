# Project QA Instructions

This repository uses a repo-based AI QA Framework for **requirements-driven,
black-box testing**.

The AI does NOT have application source code. It tests the RUNNING application
through the **Playwright MCP**, using the **SRS** (existing baseline) and the
**new-feature SRS** as the source of truth for expected behavior.

The unit of work is a **single chosen use case** — never generate tests for the
whole SRS.

## Default Reading

Before any task, read:

- `docs/ai/context.md`
- `docs/ai/handoff.md` (where the last session left off — small, always read)

Read extra docs only when relevant:

- Building the use-case index of the baseline SRS → `docs/ai/srs/_index.md` (+ the SRS files)
- Generating test cases for a use case → `docs/ai/test-case-standards.md` + the chosen UC's section
- Executing tests in the app → `docs/ai/execution-policy.md`
- Permissions / roles / test data → `docs/ai/test-data-policy.md` + `docs/ai/permission-matrix.md`
- Coverage dimensions to walk → `docs/ai/coverage-dimensions.md`
- How to derive strong cases (techniques) → `docs/ai/test-design-techniques.md`
- System model to traverse (UCs · entities · states · routes · API) → `docs/ai/system-graph.md`
- Rulings not in the SRS (BA Q&A) → `docs/ai/decisions.md`
- Deep / compound prerequisite states → `docs/ai/test-fixtures.md`
- App navigation / known UI behavior → `docs/ai/app-map.md`
- Logging a bug → `docs/ai/defect-policy.md`
- Uploading to Azure DevOps → `docs/ai/devops-policy.md`
- Unclear domain terms → `docs/ai/glossary.md`

Do NOT read all docs by default. Do NOT read the whole SRS. To find a
requirement, read the small `_index.md` files and then only the **section** of
the use case in scope.

## Skills (the pipeline)

Use only the relevant skill:

- Guided onboarding (fill the config TBDs one by one) → `.claude/skills/setup-wizard/SKILL.md`
- Health-check the framework setup → `.claude/skills/doctor/SKILL.md`
- Ingest a Word (.docx) SRS → split into per-use-case files → `.claude/skills/ingest-srs/SKILL.md`
- Build the use-case index (once per baseline) → `.claude/skills/index-srs/SKILL.md`
- Generate test cases for a chosen use case → `.claude/skills/generate-test-cases/SKILL.md`
- Execute test cases in the app → `.claude/skills/execute-test-cases/SKILL.md`
- Session-based exploratory testing → `.claude/skills/exploratory-charter/SKILL.md`
- Report requirement/use-case coverage → `.claude/skills/coverage-report/SKILL.md`
- Triage / log a defect → `.claude/skills/triage-defect/SKILL.md`
- Review results before upload → `.claude/skills/review-results/SKILL.md`
- Upload to Azure DevOps → `.claude/skills/upload-to-devops/SKILL.md`
- Propose & apply an approved improvement to the framework → `.claude/skills/self-heal/SKILL.md`
- Save session history at the end of a session → `.claude/skills/save-session/SKILL.md`

## Work Rules

- Source of truth is the SRS + new-feature SRS. If the app contradicts them,
  that is a POTENTIAL DEFECT — not the new expected behavior.
- Scope every task to the **chosen use case** plus the related use cases you have
  confirmed with the user. Do not silently widen or narrow scope.
- **Understand before generating:** model the chosen use case AND its confirmed related
  use cases thoroughly — actors, main/alternate/exception flows, business rules, data
  states, and cross-UC interactions — then cover **all** scenarios across every
  applicable coverage dimension (`coverage-dimensions.md`). Never stop at the happy path.
- **Cover every SRS statement:** treat each sentence/clause in the UC section as a
  testable item — map it to a case or mark it explicitly N/A. Ignore nothing.
- **Design strong cases, not shallow ones:** apply test-design techniques
  (`test-design-techniques.md`) — equivalence partitioning, boundary analysis, decision
  tables, state-transition, pairwise — with concrete values and a precise expected
  result/oracle. Cover negative/invalid scenarios **where applicable** (each asserting its
  exact error/handling; mark N/A with a reason when one can't occur). The `/goal` loop
  critiques adversarially; never declare strong coverage you didn't actually reach.
- **Link new-feature ↔ baseline:** always link a new-feature use case to its related /
  likely-impacted baseline test cases (persist in traceability; carried into DevOps).
- **Test data prep may use the API** when it is faster/available; the behavior under
  test is still exercised through the UI unless the case is itself an API test.
- **Parallel execution:** ask the user how many runners to use; only parallelise
  independent cases and isolate each runner's session/account/data.
- Never invent requirements. If expected behavior is unclear, missing, or
  contradictory, mark it `TBD - needs team confirmation` and do not guess pass/fail.
- Every test case must trace to a use-case ID (UC-###) and/or requirement ID.
- Do not modify the application, its data, or environment beyond what a test step
  requires. Prefer read-only / reversible actions.
- Never use real PII or production credentials. Test data and test accounts only.
- **Create the data a case needs rather than blocking:** provision/control via the
  **Admin** account, **seed via the API by default** (UI only when no usable API exists),
  assume synthetic values for unspecified inputs (mobile, email…), and create/reference
  real entities for fields that must pre-exist. Perform the
  behaviour under test as the case's role. BLOCKED only when even Admin can't (external
  system / missing capability / irreversible real-world action). Never fabricate the
  expected *result* — only input *values*.
- Capture evidence (screenshot + observed result) for every step that asserts
  behavior.
- **Fresh data every run:** create this run's own data with a unique per-run tag
  (`QA_<runid>_`); never reuse or depend on data from a previous run. Fixtures are the
  deliberate persistent exception.
- Do not upload anything to DevOps until results pass the review gate.
- Never expose the DevOps PAT, secrets, or credentials in output, logs, or work items.

## First Run / Onboarding

- A SessionStart check injects a note when setup is incomplete (config `TBD`s left
  or `AZURE_DEVOPS_PAT` unset). When you see it, OFFER to run the **setup-wizard**
  skill: ask the user for each `TBD` one at a time and update the config files.
  Put credentials in the git-ignored `.env` (loaded at runtime), never in tracked files.

## Session History

- At the START of a session, read `docs/ai/handoff.md` to resume where the last
  session left off. Open a specific `sessions/SESSION-*.md` only if you need the
  full detail of a past session.
- At the END of a session (or when asked to "save the session"), run the
  save-session skill: append a full record to `sessions/` and overwrite
  `docs/ai/handoff.md`.
- Do not duplicate structured data (test cases, runs, traceability,
  improvements-log) — record the decision/conversational layer and link the rest.

## Self-Healing (Continuous Improvement)

- During any stage, if you find a better rule, a gap, a recurring workaround, or
  an enhancement to how the framework operates, you SHOULD propose it.
- Propose — never silently change. Apply ONLY after explicit user approval.
- Do not interrupt the current task to edit framework files. Collect proposals and
  present them at a natural checkpoint (end of stage / end of run) with a
  before→after diff, the reason, and a safety check.
- You MAY improve: this file, `CLAUDE.md`, the methodology policies
  (`test-case-standards.md`, `execution-policy.md`, `defect-policy.md`,
  `glossary.md`), and the skills in `.claude/skills/`.
- You MUST NOT self-edit: SRS content / requirements (owned by the team) or the
  user's project config (`context.md`, `devops-policy.md`).
- You MUST NEVER weaken a safety rule (review gate, no real PII, no PAT exposure,
  no production testing) via self-heal. Those may only be tightened.
- Every approved change is recorded in `docs/ai/improvements-log.md`.
- Edits to governed framework files are blocked by the `guard_selfheal` hook
  unless `.qa-state/improvement-approved.json` exists. Use the self-heal skill.

## Test Data & Environment

- Use only the environment(s) named in `docs/ai/context.md`. Never production.
- Do not run destructive tests on shared environments unless `context.md`
  explicitly authorizes it.

## Final Response

Always include:

- Scope (chosen UC + confirmed related UCs)
- Test cases generated or updated (IDs)
- Tests executed: pass / fail / blocked, with evidence references
- Defects found (ID, title, severity)
- Review status (passed gate? what is pending)
- DevOps work items created/updated (IDs + links), or "not uploaded — reason"
- Coverage gaps / untested risk / open TBDs
