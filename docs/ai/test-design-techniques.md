# Test Design Techniques

Coverage dimensions say WHAT to test; these techniques say **HOW to derive thorough
cases** within each. Weak suites skip these and write one vague case per requirement.
For every requirement / input / rule, pick and APPLY the relevant technique and derive
**concrete values with precise expected results**.

## Equivalence Partitioning (EP)
- Split each input into valid and invalid classes; one representative case per class.
- One case per *distinct* class — not five cases for five values in the same class, and
  never zero cases for a class that exists.

## Boundary Value Analysis (BVA)
- For any ordered/ranged input test the edges: `min-1, min, min+1 … max-1, max, max+1`,
  plus empty / zero / overflow / max-length. Applies to numbers, lengths, counts, dates,
  pagination sizes, quantities.

## Decision Tables
- For a rule that combines multiple conditions, build a table: each condition combination
  → expected action. Generate a case per rule; note impossible combinations. This is what
  catches the combination everyone forgets.

## State-Transition
- For stateful entities (e.g. draft → submitted → approved → closed): test each valid
  transition, each **invalid** transition (must be blocked), and which actions are allowed
  in each state.

## Pairwise / Combinatorial
- When several parameters interact (e.g. role × language × theme × data type), use pairwise
  selection to cover all *pairs* without the full combinatorial explosion.

## Error Guessing & Negative
- Probe likely failure points: empty/null, duplicates, special characters, very long input,
  wrong type/format, expired/again, concurrency, back/refresh/resubmit, permission edges,
  timeouts, interrupted flows.

## What "strong" looks like (vs weak)
| Strong | Weak (reject) |
|--------|---------------|
| Concrete input values chosen by EP/BVA | "enter some value" / vague data |
| Precise expected result: exact message / state / persisted value (the **oracle**) | "it works" / "no error" |
| One clear objective per case; deterministic; traceable | bundles several behaviors; ambiguous |
| Each equivalence class, boundary, rule, and state has a case | one happy-path case per requirement |

Use these together: pick the technique per requirement, enumerate the classes/boundaries/
rules/states, then write one strong case each.
