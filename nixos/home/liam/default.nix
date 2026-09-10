{ pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "liam";
  home.homeDirectory = "/home/liam";

  imports = [
    ../modules/plasma.nix
    ../modules/webapps.nix
    ../modules/firefox.nix
    ../modules/git.nix
    ../modules/terminal.nix
    ../modules/dev.nix
    ../modules/codex.nix
    # ../modules/hyprland.nix
  ];

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    pay-respects
    btop

    # Desktop applications
    vesktop
    gnome-disk-utility
    vulkan-tools
    obs-studio
    obsidian
    protonup-qt
    fastfetch
    proton-vpn
    audacity
    gamemode
    distrobox
    heroic
    lact
    papirus-icon-theme
    zoom-us
    faugus-launcher

    # User applications
    kdePackages.kate
    kdePackages.kio-gdrive
    kdePackages.kaccounts-providers
    kdePackages.kaccounts-integration
    google-drive-ocamlfuse

    lmstudio

    # nerd fonts, for things like waybar, some vim things etc
    nerd-fonts.jetbrains-mono
    nerd-fonts.iosevka
    nerd-fonts.fira-code
    font-awesome

    gyb
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  programs.home-manager.enable = true;
}
