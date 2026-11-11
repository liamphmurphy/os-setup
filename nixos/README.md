# NixOS & Home Manager Configuration

This directory contains the declarative system and home configurations managed via Nix Flakes.

---

## Directory Structure

```
nixos/
├── flake.nix                       # Flake inputs, outputs, system configurations, checks
├── hosts/
│   ├── lime/                       # RETIRED: former bare metal desktop host
│   │   ├── default.nix
│   │   └── hardware-configuration.nix
│   ├── vesper/                     # Headless Vesper server, reached over Tailscale
│   └── wsl/                        # WSL2 host configuration (via nix-community/NixOS-WSL)
│       └── default.nix
├── home/
│   ├── liam/                       # Desktop Home Manager profile for user 'liam'
│   │   └── default.nix
│   ├── wsl/                        # WSL Home Manager profile for user 'liam'
│   │   └── default.nix
│   ├── macos/                      # Shared macOS Home Manager profile
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

### 1. `lime` (Bare Metal Desktop, retired)
> **Retired (2026-11):** the gaming desktop this ran on is Windows-only now. Kept for reference and a possible reinstall; not maintained.
- **Platform**: `x86_64-linux`
- **Kernel**: CachyOS Linux kernel (`pkgs.linuxPackages_cachyos`)
- **Features**: Full KDE Plasma 6 Wayland desktop, AMD ROCm Ollama LLM (`qwen3-coder`), Pipewire audio, Steam gaming, Docker/KVM, and full GUI applications.

### `vesper` (Headless server)
- **Platform**: `x86_64-linux`
- **Features**: Runs Vesper's Docker Compose stack, served only to the tailnet with `tailscale serve`; no desktop. Modules `server.nix` (no sleep, key-only SSH, Tailscale) and `vesper.nix` (compose unit, serve unit, restic backups).
- **Setup**: see [`docs/vesper-server.md`](../docs/vesper-server.md).

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

### Bare Metal (`lime`, retired)
```zsh
sudo nixos-rebuild switch --flake ~/os-setup/nixos#lime
```

### WSL2 (`wsl`)
```zsh
sudo nixos-rebuild switch --flake ~/os-setup/nixos#wsl
```

### Standalone Home Manager (`liam` / `personal`)
```sh
# On non-NixOS Linux:
home-manager switch --flake ~/os-setup/nixos#liam

# On macOS (Darwin):
home-manager switch --flake ~/repos/os-setup/nixos#personal
```

For first-time macOS setup, including CLI feature settings and dotfile backups, follow the [macOS quick start](../README.md#3-personal-macos-setup-apple-silicon). Standalone Home Manager does not apply nix-darwin system settings.

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

## GitHub SSH access

The shared `home/modules/ssh.nix` configures GitHub SSH authentication across NixOS desktop, WSL and macOS. See the [GitHub SSH onboarding guide](../docs/github-ssh.md) for per-system key creation and registration. GPG signing is optional.
