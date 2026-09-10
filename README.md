# Current State

Configuration for NixOS/Home Manager and Windows.
- NixOS and Home Manager configuration lives in `nixos/`. Host-specific configurations live in `nixos/hosts/lime` and `nixos/hosts/wsl`; reusable NixOS and Home Manager features live in `nixos/modules/nixos` and `nixos/home/modules` respectively.
- Windows configuration and package manifests live in `windows/`.

# What to do on a first NixOS install (Bare Metal - lime)

```zsh
nix-shell -p git
# pull this repo down, cd into it
# On NixOS, copy the generated hardware file into nixos/hosts/lime/.
# cp /etc/nixos/hardware-configuration.nix ~/os-setup/nixos/hosts/lime/
sudo nixos-rebuild switch --flake ~/os-setup/nixos#lime
```

# NixOS on WSL2 (wsl)

Using [NixOS-WSL](https://github.com/nix-community/NixOS-WSL):

```zsh
nix-shell -p git
# Clone this repo into ~/os-setup
git clone <repository-url> ~/os-setup
sudo nixos-rebuild switch --flake ~/os-setup/nixos#wsl
```

# Windows 11 GUI Applications (WinGet)

To install GUI applications on the Windows 11 host (Firefox, Obsidian, OBS Studio, Proton VPN, Google Drive, Discord, Steam, etc.), run the following in PowerShell:

```powershell
winget import -i windows/winget.json --accept-package-agreements --accept-source-agreements
```

# Home Manager only on a non-NixOS system

First, install Nix with the [official multi-user installer](https://nixos.org/download/), then enable flakes for your user:

```sh
mkdir -p ~/.config/nix
echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf
```

Clone this repository and activate the standalone Home Manager configuration:

```sh
nix-shell -p git
git clone <repository-url> ~/os-setup
cd ~/os-setup/nixos
nix run github:nix-community/home-manager -- switch --flake .#liam
```

After the first activation, Home Manager is available directly. Apply later changes with:

```sh
home-manager switch --flake ~/os-setup/nixos#liam
```

The standalone configuration currently targets `x86_64-linux` and expects the user to be named `liam` with the home directory `/home/liam`. Change `homeConfigurations.liam` in `nixos/flake.nix` and the values in `nixos/home/liam/default.nix` when using a different account.

# Useful checks

```sh
cd ~/os-setup/nixos
nix flake check
nix fmt -- --ci
```

The flake exposes `nix fmt` and includes a formatting check in `nix flake check`.
