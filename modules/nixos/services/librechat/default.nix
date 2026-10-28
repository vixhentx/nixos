{ config, lib, pkgs, inputs, ... }:
let
  cfg = config.vix.services.librechat;
  native = config.services.librechat;
  secretDirectory = "${inputs.age-secrets}/secrets";
  aiEnvironmentFile =
    if cfg.aiEnvironmentFile != null then cfg.aiEnvironmentFile
    else config.age.secrets.ai-keys-env.path;
  credentialsFile =
    if cfg.credentialsFile != null then cfg.credentialsFile
    else config.age.secrets.librechat-env.path;
  wrappedPackage = import ./package.nix {
    inherit lib pkgs;
    package = cfg.package;
  };
  endpoint = {
    inherit (cfg.endpoint) name titleConvo;
    apiKey = "\${OPENAI_API_KEY}";
    baseURL = "\${OPENAI_API_BASE}";
    modelDisplayLabel = cfg.endpoint.name;
    models = {
      inherit (cfg.endpoint.models) fetch;
      default = cfg.endpoint.models.default;
    };
  } // lib.optionalAttrs (cfg.endpoint.titleModel != null) {
    titleModel = cfg.endpoint.titleModel;
  };
in
{
  options.vix.services.librechat = {
    enable = lib.mkEnableOption "LibreChat with the shared AI gateway credentials";

    package = lib.mkPackageOption pkgs "librechat" { };

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Address on which LibreChat listens.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 3080;
      description = "Local LibreChat HTTP port. No firewall port is opened by this module.";
    };

    publicUrl = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "https://chat.example.com";
      description = "Actual external origin, without a trailing slash, used for DOMAIN_CLIENT and DOMAIN_SERVER.";
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/librechat";
      description = "Persistent LibreChat data directory; MongoDB has its own data directory.";
    };

    aiEnvironmentFile = lib.mkOption {
      type = lib.types.nullOr (lib.types.strMatching "/.+");
      default = null;
      example = "/run/secrets/ai-keys-env";
      description = ''
        Runtime path to a trusted Bash-compatible exports file. Null declares
        a system-level agenix ai-keys-env secret using aiKeysSecretFile.
        Only OPENAI_API_BASE and OPENAI_API_KEY are passed to LibreChat.
      '';
    };

    credentialsFile = lib.mkOption {
      type = lib.types.nullOr (lib.types.strMatching "/.+");
      default = null;
      example = "/run/secrets/librechat-env";
      description = ''
        Runtime systemd EnvironmentFile containing CREDS_KEY, CREDS_IV,
        JWT_SECRET and JWT_REFRESH_SECRET. Null declares an agenix
        librechat-env secret using applicationSecretFile. Use a string path,
        not a Nix path literal pointing at a plaintext file.
      '';
    };

    aiKeysSecretFile = lib.mkOption {
      type = lib.types.path;
      default = "${secretDirectory}/ai-keys-env.age";
      description = "Encrypted shared AI exports file, used when aiEnvironmentFile is null.";
    };

    applicationSecretFile = lib.mkOption {
      type = lib.types.path;
      default = "${secretDirectory}/librechat-env.age";
      description = "Encrypted application credentials file, used when credentialsFile is null.";
    };

    endpoint = {
      name = lib.mkOption {
        type = lib.types.strMatching "[^,[:space:]][^,]*";
        default = "AI Gateway";
        description = "Display name of the shared OpenAI-compatible custom endpoint.";
      };

      models = {
        fetch = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Fetch the gateway model list; requires a working models API.";
        };

        default = lib.mkOption {
          type = lib.types.listOf (lib.types.strMatching ".+");
          default = [ ];
          description = ''
            Real model IDs supported by the gateway. At least one is required,
            including when fetch is true; no model availability is assumed.
            With fetch=true this is a fallback, not an access-control allowlist.
          '';
        };
      };

      titleConvo = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Generate conversation titles using an additional model request.";
      };

      titleModel = lib.mkOption {
        type = lib.types.nullOr (lib.types.strMatching ".+");
        default = null;
        description = "Explicit title model ID, required when titleConvo is enabled.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.publicUrl != null && builtins.match "https?://[^/?#[:space:]]+" cfg.publicUrl != null;
        message = "vix.services.librechat.publicUrl must be an HTTP(S) origin without a path or trailing slash.";
      }
      {
        assertion = cfg.endpoint.models.default != [ ];
        message = "Set vix.services.librechat.endpoint.models.default to at least one real gateway model ID, even with models.fetch = true.";
      }
      {
        assertion = cfg.endpoint.titleConvo -> cfg.endpoint.titleModel != null;
        message = "Set vix.services.librechat.endpoint.titleModel when enabling automatic conversation titles.";
      }
    ];

    # These system secrets are independent of Home Manager's decryption paths.
    age.secrets = lib.mkMerge [
      (lib.mkIf (cfg.aiEnvironmentFile == null) {
        ai-keys-env = {
          file = cfg.aiKeysSecretFile;
          owner = "root";
          group = "root";
          mode = "0400";
        };
      })
      (lib.mkIf (cfg.credentialsFile == null) {
        librechat-env = {
          file = cfg.applicationSecretFile;
          owner = "root";
          group = "root";
          mode = "0400";
        };
      })
    ];

    # Enable MongoDB explicitly so the URI also names the LibreChat database,
    # rather than using the native enableLocalDB helper's database-less URI.
    services.mongodb = {
      enable = true;
      bind_ip = lib.mkDefault "127.0.0.1";
    };

    services.librechat = {
      enable = true;
      package = wrappedPackage;
      inherit (cfg) dataDir;
      inherit credentialsFile;
      openFirewall = lib.mkDefault false;
      meilisearch.enable = lib.mkDefault false;

      env = lib.mapAttrs (_: value: lib.mkDefault value) ({
        NODE_ENV = "production";
        HOST = cfg.host;
        PORT = cfg.port;
        MONGO_URI = "mongodb://127.0.0.1:27017/LibreChat";
        ENDPOINTS = "custom";
        SEARCH = false;
        ALLOW_EMAIL_LOGIN = true;
        ALLOW_REGISTRATION = false;
        ALLOW_SOCIAL_LOGIN = false;
        ALLOW_SOCIAL_REGISTRATION = false;
        ALLOW_UNVERIFIED_EMAIL_LOGIN = false;
        ALLOW_PASSWORD_RESET = false;
        DEBUG_LOGGING = false;
        DEBUG_CONSOLE = false;
        NO_INDEX = true;
      } // lib.optionalAttrs (cfg.publicUrl != null) {
        DOMAIN_CLIENT = cfg.publicUrl;
        DOMAIN_SERVER = cfg.publicUrl;
      });

      settings = {
        # Matches librechat.example.yaml in the locked LibreChat v0.8.7 source.
        version = lib.mkDefault "1.3.13";
        cache = lib.mkDefault true;
        interface.fileSearch = lib.mkDefault false;
        endpoints.custom = lib.mkDefault [ endpoint ];
      };
    };

    systemd.services.librechat = {
      wants = [ "network-online.target" ];
      requires = [ "mongodb.service" ];
      after = [ "network-online.target" "mongodb.service" ];
      serviceConfig.LoadCredential = [ "ai-keys-env:${aiEnvironmentFile}" ];
      # Only encrypted store files are restart triggers, never runtime plaintext.
      restartTriggers =
        lib.optional (cfg.aiEnvironmentFile == null) cfg.aiKeysSecretFile
        ++ lib.optional (cfg.credentialsFile == null) cfg.applicationSecretFile;
    };

    environment.systemPackages = [
      (import ./administration.nix {
        inherit config lib pkgs aiEnvironmentFile;
        package = native.package;
        credentialsFile = native.credentialsFile;
      })
    ];
  };
}
