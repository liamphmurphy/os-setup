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

Use **standalone Home Manager** to manage the terminal, dotfiles, editor and language tools without applying macOS system settings. The personal Apple Silicon target is `homeConfigurations.personal`, for user `liammurphy` with home `/Users/liammurphy`.

1. Install Xcode Command Line Tools (`xcode-select --install`) and Nix using a macOS-compatible multi-user installer. Open a new terminal after installation.
2. Clone this repository to `~/repos/os-setup`, or enter your existing checkout.
3. From the repository root, enable Nix CLI features and build the user environment:

   ```sh
   export NIX_CONFIG=$'experimental-features = nix-command flakes'
   nix build ./nixos#homeConfigurations.personal.activationPackage
   ```

4. Bootstrap Home Manager from the build result, backing up existing dotfiles:

   ```sh
   ./result/home-path/bin/home-manager switch \
     -b before-home-manager \
     --flake ./nixos#personal
   ```

   Existing files such as `~/.zshrc` and `~/.ssh/config` are renamed with the `.before-home-manager` suffix. Review those backups and transfer any settings you need into the Nix modules. If a backup with that name already exists, preserve it and choose a different suffix.

5. Open a new terminal. Apply future changes from the repository root with:

   ```sh
   home-manager switch --flake ./nixos#personal
   ```

To persist CLI feature support, add `experimental-features = nix-command flakes` to `~/.config/nix/nix.conf`, creating the directory/file if needed and preserving existing settings. If `home-manager` is unavailable during bootstrap, use the command under `./result/home-path/bin/` above.

Home Manager activation does not require `sudo` or Homebrew. Rectangle, Homebrew apps, and macOS preferences belong to the separate, optional nix-darwin configuration. See [macOS setup notes](nixos/hosts/macos/README.md) for that configuration and Android development details.

---

## GitHub authentication (NixOS and macOS)

Home Manager configures GitHub SSH access for NixOS desktop, NixOS-WSL and personal macOS. Generate a unique SSH key on each machine, add the public key to GitHub, and use Apple Keychain for the personal Mac. **GPG is not required** for GitHub SSH authentication; commit signing remains optional.

Follow the [SSH setup guide](docs/github-ssh.md) after activating a new machine.
