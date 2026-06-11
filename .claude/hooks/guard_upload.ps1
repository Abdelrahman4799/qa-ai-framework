# PreToolUse hook — blocks Azure DevOps work-item uploads until the review gate
# has written .qa-state/review-passed.json. Exit code 2 denies the tool call.
$raw = [Console]::In.ReadToEnd()
try { $data = $raw | ConvertFrom-Json } catch { exit 0 }

$cmd = $data.tool_input.command
if (-not $cmd) { exit 0 }

# Only intercept calls that target Azure DevOps work items.
if ($cmd -match 'dev\.azure\.com' -or $cmd -match 'visualstudio\.com' -or $cmd -match '_apis/wit/workitems') {
    $marker = Join-Path (Get-Location) '.qa-state\review-passed.json'
    if (-not (Test-Path $marker)) {
        [Console]::Error.WriteLine('BLOCKED: Azure DevOps upload attempted before the review gate. Run the review-results skill; it must write .qa-state/review-passed.json before any upload.')
        exit 2
    }
}
exit 0
