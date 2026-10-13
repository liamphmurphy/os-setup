# OS Setup

Unified declarative configurations and automation scripts for **NixOS**, **macOS (Apple Silicon)**, and **Windows 11**.

---

## Repository Structure

```
os-setup/
├── nixos/                          # Declarative NixOS and Home Manager configurations
│   ├── flake.nix                   # Flake definitions (lime, wsl, personal)
│   ├── hosts/                      # Host-specific configurations (lime, wsl, macos)
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

See [windows/README.md](windows/README.md) for full configuration details.

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

See [nixos/README.md](nixos/README.md) for detailed module documentation and standalone Home Manager usage.

---

### 3. Personal macOS Setup (Apple Silicon)

This profile is for the personal Mac with macOS short username `liammurphy` (home directory `/Users/liammurphy`). **Do not apply it to an employer-managed Mac.** It uses nix-darwin for system settings, Homebrew applications, and Home Manager modules.

1. Finish macOS onboarding and confirm the account name with `whoami`; it must be `liammurphy` for the current flake target.
2. Install **Xcode Command Line Tools** with `xcode-select --install` and complete the installer. Install **Nix** using the macOS multi-user installation method described in the [nix-darwin installation guide](https://github.com/nix-darwin/nix-darwin#installation).
3. Install [Homebrew](https://brew.sh/) separately. This flake manages Homebrew apps but does not install Homebrew itself. Verify `/opt/homebrew/bin/brew --version`.
4. Clone and enter the repository:

   ```sh
   git clone https://github.com/liamphmurphy/os-setup.git ~/os-setup
   cd ~/os-setup/nixos
   ```

5. **Until `nixos/flake.lock` is updated and committed on this PR**, run `nix flake lock` here and commit the resulting lockfile. The new nix-darwin input must be locked before the configuration is fully reproducible.
6. Evaluate/build the profile before activation:

   ```sh
   nix build .#darwinConfigurations.personal.system
   ```

7. Bootstrap nix-darwin, following the [official instructions](https://github.com/nix-darwin/nix-darwin#installation) for a flake-based installation, targeting `~/os-setup/nixos#personal`. After the first installation, apply changes with:

   ```sh
   sudo darwin-rebuild switch --flake ~/os-setup/nixos#personal
   ```

8. Sign into the Mac App Store for Xcode installation; open Xcode and Android Studio to finish their first-run setup and download the required simulator/SDK components. Set up Raycast hotkeys, app permissions, and Pixel USB debugging as needed.

**Important:** This configuration has not yet been evaluated or activated on the new Mac. Do not run `darwin-rebuild switch` until the build succeeds and the flake lockfile is committed. See [macOS setup notes](nixos/hosts/macos/README.md) for apps, preferences, Android USB debugging, and Nix maintenance details.
