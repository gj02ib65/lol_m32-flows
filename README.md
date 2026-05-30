# lol_m32-flows

Node-RED flows for the **Midas/X32 Dual Mixer Sync & Stream Manager**.

This repository contains only the Node-RED flow logic (`flows.json`). The Node-RED runtime, npm palettes, and Docker infrastructure live in the main [m32-utility](https://github.com/gj02ib65/LOL_M32-utility) repository.

---

## Purpose

These flows power the mute-sync system that mirrors Front of House (FOH) console mute states to the Livestream console in real time. See the [main repo README](https://github.com/gj02ib65/LOL_M32-utility) for full documentation.

---

## 🚀 Church Host Setup (One-Time)

These steps are only needed once on the church Windows PC. After setup, everything updates automatically.

### Prerequisites
- [Git for Windows](https://git-scm.com/download/win) installed
- [Podman](https://podman.io/) installed and the `m32-sync-utility` container already running
- PowerShell 5.1 or later (built into Windows 10/11)

### Steps

**1. Clone this repository to the church PC:**
```powershell
git clone https://github.com/gj02ib65/lol_m32-flows.git C:\m32-flows
```

**2. Run the one-time Task Scheduler installer (as Administrator):**
```powershell
# Right-click PowerShell → "Run as Administrator", then:
Set-ExecutionPolicy Bypass -Scope Process -Force
C:\m32-flows\scripts\Install-TaskScheduler.ps1
```

**3. That's it.** The church PC will now check for flow updates every 15 minutes automatically, even when no one is logged in.

---

## 🔄 How Updates Work

```
You edit flows.json  →  git push to GitHub
                              ↓
                   Church PC checks every 15 min
                   (Windows Task Scheduler runs Update-M32Flows.ps1)
                              ↓
              If flows.json changed → container auto-restarts
                              ↓
                     New flows are live ✅
```

No one needs to be at church. No Docker rebuild required.

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

---

## 🛠 For Developers

To edit the flows:

1. Make your changes to `flows.json` in this repo
2. Commit and push to `main`
3. The church PC will pick up changes within 15 minutes automatically

> [!NOTE]
> If you need to test locally, use the `task pull` command from the main `m32-utility` repo to sync flows from your running local container back into this file.
