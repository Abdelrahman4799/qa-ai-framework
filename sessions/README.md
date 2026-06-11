# Sessions Archive

One append-only file per session, written by the **save-session** skill:
`SESSION-<YYYY-MM-DD>-<n>.md` (use `-2`, `-3` for multiple sessions in a day).

These are the full audit trail and are NEVER overwritten. They are read only on
demand (e.g. "what did we do for UC-05 last week?") — the small
`docs/ai/handoff.md` is what gets read at the start of every session.

Each session file follows the template in the save-session skill: scope, what ran
per stage, decisions, defects filed, work items uploaded, self-heals, TBDs, and
next steps.

Empty until the first session is saved.
