# Shamelessly stolen from uku3lig's flake
{ lib, ... }:
{
  setupSecrets =
    _config:
    {
      secrets,
      extra ? { },
    }:
    let
      inherit (_config.networking) hostName;
    in
    {
      generate = {
        age.secrets = lib.genAttrs secrets (name: extra // { file = ../secrets/${hostName}/${name}.age; });
      };
      get = name: _config.age.secrets.${name}.path;
    };

  setupSingleSecret =
    _config: name: extra:
    let
      inherit (_config.networking) hostName;
    in
    {
      generate = {
        age.secrets.${name} = extra // {
          file = ../secrets/${hostName}/${name}.age;
        };
      };
      inherit (_config.age.secrets.${name}) path;
    };

  setupSharedSecrets =
    _config:
    {
      secrets,
      extra ? { },
    }:
    {
      generate = {
        age.secrets = lib.genAttrs secrets (name: extra // { file = ../secrets/shared/${name}.age; });
      };
      get = name: _config.age.secrets.${name}.path;
    };
}
