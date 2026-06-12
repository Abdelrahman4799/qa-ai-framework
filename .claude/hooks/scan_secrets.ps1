# PreToolUse hook — blocks any command that inlines the Azure DevOps PAT or a
# hardcoded Basic auth token. The PAT must be referenced as $env:AZURE_DEVOPS_PAT
# and the auth header built at runtime. Exit code 2 denies the tool call.
$raw = [Console]::In.ReadToEnd()
try { $data = $raw | ConvertFrom-Json } catch { exit 0 }

$cmd = $data.tool_input.command
if (-not $cmd) { exit 0 }

$pat = $env:AZURE_DEVOPS_PAT
if (-not $pat) {
    $envFile = Join-Path (Get-Location) '.env'
    if (Test-Path $envFile) {
        $m = Select-String -Path $envFile -Pattern '^\s*AZURE_DEVOPS_PAT\s*=\s*(.+)$' | Select-Object -First 1
        if ($m) { $pat = ($m.Matches[0].Groups[1].Value.Trim() -replace '^[''"]', '' -replace '[''"]$', '') }
    }
}
if ($pat -and $cmd.Contains($pat)) {
    [Console]::Error.WriteLine('BLOCKED: the PAT value appears inline in this command. Reference $env:AZURE_DEVOPS_PAT instead, never the token text.')
    exit 2
}

if ($cmd -match 'Authorization:\s*Basic\s+[A-Za-z0-9+/=]{20,}') {
    [Console]::Error.WriteLine('BLOCKED: hardcoded Basic auth header detected. Build the header from $env:AZURE_DEVOPS_PAT at runtime.')
    exit 2
}
exit 0
