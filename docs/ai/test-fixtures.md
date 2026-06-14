# Test Fixtures (named prerequisite states)

Some test cases need a **prerequisite data state** that is expensive, multi-role, or
partially irreversible to build live (e.g. a parent record that already has a dependent
child, or a configuration that enables a downstream flow). Building that state during a
run is slow, pollutes a shared environment, and often isn't reachable with the
available accounts.

Instead, the team **pre-seeds named fixtures** in the test environment and lists them
here. Test cases reference a fixture **by name** in their preconditions;
`generate-test-cases` tags any case that needs one, and `execute-test-cases` **asserts
the fixture exists** at pre-flight and marks dependent cases **BLOCKED — "seed fixture
`<name>`"** if it doesn't (instead of constructing deep state on the fly).

## How to use
- **Authoring (generate-test-cases):** if a case's precondition is a deep/irreversible
  state, reference a fixture name from the catalog below rather than inlining "create X
  then Y then Z". Tag the case `needs-fixture: <name>` (see precondition-feasibility
  tags in `generate-test-cases`).
- **Executing (execute-test-cases):** at pre-flight, confirm each referenced fixture is
  present (and in the expected state). If missing → BLOCKED with the fixture name; do
  not build it live unless the user explicitly authorizes it for that run.
- **Seeding:** a human (or an explicitly-authorized setup run) creates the fixture once
  and records it here with its identifying data and how to recognise it.

## Fixture catalog

Replace the EXAMPLE rows with fixtures for your application. Keep identifying data
precise enough that `execute-test-cases` can verify presence. No real PII.

| Fixture name | What it is / state | Identifying data | Status | Seeded by |
|--------------|--------------------|------------------|--------|-----------|
| `parent-with-dependent` (example) | A parent record with ≥1 child/dependent, so edit/delete must be blocked | `TBD` | `TBD` | |
| `record-no-usage` (example) | A record with no dependents (edit/delete allowed) | `TBD` | `TBD` | |
| `empty-collection` (example) | A group/collection containing no items (e.g. excluded from a dropdown) | `TBD` | `TBD` | |
| `deactivated-item` (example) | An item left deactivated (excluded from active lists) | `TBD` | `TBD` | |
| `downstream-enabled-config` (example) | An entity configured so a derived/downstream flow is available | `TBD` | `TBD` | |
| `privileged-account` (example) | An account whose role/group unlocks a specific capability | `TBD` | `TBD` | |

Add rows as new fixtures are identified.

## Relationship to test data
General per-role accounts and seed-data rules live in `docs/ai/test-data-policy.md`.
This file is specifically for **named compound states** a test case depends on.
