# Test Case Standards

## ID Scheme
- Test case ID: `TC-<UC-ID>-<NNN>` (e.g. `TC-UC05-001`).
- Every test case traces to at least one use-case ID (`UC-###`) plus the
  requirement(s) `REQ-###` and/or decision(s) `DEC-###` it covers.

## Required Fields (per test case)
- ID
- Title (action + expected outcome, concise)
- Trace: use case (UC-###) + requirement(s) (REQ-###) and/or decision(s) (DEC-###)
- Priority (P1 critical … P3 low)
- Type (positive / negative / boundary / permission / regression) + the **coverage
  dimension(s)** it targets (see `coverage-dimensions.md`)
- Preconditions (state, role, data needed) — **always include the entity/record STATUS**
  when the entity has states (e.g. "request status = Draft"); plus role and entity id.
- Precondition-feasibility tag: `self-serviceable` | `needs-fixture: <name>` |
  `needs-config` | `needs-live-action` (see generate-test-cases + `test-fixtures.md`)
- **Test Data Preparation** — the explicit build / navigation path to reach the
  precondition (cite `app-map.md` routes; fixtures; or setup created via Admin).
  For **free-input fields** (mobile, email, name, address…), assume realistic SYNTHETIC
  values tagged `QA_<runid>_`. For fields that reference another **entity/option**, CREATE
  that entity new — do NOT select a pre-existing record; use a fixture only for
  deep/irreversible state. Always create new data; never reuse existing records. No real PII.
- Steps (numbered, one UI-observable action each, executable by Playwright MCP), with a
  **per-step expected result**
- Expected result (taken from the SRS / new-feature SRS / a `DEC-###` — cite the source).
  When verifying a message/label, **quote the EXACT UI text** (per supported language,
  e.g. AR + EN) — not a paraphrase.

## Block Template
```markdown
### TC-UC05-001 — <title>
- Trace: UC-05 · REQ-112 · DEC-003 (if any)
- Priority: P1   Type: positive   Dimension: functional
- Preconditions: <state / role / data>
- Test Data Preparation: <explicit build/navigation path; fixture or steps-created
  values; app-map route; no hardcoded dummy data; no real PII>
- Steps:
  1. <action>  → Expected: <observable result>
  2. <action>  → Expected: <observable result>
- Expected result: <overall, cited from SRS section / DEC-###>
- Source: new-feature-srs/<file>.md ## <section>  (or srs/<file>.md, or DEC-###)
```

## CSV Output (step-per-row — the saved format)
Generated cases are saved as **CSV, one row per STEP** — at `test-cases/<UC-ID>/<UC-ID>.csv`
(UTF-8 no BOM, RFC 4180). Step-per-row enables **step-level execution tracking** (the
executor records which step failed, not just the case).

Header (exact column order):
```
TC ID,Title,Trace,Priority,Type,Dimension,Feasibility,Preconditions,Test Data Preparation,Step ID,Step #,Step Action,Expected Result,Actual Result,Step Status,Failure Notes,Overall TC Status
```
Layout:
- **Metadata** columns (`TC ID` … `Test Data Preparation`) appear ONLY on a case's FIRST
  step row; blank on its subsequent step rows.
- **Step** columns (`Step ID`, `Step #`, `Step Action`, `Expected Result`) on EVERY row —
  one action per row. `Step ID` = `{TC_ID}_S{NN}` (zero-padded, e.g. `TC-UC05-001_S01`).
- **Execution** columns (`Actual Result`, `Step Status`, `Failure Notes`, `Overall TC
  Status`) are left BLANK — the executor fills them per step (Overall on the first row only).
Rules:
- `Trace` = `UC-### · REQ-### · DEC-###` (as applicable). RFC 4180 quoting; header row always.
- Each step's `Expected Result` is specific to THAT action (the per-step oracle) and quotes
  the exact UI text when verifying a message.
- One CSV per use case. (For an Azure DevOps Excel/grid import the same shape works; the
  REST upload path doesn't need CSV.)

## Step-Writing Rules
- One action per step ("Click Login", "Enter <email> in the Email field").
- Each asserting step has an observable expected result.
- No assumptions about internal/source behavior — only what a user can observe.

## Quality Bar
- Independent and re-runnable (no hidden dependence on a previous case).
- Deterministic (fixed data; no reliance on real time/randomness unless required).
- Traceable (maps back to a UC and a REQ and/or DEC).
- **Consolidated** — merge redundant validation into one case (e.g. all mandatory-field
  combinations in a single TC) rather than one trivial case per field. Split only when
  steps or expected results genuinely differ.
- Ambiguities recorded as `TBD - needs team confirmation`, never guessed.

## Strength rubric (strong vs weak — reject weak)
A case is **strong** only if it is derived from a test-design technique
(`docs/ai/test-design-techniques.md`) and has:
- **Concrete input values** chosen by equivalence partitioning / boundary analysis —
  never "some value".
- A **precise expected result / oracle** — the exact message, state, or persisted value
  to observe — never "it works" / "no error".
- **One clear objective**, deterministic, traceable.
Coverage is **strong** only if every equivalence class, boundary, decision-table rule,
and state for the requirement has a case. One happy-path case per requirement is **weak**.

## Requirement-ID policy (when the SRS has no REQ IDs)
If the SRS does not number its requirements, do not leave traceability empty. Trace
each case to the SRS section / business-rule / flow reference, a `DEC-###`, or an
external tracker ID (e.g. Jira/TFS). Agree one scheme with the team and use it
consistently.
