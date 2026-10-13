# macOS setup (Apple Silicon)

The single personal Apple Silicon Mac uses `nixos/home/macos/default.nix` and shared Home Manager modules. Target: `darwinConfigurations.personal`, account `liammurphy`, home `/Users/liammurphy`. No employer-managed macOS host is configured.

## Initial installation

1. Complete macOS onboarding as `liammurphy`; install Xcode Command Line Tools (`xcode-select --install`) and Nix with a macOS-compatible multi-user installer.
2. Install [Homebrew](https://brew.sh/) separately. nix-darwin **manages** Homebrew casks but does not install Homebrew itself.
3. Clone this repository into `~/os-setup`.
4. From `~/os-setup/nixos`, update the flake lock to capture the new nix-darwin input: `nix flake lock`. Commit the generated `flake.lock` before treating the build as reproducible.
5. Preview the configuration: `nix build .#darwinConfigurations.personal.system`.
6. Bootstrap nix-darwin following its [official installation instructions](https://github.com/nix-darwin/nix-darwin), using `.#personal`. Subsequent updates: `sudo darwin-rebuild switch --flake ~/os-setup/nixos#personal`.

## Apps

Homebrew casks, managed by nix-darwin: Firefox, Obsidian, OBS Studio, Google Drive, Proton VPN, Raycast, AltTab, Android Studio and OrbStack. Xcode is managed through the Mac App Store integration.

Home Manager: Ghostty (via `ghostty-bin`, shared shell settings) and Rectangle.

The Homebrew cleanup policy is `none`, so activation will not automatically uninstall unrelated apps.

## Before activating

- Confirm the personal Mac short username is `liammurphy`; do not activate on an employer-managed Mac.
- The initial `nix flake lock` update and an Apple Silicon evaluation are still required.
- The personal Mac is managed through **nix-darwin** with integrated Home Manager; standalone macOS Home Manager and work-Mac targets have been removed.
- Firefox profile/policy management is not yet ported to macOS; only the native app is installed.

## macOS preferences

The personal profile sets the following declaratively:

- Finder: path bar, search current folder, show extensions and hidden files, default list view.
- Dock: auto-hide, instant reveal, no recent apps, stable Spaces order.
- Keyboard: faster repeat (initial delay 15, repeat interval 2), no press-and-hold accent menu.
- Trackpad: tap to click.
- Security: Touch ID authentication for `sudo` via `sudo_local`.
- Screenshots: `~/Pictures/Screenshots`, created automatically on activation.

Some preferences may require signing out or restarting Finder/Dock to take effect. Touch ID must be enrolled in macOS.

## Raycast

Raycast is installed through Homebrew alongside Rectangle. Keep macOS Spotlight indexing enabled; optionally assign Command-Space to Raycast in its onboarding/Hotkey settings and move Spotlight to another shortcut. Configure Raycast clipboard history and accessibility permissions after first launch. Rectangle remains installed for dedicated window shortcuts.

## Android development on a physical Pixel

Android Studio is installed as a Homebrew cask on the personal Mac. The existing shared `dev.nix` already provides `android-tools` (ADB/fastboot), so no separate Homebrew Platform Tools installation is necessary.

1. Launch Android Studio and complete its setup wizard. In **Settings → Languages & Frameworks → Android SDK**, install a current Android SDK Platform, Android SDK Build-Tools, SDK Platform-Tools, and SDK Command-line Tools (latest). Use the default SDK directory `~/Library/Android/sdk`.
2. Home Manager sets `ANDROID_HOME` to that SDK directory and adds its platform-tools, emulator and command-line tools to `PATH`. Restart the terminal after activation. Check `which adb` and `adb version` to confirm which ADB is active; avoid running two versions/servers simultaneously.
3. On the Pixel, enable **Developer options** (tap **Build number** seven times in Settings → About phone), then enable **USB debugging** under Developer options.
4. Plug in the Pixel with a data-capable USB cable, unlock it, and accept the RSA debugging authorization prompt.
5. Run `adb devices -l`. Once the phone is listed as `device`, select it in Android Studio and press **Run** to build/install/debug the app.

macOS requires no vendor-specific USB driver. Android Studio and its SDK Manager manage downloaded SDK/build tools; they aren't pinned by this flake. The project Gradle wrapper should specify the project's Gradle version. For a physical Pixel, no emulator image is required.

**Note:** Some Android Studio builds may use a different SDK location, so verify Android Studio's SDK path matches `ANDROID_HOME`. Android Studio includes its own JDK for Gradle by default.

## Nix store maintenance

nix-darwin runs garbage collection every Sunday at 03:00, deleting eligible generations older than seven days (`--delete-older-than 7d`). The active system and referenced packages remain protected. Automatic store optimization deduplicates identical store contents. Container images, Xcode caches and Android SDK files are outside Nix GC.

## GitHub SSH access

After applying the personal macOS profile, follow the [GitHub SSH onboarding guide](../../../docs/github-ssh.md) to create a local key, add it to the Apple Keychain, and register its public key with GitHub. GPG is not required.
