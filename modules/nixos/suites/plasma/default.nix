{ config, lib, ... }:

let
  cfg = config.vix.suites.plasma;
in
{
  options.vix.suites.plasma = {
    enable = lib.mkEnableOption "KDE Plasma desktop scenario (NixOS level)";
  };

  config = lib.mkIf cfg.enable {
    vix.desktop.plasma.enable = true;

    # 强制开启通用桌面支持（它是依赖项）
    vix.suites.desktop.enable = lib.mkDefault true;
  };
}
