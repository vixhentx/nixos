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

    # Dolphin's "Open With" integration depends on the XDG applications menu
    environment.etc."xdg/menus/applications.menu".source =
      "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";

    # 这里的 portal 保持在 Hyprland 模块中，因为它是强相关的界面支持
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk
      ];
      config = {
        common.default = [ "gtk" "hyprland" ];
        hyprland.default = [ "hyprland" "gtk" ];
      };
    };

    services.dbus.packages = [ pkgs.kdePackages.dolphin ];
  };
}