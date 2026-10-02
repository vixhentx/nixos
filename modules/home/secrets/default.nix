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
      # github访问密钥
      github.file = "${secrets}/github.age";
      # git.robotpilots.com 的git访问密钥
      rp-git.file = "${secrets}/rp-git.age";
      # 坚果云 WebDAV 密码
      nutstore.file = "${secrets}/nutstore.age";
    };
  };
}