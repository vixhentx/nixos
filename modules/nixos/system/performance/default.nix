{ config, lib, pkgs, ... }:
let
  cfg = config.vix.system.performance;
in
{
  options.vix.system.performance = {
    enable = lib.mkEnableOption "Extreme system performance optimizations";
  };

  config = lib.mkIf cfg.enable {
    zramSwap = {
      enable = true;
      algorithm = "zstd";
      priority = 100;
      memoryPercent = 50;
    };

    services.scx = {
      enable = true;
      scheduler = "scx_lavd";
    };

    boot = {
      # 使用 mkDefault 允许系统定义进行覆盖
      kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
      kernelParams = [
        "preempt=full"
        "threadirqs"
      ];
    };

    services.earlyoom = {
      enable = true;
      freeMemThreshold = 5;
      enableNotifications = true;
    };
  };
}
