{ config, lib, ... }:
let
  cfg = config.vix.system.ssh;
in
{
  options.vix.system.ssh = {
    enable = lib.mkEnableOption "SSH service";
  };

  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "prohibit-password";
        PasswordAuthentication = true; # 初始建议开启, 待配置好 Key 后可关闭
      };
    };
  };
}
