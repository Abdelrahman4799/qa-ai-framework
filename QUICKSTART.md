# Quickstart

From zero to your first tested use case. ~10 minutes of one-time setup.

---

## 1. One-time setup

### a. Fill in your config (two files)
- `docs/ai/context.md` → replace the `TBD`s: app **test/staging URLs**, environments,
  test-account env-var names, and the **Review Gate** mode (`human` or `auto`).
- `docs/ai/devops-policy.md` → Azure DevOps **org URL, project, area path, iteration path**.

### b. Set the Azure DevOps token (PowerShell)
```powershell
[Environment]::SetEnvironmentVariable("AZURE_DEVOPS_PAT", "<your-pat>", "User")
```
Required PAT scopes: **Work Items (Read & Write)**. Reopen your terminal afterward so
the variable is picked up. The token is never stored in the repo.

### c. Set a test account PER ROLE (multi-role system)
This system has roles (Admin, Manager, Supervisor, Viewer, …). Create one test
account per role so permission tests can run as each:
```powershell
[Environment]::SetEnvironmentVariable("QA_ADMIN_USER", "<user>", "User")
[Environment]::SetEnvironmentVariable("QA_ADMIN_PASS", "<pass>", "User")
[Environment]::SetEnvironmentVariable("QA_VIEWER_USER", "<user>", "User")
[Environment]::SetEnvironmentVariable("QA_VIEWER_PASS", "<pass>", "User")
# ...repeat for Manager, Supervisor, and any other roles
```
The role → account mapping lives in `docs/ai/test-data-policy.md`.

### d. Open the folder in Claude Code and approve the hooks
Open `qa-ai-framework/` as the project. When prompted to **trust the project hooks**,
approve — that activates the review gate, the secret scan, and the self-heal guard.

### e. Install pandoc (only if your SRS is a Word .docx)
The ingest-srs step uses pandoc to convert and split Word documents. Install it once:
```powershell
winget install JohnMacFarlane.Pandoc
```
Or download from https://pandoc.org/installing.html. Reopen your terminal afterward,
then verify with `pandoc --version`. Skip this if your SRS is already Markdown.

### f. Confirm Playwright MCP is available
This framework executes tests through the Playwright MCP. Make sure it is configured
in your Claude Code (you confirmed it is).

---

## 2. Add your requirements

**If your SRS is a Word document (recommended path):**
- Install pandoc once: `winget install JohnMacFarlane.Pandoc`
- Drop the `.docx` into `docs/ai/srs/_inbox/` and say:
  > "Ingest the SRS."
- This converts it to Markdown and splits it into one file per use case. Use cases
  are `####` headings by default — if your document uses a different level, say
  "ingest the SRS, use cases are level 3" (any level 1–6).
- Same for the new feature: drop its `.docx` into
  `docs/ai/new-feature-srs/_inbox/` and say "Ingest the new-feature SRS."
- Review the split, then continue.

**If you already have Markdown:** drop it into `docs/ai/srs/` (one feature per file)
and `docs/ai/new-feature-srs/`, using `####` for use cases and `REQ-###` for requirements.

**Verify your setup any time:**
> "Run doctor."

It checks pandoc, the PAT, per-role accounts, config TBDs, index freshness, and hooks,
and tells you exactly what to fix.

Then build the use-case catalog **once**:
> "Run index-srs on the baseline SRS."

(Re-run `index-srs` only when the baseline SRS changes — a hook warns you if it goes stale.)

---

## 3. Test a use case

> "Generate and run test cases for UC-05, then review and upload to DevOps."

What happens:
1. **generate** — picks UC-05, proposes related existing use cases, asks you to confirm,
   writes test cases + the regression set.
2. **execute** — drives the app via Playwright MCP, captures screenshots, writes a run report.
3. **triage** — turns real failures (those that contradict the SRS) into classified bugs.
4. **review (gate)** — shows you the summary; on your approval it writes the gate marker.
5. **upload** — creates Test Case + Bug work items in Azure DevOps.

If you ask it to upload before review, the gate hook **blocks** it and tells you to review first.

---

## 4. End of session

> "Save the session."

Appends a full record to `sessions/` and refreshes `docs/ai/handoff.md` so the next
session resumes where you left off.

---

## Handy prompts

| Goal | Say |
|------|-----|
| Convert + split a Word SRS | "Ingest the SRS." (after dropping .docx in _inbox) |
| Build/refresh the use-case catalog | "Run index-srs on the baseline SRS." |
| Test one use case end to end | "Generate, run, review and upload UC-05." |
| Just generate cases (no run) | "Generate test cases for UC-05, don't execute yet." |
| See coverage / gaps | "Run the coverage report." |
| Propose a framework improvement | "Self-heal: propose better rules from what you just saw." |
| Promote an accepted feature | "Promote UC-N01 into the baseline SRS." |
| Save progress | "Save the session." |

---

## If something blocks

| Message | Meaning | Fix |
|---------|---------|-----|
| `BLOCKED: ... upload before review gate` | No approved review marker | Run review-results first |
| `BLOCKED: PAT ... inline` | Token was about to be pasted | It must be referenced as `$env:AZURE_DEVOPS_PAT` |
| `BLOCKED: editing a governed framework file` | Self-heal not approved | Approve the proposal, or hand-edit the file yourself |
| `Baseline SRS changed since index-srs ...` | Index is stale | Re-run `index-srs` |

See `README.md` for the full layout and `ARCHITECTURE.md` / `framework-diagram.html`
for the visual map.
