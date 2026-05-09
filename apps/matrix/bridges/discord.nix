{
  config,
  _utils,
  _domain_base,
  ...
}:
let
  secrets = _utils.setupSecrets config {
    secrets = [
      "matrix/shared_secret"
    ];
  };
in
{
  imports = [
    secrets.generate
  ];

  # Should not be needed but without this the folder rights are too restrictive and matrix-synapse fail to go inside to read the registration file
  systemd.tmpfiles.rules = [
    "d /storage/mautrix-discord 0770 mautrix-discord mautrix-discord-registration -"
  ];

  services.mautrix-discord = {
    enable = true;
    dataDir = "/storage/mautrix-discord";

    environmentFile = secrets.get "matrix/shared_secret";
    registerToSynapse = true;

    settings = {
      bridge = {
        displayname_template = "{{ or .GlobalName .Username .ID }} (Discord)";
        permissions = {
          "*" = "relay";
          "${_domain_base}" = "user";
          "@flashonfire:${_domain_base}" = "admin";
        };
        login_shared_secret_map = {
          "${_domain_base}" = "as_token:$SHARED_AS_TOKEN";
        };
        sync_direct_chat_list = true;
      };
      homeserver = {
        address = "http://localhost:8008";
        domain = _domain_base;
      };
      encryption = {
        require = false;
        msc4190 = true;
      };
      appservice = {
        database = {
          type = "postgres";
          uri = "postgresql:///mautrix-discord?host=/run/postgresql";
        };
      };
    };
  };
  postgres.initialScripts = [
    ''
      CREATE USER "mautrix-discord";
      CREATE DATABASE "mautrix-discord" WITH OWNER "mautrix-discord"
        TEMPLATE template0
        LC_COLLATE = "C"
        LC_CTYPE = "C";''
  ];
}
