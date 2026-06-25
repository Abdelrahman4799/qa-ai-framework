# Coverage Dimensions

The dimensions every use case should be **considered against** during
`generate-test-cases`. Walking this list prevents whole categories being silently
skipped. Not every dimension applies to every UC — for each, record
**Covered / N/A (one-line reason) / Gap** so omissions are *visible* (see
`coverage-report`), never silent.

## Core (almost always)
1. **Functional / happy path** — the primary success flow per the SRS.
2. **Negative / invalid input** — where applicable, cover the failure side of each input,
   action, and rule, each with its **expected error / handling** as the oracle:
   · missing required field · empty / whitespace / null
   · wrong type or format · out of range / too long / too small
   · duplicate / already-exists · invalid reference (deleted / non-existent)
   · unauthorized role / forbidden action · wrong entity state for the action
   · cancel / abort / back / double-submit · expired / stale / timeout
   · malformed or unexpected input (incl. special chars)
   Cover the negatives that apply; mark a negative N/A (with a reason) when it genuinely
   can't occur. As a rule of thumb a positive case usually needs its negative counterpart.
3. **Boundary / edge** — min/max, empty, zero, very long, limits.
4. **Permission / RBAC** — each allowed role can; each disallowed role is blocked
   (positive + denied; see `permission-matrix.md`).

## Interaction & state
5. **Cross-feature integration** — effects on related use cases / downstream data.
6. **Concurrency / multi-session** — two users/sessions acting at once: record
   pick-lock, first-wins, concurrent create/edit of the same record. See
   `execution-policy.md` → Multi-session.
7. **Search / sort / filter / pagination** — for any list or grid:
   · **Search:** exact · partial · no-match (empty state) · case-insensitive · diacritics /
     accents · Arabic vs Latin script · special characters · leading/trailing spaces · very
     long query · (injection-ish input rejected safely).
   · **Sort:** each sortable column ascending + descending · locale-aware order (e.g. Arabic) ·
     numbers sorted numerically (not as text) · nulls/blanks placement · stable/secondary sort.
   · **Filter:** single filter · combined filters · clear / reset · no-results state · filter
     persists across pagination and navigation.
   · **Pagination:** page size, next / prev / first / last, and the result **count stays
     accurate** after a search or filter.
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

## Behavioral & resilience (where applicable)
13. **Delegation / on-behalf-of** — if a user can act as a proxy for another role, test the
    delegated action works and the **audit log records "on behalf of"** the principal.
14. **Navigation & unsaved state** — cancel/discard, navigate-away with an **unsaved-changes
    warning**, submit/save with no changes, browser back, close tab, session timeout.
15. **Page redirection** — verify **where the user lands** after each action (save / submit /
    cancel / delete).
16. **Data persistence** — data survives a language switch, theme change, preview-and-return,
    a validation error, and uploaded files are kept before final save.
17. **Error recovery** — network / server / upload failure mid-action, and retry afterwards.

## Per-action verification checklist
For each action a use case offers (save, submit, approve, delete…), verify all that apply:
confirmation dialog → **exact** success/error message (per language) → status transition →
**audit-log entry** → **page redirection**. These are the items most often skipped.

## Per-page completeness (test EVERY element on each page)
For each page/screen the use case touches, **enumerate ALL UI elements** and test each —
don't cover only the happy-path controls:
- every **field** (input, dropdown, date/time, file, toggle, radio, checkbox) — value,
  validation, default, enabled/disabled
- every **button / link / icon / menu / tab** — action it triggers + disabled states
- **labels & messages** (per language), tooltips, placeholders, required markers
- table/list controls (sort, filter, paging, row actions, empty state)
- page-level: title, breadcrumbs, back, help, and any role-conditional elements
Use the live page (Playwright) and `app-map.md` to enumerate; flag elements the SRS
doesn't describe as `TBD` rather than skipping them.

## Case complexity (beyond the simple/sample cases)
Alongside the simple atomic cases, design **complex / composite** cases:
- full **end-to-end journeys** (multi-step, across pages, to a real outcome)
- **combined conditions** via decision tables (several rules interacting at once)
- **interacting fields/parameters** via pairwise (e.g. role × type × state × language)
- **realistic data combinations** and sequences (not just one field at a time)
- **cross-feature** flows where this use case feeds or depends on others
The sample/atomic cases are the floor, not the target.

## How to use
- `generate-test-cases` walks this list for each UC and records, per dimension,
  Covered / N/A+reason / Gap.
- `coverage-report` renders the per-UC × per-dimension grid so gaps are visible.
- Add product-specific dimensions here as they recur.
