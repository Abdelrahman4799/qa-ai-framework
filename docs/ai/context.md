# Project Context (Always Read First)

Keep this short. It is the only doc read on every task.

## Product
- Name: `TBD - needs team confirmation`
- What it does (2-3 lines): `TBD`
- Primary users / roles: multi-role system — Admin, Manager, Supervisor, Viewer
  (+ others `TBD`). Permissions per role: see `docs/ai/test-data-policy.md`.

## Application Under Test
- App type: Web (tested black-box via the Playwright MCP)
- Environments (use ONLY these):
  - Test/QA URL: `TBD`
  - Staging URL: `TBD` (only if a task explicitly authorizes it)
- DO NOT test against production.

## Test Accounts & Data
- One test account PER ROLE, stored in the git-ignored `.env` at the repo root and
  loaded at runtime (`scripts/load_env.ps1`) as `QA_<ROLE>_USER` / `QA_<ROLE>_PASS`.
  Copy `.env.example` to `.env` to start. See the role matrix in
  `docs/ai/test-data-policy.md`. Never store credentials in tracked files.
- Test data rules: no real PII. See `docs/ai/execution-policy.md`.

## Sources of Truth
- Existing baseline requirements: `docs/ai/srs/` (use-case index: `docs/ai/srs/_index.md`)
- New feature requirements: `docs/ai/new-feature-srs/`
- To find a use case, read the small `_index.md` files — never scan the full SRS.

## Scope & Boundaries
- Unit of work: a single chosen use case + its confirmed related use cases.
- In scope: functional black-box testing of the chosen use case.
- Out of scope (unless explicitly authorized): destructive tests on shared
  environments, performance/load, security penetration.
- Test data: the AI creates whatever data a case needs to avoid BLOCKED — provisioning
  and system control done via the **Admin** account; unspecified input values (mobile,
  email…) are assumed as synthetic, tagged `QA_<runid>_`, on test/staging only (never
  production), and recorded as residue. BLOCKED only when even Admin can't (external /
  irreversible real-world). Set to `no` to forbid provisioning: `provisioning = yes`

## Review Gate
- Default: HUMAN approval required before any DevOps upload.
- Set to `auto` here ONLY if the team accepts automated approval: `human`

## DevOps
- See `docs/ai/devops-policy.md` for the Azure DevOps target and upload rules.
