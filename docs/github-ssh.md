# GitHub SSH key setup

The shared Home Manager module `nixos/home/modules/ssh.nix` configures the `github.com` SSH host to use `~/.ssh/id_ed25519` on NixOS, NixOS-WSL and personal macOS. On macOS it also enables Apple's Keychain integration. **Never commit private keys, passphrases, or tokens to this repository.** Create a different passphrase-protected key on each computer.

## NixOS desktop (`lime`) and NixOS-WSL (`wsl`)

1. After activating Home Manager, create your unique key:
   ```sh
   mkdir -p ~/.ssh && chmod 700 ~/.ssh
   ssh-keygen -t ed25519 -C "liam@phmurphy.com" -f ~/.ssh/id_ed25519
   ```
   Choose a strong passphrase. If the path already exists, do not overwrite the key.
2. Add the private key to an available SSH agent for the session:
   ```sh
   ssh-add ~/.ssh/id_ed25519
   ```
   If no agent is running, start one first with `eval "$(ssh-agent -s)"`; arrange a persistent desktop/session agent separately if desired.
3. Copy your **public** key: `cat ~/.ssh/id_ed25519.pub`. In [GitHub SSH and GPG keys](https://github.com/settings/keys), select **New SSH key**, type **Authentication Key**, and paste the public key.
4. Test: `ssh -T git@github.com`. On first connection, verify the GitHub SSH host key fingerprint against [GitHub's published fingerprints](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints) before accepting it. GitHub should greet your account.
5. For GitHub remotes, use `git@github.com:owner/repo.git` or run `git remote set-url origin git@github.com:owner/repo.git`.

**WSL note:** Your existing Git credential helper handles HTTPS credentials. This SSH setup works alongside it, but applies only to SSH remotes; Windows and WSL SSH agents are distinct unless explicitly bridged.

## Personal Apple Silicon macOS

1. Apply the nix-darwin/Home Manager configuration. If you haven't yet created a key:
   ```sh
   mkdir -p ~/.ssh && chmod 700 ~/.ssh
   ssh-keygen -t ed25519 -C "liam@phmurphy.com" -f ~/.ssh/id_ed25519
   ```
   Enter a passphrase and never overwrite an existing key.
2. Add it to the Apple Keychain-backed SSH agent:
   ```sh
   /usr/bin/ssh-add --apple-use-keychain ~/.ssh/id_ed25519
   ```
   If prompted to unlock your key, enter its passphrase. The managed host configuration enables `UseKeychain yes` and `AddKeysToAgent yes`.
3. Register `cat ~/.ssh/id_ed25519.pub` as an **Authentication Key** in [GitHub SSH and GPG keys](https://github.com/settings/keys).
4. Verify GitHub's host-key fingerprint on first connection, then run `ssh -T git@github.com`. Use SSH remotes for repositories.

## Is GPG needed?

**No.** GitHub over SSH uses an SSH authentication key; GPG is not involved. Git commit signing is also optional and is **not enabled** in this repo. GitHub supports verified commit signing with a separate SSH signing key (or with GPG), so you can add signing later without needing GPG.

If you specifically want GPG signing, generate a GPG key *locally* (`gpg --full-generate-key`), upload **only** the exported public key to GitHub as a signing key, and configure Git to use that key. Do not publish the private key. NixOS-WSL already has GPG and gpg-agent configured, but this is not required for GitHub SSH operations.
