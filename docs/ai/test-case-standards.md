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
- Preconditions (state, role, data needed)
- Precondition-feasibility tag: `self-serviceable` | `needs-fixture: <name>` |
  `needs-config` | `needs-live-action` (see generate-test-cases + `test-fixtures.md`)
- **Test Data Preparation** — the explicit build / navigation path to reach the
  precondition state (cite `app-map.md` routes and `test-fixtures.md` fixtures).
  Use real, reachable values — **no hardcoded or invented dummy data** (e.g. not
  "North"); reference a fixture or a value the steps actually create. No real PII.
- Steps (numbered, one UI-observable action each, executable by Playwright MCP)
- Expected result (taken from the SRS / new-feature SRS / a `DEC-###` — cite the source)

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
