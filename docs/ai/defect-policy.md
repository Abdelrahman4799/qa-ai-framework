# Defect Policy

## Bug Report Template (required fields)
- **Title** — `[Area] concise problem` (what is wrong, and where)
- **Description** — 1–2 lines: what the defect is and its impact
- **Trace** — test case ID · `UC-###` · `REQ-###` / `DEC-###`
- **Environment** — app URL · build/version (if known) · role used
- **Severity** (scale below) · **Priority** (scale below)
- **Preconditions** — state / role / data, including the entity **status**
- **Steps to reproduce** — numbered, minimal, with the **exact data** used
- **Expected result** — what should happen (quote exact UI text where relevant)
- **Actual result** — what actually happened (quote the exact message / observed text)
- **SRS contradiction** — the EXACT spec statement the actual behaviour violates, **quoted**,
  with its location: `srs/<file>.md ## <section>`, `new-feature-srs/...`, or `DEC-###`.
  This is what makes it a real defect. If nothing in the spec is contradicted (spec silent/
  ambiguous), it is NOT a confirmed bug → mark `TBD - needs team confirmation`.
- **Evidence** — screenshot path(s), URL, error text
- **Reproducibility** — always / intermittent / once

## Severity Scale
- S1 Critical — crash, data loss, security issue, core flow blocked, no workaround
- S2 High — major function broken, workaround painful
- S3 Medium — function impaired, reasonable workaround exists
- S4 Low — minor / cosmetic

## Priority Scale
- P1 fix now … P3 fix later. Do not assume business priority — mark
  `TBD - needs team confirmation` if unclear.

## Rules
- One defect per distinct root symptom; do not bundle.
- A FAIL is only a defect if it contradicts the SRS / new-feature SRS / a `DEC-###`.
  If the spec is silent or ambiguous, file as `TBD - needs team confirmation`, not a
  confirmed bug.
- Never include real PII or the PAT in a defect report.

## Defect classes (not just functional)
Beyond "function returns wrong result", these are reportable defects:
- **Missing user feedback / silent failure** — an action is correctly prevented or
  fails, but the user gets **no message or indication** where the SRS (or normal UX)
  expects one (e.g. edit/delete silently blocked, no error toast). File it as a UX
  defect; severity by impact (often S3, higher if it causes data confusion).
- **Localization / RTL** — untranslated strings, broken layout under RTL/LTR, or
  bilingual data rendered wrong.
- **Theme / accessibility** — broken layout in dark/light, unreadable contrast,
  keyboard-inaccessible controls.
- **Audit gap** — an action that should be logged isn't.
