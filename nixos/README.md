# NixOS & Home Manager Configuration

This directory contains the declarative system and home configurations managed via Nix Flakes.

---

## Directory Structure

```
nixos/
├── flake.nix                       # Flake inputs, outputs, system configurations, checks
├── hosts/
│   ├── lime/                       # Bare metal desktop host configuration
│   │   ├── default.nix
│   │   └── hardware-configuration.nix
│   └── wsl/                        # WSL2 host configuration (via nix-community/NixOS-WSL)
│       └── default.nix
├── home/
│   ├── liam/                       # Desktop Home Manager profile for user 'liam'
│   │   └── default.nix
│   ├── wsl/                        # WSL Home Manager profile for user 'liam'
│   │   └── default.nix
│   ├── work/                       # macOS / Darwin standalone Home Manager profile
│   │   └── default.nix
│   └── modules/                    # Shared Home Manager modules
│       ├── codex.nix               # Codex agent skill harness
│       ├── dev.nix                 # Programming runtimes (Go, Rust, Python, Nix) & LazyVim
│       ├── firefox.nix             # Firefox policies and privacy settings
│       ├── git.nix                 # Git configuration & identity
│       ├── google-chrome.nix       # Google Chrome with Wayland/Ozone acceleration
│       ├── plasma.nix              # KDE Plasma 6 desktop manager configuration
│       ├── terminal.nix            # Ghostty, zsh, oh-my-zsh, fastfetch
│       └── webapps.nix             # Chromium webapp wrappers (YT Music, etc.)
└── modules/
    └── nixos/                      # Reusable NixOS system modules
        ├── audio.nix               # Pipewire audio configuration
        ├── desktop.nix             # Plasma 6 desktop and display manager
        ├── gaming.nix              # Steam, Gamescope, Proton-GE
        ├── nix.nix                 # Flakes, garbage collection, unfree settings
        ├── printing.nix            # CUPS printing & Avahi network discovery
        └── virtualisation.nix      # Docker, Libvirt / QEMU KVM, virt-manager
```

---

## Hosts Overview

### 1. `lime` (Bare Metal Desktop)
- **Platform**: `x86_64-linux`
- **Kernel**: CachyOS Linux kernel (`pkgs.linuxPackages_cachyos`)
- **Features**: Full KDE Plasma 6 Wayland desktop, AMD ROCm Ollama LLM (`qwen3-coder`), Pipewire audio, Steam gaming, Docker/KVM, and full GUI applications.

### 2. `wsl` (WSL2 on Windows 11)
- **Platform**: `x86_64-linux`
- **Integration**: `nix-community/NixOS-WSL` with systemd support and Windows interop (`wsl.interop.register = true`).
- **Features**: Lightweight, developer-focused NixOS instance. Replicates Neovim (LazyVim), programming toolchains (Go, Rust, Python, Nix, K8s), zsh, git, and codex skills without GUI/desktop overhead.
- **Git Authentication**: Configured in `home/wsl/default.nix` to use Windows Git Credential Manager (`git-credential-manager.exe`) directly from WSL.
- **Native Docker**: Docker daemon runs natively under systemd in WSL2 with `docker-compose`, avoiding the need for Docker Desktop on Windows.
- **POSIX Filesystem on Windows Drives**: Configured `wsl.wslConf.automount.options = "metadata,uid=1000,gid=100"` so `/mnt/c` respects Linux file permissions instead of default 0777.
- **Windows Integration Bridge**: Provides a `~/winhome` symlink and alias to jump straight into your Windows user directory, plus `explore` to open Windows File Explorer from any Linux directory.

---

## Deployment & Switch Commands

### Bare Metal (`lime`)
```zsh
sudo nixos-rebuild switch --flake ~/os-setup/nixos#lime
```

### WSL2 (`wsl`)
```zsh
sudo nixos-rebuild switch --flake ~/os-setup/nixos#wsl
```

### Standalone Home Manager (`liam` / `work`)
```sh
# On non-NixOS Linux:
home-manager switch --flake ~/os-setup/nixos#liam

# On macOS (Darwin):
home-manager switch --flake ~/os-setup/nixos#work
```

---

## Development & Maintenance

### Update Flake Inputs
```sh
cd ~/os-setup/nixos
nix flake update
```
Or use the preconfigured shell alias inside `zsh`:
```zsh
update
```

### Run Checks & Formatting
```sh
cd ~/os-setup/nixos
nix flake check
nix fmt -- --ci
```
