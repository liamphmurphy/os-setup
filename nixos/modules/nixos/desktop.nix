{ pkgs, ... }:
{
  services.desktopManager.plasma6.enable = true;
  programs.kdeconnect.enable = true;
  services.displayManager = {
    plasma-login-manager.enable = true;
    autoLogin = {
      enable = true;
      user = "liam";
    };
  };
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-qt;
  };
}
