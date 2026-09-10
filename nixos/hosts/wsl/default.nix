{ pkgs, inputs, ... }:

{
  imports = [
    ../../modules/nixos/nix.nix
  ];

  wsl = {
    enable = true;
    defaultUser = "liam";
    interop.register = true;
  };

  networking.hostName = "wsl";

  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  programs.zsh.enable = true;
  users.users.liam = {
    isNormalUser = true;
    description = "Liam Murphy";
    extraGroups = [
      "docker"
      "wheel"
    ];
    shell = pkgs.zsh;
  };

  programs.nix-ld.enable = true;

  home-manager = {
    useGlobalPkgs = true;
    extraSpecialArgs = { inherit inputs; };
    users.liam = import ../../home/wsl;
  };

  system.stateVersion = "25.05";
}
