# AI QA Framework

A repo-based framework that drives an AI assistant (Claude Code) through
**requirements-driven, black-box testing** of a running web application — with
no access to source code.

Pipeline: **select a use case → generate test cases → execute via Playwright MCP
→ triage defects → review (gate) → upload to Azure DevOps**.

## What you provide

| Input | Where | When |
|---|---|---|
| App test/staging URLs, environments, test-account env-var names | `docs/ai/context.md` | once |
| Azure DevOps org / project / area / iteration | `docs/ai/devops-policy.md` | once |
| Azure DevOps PAT + per-role accounts | git-ignored `.env` (copy from `.env.example`) | once |
| Existing baseline SRS | `docs/ai/srs/` — or drop a Word `.docx` in `_inbox/` and run ingest-srs | as it changes |
| New-feature SRS | `docs/ai/new-feature-srs/` | per feature |
| Which use case to test | your chat prompt ("test UC-05") | every run |

The `srs/` and `new-feature-srs/` folders ship **empty** — drop your real
documents in. Nothing here invents requirements.

> **New? Read [ABOUT.md](ABOUT.md)** — the full explainer: what it is, features, why use it.
> **Why this framework?** See **[OVERVIEW.md](OVERVIEW.md)** — the problems it solves and who it's for.
> New here? Start with **[QUICKSTART.md](QUICKSTART.md)** — zero to first tested use case.
> Plugging in your own agents/tools? See **[EXTENDING.md](EXTENDING.md)** — stage contracts and integration patterns.

## Get the framework

Clone it (public repo — no auth needed to clone):

```bash
git clone https://github.com/Abdelrahman4799/qa-ai-framework.git
cd qa-ai-framework
```

Alternatives: `gh repo clone Abdelrahman4799/qa-ai-framework` (GitHub CLI), or SSH
`git clone git@github.com:Abdelrahman4799/qa-ai-framework.git`.

The clone is a fresh template — `docs/ai/srs/`, `.qa-state/`, and credentials are
empty or git-ignored, so each user supplies their own SRS, PAT, and per-role
accounts. Open the folder in Claude Code, approve the project hooks when prompted,
then say **"Run doctor"** to see what setup remains.

## Prerequisites

- **Playwright MCP** configured in Claude Code (the framework executes tests through it).
- **pandoc** — only if your SRS is a Word `.docx` (used to convert + split it):
  ```powershell
  winget install JohnMacFarlane.Pandoc
  ```
  Or https://pandoc.org/installing.html. Verify with `pandoc --version`. Skip if your
  SRS is already Markdown.

## Setup (once)

1. Fill in the `TBD` values in `docs/ai/context.md` and `docs/ai/devops-policy.md`.
2. Set up credentials: `Copy-Item .env.example .env`, then fill in `AZURE_DEVOPS_PAT`
   and the per-role `QA_*` accounts. `.env` is git-ignored and loaded at runtime
   (`scripts/load_env.ps1`) — no restart needed. Use test/non-production accounts.
3. Open this folder in Claude Code and **approve the project hooks** when prompted
   (they enforce the review gate and block PAT leaks).

## Daily use

1. Drop / update your SRS files, then build the use-case index **once**:
   > "Run index-srs on the baseline SRS."
2. Test a use case:
   > "Generate and run test cases for UC-05, then upload the results to DevOps."

The framework reads only the chosen use case's section plus the related use cases
it confirms with you — not the whole SRS.

## Skills

Invoke any of these in natural language (e.g. "run doctor", "ingest the SRS").

**Setup & health**
- `setup-wizard` — guided onboarding; fills config `TBD`s one at a time and updates the files
- `doctor` — setup health check (tooling, PAT, role accounts, config TBDs, index freshness, hooks)

**Requirements intake**
- `ingest-srs` — convert a Word `.docx` SRS with pandoc and split it into per-use-case files
- `index-srs` — build the use-case catalog (actors, depends-on, related) + permission matrix + fingerprint

**Test pipeline**
- `generate-test-cases` — for one chosen use case: understand it + related UCs deeply, cover every SRS statement and dimension using formal test-design techniques (equivalence/boundary/decision-table/state/pairwise) with concrete values + precise oracles, role-based + dependency-aware, link to baseline cases, adversarial `/goal` loop; saved as **CSV** (one row per case)
- `execute-test-cases` — run via Playwright MCP (optional parallel runners), auto-provision data (UI or API), fixtures, verify from persisted state, `/goal` loop; run report (PASS / FAIL / BLOCKED / INCONCLUSIVE / FLAKY)
- `exploratory-charter` — time-boxed session-based exploratory testing; findings feed triage/generate/decisions
- `triage-defect` — turn real failures (vs SRS/DEC) into classified bugs, incl. non-functional classes (silent failure, l10n/RTL, theme/a11y, audit)
- `review-results` — the human review **gate**; on pass writes the upload marker
- `upload-to-devops` — create Test Case + Bug work items; link each bug to its test case, and new-feature cases to related baseline cases
- `coverage-report` — requirement coverage + per-dimension matrix and gaps

**Maintenance**
- `self-heal` — propose rule/skill improvements (applied only after your approval)
- `save-session` — append a full session record and refresh the handoff

## Enforcement

- `CLAUDE.md` is auto-loaded every session (rules always in context).
- Hooks in `.claude/settings.json`:
  - `onboarding_check` (SessionStart) — offers the setup wizard while setup is incomplete.
  - `inject_reminder` — re-injects the core rules every prompt.
  - `srs_fingerprint` — warns when the use-case index is stale vs the SRS.
  - `guard_upload` — blocks any Azure DevOps upload until the review gate writes
    `.qa-state/review-passed.json`.
  - `scan_secrets` — blocks any command that inlines the PAT.
  - `guard_selfheal` — blocks the AI from editing its own rule/skill/policy files
    unless you approved a self-heal (`.qa-state/improvement-approved.json`).

## Self-healing

If the AI spots a better rule or an enhancement while working, it **proposes** it
with a before→after diff at a natural checkpoint. It **applies** the change only
after your approval, records it in `docs/ai/improvements-log.md`, and can never
weaken a safety rule (review gate, no PII, no PAT, no production). You can always
hand-edit any file yourself — the gate only governs the AI's tool-driven edits.
See `.claude/skills/self-heal/SKILL.md`.

## Layout

```
docs/ai/         context · handoff · policies (test-case-standards, execution,
                 defect, devops, test-data) · coverage-dimensions · test-design-techniques ·
                 decisions · test-fixtures · app-map · permission-matrix · glossary
                 + srs/ (baseline) and new-feature-srs/ (your documents)
test-cases/      generated cases (persist, per use case) + traceability + coverage
sessions/        full per-session records (append-only audit trail)
.qa-state/       runtime: run evidence + the review gate marker (git-ignored)
.claude/skills/  setup-wizard, doctor, ingest/index, generate/execute/exploratory,
                 triage, review, upload, coverage, self-heal, save-session (13)
.claude/         hooks (6) + settings
scripts/         ingest_srs.ps1, doctor.ps1, set_env.ps1, load_env.ps1
```

> Docs: [OVERVIEW](OVERVIEW.md) · [QUICKSTART](QUICKSTART.md) · [ARCHITECTURE](ARCHITECTURE.md) · [EXTENDING](EXTENDING.md) · [framework-diagram.html](framework-diagram.html)

## Session history (hybrid)

- `docs/ai/handoff.md` — one small file, overwritten each session, auto-read at
  the start of the next one (cheap).
- `sessions/SESSION-<date>-<n>.md` — one append-only file per session, the full
  audit trail, read only on demand.

At session end, run save-session (or say "save the session"): it appends the full
record and refreshes `handoff.md`. See `.claude/skills/save-session/SKILL.md`.
