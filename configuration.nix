# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  pkgs,
  _utils,
  config,
  ...
}:
let
  secret1laVarNix = _utils.setupSingleSecret config "secret1" { };
in

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./rpi-related.nix
    secret1laVarNix.generate
    # secret1laVarNix.path c'est le path vers le secret dans /run/agenix/...
  ];

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };

  # Use the GRUB 2 boot loader.
  # boot.loader.grub.enable = true;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  # boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

  networking.hostName = "lithium";

  # This is mostly portions of safe network configuration defaults that
  # nixos-images and srvos provide

  networking.useNetworkd = true;
  # mdns
  # networking.firewall.allowedUDPPorts = [ 5353 ];
  # systemd.network.networks = {
  #   "99-ethernet-default-dhcp".networkConfig.MulticastDNS = "yes";
  #   "99-wireless-client-dhcp".networkConfig.MulticastDNS = "yes";
  # };

  # This comment was lifted from `srvos`
  # Do not take down the network for too long when upgrading,
  # This also prevents failures of services that are restarted instead of stopped.
  # It will use `systemctl restart` rather than stopping it with `systemctl stop`
  # followed by a delayed `systemctl start`.
  systemd.services = {
    systemd-networkd.stopIfChanged = false;
    # Services that are only restarted might be not able to resolve when resolved is stopped before
    systemd-resolved.stopIfChanged = false;
  };

  # Use iwd instead of wpa_supplicant. It has a user friendly CLI
  networking.wireless.enable = false;
  networking.wireless.iwd = {
    enable = true;
    settings = {
      Network = {
        EnableIPv6 = true;
        RoutePriorityOffset = 300;
      };
      Settings.AutoConnect = true;
    };
  };
  # networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  time.timeZone = "Europe/Paris";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "fr";
    # useXkbConfig = true; # use xkb.options in tty.
  };

  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC4VZD6jMxRKG/RLaS23n1tBK4vNiyzTQwrPKCr+B/ZaqDRKvCx2m54z4EAuZhjDTg9+fPsi+t7HVUV1s8WacP+98aYZ4FLDGvQaOIgxet1kAt8fjAX6FFZWHH/iz0FwovSxSeG7w605EgrGtIQe/G5K/A+c2b2wpOkAIWkPmgHM+eLRxrTlkhJX/7SwzE50rKQrlS0xNGeYL5BQ0aFvZCrrHTaZJW7Lx/RPSU50RhFb+RQMnBXEvTQ3HdEdSLBnmOm6CkL2+19pbLG+79AQfjbQgKPQ5aReAOPzSUWlwrQeXrcaNJ3rKx/vcRTq5eNxKJLO0lrYhwFLQHJXdDB1gUvcrfinYEA+u2NM3CkyWquL/1Z2vAklRH4auzsvvZFysmSs+x9BA1XoMtZ8vJ8BAnFJgKnZeKFAXD/mIH5M0uUBXk+P/M32lCjU13pBWs641lV28DgF4lHNuysWcck1VGXMXTzUWScGTZrxopGkoRVEnrTjrKwSc3ngFG3YiPHMXE= flashonfire@hydrogen"
    ];
  };

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    btop
    wget
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

  programs.git.enable = true;
  virtualisation.docker.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.11"; # Did you read the comment?

}
