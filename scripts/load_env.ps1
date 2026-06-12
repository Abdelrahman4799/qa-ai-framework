# load_env.ps1 — load the repo-root .env into the current process environment.
# Dot-source it so the variables persist in your session/script:
#     . scripts/load_env.ps1
# Reads KEY=VALUE lines (ignores blanks and # comments; strips surrounding quotes)
# and sets each as a process-scope env var. No restart needed — read at runtime.
$candidates = @()
$candidates += (Join-Path (Get-Location) ".env")
if ($PSScriptRoot) { $candidates += (Join-Path (Split-Path $PSScriptRoot -Parent) ".env") }
$envFile = $candidates | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1
if (-not $envFile) { return }

foreach ($line in (Get-Content -LiteralPath $envFile)) {
  $t = $line.Trim()
  if (-not $t -or $t.StartsWith('#')) { continue }
  $i = $t.IndexOf('=')
  if ($i -lt 1) { continue }
  $k = $t.Substring(0, $i).Trim()
  $v = $t.Substring($i + 1).Trim() -replace '^[''"]', '' -replace '[''"]$', ''
  if ($k) { Set-Item -Path "Env:$k" -Value $v }
}
