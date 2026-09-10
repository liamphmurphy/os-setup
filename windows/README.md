# Windows 11 Configuration & Setup

This directory contains configuration, automation scripts, and package manifests for Windows 11.

---

## Directory Overview

```
windows/
├── winget.json                     # Declarative GUI application manifest
├── setup.ps1                       # OS preference automation script
└── configs/
    └── terminal/
        └── settings.json           # Windows Terminal profile & theme settings
```

---

## 1. Install GUI Applications (`winget.json`)

All GUI applications are installed using Windows Package Manager (`winget`).

Run in PowerShell:
```powershell
winget import -i winget.json --accept-package-agreements --accept-source-agreements
```

### Included Packages
- **Browsers & Internet**: Mozilla Firefox (`Mozilla.Firefox`), Proton VPN (`Proton.ProtonVPN`)
- **Productivity & Notes**: Obsidian (`Obsidian.Obsidian`), Google Drive (`Google.GoogleDrive`)
- **Communication & Media**: Discord (`Discord.Discord`), Zoom (`Zoom.Zoom`), Audacity (`Audacity.Audacity`), OBS Studio (`OBSProject.OBSStudio`)
- **Gaming & AI**: Steam (`Valve.Steam`), LM Studio (`ElementLabs.LMStudio`)
- **Developer Tools & Utilities**: Microsoft PowerToys (`Microsoft.PowerToys`), Git for Windows (`Git.Git`), Windows Terminal (`Microsoft.WindowsTerminal`), JetBrains Mono Nerd Font (`DEVCOM.JetBrainsMonoNerdFont`)

---

## 2. Automate System Preferences (`setup.ps1`)

Run the setup script in PowerShell to apply developer defaults:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\setup.ps1
```

### What `setup.ps1` Configures
1. **Dark Theme**: Enables dark mode for both Windows system UI and applications.
2. **Taskbar Auto-Hide**: Sets the taskbar to automatically hide when not in focus.
3. **Classic Context Menu**: Restores the full classic right-click context menu (no more "Show more options").
4. **Remove Taskbar Clutter**: Removes Widgets (news/weather), Teams Chat, and Copilot buttons.
5. **Remove Windows Copilot & Recall**: Disables Copilot and Windows Recall AI indexing policies and uninstalls Copilot Appx packages.
6. **Disable Telemetry & Tracking**: Sets diagnostic data collection to minimum (0), disables advertising ID and tailored experiences, and stops tracking background services (`DiagTrack`, `dmwappushservice`).
7. **Developer Mode**: Enables Developer Mode to allow unprompted symlink creation without elevation.
8. **File Explorer**: Shows file extensions and hidden files by default, and opens to "This PC" instead of "Home".
9. **Disable Ads & Clutter**: Disables Start Menu app recommendations, Bing web search clutter, and Windows tips/promo pop-ups.
10. **Disable Sticky Keys**: Disables the Shift-key-5x accessibility pop-up.
11. **Performance Optimizations**:
    - **Windows Defender WSL Exclusions**: Excludes `wsl.exe`, `wslhost.exe`, and `\\wsl$\*` from real-time antivirus scanning (prevents 3-5x build slowdowns).
    - **Disable Fast Startup**: Ensures clean cold boots without stale hypervisor states or WSL time drift.
12. **Windows Terminal**: Deploys `configs/terminal/settings.json` configured with JetBrains Mono Nerd Font and NixOS as the default profile.
13. **WSL2 Tuning**: Deploys `configs/wsl/.wslconfig` (memory reclaim, mirrored networking, sparse VHD) to `$env:USERPROFILE\.wslconfig`.
14. **Git Identity**: Configures `git config --global` user name and email to match your NixOS identity.
15. **Explorer Refresh**: Restarts File Explorer to apply all changes immediately.

> [!TIP]
> Run PowerShell as **Administrator** so `setup.ps1` can disable system-level telemetry policies, apply Defender exclusions, and stop background services. If run non-elevated, all user-level tweaks (HKCU) will still succeed cleanly.

---

## 3. Application & WSL Configurations

- **Windows Terminal (`configs/terminal/settings.json`)**:
  - Default Profile: NixOS WSL
  - Font: `JetBrainsMono Nerd Font`, size 12
  - Appearance: Acrylic background opacity (85%) and bar cursor
  - **Quake Mode**: Press **`Win + ~`** (or `Win + ` ` `) anytime to toggle an instant dropdown NixOS terminal.
- **WSL2 Tuning (`configs/wsl/.wslconfig`)**:
  - `memory=16GB`
  - `autoMemoryReclaim=gradual`
  - `sparseVhd=true`
  - `networkingMode=mirrored`
