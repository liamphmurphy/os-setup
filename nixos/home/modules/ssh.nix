{ pkgs, lib, ... }:

{
  # A distinct private key is generated locally on each machine, never in Nix.
  programs.ssh = {
    enable = true;
    matchBlocks."github.com" = {
      hostname = "github.com";
      user = "git";
      identityFile = "~/.ssh/id_ed25519";
      identitiesOnly = true;
      extraOptions = {
        AddKeysToAgent = "yes";
      } // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
        UseKeychain = "yes";
      };
    };
  };
}
