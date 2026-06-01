# Update-M32Flows.ps1
# Runs on a schedule via Windows Task Scheduler (every Monday at 8:00 AM).
# Checks for updated flows AND a new container image, and restarts if either changed.

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

# --- Step 1: Pull latest flows from GitHub ---
try {
    $pullOutput = git -C $RepoPath pull 2>&1
    Write-Log "git pull: $pullOutput"
} catch {
    Write-Log "ERROR running git pull: $_"
    exit 1
}

$flowsChanged = $pullOutput -match "flows\.json"

# --- Step 2: Pull latest container image ---
Write-Log "Checking for updated container image..."
try {
    Set-Location $RepoPath
    $imageOutput = podman compose pull 2>&1
    Write-Log "podman compose pull: $($imageOutput -join ' ')"
    # "Pulled" appears in output when a new image layer was downloaded
    $imageUpdated = $imageOutput -match "Pulled"
} catch {
    Write-Log "WARNING: Could not check for image update: $_"
    $imageUpdated = $false
}

# --- Step 3: Restart container if anything changed ---
if ($flowsChanged -or $imageUpdated) {
    if ($flowsChanged)  { Write-Log "flows.json was updated." }
    if ($imageUpdated)  { Write-Log "Container image was updated." }
    Write-Log "Restarting container '$Container' to apply changes..."
    try {
        Set-Location $RepoPath
        $upOutput = podman compose up -d 2>&1
        Write-Log "podman compose up: $($upOutput -join ' ')"
        Write-Log "Container restarted successfully. Changes are now live."
    } catch {
        Write-Log "ERROR restarting container: $_"
        exit 1
    }
} elseif ($pullOutput -match "Already up to date") {
    Write-Log "No changes to flows or image. Nothing to do."
} else {
    Write-Log "No restart needed."
}

Write-Log "--- Update check complete ---"
