---
name: index-srs
description: Build the use-case catalog (_index.md) for the baseline SRS. Run once, or when the baseline SRS changes.
---

# Skill: Index SRS

Read the existing baseline SRS in full ONCE and produce a small use-case catalog
so every later run can locate a use case without re-reading the SRS.

This is the only stage that reads the full SRS. Run it once, then re-run only when
the baseline SRS changes.

## Inputs
- All files in `docs/ai/srs/`. If the SRS arrived as Word, run **ingest-srs**
  first — each file is then typically one use case (its `####` heading).

## Steps
1. Parse each SRS file. Use cases are level-4 headings (`####`); capture each one's
   file + heading. A `<!-- context: ... -->` breadcrumb (if present) gives the
   parent feature for the Related column.
2. Assign / capture IDs:
   - Use case ID `UC-###` (use existing IDs if the SRS has them).
   - Requirement IDs `REQ-###` referenced by each use case.
3. For each use case, write:
   - File + `Section` heading (so later stages read only that section)
   - `Actors` — the role(s) the SRS names for this use case (the allowed set).
     Copy verbatim from the SRS; do not infer roles the SRS does not state.
   - `Depends on` — directional prerequisite UC(s): captured from the SRS
     `Preconditions`, `«include»`, `«extend»`, or "triggers" wording. Record the
     prerequisite UC IDs. If a dependency is only implied (not stated), propose it
     and CONFIRM with the user before recording; otherwise mark `TBD`.
     Keep to DIRECT (one-hop) prerequisites — chains are followed at run time.
   - A one-line `Summary` (enough for semantic matching from the index alone)
   - `Related UCs` — other use cases it loosely interacts with (semantic).
4. Flag anything ambiguous (no clear UC boundary, missing IDs, missing actors,
   an actor that is not a known role in `docs/ai/test-data-policy.md`, or a
   CIRCULAR dependency) as `TBD - needs team confirmation`. Do not invent use
   cases, IDs, actors, or dependencies.

3b. Populate the role universe (auto)
   - Collect the UNION of all `Actors` across every use case = the role list.
   - Update the Accounts/Roles Matrix in `docs/ai/test-data-policy.md`:
     add a row for any role not already listed. MERGE — never overwrite the
     user's existing account env-var names or permission notes.
   - Then ask the user to CONFIRM the list and add any role that exists but is
     never an SRS actor (the SRS can't surface those). Do not invent roles.

3c. Build the permission matrix
   - Using the confirmed role universe: for each use case
     allowed = its `Actors`; denied = all known roles − allowed.
   - Write `docs/ai/permission-matrix.md` (roles × use cases, allowed/denied grid).
   - Note data-scoped rules (e.g. "Manager — own team only") as a `TBD` cell note;
     the grid captures WHO, not WHICH records.

4b. Record the fingerprint
   - After writing the index, run:
     `powershell -NoProfile -ExecutionPolicy Bypass -File .claude/hooks/srs_fingerprint.ps1 -Write`
   - This stores `docs/ai/srs/_fingerprint.json`. A UserPromptSubmit hook compares
     it against the live SRS each session and warns if the index has gone stale.

## Output
- Overwrite `docs/ai/srs/_index.md` with the use-case catalog table (incl. Actors).
- Update the role list in `docs/ai/test-data-policy.md` (merged, credentials preserved).
- Overwrite `docs/ai/permission-matrix.md` (roles × use cases).
- Updated `docs/ai/srs/_fingerprint.json` (stale-index detection).
- List the TBDs / boundary questions for the team to confirm (incl. roles to add,
  and credentials still to be set per role).
