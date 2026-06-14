# Improvements Log

Audit trail of self-heal changes to the framework. Appended by the **self-heal**
skill after each approved improvement. Newest first.

| Date | Files | Summary | Reason | Approved by |
|------|-------|---------|--------|-------------|
| 2026-06-14 | test-fixtures.md (new) · generate-test-cases · execute-test-cases | Fixtures policy: named pre-seeded prerequisite states; generation references & tags them, execution asserts presence → BLOCKED if missing | Cases needing deep/irreversible state couldn't be built live during a run | Isadora |
| 2026-06-14 | execution-policy.md · execute-test-cases | Hardening: create-your-own / never-mutate-others' records, `QA_<runid>` naming, residue log, INCONCLUSIVE state + verification fallback | A safety case required not mutating shared records; lazy dropdowns / non-refreshing lists prevented confirming state | Isadora |
| 2026-06-14 | app-map.md (new) | Per-project app navigation + known-UI-behavior map | Navigation / role / behavior was being re-derived by trial and error | Isadora |
| 2026-06-14 | generate-test-cases · test-case-standards.md | Precondition-feasibility tagging (self-serviceable / needs-fixture / needs-config / needs-live-action) | Blocked-by-design cases weren't visible before execution | Isadora |
