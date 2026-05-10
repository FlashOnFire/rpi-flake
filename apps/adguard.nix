{
  pkgs,
  _domain_base,
  ...
}:
let
  port = 3005;
in
{
  services.adguardhome = {
    enable = true;

    inherit port;
    mutableSettings = false;

    settings = {
      http = {
        # address already set by module
        # insecure_enabled = true;
      };

      dns = {
        bind_hosts = [
          # "127.0.0.1"
          # "::1"
          "0.0.0.0"
        ];
        port = 53;

        ratelimit = 20;
        refuse_any = true;
        use_private_ptr_resolvers = false;

        upstream_dns = [
          # Example config with quad9
          # "9.9.9.9#dns.quad9.net"
          # "149.112.112.112#dns.quad9.net"
          # Uncomment the following to use a local DNS service (e.g. Unbound)
          # Additionally replace the address & port as needed
          # "127.0.0.1:5335"
          "https://base.dns.mullvad.net/dns-query"
        ];
        bootstrap_dns = [
          "9.9.9.10"
          "149.112.112.10"
          "2620:fe::10"
          "2620:fe::fe:10"
        ];
        trusted_proxies = [
          "127.0.0.1"
          "::1"
        ];

        cache_enabled = true;

        enable_dnssec = true;
      };
      filtering = {
        protection_enabled = true;
        filtering_enabled = true;

        parental_enabled = false; # Parental control-based DNS requests filtering.
        safe_search = {
          enabled = false; # Enforcing "Safe search" option for search engines, when possible.
        };
      };

      statistics = {
        enabled = true;
      };

      filters =
        map
          (url: {
            enabled = true;
            url = url;
          })
          [
            "https://adguardteam.github.io/HostlistsRegistry/assets/filter_9.txt" # The Big List of Hacked Malware Web Sites
            "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt" # malicious url blocklist
          ];

      tls = {
        enabled = true;
        server_name = "dns.${_domain_base}";
        port_https = 3006;
        port_dns_over_tls = 3007;
        port_dns_over_quic = 0;
        allow_unencrypted_doh = true;
        certificate_path = "/var/lib/AdGuardHome/cert.pem";
        private_key_path = "/var/lib/AdGuardHome/key.pem";
      };
    };
  };

  systemd.services.adguardhome.serviceConfig.ExecStartPre =
    let
      script = pkgs.writeShellScript "adguard-cert" ''
        ${pkgs.openssl}/bin/openssl req -x509 -newkey rsa:4096 -nodes \
          -keyout /var/lib/AdGuardHome/key.pem \
          -out /var/lib/AdGuardHome/cert.pem \
          -days 3650 \
          -subj "/CN=localhost" \
          -addext "subjectAltName=DNS:localhost,IP:127.0.0.1"
      '';
    in
    "${script}";
}
