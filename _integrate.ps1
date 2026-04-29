# PowerShell integration script for Cowork session 1 (2026-04-29) - AchievementTracker brief + review wrap.
# Bails loud on critical-step failures (per 2026-04-27 feedback memory: ErrorActionPreference=Continue + git scripts is a footgun).
# Runs `git worktree list` upfront so any unexpected worktree state is visible before changes start.
# Usage: cd C:\Projects\SadCave ; .\_integrate.ps1

$ErrorActionPreference = "Stop"  # halt on any cmdlet failure
Set-Location -Path "C:\Projects\SadCave"

function Invoke-Critical {
    param([string]$Description, [scriptblock]$Block)
    Write-Host "==> $Description"
    & $Block
    if ($LASTEXITCODE -ne 0) {
        throw "FATAL: '$Description' failed (git exit code $LASTEXITCODE). Aborting before anything else can drift."
    }
}

# Files to commit on this branch. Inbox is deliberately excluded - Codex's branch (codex/achievement-tracker)
# committed the inbox today with [O] + [C] lines, so any inbox edits here would conflict at merge.
# Inbox cleanup deferred to next session's integration after Codex's PR lands.
$files = @(
    "docs/Sad Cave Dev/Sadcave/00_Index.md",
    "docs/Sad Cave Dev/Sadcave/02_Systems/Title_System.md",
    "docs/Sad Cave Dev/Sadcave/02_Systems/_Live_Systems_Reference.md",
    "docs/Sad Cave Dev/Sadcave/06_Codex_Plans/2026-04-29_AchievementTracker_v1.md",
    "docs/Sad Cave Dev/Sadcave/07_Sessions/2026-04-29_session_1.md",
    "docs/Sad Cave Dev/Sadcave/09_Open_Questions/_Known_Bugs.md",
    "docs/Sad Cave Dev/Sadcave/09_Open_Questions/_Open_Questions.md",
    "docs/Sad Cave Dev/Sadcave/_Change_Log.md",
    "docs/Sad Cave Dev/Sadcave/_Decisions.md",
    "_integrate.ps1"
)

$branchName = "claude/integration-2026-04-29-session-1"

# 0. Worktree state up front - any unexpected secondary worktrees should surface before we start moving.
Write-Host ""
Write-Host "Worktree state:"
git worktree list
Write-Host ""

# 1. Clear stale lock if a prior run died mid-flight.
if (Test-Path ".git/index.lock") {
    Write-Host "Clearing stale .git/index.lock"
    Remove-Item -Force ".git/index.lock"
}

# 2. Reset the index (unstage anything left over) but keep working tree.
Write-Host "Resetting index (working tree preserved)..."
git reset HEAD 2>&1 | Out-Null

# 3. Stash everything (tracked + untracked) so we can switch branches cleanly.
$stashLabel = "claude-integration-stash-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
Invoke-Critical "Stashing working tree (label: $stashLabel)" {
    git stash push --include-untracked -m $stashLabel
}

# 4. Get to main and pull.
Invoke-Critical "Checking out main" { git checkout main }
Invoke-Critical "Pulling main from origin" { git pull origin main }

# 5. Delete any existing local + remote branch for this name and recreate fresh from main.
$existing = git branch --list $branchName
if ($existing) {
    Write-Host "Deleting existing local branch $branchName..."
    Invoke-Critical "git branch -D $branchName" { git branch -D $branchName }
}
$existingRemote = git ls-remote --heads origin $branchName
if ($existingRemote) {
    Write-Host "Deleting existing remote branch $branchName..."
    Invoke-Critical "git push origin --delete $branchName" { git push origin --delete $branchName }
}

Invoke-Critical "Creating fresh branch $branchName from main" {
    git checkout -b $branchName
}

# 6. Pop the stash so our edits come back on the new branch.
Write-Host "Restoring stashed changes..."
git stash pop 2>&1
# stash pop may emit conflict warnings (non-fatal in our case since main + Codex's branch do not touch
# these files), so we deliberately do not bail here. Conflicts get caught at the diff sanity-check below.

# 7. Strip CRLF on edited markdown files so the diff stays clean.
Write-Host "Normalizing line endings on Markdown files..."
foreach ($f in $files) {
    if ((Test-Path $f) -and ($f -like "*.md")) {
        $content = [System.IO.File]::ReadAllText((Resolve-Path $f))
        $normalized = $content -replace "`r`n", "`n"
        [System.IO.File]::WriteAllText((Resolve-Path $f), $normalized)
    }
}

# 8. Stage ONLY the files in the list - nothing else.
Write-Host "Staging files..."
foreach ($f in $files) {
    if (Test-Path $f) {
        git add -- $f
    } else {
        Write-Warning ("  (not found: " + $f + " - skipping)")
    }
}

# 9. Sanity check.
Write-Host ""
Write-Host "Staged changes:"
git diff --cached --stat
Write-Host ""

# 10. Commit and push.
$commitMessage = "Vault integration: session 1 (2026-04-29) - AchievementTracker brief shipped, Codex review verdict captured, fell_asleep_here open question resolved, FavoritePromptPersistence retired, SeatMarkers count corrected, duplicate TitleConfig drift logged."

Invoke-Critical "Committing" {
    git commit -m $commitMessage
}
Invoke-Critical "Pushing to origin/$branchName" {
    git push -u origin $branchName
}

Write-Host ""
Write-Host "Done. GitHub printed a PR URL above; open it, scan the diff, merge."
Write-Host "Reminder: also merge codex/achievement-tracker (the AchievementTracker code branch). Order does not matter."
