# Test Data & Roles Policy

Read when a use case is permission/role-sensitive or needs specific data.

## Accounts / Roles Matrix
This is a **multi-user, role-based** system. Each role needs its own test account.

The **role list (rows) is auto-populated by `index-srs`** from the actors named in
the SRS, then you confirm it and add any role the SRS never mentions. `index-srs`
merges — it will not overwrite the account key names or permission notes you fill
in here. Credentials live in the git-ignored `.env` (keys `QA_<ROLE>_USER` /
`QA_<ROLE>_PASS`, loaded at runtime), never in tracked files.
Confirm exact permissions per role with the team (`TBD`); do not assume.

The rows below are seed defaults — `index-srs` will reconcile them with the SRS.

**Admin is the default provisioning / control account.** Create, configure, and clean up
system state and prerequisite data via Admin (it can control anything in the system).
Execute the behaviour under test as the case's role — use Admin only for setup/control.
Seed data **via the API by default** (using the Admin session's auth) whenever an endpoint
exists; fall back to the UI only when there's no usable API. See `execution-policy.md`.

| Role | Account (.env keys) | Permissions / scope | Notes |
|------|-------------------|---------------------|-------|
| Admin | `$env:QA_ADMIN_USER` / `$env:QA_ADMIN_PASS` | full access (`TBD - confirm`) | |
| Manager | `$env:QA_MANAGER_USER` / `$env:QA_MANAGER_PASS` | `TBD - confirm` | |
| Supervisor | `$env:QA_SUPERVISOR_USER` / `$env:QA_SUPERVISOR_PASS` | `TBD - confirm` | |
| Viewer | `$env:QA_VIEWER_USER` / `$env:QA_VIEWER_PASS` | read-only (`TBD - confirm`) | |
| _add others_ | `$env:QA_<ROLE>_USER` / `..._PASS` | `TBD` | |

## Seed / Test Data
- Source of test data: `TBD - needs team confirmation`
- Declare the exact data a test needs in the test case "Test data" field.
- No real PII — use synthetic data only.

## Data Lifecycle
- Create only what the test needs; prefer reversible actions.
- Clean up created data when feasible; record anything left behind in the run report.
- Never run destructive data operations on shared environments unless
  `context.md` authorizes it.

## Permissions / Negative Access (role-based)
For every permission-sensitive use case, cover the role matrix, not just the happy
path:
- **Positive** — each role that SHOULD perform the action can (e.g. Admin/Manager).
- **Denied** — each role that should NOT can't, and is blocked cleanly (e.g. Viewer
  cannot edit/delete; Supervisor cannot access Admin-only screens).
- **UI vs API** — a control hidden in the UI is not proof of enforcement; where
  feasible, confirm the action is actually rejected, not just hidden.
- Treat a missing/broken access check (a role doing what it must not) as a
  **security defect** — high severity (see `defect-policy.md`).
- If the SRS does not state which roles may perform a use case, mark it
  `TBD - needs team confirmation` rather than guessing the permission.
