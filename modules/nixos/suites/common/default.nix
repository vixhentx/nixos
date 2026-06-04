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
    vix.system.boot.enable = true;
    vix.system.locale.enable = true;
    vix.system.ssh.enable = true;

    # 主用户身份定义 (策略层)
    vix.system.user = {
      enable = true;
      name = "vix_hentx";
      hashedPassword = "$6$d9Gm9yC5JN1CNHBQ$EXJWlW33OT8c/64ywgFHoepsmZf9M4KejwlIFdxN.6taFOHLLYWY8Z6a0tSJQ6xAFLxlzgG9LPZqZPGKfUic71";
    };

    # 视觉与终端 (字体由 Stylix 统一管理)
    vix.system.kmscon.enable = true;

    # 容器与沙盒
    vix.system.flatpak.enable = true;

    # 性能优化
    vix.system.performance.enable = true;

    # 网络
    vix.system.network.enable = true;
    vix.system.network.proxy.enable = true;
  };
}
