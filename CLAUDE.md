# CLAUDE.md

This project uses the repo-based **AI QA Framework** for requirements-driven,
black-box testing. There is **no application source code** — the app is tested
through the Playwright MCP, and the SRS documents are the source of truth.

**AGENTS.md is the canonical instruction set — read it fully.**

## Non-negotiables (also enforced by hooks in .claude/settings.json)

- Read `docs/ai/context.md` before any task.
- The unit of work is a **single chosen use case**, not the whole SRS.
- Expected results come from the SRS / new-feature SRS, never from assumption.
- Do **not** upload to Azure DevOps before the review gate writes
  `.qa-state/review-passed.json`.
- Never inline the DevOps PAT; reference `$env:AZURE_DEVOPS_PAT` only.
- You may **propose** improvements to the framework's rules/skills (self-heal),
  but only **apply** them after explicit user approval — never weaken a guardrail.
- On a fresh/incomplete setup (SessionStart says so), offer the **setup-wizard**
  skill: collect each config `TBD` one at a time and update the files; keep secrets
  in env vars, never in the repo.

See **AGENTS.md** for reading routing, the skill pipeline, and the required
final-response format.
