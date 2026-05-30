{ config, lib, pkgs, ... }:

let
  cfg = config.vix.desktop.hyprland;
in
{
  options.vix.desktop.hyprland = {
    enable = lib.mkEnableOption "Hyprland desktop environment";
  };

  config = lib.mkIf cfg.enable {
    programs.hyprland.enable = true;

    # 这里的 portal 保持在 Hyprland 模块中，因为它是强相关的界面支持
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk
      ];
      config = {
        common.default = [ "hyprland" "gtk" ];
        hyprland.default = [ "hyprland" "gtk" ];
      };
    };
  };
}