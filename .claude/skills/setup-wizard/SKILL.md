---
name: setup-wizard
description: Interview the user ONE item at a time to fill the config TBDs (context.md, devops-policy.md, roles) and update the files; guide secret/env-var setup without writing secrets to the repo.
---

# Skill: Setup Wizard (guided onboarding)

Walk the user through the remaining setup **one item at a time** and update the
config files for them. Use this on a fresh clone, when the SessionStart check says
setup is incomplete, or whenever the user asks to "set up" / "fill the TBDs".

## Steps

1. Discover what's missing
   - Run `doctor` (`scripts/doctor.ps1`) for the current gaps, or scan
     `docs/ai/context.md` and `docs/ai/devops-policy.md` for `TBD` placeholders.
   - Build an ordered checklist of items to collect. Tell the user how many there are.

2. Ask ONE item at a time
   - For each TBD, ask a single, specific question with context (what it is + an
     example). WAIT for the answer before moving on. Never batch them.
   - Suggested order:
     a. Product name + one-line description → `context.md`
     b. Test/QA URL, Staging URL, environments → `context.md` (never production)
     c. Review-gate mode: `human` or `auto` → `context.md`
     d. Azure DevOps: org URL, project, area path, iteration path → `devops-policy.md`
     e. Roles & their permissions → `test-data-policy.md` (or defer to `index-srs`
        if the SRS defines actors per use case)
     f. Unclear glossary terms → `glossary.md` (optional)

3. Update the file after each answer
   - Replace that specific `TBD` with the user's value in the correct file.
   - Confirm back what you wrote. If the user is unsure, LEAVE the `TBD` and note it.

4. Secrets & credentials — ASK the user and set the env vars (never write to repo files)
   - ASK the user for each secret, one at a time, and SET it for them as a User
     env var with `[Environment]::SetEnvironmentVariable(<name>, <value>, "User")`.
   - One-time heads-up BEFORE asking: "Values you type here are visible in the session
     transcript — use test (non-production) accounts. If you'd rather not share them
     in chat, I can give you commands to run yourself instead." Honour their choice.
   - Order, asking one value at a time:
     a. Azure DevOps PAT → `AZURE_DEVOPS_PAT`
     b. For each role in `docs/ai/test-data-policy.md`: ask the username then the
        password → `QA_<ROLE>_USER` / `QA_<ROLE>_PASS` (Admin, Manager, …)
   - After setting each, confirm by NAME only — never echo the secret value back.
   - Never write any secret into a repo file. (The `scan_secrets` hook still blocks a
     command that inlines an already-set PAT, so don't echo it.)
   - IMPORTANT: User-scope env vars are visible only to NEW processes. Tell the user to
     RESTART Claude Code before `doctor`/execution can see them.

5. Finish
   - Re-run `doctor` (note: env vars set this session aren't visible until restart).
   - Give a clear ordered "what's left", e.g.:
     1) RESTART Claude Code so the new env vars load
     2) add the SRS (`.docx` → `_inbox/` then ingest-srs; or Markdown), then index-srs
     3) confirm the Playwright MCP is connected
   - Summarize everything that was updated.

## Rules
- One question at a time; never invent a value.
- Never write secrets/credentials into repo files.
- `context.md`, `devops-policy.md`, `test-data-policy.md` are user config (not
  governed by the self-heal guard) — safe to edit directly.
- Stop and hand back control whenever the user wants to pause.
