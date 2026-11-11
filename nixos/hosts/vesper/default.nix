# Headless box that runs Vesper and its agents' builds, reached over Tailscale.
{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/nix.nix
    ../../modules/nixos/server.nix
    ../../modules/nixos/vesper.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "vesper";
  networking.networkmanager.enable = true;

  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";

  services.vesper = {
    enable = true;
    # Set once a restic target exists, e.g. "sftp:backup@nas:/srv/restic/vesper".
    backup.repository = null;
  };

  programs.zsh.enable = true;
  users.users.liam = {
    isNormalUser = true;
    description = "Liam Murphy";
    # Not in "docker": that group is root-equivalent. Use sudo for compose.
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      # Public keys only, e.g. the MacBook's ~/.ssh/id_ed25519.pub.
    ];
  };

  environment.systemPackages = with pkgs; [
    git
    htop
    neovim
    tmux
  ];

  # Set to the NixOS release this machine is first installed with; never bump.
  system.stateVersion = "26.05";
}
