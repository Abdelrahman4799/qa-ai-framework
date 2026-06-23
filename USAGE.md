# Usage Guide

How to use every skill and feature in the framework. Skills are native, so you can use a
**slash command** (e.g. `/doctor`) or just say it in plain English — both work.

For the big picture see [ABOUT.md](ABOUT.md); for setup detail see [QUICKSTART.md](QUICKSTART.md).

---

## 0. Open it
Open the `qa-ai-framework` folder in Claude Code. On first open, a SessionStart hook notices
setup is incomplete and offers the wizard. **Approve the project hooks** when prompted.

## 1. One-time setup
| Goal | Say | What happens |
|---|---|---|
| Guided setup | **"Run the setup wizard"** (`/setup-wizard`) | Asks for config (URLs, DevOps target) + writes `.env` (PAT + role accounts), one item at a time |
| Check readiness | **"Run doctor"** (`/doctor`) | Verifies pandoc, PAT, role accounts, index freshness, hooks, MCP — gives a fix list |

## 2. Per baseline (once, or when the SRS changes)
| Goal | Say | What happens |
|---|---|---|
| Word SRS → Markdown | drop `.docx` in `docs/ai/srs/_inbox/`, then **"Ingest the SRS"** (`/ingest-srs`) | pandoc converts + splits into per-use-case files (add `-UseCaseLevel N` if not `####`) |
| Build the model | **"Run index-srs"** (`/index-srs`) | Builds the **use-case catalog** (actors, depends-on, related), **permission matrix**, **system graph**, and the stale-index fingerprint |

## 3. Per use case — the core loop
Simplest end to end:

> **"Generate and run test cases for UC-05, then review and upload to DevOps."**

Or run the stages individually:

| Step | Say | Notes / options |
|---|---|---|
| **Generate** (`/generate-test-cases`) | "Generate test cases for UC-05" | confirms related UCs with you; output is **CSV** in `test-cases/UC-05/` |
| **Execute** (`/execute-test-cases`) | "Execute UC-05" | add "use 3 parallel runners", "explore the API to seed", "test in Arabic + English" |
| **Triage** (`/triage-defect`) | "Triage the failures" | real failures → classified bugs (incl. silent-failure/UX classes) |
| **Review** (`/review-results`) | "Review the results" | the **gate** — shows a summary and waits for your approval |
| **Upload** (`/upload-to-devops`) | "Upload to DevOps" | creates Test Case + Bug work items; links bug↔case and new-feature↔baseline |

> Upload is **blocked by a hook** until you approve the review — by design.

## 4. Support skills (anytime)
| Goal | Say |
|---|---|
| Coverage + per-dimension matrix | **"Run the coverage report"** (`/coverage-report`) |
| Exploratory session | **"Run an exploratory charter on checkout, 30 minutes"** (`/exploratory-charter`) |
| Save progress / resume point | **"Save the session"** (`/save-session`) |
| Improve a framework rule | **"Self-heal: propose a better rule for X"** (`/self-heal`) — applied only after you approve |

## 5. Options you can just say
- **Speed:** "use N parallel runners" (isolated by browser context, not account).
- **Data:** it auto-creates needed data via **Admin**, **seeding via the API by default** (UI only when no API), and **assumes input values** (mobile, email…), fresh per run.
- **Roles:** generation covers allowed + denied roles automatically; setup/control runs as Admin, the action-under-test as the case's role.
- **Concurrency:** ask for "a multi-session pick-lock test" and it drives two sessions.
- **Scope:** always one use case at a time (`UC-05`); it pulls in the related/regression set itself.
- **Decisions:** when a rule isn't in the SRS, log it in `docs/ai/decisions.md` as `DEC-###` so a case can cite it.

## 6. Where things land
```
test-cases/UC-xx/*.csv      generated cases (CSV)
test-cases/traceability.md  UC/REQ/DEC → TC + related baseline TCs
test-cases/coverage.md      coverage + dimension matrix
.qa-state/runs/<id>/        screenshots + RUN-REPORT.md (+ residue)
docs/ai/decisions.md        log a BA ruling so a case can cite it
sessions/ + handoff.md      session history / resume point
```

---

## 7. Hooks (the enforcement)
Hooks are scripts in `.claude/hooks/`, registered in `.claude/settings.json`. They run
**outside the model** and either inject context or **block** an unsafe action — turning
"please follow the rules" into rules that hold. You approve them once (Claude Code's trust
prompt). **All hooks fail OPEN** — a missing file or parse error means allow + no warning,
so they never block legitimate work.

| Hook | Event | What it does |
|---|---|---|
| `onboarding_check` | SessionStart | If setup is incomplete (config `TBD`s left or `AZURE_DEVOPS_PAT` unset), injects an offer to run the setup wizard. Goes silent once setup is done. |
| `inject_reminder` | UserPromptSubmit | Re-injects the core rules every prompt (read context first, one use case, SRS is truth, no upload before review, never inline the PAT) so they don't drift out of context. |
| `srs_fingerprint` | UserPromptSubmit | Hashes the baseline SRS and warns when it changed since `index-srs` ran — i.e. the use-case index / graph may be stale. |
| `guard_upload` | PreToolUse (Bash/PowerShell) | **Blocks** any Azure DevOps work-item call unless `.qa-state/review-passed.json` exists. Enforces "no upload before the human review gate." |
| `scan_secrets` | PreToolUse (Bash/PowerShell) | **Blocks** any command that inlines the PAT value or a hardcoded Basic-auth token. Allows the sanctioned `set_env.ps1` write path. |
| `guard_selfheal` | PreToolUse (Edit/Write) | **Blocks** the AI from editing its own governed rule/skill/policy files unless an approved self-heal marker (`.qa-state/improvement-approved.json`) lists that file. You can always hand-edit files yourself. |

What this guarantees, regardless of what the model does: it can't upload before you review,
can't leak the PAT, and can't rewrite its own rules without your approval — while the softer
rules (read context, one UC, SRS-as-truth) are reinforced every turn.

---

## Mental model
**Set up once → index the SRS once → then per use case: generate (CSV) → execute (real
browser, Admin-seeded fresh data, optional parallel) → triage → review (gate) → upload.**
Hooks keep it safe; the system graph + decisions log keep it accurate; self-heal + session
handoffs keep it improving.
