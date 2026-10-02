{ config, lib, ... }:
let
  cfg = config.vix.services.tunnel;
  secrets = config.vix.secrets;
in 
{
  options = {
    vix.services.tunnel = {
      enable = lib.mkEnableOption "Enable the frp services deployment";
    };
  };
  config = lib.mkIf cfg.enable {
    services.frp = {
      enable = true;
      instances = {
        major = {
          enable = true;
          environmentFiles = [
            secrets.frps-major-env.path
          ];
          settings = {
            bindPort = 7000;
            auth.method = "token";
            auth.token = "{{ .Envs.FRP_TOKEN }}";
            allowPorts = [
              { single = 211; }
              { start = 6000; end = 7099; }
            ];
          };
        };
      };
    };
  };
}