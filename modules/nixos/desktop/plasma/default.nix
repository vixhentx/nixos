{ config, lib, pkgs, ... }:

let
  cfg = config.vix.desktop.plasma;
in
{
  options.vix.desktop.plasma = {
    enable = lib.mkEnableOption "KDE Plasma 6 desktop environment";
  };

  config = lib.mkIf cfg.enable {
    services.desktopManager.plasma6.enable = true;

    services.displayManager.defaultSession = lib.mkDefault "plasma";

    # 触屏键盘: pinned nixpkgs 的 plasma6 模块不自动携带 plasma-keyboard, 显式安装
    environment.systemPackages = with pkgs.kdePackages; [
      plasma-keyboard
      qtvirtualkeyboard
    ];

    # powerdevil (电源管理/电池模式) 仅在 powerManagement 开启时被 plasma6 模块拉入
    powerManagement.enable = true;
  };
}
