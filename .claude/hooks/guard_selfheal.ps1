# PreToolUse hook (Edit|Write) — blocks the AI from editing GOVERNED framework
# files (rules / skills / methodology policies) unless the user has approved a
# self-heal: .qa-state/improvement-approved.json must exist and list the target
# file. Enforces "apply only after my approval". Manual edits in an editor are
# unaffected (this only governs the AI's tool calls). Exit 2 denies the call.
$raw = [Console]::In.ReadToEnd()
try { $data = $raw | ConvertFrom-Json } catch { exit 0 }

$path = $data.tool_input.file_path
if (-not $path) { exit 0 }
$p = $path -replace '/', '\'

# Governed = files that define HOW the framework operates.
# NOT governed: SRS content, context.md, devops-policy.md, test-cases, .qa-state.
$governed = $false
if ($p -match '\\AGENTS\.md$') { $governed = $true }
if ($p -match '\\CLAUDE\.md$') { $governed = $true }
if ($p -match '\\\.claude\\skills\\') { $governed = $true }
if ($p -match '\\docs\\ai\\(test-case-standards|execution-policy|defect-policy|glossary)\.md$') { $governed = $true }

if (-not $governed) { exit 0 }

$marker = Join-Path (Get-Location) '.qa-state\improvement-approved.json'
if (-not (Test-Path $marker)) {
    [Console]::Error.WriteLine('BLOCKED: editing a governed framework file (rule/skill/policy) requires user approval. Use the self-heal skill: propose the change, get approval (writes .qa-state/improvement-approved.json), then apply.')
    exit 2
}

# Precision: the target file must be in the approved set.
try {
    $approved = (Get-Content $marker -Raw | ConvertFrom-Json).files
    $leaf = Split-Path $p -Leaf
    if ($approved -and -not ($approved -contains $leaf)) {
        [Console]::Error.WriteLine("BLOCKED: $leaf is not in the approved self-heal set. Re-run self-heal to approve this specific file.")
        exit 2
    }
} catch { }
exit 0
