{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    walker.url = "github:abenz1267/walker";

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      chaotic,
      home-manager,
      darwin,
      ...
    }:
    {
      nixosConfigurations.lime = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/lime
          chaotic.nixosModules.default
          inputs.home-manager.nixosModules.default
        ];
      };

      nixosConfigurations.wsl = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          inputs.nixos-wsl.nixosModules.default
          inputs.home-manager.nixosModules.default
          ./hosts/wsl
        ];
      };

      # Standalone Home Manager configuration for non-NixOS systems.
      homeConfigurations.liam = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
        extraSpecialArgs = { inherit inputs; };
        modules = [
          inputs.plasma-manager.homeModules.plasma-manager
          ./home/liam
        ];
      };

      # Both macOS machines use identical Home Manager modules; only the
      # macOS short account name / home directory differs.
      homeConfigurations =
        let
          mkMacOS = username: home-manager.lib.homeManagerConfiguration {
            pkgs = import nixpkgs {
              system = "aarch64-darwin";
              config.allowUnfree = true;
            };
            extraSpecialArgs = { inherit inputs; };
            modules = [
              ./home/macos
              {
                home.username = username;
                home.homeDirectory = "/Users/${username}";
              }
            ];
          };
        in
        {
          work = mkMacOS "lmurphy";
          personal = mkMacOS "liammurphy";
        };

      # Native macOS provisioning: Homebrew apps + shared Home Manager setup.
      darwinConfigurations =
        let
          mkDarwin = username: darwin.lib.darwinSystem {
            system = "aarch64-darwin";
            specialArgs = { inherit inputs; };
            modules = [
              ./hosts/macos
              home-manager.darwinModules.home-manager
              {
                system.primaryUser = username;
                users.users.${username}.home = "/Users/${username}";
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.extraSpecialArgs = { inherit inputs; };
                home-manager.users.${username} = { lib, ... }: {
                  imports = [ ./home/macos ];
                  home.username = username;
                  home.homeDirectory = "/Users/${username}";
                  programs.zsh.shellAliases.update = lib.mkForce
                    "nix flake update --flake ~/os-setup/nixos && sudo darwin-rebuild switch --flake ~/os-setup/nixos#${if username == "lmurphy" then "work" else "personal"}";
                };
              }
            ];
          };
        in
        {
          work = mkDarwin "lmurphy";
          personal = mkDarwin "liammurphy";
        };

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-tree;
      formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt-tree;

      checks.x86_64-linux.format =
        let
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
        in
        pkgs.runCommand "os-setup-format-check"
          {
            nativeBuildInputs = [ pkgs.nixfmt-tree ];
          }
          ''
            cd ${self}
            treefmt --ci
            touch $out
          '';
    };
}
