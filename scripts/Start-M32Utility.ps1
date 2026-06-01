# Start-M32Utility.ps1
# Starts the M32 Sync Utility containers (Node-RED + Watchtower).
# Run this once after cloning the repo, or any time you need to start the service manually.
# After first run the containers will start automatically on system boot (restart: always).

$RepoPath = "C:\m32-flows"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   M32 Utility — Start Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# --- Verify repo exists ---
if (-not (Test-Path $RepoPath)) {
    Write-Host "ERROR: Repo not found at $RepoPath" -ForegroundColor Red
    Write-Host "Please clone the repository first:" -ForegroundColor Yellow
    Write-Host "  git clone https://github.com/gj02ib65/lol_m32-flows.git $RepoPath" -ForegroundColor Yellow
    exit 1
}

# --- Verify docker-compose.yml exists ---
if (-not (Test-Path "$RepoPath\docker-compose.yml")) {
    Write-Host "ERROR: docker-compose.yml not found in $RepoPath" -ForegroundColor Red
    exit 1
}

# --- Verify podman is available ---
if (-not (Get-Command podman -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: podman is not found in PATH. Please install Podman Desktop." -ForegroundColor Red
    exit 1
}

Write-Host "Starting containers from $RepoPath ..." -ForegroundColor Green
Set-Location $RepoPath
podman compose up -d

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "Containers started successfully!" -ForegroundColor Green
    Write-Host "Node-RED dashboard: http://localhost:1880/dashboard/mixer" -ForegroundColor Cyan
    Write-Host "Node-RED editor:    http://localhost:1880" -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "ERROR: Containers failed to start. Check output above." -ForegroundColor Red
    exit 1
}
