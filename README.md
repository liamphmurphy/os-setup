# OS Setup

Unified declarative configurations and automation scripts for **NixOS** and **Windows 11**.

---

## Repository Structure

```
os-setup/
├── nixos/                          # Declarative NixOS and Home Manager configurations
│   ├── flake.nix                   # Flake definitions (lime, wsl, work)
│   ├── hosts/                      # Host-specific configurations (lime, wsl)
│   ├── home/                       # Home Manager user configurations
│   └── modules/                    # Reusable NixOS and Home Manager modules
│
└── windows/                        # Windows 11 setup and application manifests
    ├── winget.json                 # WinGet GUI package import manifest
    ├── setup.ps1                   # Automated OS preferences & taskbar auto-hide
    └── configs/                    # Tracked application configurations (Windows Terminal)
```

---

## Quick Start

### 1. Windows 11 Setup

From a PowerShell terminal inside the `windows/` folder:

```powershell
# 1. Install GUI applications (Firefox, Obsidian, Discord, Steam, Terminal, etc.)
winget import -i winget.json --accept-package-agreements --accept-source-agreements

# 2. Apply system preferences (Dark mode, auto-hide taskbar, show file extensions, terminal settings)
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\setup.ps1
```

👉 See [windows/README.md](file:///home/amelia/nix-config/windows/README.md) for full configuration details.

---

### 2. NixOS Setup

Clone this repository to `~/os-setup`:

```zsh
nix-shell -p git
git clone <repository-url> ~/os-setup
```

#### On WSL2 (`wsl`)
```zsh
sudo nixos-rebuild switch --flake ~/os-setup/nixos#wsl
```

#### On Bare Metal Desktop (`lime`)
```zsh
# On first install, ensure /etc/nixos/hardware-configuration.nix is copied to ~/os-setup/nixos/hosts/lime/
sudo nixos-rebuild switch --flake ~/os-setup/nixos#lime
```

👉 See [nixos/README.md](file:///home/amelia/nix-config/nixos/README.md) for detailed module documentation and standalone Home Manager usage.
