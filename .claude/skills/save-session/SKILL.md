---
name: save-session
description: At the end of a session, append a full session record to sessions/ and overwrite docs/ai/handoff.md with the small "where we left off" summary.
---

# Skill: Save Session

Persist session history using the hybrid model:
- **Append** a full, never-overwritten record to `sessions/`.
- **Overwrite** the small `docs/ai/handoff.md` so the next session reads one tiny file.

Run this at the end of a working session, or when the user says "save the session".

## What NOT to duplicate
- Structured data already persisted elsewhere — `test-cases/`,
  `test-cases/traceability.md`, `.qa-state/runs/`, `docs/ai/improvements-log.md`.
- Capture the **decision / conversational layer**: why a scope was chosen, what
  the user approved, what is still open. Reference the artifacts by path; do not
  copy their contents.

## Steps

1. Determine the session ID
   - `SESSION-<YYYY-MM-DD>-<n>` (use the current date; increment `<n>` if a file
     for today already exists).

2. APPEND the full record — create `sessions/SESSION-<date>-<n>.md`:
   ```markdown
   # SESSION-<date>-<n>

   ## Scope
   - Use case(s): <UC-IDs>   Related/regression: <UC-IDs>

   ## What ran (by stage)
   - index-srs / generate / execute / triage / review / upload: <notes>

   ## Decisions
   - <choices the user made, scope confirmations, approvals>

   ## Defects filed
   - <BUG-ID — title — severity — DevOps work item link>

   ## Work items uploaded
   - <Test Case / Bug IDs + URLs>   (or "none — reason")

   ## Self-heal
   - Proposed: <...>   Approved: <...>   (see improvements-log.md)

   ## Open TBDs / pending your input
   - <items awaiting team confirmation>

   ## Next steps
   - <what the next session should do first>

   ## Pointers
   - Run: .qa-state/runs/<id>   Cases: test-cases/<UC>/
   ```

3. OVERWRITE the handoff — replace `docs/ai/handoff.md` with the small summary:
   - Last session date/ID + the session file path
   - Use case in progress + stage reached
   - Pending your input (TBDs, self-heal proposals, review approvals)
   - Next action
   - Pointers (latest run, traceability, improvements log)
   - Keep it short — this file is always loaded next session.

4. REPORT
   - The session file written + confirm handoff.md updated.

## Rules
- Never overwrite an existing `sessions/SESSION-*.md` — append a new file instead.
- No real PII, no PAT, no secrets in either file.
- Keep `handoff.md` minimal; put detail in the session file.
