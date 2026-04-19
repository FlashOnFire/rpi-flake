{
  config,
  _base_domain,
  _utils,
  ...
}:
let
  secrets = _utils.setupSecrets config {
    secrets = [
      "onlyoffice/jwt"
      "onlyoffice/security_nonce"
    ];
    extra = {
      owner = "onlyoffice";
      group = "onlyoffice";
    };
  };
in
{
  imports = [
    secrets.generate
  ];

  services.onlyoffice = {
    enable = true;
    hostname = "https://office.${_base_domain}";

    wopi = true;
    jwtSecretFile = secrets.get "onlyoffice/jwt";
    securityNonceFile = secrets.get "onlyoffice/security_nonce";
  };
}
