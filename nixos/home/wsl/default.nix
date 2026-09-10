{ config, pkgs, ... }:

{
  home.username = "liam";
  home.homeDirectory = "/home/liam";
  home.stateVersion = "25.05";

  # Quick-access symlink to Windows user profile
  home.file."winhome".source = config.lib.file.mkOutOfStoreSymlink "/mnt/c/Users/liam";

  imports = [
    ../modules/git.nix
    ../modules/terminal.nix
    ../modules/dev.nix
    ../modules/codex.nix
  ];

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    pay-respects
    btop
    fastfetch

    # nerd fonts
    nerd-fonts.jetbrains-mono
    nerd-fonts.iosevka
    nerd-fonts.fira-code
    font-awesome
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

  programs.home-manager.enable = true;
}
