{ ... }:

{
  # Shared across work and personal Apple Silicon Macs.
  # Account-specific username and home directory are supplied in flake.nix.
  home.stateVersion = "25.05";

  # Copy app bundles so Spotlight can index them outside the Nix store.
  targets.darwin.linkApps.enable = false;
  targets.darwin.copyApps.enable = true;

  imports = [
    ../modules/common.nix
    ../modules/git.nix
    ../modules/ssh.nix
    ../modules/terminal.nix
    ../modules/tmux.nix
    ../modules/dev.nix
    ../modules/codex.nix
    ../modules/gemini.nix
  ];

  # Android Studio installs SDK components through its SDK Manager.
  # Keep one writable SDK in the standard macOS location.
  home.sessionVariables.ANDROID_HOME = "$HOME/Library/Android/sdk";
  home.sessionPath = [
    "$HOME/Library/Android/sdk/platform-tools"
    "$HOME/Library/Android/sdk/emulator"
    "$HOME/Library/Android/sdk/cmdline-tools/latest/bin"
  ];

  # Put Homebrew on PATH when it's installed (guarded so it's harmless without it).
  programs.zsh.profileExtra = ''
    if [ -x /opt/homebrew/bin/brew ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
  '';

  programs.home-manager.enable = true;
}
