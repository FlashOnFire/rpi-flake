{ nixos-raspberrypi, pkgs, ... }:
{
  imports = with nixos-raspberrypi.nixosModules.raspberry-pi-5; [
    base
    display-vc4
    page-size-16k
    bluetooth
    ./pi5-configtxt.nix
  ];

  nixpkgs.overlays = [
    nixos-raspberrypi.overlays.vendor-kernel
    nixos-raspberrypi.overlays.vendor-firmware
    nixos-raspberrypi.overlays.kernel-and-firmware
    nixos-raspberrypi.overlays.vendor-pkgs
  ];

  # Override the kernel packages to use the locally-overlayed version
  # instead of the pre-built one from nixos-raspberrypi.packages
  boot.kernelPackages = pkgs.linuxPackages_rpi5;
  boot.loader.raspberry-pi.firmwarePackage = pkgs.raspberrypifw;

  boot.loader.raspberry-pi.bootloader = "kernel";
}
