{ config, _utils, ... }:
let
  secrets = _utils.setupSecrets config {
    secrets = [
      "authelia-config"
      "authelia-jwt"
      "authelia-storage"
      "authelia-oauth2"
      "authelia-oauth2-hmac"
      "smtp"
    ];
    extra = {
      owner = "authelia-main";
      group = "authelia-main";
    };
  };
in
{
  imports = [
    secrets.generate
  ];

  systemd.services."authelia-main" = {
    environment = {
      # needed to set the secrets using agenix see: https://www.authelia.com/configuration/methods/files/#file-filters
      X_AUTHELIA_CONFIG_FILTERS = "template";
      AUTHELIA_NOTIFIER_SMTP_PASSWORD_FILE = secrets.get "smtp";
    };
  };

  systemd.tmpfiles.rules = [
    "d /run/authelia 0775 authelia-main caddy"
    "z /run/authelia/authelia.sock 0775 authelia-main caddy"
  ];

  services.authelia = {
    instances.main = {
      enable = true;
      secrets = {
        storageEncryptionKeyFile = secrets.get "authelia-storage";
        jwtSecretFile = secrets.get "authelia-jwt";
        # oidcIssuerPrivateKeyFile = secrets.get "authelia-oauth2";
        # oidcHmacSecretFile = secrets.get "authelia-oauth2-hmac";
      };
      settings = {
        theme = "auto";
        webauthn = {
          disable = false;
          display_name = "Authelia";
          attestation_conveyance_preference = "indirect";
          timeout = "60s";
          selection_criteria.user_verification = "preferred";
        };

        totp = {
          disable = false;
          issuer = "lithium.ovh";
          algorithm = "sha1";
          digits = 6;
          period = 30;
          skew = 1;
          secret_size = 32;
          allowed_algorithms = [ "SHA1" ];
          allowed_digits = [ 6 ];
          allowed_periods = [ 30 ];
          disable_reuse_security_policy = false;
        };

        server = {
          address = "unix:///run/authelia/authelia.sock?umask=0117";
          endpoints = {
            authz = {
              auth-request = {
                implementation = "AuthRequest";
              };
            };
          };
        };
        log = {
          format = "text";
          file_path = "/var/lib/authelia-main/authelia.log";
          keep_stdout = true;
          level = "info";
        };
        storage.local.path = "/tmp/db.sqlite3";

        notifier = {
          disable_startup_check = true;
          smtp = {
            address = "smtp://smtp.mail.ovh.net:587";
            timeout = "15s";
            username = "server@lithium.ovh";
            sender = "Authelia <authelia@lithium.ovh>";
            subject = "[Authelia] {title}";
            startup_check_address = "guillaume.calderon1313@gmail.com";
            disable_require_tls = false;
            disable_starttls = false;
            disable_html_emails = false;
          };
        };

        access_control = {
          default_policy = "deny";
          rules = [
            {
              domain_regex = "authelia.lithium.ovh";
              policy = "two_factor";
            }
          ];
        };

        authentication_backend = {
          password_reset.disable = true;
          password_change.disable = true;
          file = {
            path = secrets.get "authelia-config";
          };
        };

        session = {
          cookies = [
            {
              domain = "lithium.ovh";
              authelia_url = "https://authelia.lithium.ovh";
              default_redirection_url = "https://lithium.ovh";
            }
          ];
        };

        # identity_providers.oidc = {
        # enable to make it working so using settingsFiles (look above)
        # jwks = [
        #   {
        #     key_id = "main";
        #     key = ''{{ secret "${config.age.secrets."authelia/oAuth2PrivateKey".path}" | mindent 10 "|" | msquote }}'';
        #   }
        # ];
        # claims_policies = {
        #   grafana.id_token = [
        #     "email"
        #     "name"
        #     "groups"
        #     "preferred_username"
        #   ];
        #
        # };
        # clients = [ ];
        # };
      };
    };
  };
}
