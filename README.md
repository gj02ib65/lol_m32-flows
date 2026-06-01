# lol_m32-flows

Node-RED flows for the **Midas/X32 Dual Mixer Sync & Stream Manager**.

This repository contains only the Node-RED flow logic (`flows.json`). The Node-RED runtime, npm palettes, and Docker infrastructure live in the main [m32-utility](https://github.com/gj02ib65/LOL_M32-utility) repository.

---

## Purpose

These flows power the mute-sync system that mirrors Front of House (FOH) console mute states to the Livestream console in real time. See the [main repo README](https://github.com/gj02ib65/LOL_M32-utility) for full documentation.

---

## 🚀 Church Host Setup (One-Time)

These steps are only needed once on the church Windows PC. After setup, everything updates automatically every Monday at 8:00 AM.

> [!NOTE]
> **No administrator rights are required.** The setup script runs as the currently logged-in user.

### Prerequisites
- [Git for Windows](https://git-scm.com/download/win) installed
- [Podman](https://podman.io/) installed and the `m32-sync-utility` container already running
- PowerShell 5.1 or later (built into Windows 10/11)

### Steps

**1. Open PowerShell** — no need to run as Administrator. You can open it from the Start menu by searching for `PowerShell`.

**2. Clone this repository to the church PC:**
```powershell
git clone https://github.com/gj02ib65/lol_m32-flows.git C:\m32-flows
```

**3. Start the utility for the first time:**
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
C:\m32-flows\scripts\Start-M32Utility.ps1
```

This pulls the latest container image from GitHub and starts Node-RED and Watchtower. After the first run, the containers start automatically whenever the PC boots — you never need to run this script again unless you stop them manually.

**4. Set up automatic weekly flow updates:**
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
C:\m32-flows\scripts\Install-TaskScheduler.ps1
```

> [!IMPORTANT]
> `Set-ExecutionPolicy Bypass -Scope Process -Force` is required before running any script. This is a **temporary, session-only change** — it only affects the current PowerShell window and resets automatically when you close it. It does not permanently change any system settings.

**5. That's it.** The church PC will now check for flow updates every Monday at 8:00 AM automatically. Node-RED is accessible at `http://localhost:1880`.

---

## 🔄 How Updates Work

```
You edit flows.json  →  git push to GitHub
                              ↓
              Church PC checks every Monday at 8:00 AM
         (Windows Task Scheduler runs Update-M32Flows.ps1)
                              ↓
          If flows.json changed → container auto-restarts
                              ↓
                     New flows are live ✅
```

No one needs to be at church to trigger the update. No Docker image rebuild required.

---

## 📋 Checking Update Logs

To see what the auto-updater has been doing, open the log file on the church PC:

```powershell
notepad C:\m32-flows\update.log
```

Or in PowerShell to watch it live:
```powershell
Get-Content C:\m32-flows\update.log -Wait -Tail 20
```

The log records every check — whether flows changed, whether the container was restarted, and any errors encountered.

---

## 🔁 Re-Running the Installer

If you need to reinstall or update the scheduled task (e.g. after cloning to a new PC), just run the installer again — it will overwrite the existing task safely:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
C:\m32-flows\scripts\Install-TaskScheduler.ps1
```

---

## 🛠 For Developers

To edit the flows:

1. Make your changes to `flows.json` in this repo
2. Commit and push to `main`
3. The church PC will pick up changes on the next Monday at 8:00 AM

> [!NOTE]
> If you need to test locally, use the `task pull` command from the main `m32-utility` repo to sync flows from your running local container back into this file.
