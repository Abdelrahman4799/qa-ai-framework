# About the AI QA Framework

> **One line:** a repository-based framework that turns an AI assistant (Claude Code)
> into a disciplined QA tester — it reads your requirements, designs thorough test
> cases, runs them in a real browser, files real defects, and pushes everything to
> Azure DevOps, with guardrails that make the safety rules unbreakable.

This is the single "explain everything" document. For the rationale see
[OVERVIEW.md](OVERVIEW.md); to get started see [QUICKSTART.md](QUICKSTART.md); for the
visual map see [framework-diagram.html](framework-diagram.html) /
[ARCHITECTURE.md](ARCHITECTURE.md); to extend it see [EXTENDING.md](EXTENDING.md).

---

## 1. What it is

A set of plain Markdown instructions, skills, and hooks that live **inside a Git
repository**. When you open the repo in Claude Code, those files steer the AI through a
fixed, safe QA pipeline. It is:

- **Requirements-driven** — your SRS (and a decisions log) are the only source of truth.
- **Black-box** — it tests the *running* application through the Playwright MCP; it never
  reads or changes source code, so it fits a testing team that only has the deployed app.
- **Enforced** — the critical rules aren't suggestions; deterministic hooks block unsafe
  actions outside the model.
- **Token-efficient** — the full SRS is read once to build an index; every test run reads
  only the one use case in scope plus its related sections.
- **Generic & reusable** — ships as a template; app-specific knowledge lives in per-project
  files you fill in, never hard-coded into the framework.

## 2. The problem it solves

Manual QA is slow and uneven; coverage, regression scope, and traceability depend on who
did the work that day. Throwing an SRS at a chatbot is worse — it forgets between sessions,
invents requirements when the spec is silent, is inconsistent, leaks secrets, and burns
tokens. This framework keeps the context, rules, and workflows **in the repo**, so testing
is repeatable, traceable, safe, and cheap to run. (Full breakdown in
[OVERVIEW.md](OVERVIEW.md).)

## 3. Why use it

- **Thorough by construction** — every use case is understood deeply (main / alternate /
  exception flows), every SRS sentence is tracked, and a 12-dimension checklist makes
  skipped categories *visible* instead of silent.
- **Real execution, real evidence** — tests run in an actual browser with screenshots and
  a run report, not just generated text.
- **Safe on shared/real environments** — never production, never mutate records you didn't
  create, never leak the token, never upload before human review.
- **Full traceability** — requirement / use case / decision → test case → result → defect →
  Azure DevOps work item, with bugs linked to their test cases.
- **Improves itself** — a self-heal loop proposes better rules (only applied on your
  approval); session handoffs preserve continuity.
- **Low cost** — reads scale with the one use case under test, not the size of the SRS.

## 4. Features

**Requirements intake**
- Convert a Word `.docx` SRS with pandoc and split it into per-use-case files (configurable
  heading level); works for the baseline SRS and the new-feature SRS.
- Use-case **index/catalog**: per UC — section, requirement refs, **actors**, **depends-on**,
  related UCs, summary; plus a **fingerprint** that warns when the index is stale.
- **Permission matrix** (roles × use cases) auto-derived from SRS actors; role universe
  auto-populated.
- **Decisions log** (`DEC-###`) — BA/product rulings not in the SRS, a legitimate source of
  truth a case can cite.

**Test-case generation**
- Works on **one chosen use case** at a time; discovers and **confirms** related/dependent
  use cases with you.
- Covers **every SRS statement**, every flow, and every applicable **coverage dimension**
  (functional, negative, boundary, RBAC, integration, concurrency, list-ops, soft-delete,
  audit, localization/RTL, theme, a11y).
- **Role-based**: positive for each allowed actor, denied for each other role.
- **Dependency-aware** preconditions; **precondition-feasibility tags**
  (self-serviceable / needs-fixture / needs-config / needs-live-action).
- **Test Data Preparation** with explicit build/navigation paths — no hardcoded dummy data.
- **Consolidation** of redundant cases; links the new-feature UC to its **related baseline
  test cases**; full traceability (UC + REQ + DEC).
- A bounded **`/goal` loop** iterates until coverage is complete.

**Execution (Playwright MCP)**
- Runs against the **pinned test environment** (never production); **role switching**;
  optional **parallel runners** (you choose how many).
- **Auto-provisions** missing prerequisite data (via UI or **API** when faster); uses named
  **fixtures** for deep/irreversible state; **BLOCKED** only as a last resort.
- **Verification** from persisted state (reload before asserting); result states
  PASS / FAIL / BLOCKED / **INCONCLUSIVE** / **FLAKY** (one controlled retry).
- **Multi-session/concurrency** support; a bounded **`/goal` loop** drives every case to a
  definitive result; **run report** with evidence + residue.

**Defects, review & upload**
- **Triage** turns real failures into classified bugs — including non-functional classes
  (silent failure / missing user feedback, localization/RTL, theme/a11y, audit gaps).
- **Human review gate** must approve before anything is uploaded.
- **Azure DevOps** upload via REST + PAT: creates Test Case + Bug work items, de-dups, attaches
  evidence, and **links each bug to its test case** and new-feature cases to related baseline
  cases.
- **Coverage report**: requirement coverage + a per-UC × per-dimension matrix.
- **Exploratory charter**: time-boxed session-based testing whose findings feed triage /
  generation / decisions.

**Governance, safety & continuity**
- **Six hooks** enforce the rules deterministically: onboarding offer, per-turn reminders,
  stale-index warning, no-upload-before-review, no-PAT-leak, no-self-editing-rules-without-approval.
- **Credentials in a git-ignored `.env`** (loaded at runtime — no restart, no secrets in the repo).
- **Setup wizard** (interactive onboarding), **doctor** (health check), **self-heal**
  (approval-gated improvements + log), **session handoff + archive**.
- **App map** (navigation + known UI behaviors) and **test fixtures** (named seeded states)
  capture app knowledge once so runs don't re-derive it.

## 5. How it works (pipeline)

```
SETUP (once):   setup-wizard → doctor
PER BASELINE:   ingest-srs → index-srs  (catalog · actors · depends-on · permission matrix · fingerprint)
PER USE CASE:   generate-test-cases → execute-test-cases → triage-defect
                → review-results (GATE) → upload-to-devops
ALSO:           exploratory-charter · coverage-report · self-heal · save-session
```

The SRS is read in full only at indexing. Each test run reads tiny index files plus the
chosen use case's section and its confirmed related sections — then downstream stages read
generated artifacts, never the SRS again.

## 6. The safety model

LLM instructions are advisory; hooks are not. The costly mistakes are blocked outside the
model: uploads can't happen before the human review gate writes its marker, the PAT can't be
inlined into a command, and the AI can't edit its own rules without your approval. Everything
else (never production, never mutate others' data, no real PII, no invented requirements) is
reinforced every turn and checked at review.

## 7. Who it's for

- QA / testing teams validating a web application **from requirements, without source code**.
- Teams on **Azure DevOps** for test cases and bugs.
- **Multi-role** systems (Admin / Manager / Supervisor / Viewer …) needing permission testing.
- Anyone who wants AI-assisted testing that is **repeatable, traceable, and safe** rather than
  ad-hoc prompting.

## 8. What it does NOT do

- Doesn't read/modify application source code (black-box).
- Doesn't fix bugs (testers report; developers fix).
- Doesn't invent requirements, roles, or rules — gaps become `TBD` or a logged decision.
- Doesn't test the whole SRS at once — always one use case in scope.
- Doesn't upload without review, and can't leak the PAT.

## 9. What you provide vs. what it does

| You provide | The framework does |
|-------------|--------------------|
| SRS + new-feature spec (Markdown or Word) | Ingest, index, and understand it |
| App URL + environments, DevOps target | Pin scope; target uploads |
| Test accounts per role + PAT (in `.env`) | Run as each role; push to DevOps |
| Decisions/clarifications (as they arise) | Treat them as a valid source to cite |
| "Test UC-05" | Generate → execute → triage → (review) → upload |

## 10. FAQ

- **Does it need our source code?** No — black-box via the running app.
- **Will it test against production?** No — the environment is pinned; production is off-limits.
- **What if the SRS doesn't say something?** It won't guess — it flags `TBD` or cites a logged
  decision (`DEC-###`).
- **Are our credentials safe?** They live in a git-ignored `.env`, never committed; the PAT is
  never inlined (a hook blocks it).
- **Can we plug in our own test agents/tools?** Yes — see [EXTENDING.md](EXTENDING.md); stages
  are contract-based and swappable.
- **Is it tied to our app?** No — it's a generic template; your app's specifics live in
  per-project files you fill in.

## 11. Next

[QUICKSTART.md](QUICKSTART.md) · [OVERVIEW.md](OVERVIEW.md) · [README.md](README.md) ·
[ARCHITECTURE.md](ARCHITECTURE.md) · [EXTENDING.md](EXTENDING.md) ·
[framework-diagram.html](framework-diagram.html)
