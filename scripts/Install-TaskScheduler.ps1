# Install-TaskScheduler.ps1
# ONE-TIME SETUP SCRIPT — Run this as Administrator on the church Windows host.
# Registers the M32 flows auto-updater as a Windows Scheduled Task.

#Requires -RunAsAdministrator

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

# --- Step 3: Create the Scheduled Task ---
# Runs every 15 minutes, at any time, even when no user is logged in.

$Action  = New-ScheduledTaskAction `
    -Execute "powershell.exe" `
    -Argument "-NonInteractive -ExecutionPolicy Bypass -File `"$ScriptPath`""

$Trigger = New-ScheduledTaskTrigger -RepetitionInterval (New-TimeSpan -Minutes 15) -Once -At (Get-Date)

$Settings = New-ScheduledTaskSettingsSet `
    -ExecutionTimeLimit (New-TimeSpan -Minutes 5) `
    -RestartCount 3 `
    -RestartInterval (New-TimeSpan -Minutes 1) `
    -StartWhenAvailable

# Run as SYSTEM so it works whether or not a user is logged in
$Principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest

# Remove old task if it exists
if (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue) {
    Write-Host "Removing existing task '$TaskName'..." -ForegroundColor Yellow
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
}

Register-ScheduledTask `
    -TaskName  $TaskName `
    -Action    $Action `
    -Trigger   $Trigger `
    -Settings  $Settings `
    -Principal $Principal `
    -Description "Pulls the latest m32 Node-RED flows from GitHub and restarts the container if flows.json changed." | Out-Null

Write-Host "[3/3] Scheduled Task '$TaskName' registered successfully." -ForegroundColor Green
Write-Host ""
Write-Host "Setup complete!" -ForegroundColor Cyan
Write-Host "The flows will now auto-update every 15 minutes." -ForegroundColor Cyan
Write-Host ""
Write-Host "To verify: Open Task Scheduler and look for '$TaskName'" -ForegroundColor Gray
Write-Host "To check logs: notepad C:\m32-flows\update.log" -ForegroundColor Gray
Write-Host ""
