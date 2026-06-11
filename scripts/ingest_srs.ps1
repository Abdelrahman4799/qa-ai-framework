# Ingest SRS — convert a Word (.docx) SRS to Markdown with pandoc, then split it
# into one file per use case at a configurable heading level.
#
#   Use cases  = headings at -UseCaseLevel (default 4 => ####)
#   Features   = headings ABOVE that level -> carried as a context breadcrumb
#   Body       = headings BELOW that level -> kept inside the use-case file
#
# Targets either the baseline SRS or the new-feature SRS via -Target.
#
# Usage:
#   powershell -NoProfile -ExecutionPolicy Bypass -File scripts/ingest_srs.ps1
#   powershell ... -File scripts/ingest_srs.ps1 -Target new-feature
#   powershell ... -File scripts/ingest_srs.ps1 -UseCaseLevel 3
#   powershell ... -File scripts/ingest_srs.ps1 -DocxPath "C:\path\SRS.docx" -UseCaseLevel 2
[CmdletBinding()]
param(
  [ValidateSet('baseline','new-feature')]
  [string]$Target = 'baseline',
  [ValidateRange(1,6)]
  [int]$UseCaseLevel = 4,
  [string]$DocxPath,
  [string]$Inbox,
  [string]$OutDir
)
$ErrorActionPreference = "Stop"

# Resolve target folders (explicit -Inbox/-OutDir override -Target)
if (-not $OutDir) {
  $OutDir = if ($Target -eq 'new-feature') { "docs/ai/new-feature-srs" } else { "docs/ai/srs" }
}
if (-not $Inbox) { $Inbox = Join-Path $OutDir "_inbox" }
$hashes = "#" * $UseCaseLevel
Write-Host ("Target : {0}  (use cases = level {1} '{2}')  ->  {3}" -f $Target, $UseCaseLevel, $hashes, $OutDir)

# 0. pandoc available?
$pandoc = Get-Command pandoc -ErrorAction SilentlyContinue
if (-not $pandoc) {
  Write-Error "pandoc is not installed or not on PATH. Install it: winget install JohnMacFarlane.Pandoc  (or https://pandoc.org/installing.html)"
  exit 1
}

# 1. Resolve the .docx
if (-not $DocxPath) {
  $cand = Get-ChildItem -Path $Inbox -Filter *.docx -File -ErrorAction SilentlyContinue | Select-Object -First 1
  if (-not $cand) { Write-Error "No .docx found. Pass -DocxPath or drop a Word file into $Inbox."; exit 1 }
  $DocxPath = $cand.FullName
}
if (-not (Test-Path $DocxPath)) { Write-Error "File not found: $DocxPath"; exit 1 }
Write-Host "Source : $DocxPath"

# 2. Convert docx -> single Markdown (gfm), extract images into _media
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$media  = Join-Path $OutDir "_media"
$fullMd = Join-Path $OutDir "_full.md"
& $pandoc.Source $DocxPath -f docx -t gfm --wrap=none --extract-media="$media" -o $fullMd
Write-Host "Converted to Markdown (images -> $media)"

# 3. Split at #### into one file per use case
$lines = Get-Content -LiteralPath $fullMd
$ancestors = @{}          # heading text by level, for the breadcrumb
$ucTitle = $null
$buffer  = $null
$crumb   = ""
$seq = 0
$created = New-Object System.Collections.Generic.List[string]
$utf8 = New-Object System.Text.UTF8Encoding($false)

function Save-UC {
  param([string]$Title, $Body, [string]$Crumb, [int]$Idx)
  if (-not $Title) { return $null }
  # use-case id: reuse one in the heading if present, else assign sequential
  $id = $null
  if ($Title -match '(UC[-_ ]?\d+)') { $id = ($Matches[1] -replace '[ _]','-').ToUpper() }
  if (-not $id) { $id = "UC-{0:D3}" -f $Idx }
  # slug from the title (strip a leading UC id so it is not duplicated)
  $slugSrc = $Title -replace '^\s*UC[-_ ]?\d+\s*[:.\-)]*\s*',''
  $slug = ($slugSrc -replace '[^A-Za-z0-9]+','-').Trim('-').ToLower()
  if ($slug.Length -gt 50) { $slug = $slug.Substring(0,50).Trim('-') }
  if (-not $slug) { $slug = "use-case" }
  $name = "$id-$slug.md"
  $path = Join-Path $script:OutDir $name
  # avoid clobber
  $n = 2
  while (Test-Path $path) { $name = "$id-$slug-$n.md"; $path = Join-Path $script:OutDir $name; $n++ }
  $sb = New-Object System.Text.StringBuilder
  if ($Crumb) { [void]$sb.AppendLine("<!-- context: $Crumb -->"); [void]$sb.AppendLine("") }
  foreach ($l in $Body) { [void]$sb.AppendLine($l) }
  [System.IO.File]::WriteAllText($path, $sb.ToString(), $utf8)
  return $name
}

foreach ($line in $lines) {
  $m = [regex]::Match($line, '^(#{1,6})\s+(.*)$')
  if ($m.Success) {
    $level = $m.Groups[1].Value.Length
    $text  = $m.Groups[2].Value.Trim()
    if ($level -lt $UseCaseLevel) {
      if ($ucTitle) { $created.Add((Save-UC $ucTitle $buffer $crumb $seq)); $ucTitle=$null; $buffer=$null }
      $ancestors[$level] = $text
      foreach ($k in @($ancestors.Keys)) { if ($k -gt $level) { $ancestors.Remove($k) } }
      continue
    }
    elseif ($level -eq $UseCaseLevel) {
      if ($ucTitle) { $created.Add((Save-UC $ucTitle $buffer $crumb $seq)) }
      $seq++
      $ucTitle = $text
      $crumb   = (1..([math]::Max(1,$UseCaseLevel-1)) | ForEach-Object { $ancestors[$_] } | Where-Object { $_ }) -join " > "
      $buffer  = New-Object System.Collections.Generic.List[string]
      [void]$buffer.Add(("#" * $UseCaseLevel) + " " + $text)
      continue
    }
  }
  if ($ucTitle) { [void]$buffer.Add($line) }   # body of the current use case
}
if ($ucTitle) { $created.Add((Save-UC $ucTitle $buffer $crumb $seq)) }

# 4. Clean up the intermediate full file
Remove-Item -LiteralPath $fullMd -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host ("Created {0} use-case file(s) in {1}:" -f $created.Count, $OutDir)
$created | Where-Object { $_ } | ForEach-Object { Write-Host "  - $_" }
if ($created.Count -eq 0) {
  Write-Warning ("No level-{0} ('{1}') use-case headings were found. Check the Word heading styles, or re-run with a different -UseCaseLevel." -f $UseCaseLevel, $hashes)
}
