# Extending the Framework

The framework is **contract-based**, not a monolith. Each pipeline stage has a defined
input/output contract; any agent, tool, or script that honours the contract can replace
or augment a stage without breaking the rest. This guide is the official "how to plug in
your own agent/tool" reference.

For the pipeline overview see [ARCHITECTURE.md](ARCHITECTURE.md); for the rationale see
[OVERVIEW.md](OVERVIEW.md).

---

## 1. The mental model

```
inputs (SRS index)  →  [ stage ]  →  artifacts on disk  →  next stage
                          ▲
              swap the stage's executor here
```

A stage is just a `SKILL.md` (a workflow). Replacing "who does the work" means editing
that skill to call your agent — as long as your agent reads the same inputs and writes
the same artifacts, triage / review / upload keep working unchanged.

---

## 2. Stage contracts

### `generate-test-cases`
| | Contract |
|---|---|
| **Reads** | the chosen use case's `Section`, plus its `Actors` and `Depends on` from `docs/ai/srs/_index.md`; format rules in `docs/ai/test-case-standards.md` |
| **Writes** | test-case files in `test-cases/<UC-ID>/` (standard format: TC-IDs, observable steps, expected results cited from the SRS) |
| **Updates** | `test-cases/traceability.md` (UC/REQ → TC) |
| **Must honour** | one use case in scope; role-based (allowed/denied) coverage; dependency-aware preconditions; `TBD` for anything the SRS does not state |

### `execute-test-cases`
| | Contract |
|---|---|
| **Reads** | the test cases for the chosen UC + its regression set |
| **Writes** | per-case results + evidence in `.qa-state/runs/<runid>/`, and `RUN-REPORT.md` |
| **Result states** | `PASS` / `FAIL` / `BLOCKED` / `FLAKY` |
| **Must honour** | the pinned environment in `context.md` (never production); dependency ordering; evidence (screenshot + observed result) per asserting step |

### Downstream stages (unchanged regardless of executor)
`triage-defect` reads FAILs + evidence → defects · `review-results` is the **gate** →
writes `.qa-state/review-passed.json` · `upload-to-devops` reads reviewed artifacts →
Azure DevOps work items.

---

## 3. Three integration patterns

| Pattern | Use when | How to wire it |
|---|---|---|
| **Claude Code subagent** | your agent is a Claude agent type | the skill delegates via the Agent/Task tool: "use the `test-generator` agent for this UC" |
| **MCP tool** | your agent is a service/tool | expose it as an MCP server; the skill calls the tool (exactly how execution already calls the Playwright MCP) |
| **CLI / script** | your agent is a script or binary | the skill runs a command; the agent reads inputs from files and writes outputs to the contract locations |

In every case the `SKILL.md` becomes a **thin orchestrator** around your agent rather than
doing the work inline.

---

## 4. How to add an agent later

1. Edit the relevant `SKILL.md` (`generate-test-cases` and/or `execute-test-cases`) to
   invoke your agent.
2. Keep the **contract** identical — output format, file locations, traceability.
3. Governed files go through the **self-heal approval** flow (or hand-edit them directly;
   manual edits are not gated).
4. Run **`doctor`**, then a small test use case end to end, to confirm the handoff.

---

## 5. Rules an external agent must not break

- **The review gate still applies.** Execution results must pass `review-results` before
  upload — the `guard_upload` hook blocks any Azure DevOps push without the review marker,
  no matter who ran the tests. Never let an external agent push to DevOps directly.
- **No secret exposure.** The `scan_secrets` hook blocks inlined PATs; build auth from
  `$env:AZURE_DEVOPS_PAT` at runtime.
- **State lives in the repo, not the agent.** Persist outputs to `test-cases/` and
  `.qa-state/` so traceability, coverage, and session handoff stay accurate — even if your
  agent has its own memory.
- **Source of truth is the SRS.** Don't let an agent invent requirements; unstated
  behaviour is `TBD - needs team confirmation`.
- **One use case in scope.** Keep the per-UC discipline that keeps token cost bounded.

---

## 6. Design notes

- **Scripted automation (e.g. real Playwright scripts) vs black-box MCP.** If your
  execution agent generates and runs Playwright *scripts* rather than driving the live app
  via MCP, that still fits — decide whether generated scripts become a versioned artifact
  (e.g. a `tests/` folder) and have the agent emit them alongside the run evidence.
- **New stages.** You can add stages (e.g. a `retest` loop, a performance pass) as new
  skills; give each a clear contract and, if it touches DevOps or the app, route it through
  the same gate/hook discipline.
- **Keep stages composable.** A new executor should depend only on the contract above, not
  on how a previous stage was implemented — that is what makes parts swappable.
