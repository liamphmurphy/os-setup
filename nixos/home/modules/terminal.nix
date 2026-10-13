# Setup anything related to the terminal config, e.g. Ghostty / zsh
{
  config,
  pkgs,
  lib,
  ...
}:

{

  programs.ghostty = {
    enable = true;
    package = if pkgs.stdenv.hostPlatform.isDarwin then pkgs.ghostty-bin else pkgs.ghostty;
    settings = {
      confirm-close-surface = false;
      background-opacity = 0.7;
      background-blur-radius = 5;
      font-size = 12;
    };
  };

  # Plasma cannot activate Ghostty's D-Bus desktop entry reliably, even though
  # launching the executable directly works.
  xdg.desktopEntries = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    "com.mitchellh.ghostty" = {
      name = "Ghostty";
      genericName = "Terminal Emulator";
      exec = "ghostty --gtk-single-instance=true";
      icon = "com.mitchellh.ghostty";
      terminal = false;
      categories = [
        "System"
        "TerminalEmulator"
      ];
      settings = {
        DBusActivatable = "false";
      };
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    initContent = ''
      eval "$(pay-respects zsh --alias)"
      fastfetch
    '';

    shellAliases = {
      ll = "ls -l";
      gfgp = "git fetch && git pull";
      v = "vim";
      t = "tmux";
    } // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
      update = "nix flake update --flake ~/os-setup/nixos && home-manager switch --flake ~/os-setup/nixos#personal";
    } // lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
      update = lib.mkDefault "nix flake update --flake ~/os-setup/nixos && sudo nixos-rebuild switch --flake ~/os-setup/nixos#lime";
      restartshell = "systemctl --user restart plasma-plasmashell";
    };

    history.size = 10000;

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "kubectl"
        "helm"
        "golang"
      ];
      theme = "robbyrussell";
    };
  };

}
