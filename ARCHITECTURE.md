# Framework Architecture

Visual reference for the AI QA Framework. Diagrams are written in Mermaid and
render in GitHub, VS Code (with a Mermaid extension), and most Markdown viewers.

Contents:
1. [The pipeline](#1-the-pipeline-end-to-end) — end to end
2. [System layers](#2-system-layers) — what the files are
3. [Enforcement](#3-enforcement-hooks) — the hooks and what they gate
4. [Token-efficient read path](#4-token-efficient-read-path)
5. [Session lifecycle](#5-session-lifecycle)
6. [One-line mental model](#6-mental-model)

---

## 1. The pipeline (end to end)

The core flow: a single **chosen use case** travels from the SRS, through
generation and execution, past a review gate, into Azure DevOps. Cylinders are
persisted artifacts; the diamond is the human-approved gate.

```mermaid
flowchart TD
    SRS["Existing SRS<br/>docs/ai/srs/"]
    NFS["New-feature SRS<br/>docs/ai/new-feature-srs/"]

    SRS --> S1["1 · index-srs<br/>read full SRS ONCE<br/>build UC catalog"]
    S1 --> IDX[("srs/_index.md<br/>+ _fingerprint.json")]

    NFS --> S2
    IDX --> S2["2 · generate-test-cases<br/>SELECT one UC · discover + CONFIRM<br/>cases + regression set"]
    S2 -.->|"/goal loop ≤3<br/>maximise coverage"| S2
    S2 --> TC[("test-cases/UC-xx/<br/>traceability.md<br/>coverage.md")]

    TC --> S3["3 · execute-test-cases<br/>Playwright MCP · auto-provision data<br/>PASS / FAIL / BLOCKED / FLAKY"]
    S3 -.->|"/goal loop ≤3<br/>definitive results"| S3
    S3 --> RUN[(".qa-state/runs/id/<br/>screenshots + RUN-REPORT.md")]

    RUN --> S4["4 · triage-defect<br/>FAIL that contradicts SRS<br/>= classified bug"]
    S4 --> S5{"5 · review-results<br/>GATE"}
    S5 -->|fail| FIX["fix & re-review<br/>no marker written"]
    FIX --> S5
    S5 -->|pass| MARK[(".qa-state/<br/>review-passed.json")]
    MARK --> S6["6 · upload-to-devops<br/>REST + PAT<br/>Test Case + Bug"]
    S6 --> ADO[["Azure DevOps"]]
```

**Reading it:** `index-srs` is the only full-SRS read and runs once. Everything
after is scoped to one use case. Stages 2 and 3 each run a bounded **`/goal` loop**
(≤3 rounds, early-stop on no progress) — generate iterates to maximise coverage,
execute iterates to drive every case to a definitive PASS/FAIL, **auto-provisioning**
missing prerequisite data (synthetic, test-env only) instead of blocking. The gate
(stage 5) is the single point that can authorize an upload — it writes a marker file
that stage 6's hook checks, after which results land in Azure DevOps.

---

## 2. System layers

Four kinds of files plus the persistent stores. Only the top layer is loaded
every session; everything else is read on demand.

```mermaid
flowchart TB
    subgraph L1["Always loaded · every session"]
        A1["CLAUDE.md"]
        A2["AGENTS.md"]
        A3["context.md"]
        A4["handoff.md"]
    end
    subgraph L2["Policies · read on demand"]
        P1["test-case-standards"]
        P2["execution-policy"]
        P3["defect-policy"]
        P4["devops-policy"]
        P5["test-data-policy"]
        P6["glossary"]
    end
    subgraph L3["Skills · the pipeline"]
        K1["index-srs"]
        K2["generate-test-cases"]
        K3["execute-test-cases"]
        K4["triage-defect"]
        K5["review-results"]
        K6["upload-to-devops"]
        K8["coverage-report"]
        K9["self-heal"]
        K10["save-session"]
    end
    subgraph L4["Enforcement · .claude/hooks"]
        H1["inject_reminder"]
        H2["srs_fingerprint"]
        H3["guard_upload"]
        H4["scan_secrets"]
        H5["guard_selfheal"]
    end
    subgraph L5["Persistent stores"]
        D1["srs + new-feature-srs"]
        D2["test-cases/"]
        D3["sessions/"]
        D4[".qa-state/ · runtime"]
    end

    L1 --> L3
    L2 --> L3
    L3 --> L5
    L4 -. guards .-> L3
```

**Reading it:** entry files tell the AI *what to read and when*; policies are the
*how-we-test* rules; skills are the *workflows*; hooks *enforce* the rules from
outside the model; stores hold everything that persists between sessions.

---

## 3. Enforcement (hooks)

Markdown rules are advisory; hooks are deterministic and run outside the model.
Diamonds are checks; a DENY blocks the tool call (exit code 2).

```mermaid
flowchart TD
    subgraph PROMPT["On every user prompt"]
        H1["inject_reminder<br/>re-inject core rules"]
        H2["srs_fingerprint<br/>warn if index is stale"]
    end
    subgraph SHELL["Before any Bash / PowerShell call"]
        H3{"guard_upload<br/>targets Azure DevOps?"}
        H4{"scan_secrets<br/>PAT inline?"}
    end
    subgraph EDIT["Before any Edit / Write"]
        H5{"guard_selfheal<br/>governed rule file?"}
    end

    H3 -->|yes & no review marker| B1["DENY upload"]
    H3 -->|marker present| OK1["allow"]
    H4 -->|PAT found inline| B2["DENY command"]
    H4 -->|clean| OK2["allow"]
    H5 -->|yes & no approval marker| B3["DENY edit"]
    H5 -->|approved or not governed| OK3["allow"]
```

| Hook | Trigger | Guarantees |
|------|---------|-----------|
| `inject_reminder` | every prompt | core rules never drift out of context |
| `srs_fingerprint` | every prompt | warns when the use-case index is stale |
| `guard_upload` | shell calls | no DevOps upload before the review gate |
| `scan_secrets` | shell calls | the PAT is never inlined / leaked |
| `guard_selfheal` | Edit/Write | the AI cannot edit its own rules without approval |

All hooks **fail open** (a parse error or missing file = allow + no warning), so
they never block legitimate work — worst case they stay silent.

---

## 4. Token-efficient read path

What actually gets loaded for one run. Green = the only substantial reads, and
they are single sections — never the whole SRS.

```mermaid
flowchart LR
    Q["You: test UC-05"] --> R1["context.md · tiny"]
    R1 --> R2["handoff.md · tiny"]
    R2 --> R3["new-feature-srs/_index.md · tiny"]
    R3 --> R4["chosen UC section ONLY"]
    R4 --> R5["srs/_index.md · tiny"]
    R5 --> R6["related UC sections ONLY"]
    R6 --> GEN["generate test cases"]

    style R4 fill:#d7f5d7,stroke:#2e7d32
    style R6 fill:#d7f5d7,stroke:#2e7d32
```

**Reading it:** the full SRS is read **once** (at `index-srs`). Every test run
reads only small index files plus the one use case in scope and its confirmed
related sections. Downstream stages (execute / triage / upload) read
`test-cases/` and `.qa-state/` — they never reopen the SRS.

---

## 5. Session lifecycle

History uses a hybrid: a tiny always-read handoff + a full append-only archive.

```mermaid
flowchart LR
    ST["Session start"] --> RH["read handoff.md · tiny"]
    RH --> WORK["run pipeline stages"]
    WORK --> SS["save-session"]
    SS --> AR["append sessions/SESSION-date.md<br/>full · kept forever"]
    SS --> OV["overwrite handoff.md<br/>tiny · for next time"]
    OV --> END["Session end"]
```

**Reading it:** you get a complete audit trail (the `sessions/` pile never
shrinks) without growing per-session token cost — only the small handoff is read
next time; a specific session file is opened only on request.

---

## 6. Mental model

> **Pick a use case → the framework reads only that slice of the spec, discovers
> what it touches (with your confirmation), tests it in a real browser, files real
> bugs, and — only after a review gate — pushes everything to Azure DevOps, with
> hooks making the safety rules unbreakable, a self-heal loop improving the rules
> on your approval, and session handoffs preserving continuity.**
