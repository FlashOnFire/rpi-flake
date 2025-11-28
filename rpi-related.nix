{ nixos-raspberrypi, ... }:
{
  imports = with nixos-raspberrypi.nixosModules.raspberry-pi-5; [
    base
    display-vc4
    page-size-16k
    bluetooth
    ./pi5-configtxt.nix
  ];

  nixpkgs.overlays = [
    nixos-raspberrypi.overlays.vendor-pkgs
  ];
  boot.loader.raspberryPi.bootloader = "kernel";
}
