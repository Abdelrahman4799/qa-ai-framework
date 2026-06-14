# Coverage Dimensions

The dimensions every use case should be **considered against** during
`generate-test-cases`. Walking this list prevents whole categories being silently
skipped. Not every dimension applies to every UC — for each, record
**Covered / N/A (one-line reason) / Gap** so omissions are *visible* (see
`coverage-report`), never silent.

## Core (almost always)
1. **Functional / happy path** — the primary success flow per the SRS.
2. **Negative / invalid input** — bad values, missing required fields, wrong format.
3. **Boundary / edge** — min/max, empty, zero, very long, limits.
4. **Permission / RBAC** — each allowed role can; each disallowed role is blocked
   (positive + denied; see `permission-matrix.md`).

## Interaction & state
5. **Cross-feature integration** — effects on related use cases / downstream data.
6. **Concurrency / multi-session** — two users/sessions acting at once: record
   pick-lock, first-wins, concurrent create/edit of the same record. See
   `execution-policy.md` → Multi-session.
7. **List operations** — search, sort, filter, reset, pagination, empty-state.
8. **Soft-delete & confirmation** — delete asks for confirmation; soft-deleted items
   behave per the SRS (hidden / restorable).
9. **Audit log** — actions that should be recorded are captured (who / what / when),
   if the product has auditing.

## Non-functional UI (when the app has these)
10. **Localization & direction** — each supported language + RTL/LTR layout flip;
    bilingual data renders correctly under either UI (e.g. native-script vs latin
    names). **First-class when the app is multilingual.**
11. **Theme** — dark / light (and high-contrast if present); layout intact in each.
12. **Accessibility (basic)** — keyboard navigation, labels, colour contrast.

## How to use
- `generate-test-cases` walks this list for each UC and records, per dimension,
  Covered / N/A+reason / Gap.
- `coverage-report` renders the per-UC × per-dimension grid so gaps are visible.
- Add product-specific dimensions here as they recur.
