{ pkgs, ... }:

{
  home.username = "liam";
  home.homeDirectory = "/home/liam";
  home.stateVersion = "25.05";

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
    update = "nix flake update --flake ~/nix-config && sudo nixos-rebuild switch --flake ~/nix-config#wsl";
  };

  programs.home-manager.enable = true;
}
