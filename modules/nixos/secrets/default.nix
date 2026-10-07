{ config, lib, inputs, ... }:
let
  cfg = config.vix.secrets;
  secrets = "${inputs.age-secrets}/secrets";
in
{
  options.vix.secrets = {
    enable = lib.mkEnableOption "Enable the age-nix secret-related services";
  };
  config = lib.mkIf cfg.enable {
    age.secrets = {
      # FRP 主服务实例密码环境变量
      frp-major-env.file = "${secrets}/frp-major-env.age";
    };
  };
}