{
  config,
  _domain_base,
  _utils,
  ...
}:
let
  secrets = _utils.setupSecrets config {
    secrets = [
    ];
    extra = {
      owner = "oxicloud";
      group = "oxicloud";
    };
  };
in
{
  imports = [
    secrets.generate
  ];

  services.oxicloud = {
    enable = true;
    dataDir = "/storage/oxicloud";
    createDatabase = true;

    settings = {
      baseUrl = "https://cloud.${_domain_base}/";
    };
  };
}
