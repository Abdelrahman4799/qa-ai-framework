# set_env.ps1 — upsert one KEY=VALUE into the repo-root .env (create if missing).
# Used by the setup wizard to store one credential at a time without clobbering
# the other keys or comments.
#   powershell -NoProfile -ExecutionPolicy Bypass -File scripts/set_env.ps1 -Key AZURE_DEVOPS_PAT -Value "<value>"
param(
  [Parameter(Mandatory = $true)][string]$Key,
  [Parameter(Mandatory = $true)][AllowEmptyString()][string]$Value,
  [string]$Path = ".env"
)

$full = if ([System.IO.Path]::IsPathRooted($Path)) { $Path } else { Join-Path (Get-Location) $Path }

if (-not (Test-Path $full)) {
  if (Test-Path ".env.example") { Copy-Item ".env.example" $full }
  else { New-Item -ItemType File -Path $full | Out-Null }
}

$lines = @(Get-Content -LiteralPath $full)
$set = $false
for ($i = 0; $i -lt $lines.Count; $i++) {
  if ($lines[$i] -match ("^\s*" + [regex]::Escape($Key) + "\s*=")) {
    $lines[$i] = "$Key=$Value"; $set = $true; break
  }
}
if (-not $set) { $lines += "$Key=$Value" }

[System.IO.File]::WriteAllLines($full, $lines, (New-Object System.Text.UTF8Encoding($false)))
Write-Host "Set $Key in $Path"
