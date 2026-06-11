# Test Case Standards

## ID Scheme
- Test case ID: `TC-<UC-ID>-<NNN>` (e.g. `TC-UC05-001`).
- Every test case links to at least one use-case ID (`UC-###`) and the
  requirement ID(s) it covers (`REQ-###`).

## Required Fields (per test case)
- ID
- Title (action + expected outcome, concise)
- Linked use case (UC-###) + requirement(s) (REQ-###)
- Priority (P1 critical … P3 low)
- Type (positive / negative / boundary / permission / regression)
- Preconditions (state, role, data needed)
- Test data (explicit; no real PII)
- Steps (numbered, one UI-observable action each, executable by Playwright MCP)
- Expected result (taken from the SRS / new-feature SRS — cite the source)

## Block Template
```markdown
### TC-UC05-001 — <title>
- UC: UC-05   REQ: REQ-112
- Priority: P1   Type: positive
- Preconditions: <state / role / data>
- Test data: <explicit, no real PII>
- Steps:
  1. <action>  → Expected: <observable result>
  2. <action>  → Expected: <observable result>
- Expected result: <overall, cited from SRS section>
- Source: new-feature-srs/<file>.md ## <section>  (or srs/<file>.md)
```

## Step-Writing Rules
- One action per step ("Click Login", "Enter <email> in the Email field").
- Each asserting step has an observable expected result.
- No assumptions about internal/source behavior — only what a user can observe.

## Quality Bar
- Independent and re-runnable (no hidden dependence on a previous case).
- Deterministic (fixed data; no reliance on real time/randomness unless required).
- Traceable (maps back to a UC / requirement).
- Ambiguities recorded as `TBD - needs team confirmation`, never guessed.
