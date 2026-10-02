{ config, lib, ... }:
let
  cfg = config.vix.suites.common;
in
{
  options.vix.suites.common = {
    enable = lib.mkEnableOption "Common system-level configuration suite";
  };

  config = lib.mkIf cfg.enable {
    # 程序
    vix.program.zsh.enable = true;

    # 系统基础
    vix.system.core.enable = true;
    vix.system.nix.enable = true;
    vix.system.locale.enable = true;

    # 主用户身份定义 (认证策略由主机配置决定)
    vix.system.user = {
      enable = true;
      name = "vix_hentx";
    };
  };
}
