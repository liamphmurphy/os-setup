{ config, lib, ... }:

let
  screenshotsDir = "/Users/${config.system.primaryUser}/Pictures/Screenshots";
in
{
  # Homebrew must be installed separately before the first darwin-rebuild.
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  homebrew = {
    enable = true;
    masApps = {
      Xcode = 497799835;
    };
    onActivation.cleanup = "none"; # Do not remove existing work-machine apps.
    casks = [
      "firefox"
      "obsidian"
      "obs"
      "google-drive"
      "protonvpn"
      "raycast"
      "alt-tab"
    ] ++ lib.optionals (config.system.primaryUser == "liammurphy") [
      # Personal Mac only; work continues to use Colima.
      "orbstack"
    ];
  };

  # Preferences shared by work and personal Macs.
  system.defaults = {
    finder = {
      ShowPathbar = true;
      FXDefaultSearchScope = "SCcf"; # Current folder
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
      FXPreferredViewStyle = "Nlsv"; # List view
    };

    dock = {
      autohide = true;
      show-recents = false;
      mru-spaces = false; # Keep Spaces in their assigned order
    };

    NSGlobalDomain = {
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
      ApplePressAndHoldEnabled = false;
    };

    trackpad.Clicking = true;
    screencapture.location = screenshotsDir;

    # The dedicated dock.autohide-delay option is deprecated in newer
    # nix-darwin versions, so set the underlying preference directly.
    CustomUserPreferences."com.apple.dock"."autohide-delay" = 0.0;
  };

  # Screenshot destinations must exist before macOS can save files there.
  system.activationScripts.postUserActivation.text = ''
    /usr/bin/install -d -o "${config.system.primaryUser}" -g staff "${screenshotsDir}"
  '';

  security.pam.services.sudo_local.touchIdAuth = true;

  system.stateVersion = 7;
}
