{ config, lib, ... }:
let
  cfg = config.vix.services.matrix;
in
{
  options.vix.services.matrix = {
    enable = lib.mkEnableOption "Enable the Matrix Conduit server";
    settings = {
      server = lib.mkOption {
        type = lib.types.str;
        default = "matrix.vixhentx.tech";
        description = "Matrix Home Server Domain. e.g. matrix.vixhentx.tech";
      };
      port = lib.mkOption {
        type = lib.types.int;
        default = 6167;
        description = "Port for conduit";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.matrix-conduit = {
      enable = true;
      settings.global = {
        server_name = cfg.settings.server;
        port = cfg.settings.port;
        address = "0.0.0.0";
        database_path = "/var/lib/matrix-conduit";
        database_backend = "rocksdb";
        max_request_size = 200000000;
        allow_registration = false;
        allow_federation = true;
        trusted_servers = [
          "matrix.org"
          "kde.org"
        ];
      };
    };
  };
}
