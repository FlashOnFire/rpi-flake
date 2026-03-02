{ config, _utils, ... }:
let
  secrets = _utils.setupSecrets config {
    secrets = [
      "synapse-signingKey"
      "synapse-masSharedSecret"
    ];
    extra = {
      owner = "matrix-synapse";
      group = "matrix-synapse";
    };
  };
in
{
  imports = [
    secrets.generate
  ];

  systemd.tmpfiles.rules = [
    "d /storage/synapse-media 0750 matrix-synapse matrix-synapse - -"
    "d /storage/matrix-synapse 0750 matrix-synapse matrix-synapse - -"
  ];

  services.matrix-synapse = {
    enable = true;
    extras = [
      "systemd"
      "url-preview"
      "oidc"
    ];

    dataDir = "/storage/matrix-synapse";

    settings = {
      server_name = "lithium.ovh";
      public_baseurl = "https://matrix.lithium.ovh";
      federation_client_minimum_tls_version = 1.2;
      enable_registration = false;
      max_upload_size = "100M";

      signing_key_path = secrets.get "synapse-signingKey";
      media_store_path = "/storage/synapse-media";

      database = {
        name = "psycopg2";
        args = {
          database = "matrix-synapse";
          user = "matrix-synapse";
        };
      };

      listeners = [
        {
          bind_addresses = [ "::1" ];
          port = 8008;
          x_forwarded = true;
          tls = false;
          resources = [
            {
              names = [
                "client" # implies ["media" "static"]
                "federation"
                # "keys"
                # "replication"
              ];
            }
          ];
        }
      ];

      experimental_features = {
        msc3266_enabled = true;
        msc4222_enabled = true;
      };

      matrix_authentication_service = {
        enabled = true;
        endpoint = "http://localhost:8089";
        secret_path = secrets.get "synapse-masSharedSecret";
      };

      trusted_key_servers = [
        {
          server_name = "matrix.org";
          verify_keys = {
            "ed25519:auto" = "Noi6WqcDj0QmPxCNQqgezwTlBKrfqehY1u2FyWP9uYw";
          };
        }
      ];
    };
  };

  postgres.initialScripts = [
    ''
      CREATE USER "matrix-synapse";
      CREATE DATABASE "matrix-synapse" WITH OWNER "matrix-synapse"
        TEMPLATE template0
        LC_COLLATE = "C"
        LC_CTYPE
         = "C";
    ''
  ];
}
