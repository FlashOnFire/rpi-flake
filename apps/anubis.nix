{ config, ... }:
{
  services.anubis = {
    defaultOptions = {
      policy.settings = {
        openGraph = {
          enabled = true;
          considerHost = false;
          ttl = "4h";
        };
      };
    };

    instances = {
      forgejo.settings = {
        TARGET = "http://127.0.0.1:${toString config.services.forgejo.settings.server.HTTP_PORT}";
      };
    };
  };

  users.users.caddy.extraGroups = [ config.users.groups.anubis.name ];
}
