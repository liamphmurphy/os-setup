{ pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/audio.nix
    ../../modules/nixos/desktop.nix
    ../../modules/nixos/gaming.nix
    ../../modules/nixos/nix.nix
    ../../modules/nixos/printing.nix
    ../../modules/nixos/virtualisation.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_cachyos;
  # Prevents a split-lock crash seen in A Plague Tale: Requiem.
  boot.kernelParams = [ "split_lock_detect=off" ];

  networking.hostName = "lime";
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;
  networking.nftables.enable = true;
  services.tailscale.enable = true;
  services.ollama = {
    enable = true;
    package = pkgs.ollama-rocm;
    loadModels = [
      "qwen3-coder"
    ];
  };

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

  services.xserver = {
    enable = false;
    xkb.layout = "us";
  };

  services.power-profiles-daemon.enable = false;
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "performance";
  };

  programs.zsh.enable = true;
  users.users.liam = {
    isNormalUser = true;
    description = "Liam Murphy";
    extraGroups = [
      "docker"
      "lp"
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.zsh;
  };

  programs.nix-ld.enable = true;
  hardware.amdgpu.overdrive.enable = true;
  services.lact.enable = true;

  home-manager = {
    useGlobalPkgs = true;
    extraSpecialArgs = { inherit inputs; };
    sharedModules = [ inputs.plasma-manager.homeModules.plasma-manager ];
    users.liam = import ../../home/liam;
  };

  system.stateVersion = "25.05";
}
