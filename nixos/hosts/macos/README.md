# macOS setup (Apple Silicon)

The personal Apple Silicon Mac uses `nixos/home/macos/default.nix` and shared Home Manager modules. Account: `liammurphy`, home: `/Users/liammurphy`.

## Terminal and development tools only (standalone Home Manager)

Follow the [root README's macOS quick start](../../../README.md#3-personal-macos-setup-apple-silicon) for installation, CLI feature settings, and first activation with dotfile backups. The standalone target is `homeConfigurations.personal`.

After bootstrap, run this from the repository root:

```sh
home-manager switch --flake ./nixos#personal
```

The `update` shell alias updates flake inputs and switches this Home Manager profile using `~/repos/os-setup/nixos`. Adjust the alias in `home/modules/terminal.nix` if you clone elsewhere. Standalone activation does not apply the system preferences or Homebrew apps described below.

## Optional full macOS configuration (nix-darwin)

Use `darwinConfigurations.personal` only when you also want macOS preferences, Homebrew applications, and system maintenance managed declaratively. This target integrates Home Manager; choose it instead of independently activating the standalone profile for the same user.

1. Homebrew is installed and managed by [nix-homebrew](https://github.com/zhaofengli/nix-homebrew); an existing `/opt/homebrew` install is migrated automatically (`autoMigrate`), so no manual install is needed.
2. From the repository root, preview the system build:

   ```sh
   nix build ./nixos#darwinConfigurations.personal.system
   ```

3. Bootstrap nix-darwin following its [official installation instructions](https://github.com/nix-darwin/nix-darwin#installation), targeting `~/repos/os-setup/nixos#personal`. `darwin-rebuild` is available only after nix-darwin is installed. Subsequent updates:

   ```sh
   sudo darwin-rebuild switch --flake ~/repos/os-setup/nixos#personal
   ```

The sections below describe the optional nix-darwin configuration unless explicitly referring to Home Manager.

## Apps

Homebrew casks, managed by nix-darwin: Obsidian, Proton VPN, Raycast, Rectangle, AltTab and Android Studio. Xcode is managed through the Mac App Store integration.

Home Manager: Ghostty (via `ghostty-bin`, shared shell settings).

Home Manager copies app bundles into `~/Applications/Home Manager Apps` so Spotlight can index them. After activation, allow Spotlight time to discover newly installed apps.

The Homebrew cleanup policy is `none`, so activation will not automatically uninstall unrelated apps.

## Before activating

- Confirm the personal Mac short username is `liammurphy`; do not activate on an employer-managed Mac.
- Build the selected target successfully before activating it.
- Both standalone Home Manager and nix-darwin personal targets are available; no work-Mac target is configured.

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
