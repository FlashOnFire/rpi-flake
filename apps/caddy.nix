{ ... }:
{
  services.caddy = {
    enable = true;
    virtualHosts."https://lithium.ovh" = {
      extraConfig = ''
        respond "hello world";
      '';
    };

    virtualHosts."https://authelia.lithium.ovh".extraConfig = ''
      reverse_proxy unix//run/authelia/authelia.sock {
        header_down X-Real-IP {http.request.remote}
        header_down X-Forwarded-For {http.request.remote}
      }
    '';
  };
}
