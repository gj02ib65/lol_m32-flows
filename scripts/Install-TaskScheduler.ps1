# Install-TaskScheduler.ps1
# ONE-TIME SETUP SCRIPT — Run this on the church Windows host.
# No administrator rights required — the task runs as the current user.

$TaskName   = "M32 Flows Auto-Update"
$ScriptPath = "C:\m32-flows\scripts\Update-M32Flows.ps1"
$RepoPath   = "C:\m32-flows"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  M32 Flows Auto-Updater — Setup Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# --- Step 1: Verify the repo exists ---
if (-not (Test-Path $RepoPath)) {
    Write-Host "ERROR: The flows repo was not found at $RepoPath" -ForegroundColor Red
    Write-Host "Please clone the m32-flows repository first:" -ForegroundColor Yellow
    Write-Host "  git clone https://github.com/gj02ib65/lol_m32-flows.git $RepoPath" -ForegroundColor Yellow
    exit 1
}

Write-Host "[1/3] Found flows repo at $RepoPath" -ForegroundColor Green

# --- Step 2: Verify the update script exists ---
if (-not (Test-Path $ScriptPath)) {
    Write-Host "ERROR: Update script not found at $ScriptPath" -ForegroundColor Red
    exit 1
}

Write-Host "[2/3] Found update script at $ScriptPath" -ForegroundColor Green

# --- Step 3: Register the Scheduled Task using schtasks.exe ---
# Uses schtasks.exe instead of Register-ScheduledTask so NO admin rights are needed.
# The task runs as the current logged-in user every Monday at 8:00 AM.
# If the PC is not on at exactly 8:00 AM, it will run as soon as the user logs in.

$taskCommand = "powershell.exe -NonInteractive -ExecutionPolicy Bypass -File `"$ScriptPath`""

# /f  = force overwrite if task already exists
# /rl = run level LIMITED (no elevation, works without admin)
# /sc = schedule WEEKLY, /d = day, /st = start time
$result = schtasks.exe /create /f `
    /tn $TaskName `
    /tr $taskCommand `
    /sc WEEKLY `
    /d  MON `
    /st 08:00 `
    /rl LIMITED 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to create scheduled task." -ForegroundColor Red
    Write-Host $result -ForegroundColor Red
    exit 1
}

Write-Host "[3/3] Scheduled Task '$TaskName' registered successfully." -ForegroundColor Green
Write-Host ""
Write-Host "Setup complete!" -ForegroundColor Cyan
Write-Host "The flows will auto-update every Monday at 8:00 AM." -ForegroundColor Cyan
Write-Host "(No admin rights were required.)" -ForegroundColor Gray
Write-Host ""
Write-Host "To verify: Open Task Scheduler and look for '$TaskName'" -ForegroundColor Gray
Write-Host "To check logs: notepad C:\m32-flows\update.log" -ForegroundColor Gray
Write-Host ""
