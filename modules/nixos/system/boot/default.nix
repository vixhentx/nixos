{ config, lib, ... }:
let
  cfg = config.vix.system.boot;
in
{
  options.vix.system.boot = {
    enable = lib.mkEnableOption "System boot configuration";
  };

  config = lib.mkIf cfg.enable {
    boot.loader = {
      systemd-boot = {
        enable = true;
        # 限制版本数量, 防止 /boot 溢出
        configurationLimit = 10;
        # 提高分辨率支持
        consoleMode = "max";
      };
      efi.canTouchEfiVariables = true;
    };
  };
}
