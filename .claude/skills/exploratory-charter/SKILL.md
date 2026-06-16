---
name: exploratory-charter
description: Session-based exploratory testing — time-boxed, charter-driven investigation of an area to find issues and test ideas that scripted cases miss. Findings feed triage-defect, generate-test-cases, and decisions.
---

# Skill: Exploratory Charter

Structured, time-boxed exploration of an area or use case — complementary to scripted
test cases, not a replacement. Use it to probe risk, learn the app, and surface issues
and test ideas the scripted set didn't anticipate.

## Inputs
- The area / use case / feature to explore (ask the user if unspecified).
- `docs/ai/context.md` (env + accounts), `docs/ai/app-map.md` (navigation/gotchas),
  `docs/ai/coverage-dimensions.md` (idea prompts), `docs/ai/decisions.md`.

## Steps
1. CHARTER — agree a one-line mission and bounds before exploring:
   - Mission: "Explore <area> for <risk/quality goal>."
   - Scope / areas in and out; the role(s) to use; a time-box (e.g. 30–45 min).
2. EXPLORE via Playwright MCP — interact freely, follow hunches:
   - Vary inputs, sequences, roles, data shapes, interrupted/abandoned flows, back/refresh,
     concurrent actions; use `coverage-dimensions.md` as idea prompts (boundaries, RTL,
     theme, concurrency, list ops…). Navigate via `app-map.md`.
   - Stay on the env in `context.md` (never production). Create your own disposable data
     (`QA_<runid>_`); never edit/delete records you didn't create. No real PII.
3. NOTE as you go — keep a running session log: what you tried, what you observed,
   surprises, questions, and ideas. Capture screenshots/evidence for anything notable.
4. CLASSIFY findings:
   - Likely bug (contradicts SRS / DEC, or a silent-failure UX defect) → hand to
     **triage-defect** (don't file directly).
   - New scripted-case idea → note for **generate-test-cases**.
   - Unclear rule / unanswered question → record for `docs/ai/decisions.md` as `TBD`.
   - App behavior/quirk worth keeping → propose adding to `app-map.md`.

## Output — write a session report to `.qa-state/exploratory/<id>.md`
- Charter (mission, scope, role(s), time-box) and actual duration
- Areas covered / not covered (so gaps are visible)
- Findings: candidate defects · new test-case ideas · open questions · risks
- Evidence references

## Rules
- Time-boxed and scoped — don't drift into a full regression.
- Exploratory does NOT upload anything. Bugs go through triage-defect → review-results
  → upload-to-devops like any other finding.
- Surface, don't guess: unconfirmed behavior is a question/risk, not a stated fact.
