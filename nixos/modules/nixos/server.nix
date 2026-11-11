# Baseline for an always-on headless machine reached over Tailscale.
{ lib, ... }:

{
  # Never sleep: it's a server.
  systemd.targets = {
    sleep.enable = false;
    suspend.enable = false;
    hibernate.enable = false;
    hybrid-sleep.enable = false;
  };

  networking.firewall.enable = true;
  networking.nftables.enable = true;

  services.tailscale = {
    enable = true;
    # Opens Tailscale's WireGuard UDP port for direct (non-relayed) connections.
    openFirewall = true;
  };

  # Key-only SSH. Add public keys on the host's users.users.<name>.
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # Reboots into the newest generation stay manual: `nixos-rebuild switch`.
  boot.loader.systemd-boot.configurationLimit = lib.mkDefault 20;
}
