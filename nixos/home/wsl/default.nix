{ config, pkgs, ... }:

{
  home.username = "liam";
  home.homeDirectory = "/home/liam";
  home.stateVersion = "25.05";

  # Quick-access symlink to Windows user profile
  home.file."winhome".source = config.lib.file.mkOutOfStoreSymlink "/mnt/c/Users/liam";

  imports = [
    ../modules/common.nix
    ../modules/google-chrome.nix
    ../modules/git.nix
    ../modules/ssh.nix
    ../modules/terminal.nix
    ../modules/tmux.nix
    ../modules/dev.nix
    ../modules/codex.nix
    ../modules/gemini.nix
    ../modules/cliphist.nix
  ];

  programs.zsh.shellAliases = {
    update = "nix flake update --flake ~/os-setup/nixos && sudo nixos-rebuild switch --flake ~/os-setup/nixos#wsl";
    winhome = "cd /mnt/c/Users/liam";
    explore = "explorer.exe .";
  };

  # Use Windows Git Credential Manager from within WSL
  programs.git.settings = {
    credential.helper = "/mnt/c/Program\\ Files/Git/mingw64/bin/git-credential-manager.exe";
  };

  programs.gpg.enable = true;

  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-curses;
    enableZshIntegration = true;
  };

  programs.home-manager.enable = true;
}
