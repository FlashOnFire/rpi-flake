{
  inputs = {
    # follow `main` branch of this repository, considered being stable
    nixpkgs.url = "github:nvmd/nixpkgs/modules-with-keys-25.05";
    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/main";
    # nixos-raspberrypi.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      nixpkgs,
      nixos-raspberrypi,
      ...
    }@inputs:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
      };
    in
    {
      formatter.x86_64-linux = pkgs.nixfmt-tree;
      nixosConfigurations.lithium = nixos-raspberrypi.lib.nixosSystemFull {
        specialArgs = inputs;

        modules = [
          # {
          #   nixpkgs = {
          #     buildPlatform = "x86_64-linux";
          #     hostPlatform = "aarch64-linux";
          #   };
          # }
          (
            {
              config,
              pkgs,
              lib,
              nixos-raspberrypi,
              ...
            }:
            {
              # Hardware specific configuration, see section below for a more complete
              # list of modules
              imports = with nixos-raspberrypi.nixosModules; [
                raspberry-pi-5.base
                # raspberry-pi-5.page-size-16k
                raspberry-pi-5.display-vc4
                # raspberry-pi-5.bluetooth
                # raspberry-pi-5.display-rp1
                # usb-gadget-ethernet
                ./pi5-configtxt.nix
              ];
            }
          )

          (
            {
              config,
              pkgs,
              lib,
              ...
            }:
            {
              system.nixos.tags =
                let
                  cfg = config.boot.loader.raspberryPi;
                in
                [
                  "raspberry-pi-${cfg.variant}"
                  cfg.bootloader
                  config.boot.kernelPackages.kernel.version
                ];
            }
          )

          ./configuration.nix

        ];
      };
    };

  # Optional: Binary cache for the flake
  nixConfig = {
    extra-substituters = [
      "https://nixos-raspberrypi.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
  };
}
