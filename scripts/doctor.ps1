# Doctor — framework setup health check. READ-ONLY (changes nothing).
# Run from the repo root:
#   powershell -NoProfile -ExecutionPolicy Bypass -File scripts/doctor.ps1
$ok = 0; $warn = 0; $fail = 0
function Pass($m) { Write-Host "  [ OK ] $m";  $script:ok++ }
function Warn($m) { Write-Host "  [WARN] $m";  $script:warn++ }
function Fail($m) { Write-Host "  [FAIL] $m";  $script:fail++ }

Write-Host "AI QA Framework - setup doctor"
Write-Host ""

# Load credentials from .env so the checks below see them (no restart needed)
if (Test-Path "$PSScriptRoot\load_env.ps1") { . "$PSScriptRoot\load_env.ps1" }

# --- Credentials file ---
if (Test-Path ".env") { Pass ".env present (credentials loaded from it)" }
else { Warn "no .env file - copy .env.example to .env and fill it (or run setup-wizard)" }

# --- Tooling ---
if (Get-Command pandoc -ErrorAction SilentlyContinue) {
  Pass ("pandoc installed ({0})" -f (pandoc --version | Select-Object -First 1))
} else { Warn "pandoc not found - only needed for Word (.docx) ingest. Install: winget install JohnMacFarlane.Pandoc" }
if (Get-Command git -ErrorAction SilentlyContinue) { Pass "git installed" } else { Warn "git not found - needed to version/push the repo" }

# --- Secrets / DevOps ---
if ($env:AZURE_DEVOPS_PAT) { Pass "AZURE_DEVOPS_PAT is set (value not shown)" }
else { Fail "AZURE_DEVOPS_PAT not set - DevOps upload will fail. Set it as a User env var." }

# --- Per-role accounts: derive from test-data-policy.md, check each is set ---
$tdp = "docs/ai/test-data-policy.md"
if (Test-Path $tdp) {
  $names = Select-String -Path $tdp -Pattern '\$env:([A-Z0-9_]+)' -AllMatches |
           ForEach-Object { $_.Matches } | ForEach-Object { $_.Groups[1].Value } |
           Where-Object { $_ -ne 'AZURE_DEVOPS_PAT' -and $_ -notmatch '_$' } | Sort-Object -Unique
  if ($names) {
    foreach ($n in $names) {
      if ([Environment]::GetEnvironmentVariable($n)) { Pass "role account $n is set" }
      else { Warn "role account env var $n is referenced but not set" }
    }
  } else { Warn "no role account env vars referenced yet - run index-srs to populate roles, then set credentials" }
} else { Fail "$tdp missing" }

# --- Config TBDs ---
foreach ($f in @("docs/ai/context.md","docs/ai/devops-policy.md")) {
  if (Test-Path $f) {
    $n = (Select-String -Path $f -Pattern 'TBD' -AllMatches | ForEach-Object { $_.Matches.Count } | Measure-Object -Sum).Sum
    if ($n -gt 0) { Warn "$f still has $n 'TBD' placeholder(s) to fill" } else { Pass "$f has no TBDs left" }
  } else { Fail "$f missing" }
}

# --- Baseline SRS present ---
$srs = Get-ChildItem "docs/ai/srs" -Filter *.md -File -ErrorAction SilentlyContinue |
       Where-Object { $_.Name -ne 'README.md' -and $_.Name -ne '_index.md' }
if ($srs) { Pass ("baseline SRS present ({0} file(s))" -f $srs.Count) }
else { Warn "no baseline SRS files yet - add Markdown to docs/ai/srs, or drop a .docx in _inbox and run ingest-srs" }

# --- Index built + fresh ---
$fp = "docs/ai/srs/_fingerprint.json"
if (Test-Path $fp) {
  Pass "use-case index fingerprint present"
  $stale = & "$PSScriptRoot\..\.claude\hooks\srs_fingerprint.ps1" 2>$null
  if ($stale) { Warn "index may be STALE vs the SRS - re-run index-srs" } else { Pass "index is up to date" }
} elseif ($srs) { Warn "SRS present but not indexed yet - run index-srs" }
else { Warn "index not built yet" }

# --- Hooks + settings ---
$sj = ".claude/settings.json"
if (Test-Path $sj) {
  try { Get-Content $sj -Raw | ConvertFrom-Json | Out-Null; Pass "settings.json is valid JSON" }
  catch { Fail "settings.json is not valid JSON - hooks may not load" }
} else { Fail ".claude/settings.json missing - hooks won't run" }
$hooks = @("inject_reminder","srs_fingerprint","guard_upload","scan_secrets","guard_selfheal")
$missing = $hooks | Where-Object { -not (Test-Path ".claude/hooks/$_.ps1") }
if ($missing) { Fail ("missing hook scripts: {0}" -f ($missing -join ', ')) } else { Pass "all 5 hook scripts present" }

Write-Host ""
Write-Host ("Summary: {0} OK, {1} warning(s), {2} failure(s)" -f $ok, $warn, $fail)
if ($fail -gt 0) { Write-Host "Resolve the FAILs before running the pipeline." }
Write-Host "Note: also confirm the Playwright MCP is available in Claude Code (this script cannot check that)."
