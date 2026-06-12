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
| Azure DevOps PAT | `$env:AZURE_DEVOPS_PAT` (env var, never a file) | once per machine |
| Existing baseline SRS | `docs/ai/srs/` — or drop a Word `.docx` in `_inbox/` and run ingest-srs | as it changes |
| New-feature SRS | `docs/ai/new-feature-srs/` | per feature |
| Which use case to test | your chat prompt ("test UC-05") | every run |

The `srs/` and `new-feature-srs/` folders ship **empty** — drop your real
documents in. Nothing here invents requirements.

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
2. Set the token (PowerShell):
   ```powershell
   [Environment]::SetEnvironmentVariable("AZURE_DEVOPS_PAT", "<your-pat>", "User")
   ```
3. Open this folder in Claude Code and **approve the project hooks** when prompted
   (they enforce the review gate and block PAT leaks).

## Daily use

1. Drop / update your SRS files, then build the use-case index **once**:
   > "Run index-srs on the baseline SRS."
2. Test a use case:
   > "Generate and run test cases for UC-05, then upload the results to DevOps."

The framework reads only the chosen use case's section plus the related use cases
it confirms with you — not the whole SRS.

## Enforcement

- `CLAUDE.md` is auto-loaded every session (rules always in context).
- Hooks in `.claude/settings.json`:
  - `inject_reminder` — re-injects the core rules every prompt.
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
See `.agents/skills/self-heal/SKILL.md`.

## Layout

```
docs/ai/         context + policies + SRS (baseline) + new-feature SRS
                 + handoff.md (small "where we left off", read each session)
test-cases/      generated cases (persist, per use case) + traceability + coverage
sessions/        full per-session records (append-only audit trail)
.qa-state/       runtime: run evidence + the review gate marker (git-ignored)
.agents/skills/  the pipeline skills + self-heal + save-session
.claude/         hooks + settings
```

## Session history (hybrid)

- `docs/ai/handoff.md` — one small file, overwritten each session, auto-read at
  the start of the next one (cheap).
- `sessions/SESSION-<date>-<n>.md` — one append-only file per session, the full
  audit trail, read only on demand.

At session end, run save-session (or say "save the session"): it appends the full
record and refreshes `handoff.md`. See `.agents/skills/save-session/SKILL.md`.
