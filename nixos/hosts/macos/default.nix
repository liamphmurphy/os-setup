{ ... }:

{
  # Homebrew must be installed separately before the first darwin-rebuild.
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  homebrew = {
    enable = true;
    onActivation.cleanup = "none"; # Do not remove existing work-machine apps.
    casks = [
      "firefox"
      "obsidian"
      "obs"
      "google-drive"
      "protonvpn"
    ];
  };

  system.stateVersion = 7;
}
