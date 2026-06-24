# UserPromptSubmit hook — re-injects the core QA rules into context every prompt.
# stdout from a UserPromptSubmit hook is added to the model's context.
Write-Output "[QA Framework] Read docs/ai/context.md first. Work on ONE chosen use case only. Expected results come from the SRS / new-feature SRS, never assumption. Trace every test case to a UC-### / requirement ID. During execution, AUTOMATICALLY prepare/seed required data (API-first, via Admin) - do not wait to be asked. No Azure DevOps upload before the review gate writes .qa-state/review-passed.json. Never inline the PAT - use `$env:AZURE_DEVOPS_PAT."
exit 0
