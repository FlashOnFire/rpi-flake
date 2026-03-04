{
  config,
  pkgs,
  _domain_base,
  _smtp_address,
  _utils,
  ...
}:
let
  domain = "git.${_domain_base}";
  port = 3004;

  secrets = _utils.setupSecrets config {
    secrets = [
      "forgejo-smtp"
      "forgejo-runner-token"
    ];
    extra = {
      owner = "forgejo";
      group = "forgejo";
    };
  };
in
{
  imports = [
    secrets.generate
  ];

  # mkforce to fix conflict with other services
  # services.openssh.settings.AcceptEnv = lib.mkForce [
  #   "GIT_PROTOCOL"
  #   "LANG"
  #   "LC_*"
  # ];

  services = {
    forgejo = {
      enable = true;
      package = pkgs.forgejo; # forgejo-lts by default

      database = {
        type = "postgres";
        createDatabase = true;
      };

      # Enable support for Git Large File Storage
      lfs.enable = true;
      settings = {
        DEFAULT.APP_NAME = "Lithium Forge";

        server = {
          DOMAIN = "${domain}";
          ROOT_URL = "https://${domain}/";
          HTTP_PORT = port;
          START_SSH_SERVER = false;
          BUILTIN_SSH_SERVER_USER = "forgejo";
        };

        oauth2 = {
          # providers are configured in the admin panel
          ENABLED = true;
        };

        # Authelia must be manually registered with
        # forgejo admin auth add-oauth \
        #     --name     authelia \
        #     --provider openidConnect \
        #     --key      ${client_id} \
        #     --secret   secret \
        #     --auto-discover-url ${sso.endpoint}/.well-known/openid-configuration
        #     --scopes='openid email profile groups'

        authelia = {
          ENABLE_OPENID_SIGNIN = true;
          ENABLE_OPENID_SIGNUP = true;
        };

        service = {
          DISABLE_REGISTRATION = false;
          ALLOW_ONLY_EXTERNAL_REGISTRATION = true;
          SHOW_REGISTRATION_BUTTON = false;
          ENABLE_INTERNAL_SIGNIN = false;
          ENABLE_BASIC_AUTHENTICATION = false;
          ENABLE_NOTIFY_MAIL = true;
        };

        # Add support for actions, based on act: https://github.com/nektos/act
        actions = {
          ENABLED = true;
          DEFAULT_ACTIONS_URL = "https://${domain}";
        };

        indexer = {
          REPO_INDEXER_ENABLED = true;
        };

        # You can send a test email from the web UI at:
        # Profile Picture > Site Administration > Configuration >  Mailer Configuration
        mailer = {
          ENABLED = true;
          FROM = "noreply@${domain}";
          PROTOCOL = "smtp";
          SMTP_ADDR = _smtp_address;
          SMTP_PORT = 587;
          USER = "server@${_domain_base}";
        };
      };
      secrets.mailer.PASSWD = secrets.get "forgejo-smtp";
      stateDir = "/storage/forgejo";
    };

    gitea-actions-runner = {
      package = pkgs.forgejo-runner;
      instances.lithium = {
        enable = true;
        name = "lithium-runner";
        url = "https://${domain}/";
        tokenFile = secrets.get "forgejo-runner-token";
        labels = [
          "docker:docker://node:24-alpine"
          "alpine-latest:docker://node:24-alpine"
          "ubuntu-latest:docker://catthehacker/ubuntu:act-latest"
        ];

        settings = {
          log.level = "info";
          container.network = "host";
          runner = {
            capacity = 4;
            timeout = "5h";
            insecure = false;
          };
          session.COOKIE_SECURE = true;
        };
      };
    };
  };

  # Takes the form of "gitea-runner-<instance>"
  systemd.services.gitea-runner-lithium = {
    # Prevents Forgejo runner deployments
    # from being restarted on a system switch,
    # thus breaking a deployment.
    # You'll have to restart the runner manually
    # or reboot the system after a deployment!
    # restartIfChanged = false;

    path = with pkgs; [
      nix
      openssh
    ];

    serviceConfig = {
      MemoryMax = "4G";
      CPUQuota = "50%";
      Nice = 10;
    };

    wants = [ "forgejo.service" ];
    after = [ "forgejo.service" ];
  };
}
