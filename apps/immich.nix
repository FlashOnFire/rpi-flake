{
  config,
  _utils,
  ...
}:
let
  secrets = _utils.setupSecrets config {
    secrets = [
      "immich-oidc-secret"
    ];
    extra = {
      owner = "immich";
      group = "immich";
    };
  };
in
{
  imports = [
    secrets.generate
  ];

  services.immich = {
    enable = true;
    host = "0.0.0.0";

    # settings = {
    #   oauth = {
    #     enabled = true;
    #     issuerUrl = "https://auth.${_domain_base}";
    #     clientId = "CUkbjHcjkc9K4ZyCdcnaYwdub66eY5F-BJScctEVS5DBTeUp954ZzWNnAbbGWCIGv1Xi58Nf";
    #     clientSecret = secrets.get "immich-oidc-secret";
    #     scope = "openid email profile";
    #     signingAlgorithm = "RS256";
    #     profileSigningAlgorithm = "RS256";
    #     timeout = 30000;
    #     storageLabelClaim = "preferred_username";
    #     storageQuotaClaim = "immich_quota";
    #     defaultStorageQuota = null;
    #     buttonText = "Login with OAuth";
    #     autoRegister = true;
    #     autoLaunch = false;
    #     mobileOverrideEnabled = false;
    #     mobileRedirectUri = "";
    #     roleClaim = "immich_role";
    #     tokenEndpointAuthMethod = "client_secret_post";
    #   };
    # };
    mediaLocation = "/storage/immich";
    accelerationDevices = [ "/dev/dri/renderD128" ];

    environment = {
      TZ = "Europe/Paris";
      # JEMALLOC_SYS_WITH_LG_PAGE = "14";
    };
  };

  users.users.immich.extraGroups = [
    "video"
    "render"
  ];
}
