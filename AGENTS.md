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
- Report requirement/use-case coverage → `.claude/skills/coverage-report/SKILL.md`
- Triage / log a defect → `.claude/skills/triage-defect/SKILL.md`
- Review results before upload → `.claude/skills/review-results/SKILL.md`
- Upload to Azure DevOps → `.claude/skills/upload-to-devops/SKILL.md`
- Promote an accepted new use case into the baseline SRS → `.claude/skills/promote-to-srs/SKILL.md`
- Propose & apply an approved improvement to the framework → `.claude/skills/self-heal/SKILL.md`
- Save session history at the end of a session → `.claude/skills/save-session/SKILL.md`

## Work Rules

- Source of truth is the SRS + new-feature SRS. If the app contradicts them,
  that is a POTENTIAL DEFECT — not the new expected behavior.
- Scope every task to the **chosen use case** plus the related use cases you have
  confirmed with the user. Do not silently widen or narrow scope.
- Never invent requirements. If expected behavior is unclear, missing, or
  contradictory, mark it `TBD - needs team confirmation` and do not guess pass/fail.
- Every test case must trace to a use-case ID (UC-###) and/or requirement ID.
- Do not modify the application, its data, or environment beyond what a test step
  requires. Prefer read-only / reversible actions.
- Never use real PII or production credentials. Test data and test accounts only.
- Capture evidence (screenshot + observed result) for every step that asserts
  behavior.
- Do not upload anything to DevOps until results pass the review gate.
- Never expose the DevOps PAT, secrets, or credentials in output, logs, or work items.

## First Run / Onboarding

- A SessionStart check injects a note when setup is incomplete (config `TBD`s left
  or `AZURE_DEVOPS_PAT` unset). When you see it, OFFER to run the **setup-wizard**
  skill: ask the user for each `TBD` one at a time and update the config files.
  Never write secrets into repo files — guide env-var setup separately.

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
- You MUST NOT self-edit: SRS content / requirements (use promote-to-srs) or the
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
