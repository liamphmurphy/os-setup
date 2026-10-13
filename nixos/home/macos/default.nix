{ ... }:

{
  # Shared across work and personal Apple Silicon Macs.
  # Account-specific username and home directory are supplied in flake.nix.
  home.stateVersion = "25.05";

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

  programs.rectangle.enable = true;

  programs.home-manager.enable = true;
}
