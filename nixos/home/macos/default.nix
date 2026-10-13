{ ... }:

{
  # Shared across work and personal Apple Silicon Macs.
  # Account-specific username and home directory are supplied in flake.nix.
  home.stateVersion = "25.05";

  imports = [
    ../modules/terminal.nix
    ../modules/tmux.nix
    ../modules/dev.nix
    ../modules/codex.nix
    ../modules/gemini.nix
  ];

  programs.home-manager.enable = true;
}
