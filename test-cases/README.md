# Test Cases

Generated test cases persist here as **CSV, one row per case**, grouped by use case
(e.g. `UC-05/UC-05.csv`). The CSV schema/columns are defined in
`docs/ai/test-case-standards.md`. They are written by the **generate-test-cases** skill
and re-read by the execute / triage / upload stages — so those stages never reopen the SRS.

`traceability.md` maps use cases / requirements → test case IDs. The regression
set for a new use case is selected from here.

Empty until you run generate-test-cases.
