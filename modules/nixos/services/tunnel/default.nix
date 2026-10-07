{ config, lib, ... }:
let
  cfg = config.vix.services.tunnel;
  secrets = config.age.secrets;
in 
{
  options = {
    vix.services.tunnel = {
      enable = lib.mkEnableOption "Enable the frp services deployment";
      port = lib.mkOption {
        type = lib.types.int;
        default = 7000;
        description = "FRP Major Server instance port";
      };
      allowPorts = lib.mkOption {
        type = lib.types.listOf lib.types.attrs;
        default = [];
        description = "FRP Major Server allow ports";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.enable -> config.vix.secrets.enable;
        message = "Tunnel module needs secret module on. Set `vix.secerts.enable` to true.";
      }
    ];
    services.frp = {
      instances = {
        major-server = {
          enable = true;
          role = "server";
          environmentFiles = [
            secrets.frp-major-env.path
          ];
          settings = {
            bindPort = cfg.port;
            auth.method = "token";
            auth.token = "{{ .Envs.FRP_TOKEN }}";
            allowPorts = cfg.allowPorts;
          };
        };
      };
    };
  };
}