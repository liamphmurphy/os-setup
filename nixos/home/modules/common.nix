{ pkgs, lib, ... }:

{
  # Portable command-line utilities and developer fonts.
  home.packages = with pkgs; [
    pay-respects
    btop
    fastfetch
    yt-dlp
    nerd-fonts.jetbrains-mono
    nerd-fonts.iosevka
    nerd-fonts.fira-code
    font-awesome
  ];

  # fontconfig is configured on Linux; macOS manages its fonts natively.
  fonts.fontconfig.enable = lib.mkIf pkgs.stdenv.hostPlatform.isLinux true;
}
