# AI QA Framework — Overview & Rationale

> **In one sentence:** a repository-based framework that turns an AI assistant into a
> disciplined QA tester — driven by your SRS, executing real browser tests, filing
> real defects, and pushing them to Azure DevOps — with guardrails that make the
> rules unbreakable and a design that keeps token cost low.

This document explains **why** the framework exists, **what problems it solves**, and
**who should use it**. For setup see [QUICKSTART.md](QUICKSTART.md); for the visual
map see [framework-diagram.html](framework-diagram.html) and [ARCHITECTURE.md](ARCHITECTURE.md).

---

## 1. The problem

### 1a. Manual QA is slow and uneven
Writing test cases from a requirements spec, running them in the browser, capturing
evidence, filing well-formed bugs, and logging everything into Azure DevOps is
repetitive, time-consuming work. Coverage depends on who wrote the cases that day.
Regression scope is guessed. Traceability to requirements is often missing.

### 1b. Using AI ad-hoc makes it worse, not better
Teams that throw a requirements doc at a chatbot and say "write tests" hit a wall:

- **No memory between sessions.** Context resets; the assistant re-learns the project
  every time and contradicts itself.
- **It invents requirements.** When the spec is silent, the model guesses expected
  behavior — producing confident, wrong test results.
- **It is inconsistent.** Test-case format, severity, and bug structure drift from run
  to run and person to person.
- **It is unsafe.** Nothing stops it from leaking a token, uploading half-baked results,
  or testing against production.
- **It is expensive.** Dumping a whole SRS into context on every request burns tokens
  and still misses cross-cutting requirements.
- **No traceability or audit trail.** You can't prove what was tested, by whom, against
  which requirement, on which build.

### 1c. The testing team usually has no source code
QA validates the running application as a black box. Frameworks built for *developers*
(read the code, refactor, fix bugs) don't fit a testing team that must work purely from
**requirements + the deployed app**.

---

## 2. What this framework is

A set of plain files that live **inside a repository** and steer an AI assistant
(Claude Code) through a fixed, safe QA pipeline:

```
Word/Markdown SRS  →  index use cases  →  pick ONE use case
                   →  generate test cases (role- & dependency-aware)
                   →  execute in a real browser (Playwright MCP)
                   →  triage defects  →  review GATE  →  upload to Azure DevOps
```

It is **requirements-driven** (the SRS is the only source of truth), **black-box**
(no source code needed), and **enforced** (hooks, not hope).

---

## 3. Problems it solves — mapped

| Problem | How the framework solves it |
|---|---|
| AI forgets between sessions | Rules and context live in the repo; a tiny `handoff.md` resumes each session, with a full append-only `sessions/` archive |
| AI invents requirements | The SRS is the only source of truth; anything unstated is marked `TBD - needs team confirmation`, never guessed |
| Inconsistent output | Fixed standards for test cases, defects, severity, and a required final-response format |
| Token cost of big specs | The full SRS is read **once** to build an index; every test run reads only one use-case section + its confirmed neighbors |
| No regression scope | Use-case `Related` and directional `Depends on` links drive the regression/impact set automatically |
| Role/permission gaps | Actors per use case are extracted from the SRS into a permission matrix; tests cover allowed **and** denied roles |
| Broken access control slips through | A role doing what it must not is treated as a **high-severity security defect** |
| Unsafe automation | Hooks **block** uploads before review, **block** PAT leaks, and **block** the AI editing its own rules without approval |
| Testing against the wrong target | Environment is pinned in `context.md`; production is explicitly off-limits |
| Flaky browser tests → false bugs | One controlled retry; pass-on-retry is flagged FLAKY, not filed as a defect |
| No traceability / audit | Requirement → use case → test case → result → defect → DevOps work item, plus coverage and per-run reports |
| Word docs aren't AI-ready | `ingest-srs` converts `.docx` with pandoc and splits it into per-use-case files |
| The framework itself going stale | A self-heal loop proposes rule improvements (applied only on your approval); a fingerprint warns when the index is out of date |

---

## 4. Why it is efficient (token cost)

Big specs are expensive to feed to an LLM. The framework borrows one idea everywhere:
**a tiny always-read pointer + a detailed on-demand archive.**

- The **full SRS is read once** (indexing) → a small use-case catalog.
- Each test run reads `context.md` + tiny index files + **one use-case section** and its
  confirmed related sections — typically a few KB, not the whole spec.
- Downstream stages (execute, triage, upload) read generated artifacts, **never the SRS
  again**.
- Session history uses the same split: a small handoff is loaded by default; full session
  logs are opened only on request.

Result: cost scales with the **one use case under test**, not the size of your SRS.

---

## 5. Why it is safe (enforcement, not hope)

LLM instructions are advisory. This framework backs the non-negotiables with **hooks** —
deterministic scripts that run outside the model and can deny an action:

- **No upload before review** — the DevOps upload is blocked until a human-approved
  review marker exists.
- **No secret leaks** — any command that inlines the Azure DevOps token is blocked.
- **No self-editing without approval** — the AI cannot change its own rules/skills unless
  you approve the specific change.
- **Always-on reminders + stale-index warnings** injected every turn.

So "please follow the rules" becomes rules that hold.

---

## 6. Who should use it

- **QA / testing teams** validating a web application from requirements, without source code.
- Teams already on **Azure DevOps** for test cases and bugs.
- Teams with a **multi-role** system (Admin / Manager / Supervisor / Viewer …) that need
  permission testing.
- Anyone who wants **AI-assisted testing that is repeatable, traceable, and safe**, rather
  than ad-hoc prompting.

---

## 7. What it deliberately does NOT do

Being honest about scope is part of the design:

- It does **not** read or modify application source code — it is black-box.
- It does **not** fix bugs — testers report; developers fix.
- It does **not** invent requirements, roles, or dependencies — gaps become `TBD`.
- It does **not** test the whole SRS at once — always one use case in scope.
- It does **not** upload anything without a passed review gate, and **cannot** leak the PAT.
- It is only as complete as your SRS: stated actors, preconditions, and acceptance
  criteria drive coverage; silence becomes a flagged question, not a guess.

---

## 8. The outcome

- **Faster** test-case creation and execution, with evidence captured automatically.
- **Higher, measurable coverage** — every requirement traced, gaps reported, roles covered.
- **Fewer false bugs** (flaky handling) and **fewer duplicates**.
- **Full traceability** from requirement to DevOps work item, with a per-run report and a
  permission matrix.
- **Safe by construction** — the costly mistakes (leaks, premature uploads, production
  testing) are blocked, not merely discouraged.
- **Continuity** — the project's testing knowledge lives in the repo and improves over time.

---

## 9. Start here

1. [QUICKSTART.md](QUICKSTART.md) — setup to first tested use case.
2. [framework-diagram.html](framework-diagram.html) — the visual map.
3. [README.md](README.md) — layout and daily usage.
4. [ARCHITECTURE.md](ARCHITECTURE.md) — diagrams and component detail.
