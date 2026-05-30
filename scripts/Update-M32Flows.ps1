# Update-M32Flows.ps1
# Runs on a schedule via Windows Task Scheduler.
# Pulls the latest flows from GitHub and restarts the Node-RED container if flows.json changed.

$RepoPath   = "C:\m32-flows"
$LogFile    = "C:\m32-flows\update.log"
$Container  = "m32-sync-utility"

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[$timestamp] $Message"
    Write-Host $line
    Add-Content -Path $LogFile -Value $line
}

# --- Rotate log file if it exceeds 1 MB ---
if (Test-Path $LogFile) {
    $logSize = (Get-Item $LogFile).Length
    if ($logSize -gt 1MB) {
        Rename-Item -Path $LogFile -NewName "update.log.bak" -Force
        Write-Log "Log rotated (exceeded 1 MB)."
    }
}

Write-Log "--- Starting update check ---"

# --- Check that git is available ---
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Log "ERROR: git is not found in PATH. Install git and re-run."
    exit 1
}

# --- Check that podman is available ---
if (-not (Get-Command podman -ErrorAction SilentlyContinue)) {
    Write-Log "ERROR: podman is not found in PATH."
    exit 1
}

# --- Run git pull ---
try {
    $pullOutput = git -C $RepoPath pull 2>&1
    Write-Log "git pull: $pullOutput"
} catch {
    Write-Log "ERROR running git pull: $_"
    exit 1
}

# --- Check if flows.json was among the changed files ---
$flowsChanged = $pullOutput -match "flows\.json"

if ($flowsChanged) {
    Write-Log "flows.json was updated. Restarting container '$Container'..."
    try {
        $restartOutput = podman restart $Container 2>&1
        Write-Log "podman restart: $restartOutput"
        Write-Log "Container restarted successfully. New flows are now live."
    } catch {
        Write-Log "ERROR restarting container: $_"
        exit 1
    }
} elseif ($pullOutput -match "Already up to date") {
    Write-Log "No changes. Nothing to do."
} else {
    Write-Log "Changes pulled but flows.json was not among them. No restart needed."
}

Write-Log "--- Update check complete ---"
