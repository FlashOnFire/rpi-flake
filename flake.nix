{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/main";
    nixpkgs-patcher.url = "github:gepbird/nixpkgs-patcher";

    systems.url = "github:nix-systems/default";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    nixpkgs-patch-fix-raspi-module-renames = {
      url = "https://github.com/NixOS/nixpkgs/pull/398456.diff";
      flake = false;
    };
    nixpkgs-patch-neovim-zig-build = {
      url = "https://github.com/FlashOnFire/nixpkgs/commit/cfb25ebf1c5d0ef056c7d01eee3987ce48e55434.diff";
      flake = false;
    };
    nixpkgs-patch-fix-neovim-cross-compile = {
      url = "https://github.com/FlashOnFire/nixpkgs/commit/e59418955fbf1186a9ac36c6f4f9fa81b27bd952.diff";
      flake = false;
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        darwin.follows = "";
      };
    };
  };

  outputs =
    {
      flake-parts,
      agenix,
      nixpkgs-patcher,
      self,
      ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      flake = {
        nixosConfigurations.lithium = nixpkgs-patcher.lib.nixosSystem {
          system = "x86_64-linux";

          specialArgs = inputs // {
            _utils = (import ./uku_utils.nix) { lib = flake-parts.lib; };
          };

          modules = [
            ./configuration.nix
            agenix.nixosModules.default
            (
              { lib, ... }:
              {
                nixpkgs.buildPlatform = lib.mkDefault "x86_64-linux";
                nixpkgs.hostPlatform = "aarch64-linux";
              }
            )
          ];
        };
      };

      perSystem =
        { pkgs, system, ... }:
        {
          formatter = pkgs.nixfmt-tree;
        };
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
    };
  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://nixos-raspberrypi.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
  };
}
