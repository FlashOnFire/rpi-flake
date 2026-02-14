{
  config,
  _utils,
  _domain_base,
  _smtp_server,
  ...
}:
let
  secrets = _utils.setupSecrets config {
    secrets = [
      "smtp"
    ];
    extra = {
      owner = "authelia-main";
      group = "authelia-main";
    };
  };
in
{
  services.vaultwarden = {
    enable = true;
    config = {
      DOMAIN = "https://vaultwarden.${_domain_base}";
      SIGNUPS_ALLOWED = false;
      ROCKET_ADDRESS = "::1";
      ROCKET_PORT = 8222;
      SMTP_HOST = _smtp_server;
      SMTP_USERNAME = "server@${_domain_base}";
      SMTP_PORT = 587;
      SMTP_FROM = "server@${_domain_base}";
      SMTP_FROM_NAME = "VaultWarden";
      SMTP_SECURITY = "starttls";
    };
    backupDir = "/storage/vaultwarden_backup";
    # dbBackend = "postgresql";
    environmentFile = secrets.get "smtp";
  };
}
