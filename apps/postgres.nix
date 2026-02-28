{
  lib,
  config,
  pkgs,
  ...
}:
{
  options = {
    postgres.initialScripts = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
  };
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_18;

    settings.port = 5432;
    enableTCPIP = true;

    dataDir = "/storage/postgresql";

    # local synapse synapse scram-sha-256
    authentication = ''
      local all all peer
    '';

    initialScript = pkgs.writeText "init-script.sql" (
      lib.concatStrings (config.postgres.initialScripts or [ ])
    );
  };
}
