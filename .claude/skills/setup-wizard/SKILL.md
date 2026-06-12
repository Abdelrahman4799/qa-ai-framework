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

4. Secrets & credentials — NEVER write to the repo
   - For the Azure DevOps PAT and per-role accounts, do NOT put values in any file.
     Give the user the exact commands to set them as User env vars and ask them to
     run those in their own terminal, e.g.:
     ```powershell
     [Environment]::SetEnvironmentVariable("AZURE_DEVOPS_PAT","<pat>","User")
     [Environment]::SetEnvironmentVariable("QA_ADMIN_USER","<user>","User")
     [Environment]::SetEnvironmentVariable("QA_ADMIN_PASS","<pass>","User")
     ```
   - Do not echo or run commands that contain the secret values yourself (the
     `scan_secrets` hook blocks inlined PATs).

5. Finish
   - Re-run `doctor` and report what remains (e.g. SRS not added yet, env vars the
     user still needs to set, leftover `TBD`s they were unsure about).
   - Summarize everything that was updated.

## Rules
- One question at a time; never invent a value.
- Never write secrets/credentials into repo files.
- `context.md`, `devops-policy.md`, `test-data-policy.md` are user config (not
  governed by the self-heal guard) — safe to edit directly.
- Stop and hand back control whenever the user wants to pause.
