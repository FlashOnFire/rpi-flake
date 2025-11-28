{ ... }:
{
  services.caddy = {
    enable = true;
    virtualHosts.":80" = {
      extraConfig = ''
        reverse_proxy :3003
      '';
    };
  };
}
