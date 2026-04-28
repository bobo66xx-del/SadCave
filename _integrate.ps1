# PowerShell integration script for Cowork session 8 wrap.
# Recovery-aware: stashes any leftover state, force-recreates the branch, applies cleanly.
# Usage: cd C:\Projects\SadCave ; .\_integrate.ps1

$ErrorActionPreference = "Continue"
Set-Location -Path "C:\Projects\SadCave"

$files = @(
    "docs/Sad Cave Dev/Sadcave/00_Inbox/_Inbox.md",
    "docs/Sad Cave Dev/Sadcave/_Decisions.md",
    "docs/Sad Cave Dev/Sadcave/07_Sessions/2026-04-28_session_2.md"
)

# 1. Clear stale lock
if (Test-Path ".git/index.lock") {
    Write-Host "Clearing stale .git/index.lock"
    Remove-Item -Force ".git/index.lock"
}

# 2. Reset the index (unstage anything left from the prior run) but keep working tree
Write-Host "Resetting index (working tree preserved)..."
git reset HEAD 2>&1 | Out-Null

# 3. Stash everything (tracked + untracked) so we can switch branches cleanly
Write-Host "Stashing working tree..."
$stashLabel = "claude-integration-stash-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
git stash push --include-untracked -m $stashLabel 2>&1 | Out-Null

# 4. Get to main
Write-Host "Switching to main and pulling..."
git checkout main
git pull origin main

# 5. Delete any existing branch and recreate fresh from main
$branchName = "claude/integration-2026-04-28-session-8-wrap"
$existing = git branch --list $branchName
if ($existing) {
    Write-Host "Deleting existing local branch $branchName..."
    git branch -D $branchName
}
$existingRemote = git ls-remote --heads origin $branchName
if ($existingRemote) {
    Write-Host "Deleting existing remote branch $branchName..."
    git push origin --delete $branchName
}

Write-Host "Creating fresh branch $branchName from main..."
git checkout -b $branchName

# 6. Pop the stash so our edits come back on the new branch
Write-Host "Restoring stashed changes..."
git stash pop 2>&1

# 7. Strip CRLF on the edited files
Write-Host "Normalizing line endings..."
foreach ($f in $files) {
    if (Test-Path $f) {
        $content = [System.IO.File]::ReadAllText((Resolve-Path $f))
        $normalized = $content -replace "`r`n", "`n"
        [System.IO.File]::WriteAllText((Resolve-Path $f), $normalized)
    }
}

# 8. Stage ONLY the wrap files
Write-Host "Staging files..."
foreach ($f in $files) {
    if (Test-Path $f) {
        git add -- $f
    }
}

# 9. Sanity-check
Write-Host ""
Write-Host "Staged changes:"
git diff --cached --stat
Write-Host ""

# 10. Commit and push
git commit -m "Vault integration: session-8 wrap (recap + workflow decision + inbox clear)"
git push -u origin $branchName

Write-Host ""
Write-Host "Done. GitHub printed a PR URL above; open it, scan the diff, merge."
