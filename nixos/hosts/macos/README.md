# macOS setup (Apple Silicon)

Both Macs share `nixos/home/macos/default.nix` and its Home Manager modules.

| Flake target | macOS account |
| --- | --- |
| `work` | `lmurphy` |
| `personal` | `liammurphy` |

## Initial installation

1. Install Nix with a macOS-compatible multi-user installer.
2. Install [Homebrew](https://brew.sh/) separately. nix-darwin **manages** Homebrew casks but does not install Homebrew itself.
3. Clone this repository into `~/os-setup`.
4. From `~/os-setup/nixos`, update the flake lock to capture the new nix-darwin input: `nix flake lock`. Commit the generated `flake.lock` before treating the build as reproducible.
5. Preview the configuration: `nix build .#darwinConfigurations.personal.system` (or `work`).
6. Bootstrap nix-darwin following its [official installation instructions](https://github.com/nix-darwin/nix-darwin), using `.#personal` or `.#work`. Subsequent updates: `sudo darwin-rebuild switch --flake ~/os-setup/nixos#personal` (or `#work`).

## Apps

Homebrew casks, managed by nix-darwin: Firefox, Obsidian, OBS Studio, Google Drive, Proton VPN.

Home Manager: Ghostty (via `ghostty-bin`, shared shell settings) and Rectangle.

The Homebrew cleanup policy is `none`, so activating on an existing work Mac will not automatically uninstall unrelated apps.

## Before activating

- Confirm the actual short username on each Mac matches the flake target.
- The initial `nix flake lock` update and an Apple Silicon evaluation are still required.
- Existing standalone `homeConfigurations.work` and `homeConfigurations.personal` remain available, but use **nix-darwin** as the primary macOS activation path to manage both Home Manager and casks.
- Firefox profile/policy management is not yet ported to macOS; only the native app is installed.

## macOS preferences

Both profiles set the following declaratively:

- Finder: path bar, search current folder, show extensions and hidden files, default list view.
- Dock: auto-hide, instant reveal, no recent apps, stable Spaces order.
- Keyboard: faster repeat (initial delay 15, repeat interval 2), no press-and-hold accent menu.
- Trackpad: tap to click.
- Security: Touch ID authentication for `sudo` via `sudo_local`.
- Screenshots: `~/Pictures/Screenshots`, created automatically on activation.

Some preferences may require signing out or restarting Finder/Dock to take effect. Touch ID must be enrolled in macOS.

## Raycast

Raycast is installed through Homebrew alongside Rectangle. Keep macOS Spotlight indexing enabled; optionally assign Command-Space to Raycast in its onboarding/Hotkey settings and move Spotlight to another shortcut. Configure Raycast clipboard history and accessibility permissions after first launch. Rectangle remains installed for dedicated window shortcuts.
