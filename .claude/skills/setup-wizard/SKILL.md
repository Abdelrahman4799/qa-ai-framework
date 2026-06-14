---
name: setup-wizard
description: Interview the user ONE item at a time to fill the config TBDs (context.md, devops-policy.md, roles) and update the files; collect credentials into a git-ignored .env file.
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

4. Secrets & credentials — write them to `.env` (git-ignored), never to tracked files
   - The framework reads credentials from a `.env` file at the repo root, loaded at
     runtime by `scripts/load_env.ps1`. This avoids Windows env-var restart issues —
     values are usable immediately, no restart.
   - One-time heads-up: `.env` stores plaintext secrets on disk (git-ignored). Use
     TEST / non-production accounts. If the repo is in a synced folder (e.g. OneDrive),
     `.env` syncs to the cloud — keep that in mind.
   - ASK the user for each value, one at a time, and store it by running the helper
     (it creates `.env` from `.env.example` if missing and upserts the key):
     ```
     powershell -NoProfile -ExecutionPolicy Bypass -File scripts/set_env.ps1 -Key <KEY> -Value "<value>"
     ```
     Keys to collect:
     a. Azure DevOps PAT → `AZURE_DEVOPS_PAT`
     b. For each role in `docs/ai/test-data-policy.md`: ask username then password →
        `QA_<ROLE>_USER` / `QA_<ROLE>_PASS` (Admin, Manager, Supervisor, Viewer, …)
   - Confirm each by NAME only — never echo the secret value back. Never put secrets in
     a tracked file. (`scan_secrets` allows `set_env.ps1` but blocks the PAT inlined
     anywhere else.)
   - No restart needed — `.env` is read at runtime.

5. (Optional) Capture known app knowledge
   - Offer — don't force: "Do you already know any of the app's navigation routes,
     per-role landing pages, known UI quirks, or pre-seeded fixtures? I can record them
     now so runs don't re-derive them."
   - If yes, write what they give into:
     · `docs/ai/app-map.md` — login/landing per role, feature → route → roles, gotchas
     · `docs/ai/test-fixtures.md` — any already-seeded named states (with identifying data)
   - If no / unsure, leave the templates as-is — they fill in naturally as runs surface
     the need (execution updates app-map gotchas; fixtures are added when first required).
   - These are not blockers for a first run.

6. Finish
   - Run `doctor` — it loads `.env`, so values show immediately (no restart).
   - Give a clear ordered "what's left", e.g.:
     1) add the SRS (`.docx` → `_inbox/` then ingest-srs; or Markdown), then index-srs
     2) confirm the Playwright MCP is connected
   - Summarize everything that was updated.

## Rules
- One question at a time; never invent a value.
- Never write secrets/credentials into repo files.
- `context.md`, `devops-policy.md`, `test-data-policy.md` are user config (not
  governed by the self-heal guard) — safe to edit directly.
- Stop and hand back control whenever the user wants to pause.
