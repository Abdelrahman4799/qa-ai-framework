---
name: self-heal
description: Propose and, after explicit user approval, apply improvements to the framework's own rules, skills, and methodology policies. Records every change in the improvements log.
---

# Skill: Self-Heal (Continuous Improvement)

During any stage, if you discover a better rule, a gap, a recurring friction, or
an enhancement to how the framework operates, propose it — and apply it ONLY
after the user approves.

## Scope
- MAY improve (governed framework files): `AGENTS.md`, `CLAUDE.md`, the
  methodology policies in `docs/ai/` (`test-case-standards.md`,
  `execution-policy.md`, `defect-policy.md`, `glossary.md`), and the skills in
  `.agents/skills/`.
- MUST NOT self-edit: SRS content / requirements (that goes through
  `promote-to-srs`) or the user's project config (`context.md`,
  `devops-policy.md` — the user owns those).
- MUST NEVER weaken a safety rule (review gate, no real PII, no PAT exposure, no
  production testing). Self-heal may only TIGHTEN guardrails, never loosen them,
  and only with explicit written approval.

## When to trigger
- A skill step was ambiguous or led you astray.
- You repeated a manual workaround that should be a documented rule.
- A policy is missing a case you just hit (e.g. a new defect field, new evidence need).
- An index / test-case format would be clearer or more consistent.

## Steps
1. CAPTURE — note the observation while you work. Do NOT interrupt the current
   task to edit files. Collect proposals until a natural checkpoint.
2. PROPOSE — for each proposal present:
   - Problem: what went wrong / what is missing
   - Target file + exact change as a before → after diff
   - Why it helps + any risk
   - Safety check: confirm it does not weaken a guardrail
3. WAIT for explicit approval. The user may approve all, some, or none.
4. APPLY (approved items only):
   - Write `.qa-state/improvement-approved.json`:
     ```json
     { "approvedAt": "<date>", "approvedBy": "<name>", "files": ["AGENTS.md", "..."] }
     ```
     (List the leaf filenames approved. The guard_selfheal hook checks this.)
   - Make the approved edits.
   - Delete / expire the marker when done so it cannot authorize later edits.
5. LOG — append an entry to `docs/ai/improvements-log.md`
   (date, files, summary, reason, approved by).
6. REPORT — what changed and what was deferred.

## Hard gate
- Edits to governed framework files are denied by the `guard_selfheal` hook
  unless `.qa-state/improvement-approved.json` exists and lists the target file.
  This enforces "apply only after approval".
- The user can always hand-edit any file directly in an editor — the gate only
  governs the AI's own tool-driven edits.

## Output
- Proposals (with diffs), the approval outcome, files changed, and the
  improvements-log entry reference.

## Example (for reference)

**Proposal presented to the user:**
- Problem: defect reports don't capture which browser the bug occurred in.
- Target: `docs/ai/defect-policy.md`
- Change:
  ```diff
  - - Environment + app URL + build/version (if known)
  + - Environment + app URL + browser/version + build/version (if known)
  ```
- Why: browser-specific bugs can't be reproduced without it.
- Safety check: adds a field; does not weaken any guardrail. OK

**Marker written after approval** (`.qa-state/improvement-approved.json`):
```json
{ "approvedAt": "2026-06-11", "approvedBy": "Isadora", "files": ["defect-policy.md"] }
```

**Log entry appended to `docs/ai/improvements-log.md`:**
```
| 2026-06-11 | defect-policy.md | Added browser/version to bug template | Repro needs browser info | Isadora |
```

Then the marker is deleted (one approval = one change set).
