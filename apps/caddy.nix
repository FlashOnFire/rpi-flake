{
  _domain_base,
  ...
}:
{
  users.users."caddy".extraGroups = [
    "authelia-main"
  ];

  services.caddy = {
    enable = true;

    globalConfig = ''
      admin off
    '';

    virtualHosts."https://${_domain_base}".extraConfig = ''
      forward_auth unix//run/authelia/authelia.sock {
        uri /api/authz/forward-auth
        ## The following commented line is for configuring the Authelia URL in the proxy. We strongly suggest
        ## this is configured in the Session Cookies section of the Authelia configuration.
        # uri /api/authz/forward-auth?authelia_url=https://auth.example.com/
        copy_headers Remote-User Remote-Groups Remote-Email Remote-Name
      }

      # header_up Cookie "authelia_session=[^;]+" "authelia_session=_"
      respond "hello world"
    '';

    virtualHosts."https://auth.${_domain_base}".extraConfig = ''
      reverse_proxy unix//run/authelia/authelia.sock {
        header_down X-Real-IP {http.request.remote}
        header_down X-Forwarded-For {http.request.remote}
      }
    '';

    virtualHosts."https://dns.${_domain_base}".extraConfig = ''
      forward_auth unix//run/authelia/authelia.sock {
        uri /api/authz/forward-auth
        ## The following commented line is for configuring the Authelia URL in the proxy. We strongly suggest
        ## this is configured in the Session Cookies section of the Authelia configuration.
        # uri /api/authz/forward-auth?authelia_url=https://auth.example.com/
        copy_headers Remote-User Remote-Groups Remote-Email Remote-Name
      }

      reverse_proxy :3003 {
        header_up Cookie "authelia_session=[^;]+" "authelia_session=_"
      }
    '';

    virtualHosts."https://lt.${_domain_base}".extraConfig = ''
      forward_auth unix//run/authelia/authelia.sock {
        uri /api/authz/forward-auth
        ## The following commented line is for configuring the Authelia URL in the proxy. We strongly suggest
        ## this is configured in the Session Cookies section of the Authelia configuration.
        # uri /api/authz/forward-auth?authelia_url=https://auth.example.com/
        copy_headers Remote-User Remote-Groups Remote-Email Remote-Name
      }

      reverse_proxy :8001 {
        header_up Cookie "authelia_session=[^;]+" "authelia_session=_"
      }
    '';

    virtualHosts."https://office.${_domain_base}".extraConfig = ''
      forward_auth unix//run/authelia/authelia.sock {
        uri /api/authz/forward-auth
        ## The following commented line is for configuring the Authelia URL in the proxy. We strongly suggest
        ## this is configured in the Session Cookies section of the Authelia configuration.
        # uri /api/authz/forward-auth?authelia_url=https://auth.example.com/
        copy_headers Remote-User Remote-Groups Remote-Email Remote-Name
      }

      reverse_proxy :8000 {
        header_up Cookie "authelia_session=[^;]+" "authelia_session=_"
      }
    '';

    virtualHosts."https://vaultwarden.${_domain_base}".extraConfig = ''
      encode zstd gzip

      reverse_proxy :8222 {
          header_up X-Real-IP {remote_host}
      }
    '';
  };
}
