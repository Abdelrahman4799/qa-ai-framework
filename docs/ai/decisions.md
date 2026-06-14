# Decisions & Clarifications Log

Rulings and clarifications that are **not written in the SRS** — typically BA / product
answers to questions raised during testing. This is a **legitimate source of truth
alongside the SRS**: a test case may cite a decision instead of being blocked as
"unstated".

Each entry has a stable ID `DEC-###`. Test cases trace to `DEC-###` the same way they
trace to `REQ-###`. If a decision later contradicts the SRS, flag it for the team.

| ID | Question / topic | Decision / ruling | Source (who decided) | Date | Affects (UC / feature) |
|----|------------------|-------------------|----------------------|------|------------------------|
| `DEC-001` (example) | _the open question that the SRS didn't answer_ | _the agreed answer, verbatim enough to test against_ | _BA / PO name_ | `TBD` | _UC-xx_ |

## Rules
- Record the decision precisely enough to test against — don't paraphrase the rule away.
- No real PII or secrets.
- An unanswered question stays `TBD - needs team confirmation` until a decision is
  logged here; do not invent the answer.
- A test case that relies on a decision must cite its `DEC-###` in its traceability.
