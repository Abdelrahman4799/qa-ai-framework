# Improvements Log

Audit trail of self-heal changes to the framework. Appended by the **self-heal**
skill after each approved improvement. Newest first.

| Date | Files | Summary | Reason | Approved by |
|------|-------|---------|--------|-------------|
| 2026-06-14 | test-fixtures.md (new) · generate-test-cases · execute-test-cases | Fixtures policy: named pre-seeded prerequisite states; generation references & tags them, execution asserts presence → BLOCKED if missing | Cases needing deep/irreversible state couldn't be built live during a run | Isadora |
| 2026-06-14 | execution-policy.md · execute-test-cases | Hardening: create-your-own / never-mutate-others' records, `QA_<runid>` naming, residue log, INCONCLUSIVE state + verification fallback | A safety case required not mutating shared records; lazy dropdowns / non-refreshing lists prevented confirming state | Isadora |
| 2026-06-14 | app-map.md (new) | Per-project app navigation + known-UI-behavior map | Navigation / role / behavior was being re-derived by trial and error | Isadora |
| 2026-06-14 | generate-test-cases · test-case-standards.md | Precondition-feasibility tagging (self-serviceable / needs-fixture / needs-config / needs-live-action) | Blocked-by-design cases weren't visible before execution | Isadora |
| 2026-06-14 | coverage-dimensions.md (new) · generate-test-cases · coverage-report | Coverage-dimensions checklist (incl. concurrency, list-ops, soft-delete, audit, localization/RTL, theme, a11y) walked per UC; coverage report shows per-dimension matrix | Only functional/negative/boundary/permission were considered; 6+ dimensions silently skipped | Isadora |
| 2026-06-14 | decisions.md (new) · test-case-standards.md · traceability.md | Decisions/clarifications log (DEC-###) as a source of truth alongside the SRS; cases trace to DEC | BA rulings not in the SRS had no home, so valid cases were blocked as "unstated" | Isadora |
| 2026-06-14 | test-case-standards.md · generate-test-cases | Test Data Preparation field (explicit build/nav paths, no dummy values) + validation consolidation + REQ-ID policy when SRS has none | Cases invented dummy values, duplicated per-field, and lacked traceability | Isadora |
| 2026-06-14 | execution-policy.md · execute-test-cases · app-map.md | Role-switch (login-as) procedure + multi-session/concurrency guidance | Role coverage and concurrency runs were re-derived each time | Isadora |
| 2026-06-14 | defect-policy.md · triage-defect | Non-functional defect classes: silent blocked action / missing user feedback, localization/RTL, theme/a11y, audit gap | A correctly-blocked action with no user message wasn't being captured as a defect | Isadora |
| 2026-06-23 | system-graph.md (new) · index-srs · generate-test-cases · execute-test-cases | System graph (typed edges: UC/role/entity/state/route/API) built at indexing and traversed for discovery, provisioning order, and impact | Relationships were re-derived from scattered files each run, hurting accuracy | Isadora |
