{ config, lib, ... }:

let
  cfg = config.vix.suites.hyprland;
in
{
  options.vix.suites.hyprland = {
    enable = lib.mkEnableOption "Hyprland desktop scenario (NixOS level)";
  };

  config = lib.mkIf cfg.enable {
    vix.desktop.hyprland.enable = true;
    
    # 强制开启通用桌面支持（它是依赖项）
    vix.suites.desktop.enable = lib.mkDefault true;

    environment.sessionVariables = {
      WLR_NO_HARDWARE_CURSORS = "1";
    };
  };
}