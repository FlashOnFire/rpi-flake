{ lib, pkgs, ... }:
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

  # shamelessly stolen from uku3lig
  # shamelessly stolen from soopyc's gensokyo
  mkNginxFile =
    {
      filename ? "index.html",
      content,
      status ? 200,
    }:
    {
      # gets the store path of the directory in which the file is contained
      # we have to use writeTextDir because we don't want to expose the whole nix store to nginx
      # and because you can't just return an absolute path to a file
      alias = builtins.toString (pkgs.writeTextDir filename content) + "/";
      tryFiles = "${filename} =${builtins.toString status}";
    };
}
