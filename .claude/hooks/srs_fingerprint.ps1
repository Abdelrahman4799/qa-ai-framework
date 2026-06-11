# SRS fingerprint — stale-index detection.
#   -Write  : (run by the index-srs skill) store the current SRS fingerprint.
#   no arg  : (UserPromptSubmit hook) warn if the SRS changed since indexing.
# Hashes docs/ai/srs/*.md (excluding _index.md, README.md, _fingerprint.json)
# and compares against docs/ai/srs/_fingerprint.json. Identical hashing in both
# modes guarantees the check matches what was written.
param([switch]$Write)

$srsDir = Join-Path (Get-Location) 'docs\ai\srs'
if (-not (Test-Path $srsDir)) { exit 0 }

$files = Get-ChildItem -Path $srsDir -Filter *.md -File -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -ne '_index.md' -and $_.Name -ne 'README.md' } |
    Sort-Object Name
if (-not $files -or $files.Count -eq 0) { exit 0 }   # no SRS files yet

$sb = New-Object System.Text.StringBuilder
foreach ($f in $files) {
    $h = (Get-FileHash -Path $f.FullName -Algorithm SHA256).Hash
    [void]$sb.AppendLine("$($f.Name):$h")
}
$current = $sb.ToString().Trim()
$fp = Join-Path $srsDir '_fingerprint.json'

if ($Write) {
    $obj = [ordered]@{ fingerprint = $current; updatedAt = (Get-Date -Format 'yyyy-MM-dd') }
    ($obj | ConvertTo-Json) | Set-Content -Path $fp -Encoding UTF8
    Write-Output "SRS fingerprint updated."
    exit 0
}

# Check mode (UserPromptSubmit hook) — stdout is added to the model's context.
if (-not (Test-Path $fp)) {
    Write-Output "[QA Framework] Baseline SRS is present but not indexed (no fingerprint). Run the index-srs skill before generating test cases."
    exit 0
}
try { $stored = (Get-Content $fp -Raw | ConvertFrom-Json).fingerprint } catch { $stored = $null }
if ($stored -ne $current) {
    Write-Output "[QA Framework] The baseline SRS changed since index-srs last ran - the use-case index may be stale. Re-run index-srs before relying on scope/discovery."
}
exit 0
