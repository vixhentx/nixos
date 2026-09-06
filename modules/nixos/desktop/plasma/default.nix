{ config, lib, ... }:

let
  cfg = config.vix.desktop.plasma;
in
{
  options.vix.desktop.plasma = {
    enable = lib.mkEnableOption "KDE Plasma 6 desktop environment";
    mobile = {
      enable = lib.mkEnableOption "Mobile support";
    };
  };

  config = lib.mkIf cfg.enable {
    services.desktopManager.plasma6.enable = true;
    # powerdevil (电源管理/电池模式) 仅在 powerManagement 开启时被 plasma6 模块拉入
    powerManagement.enable = true;

    # 自动开启 KDE 应用套件并传递 mobile 选项
    vix.suites.kde.enable = lib.mkDefault true;
    vix.suites.kde.mobile.enable = cfg.mobile.enable;
  };
}
