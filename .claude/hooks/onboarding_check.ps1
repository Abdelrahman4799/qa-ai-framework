# SessionStart hook — if setup is incomplete, prompt Claude to run the setup wizard.
# stdout from a SessionStart hook is added to the session context. Stays silent once
# setup is complete, so it does not nag.
$msgs = @()

$tbd = 0
foreach ($f in @("docs/ai/context.md","docs/ai/devops-policy.md")) {
  if (Test-Path $f) {
    $tbd += (Select-String -Path $f -Pattern 'TBD' -AllMatches |
             ForEach-Object { $_.Matches.Count } | Measure-Object -Sum).Sum
  }
}
if ($tbd -gt 0) { $msgs += "$tbd config TBD(s) remain in context.md / devops-policy.md" }
if (-not $env:AZURE_DEVOPS_PAT) { $msgs += "AZURE_DEVOPS_PAT is not set" }

if ($msgs.Count -gt 0) {
  Write-Output ("[QA Framework] Setup looks incomplete: " + ($msgs -join "; ") +
    ". Offer to run the setup-wizard skill now - ask the user for each TBD ONE at a " +
    "time and update the config files. Guide secret/env-var setup separately and never " +
    "write secrets into repo files. Do not begin testing until setup is complete or the " +
    "user declines.")
}
exit 0
