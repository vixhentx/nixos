{ config, lib, pkgs, ... }:

let
  cfg = config.vix.desktop.hyprland;
in
{
  options.vix.desktop.hyprland = {
    enable = lib.mkEnableOption "Hyprland desktop environment";
  };

  config = lib.mkIf cfg.enable {
    programs.hyprland = {
      enable = true;
      # uwsm 管理会话生命周期, 根治注销后无法登录 / tty 切换后登录管理器不出现等问题
      withUWSM = true;
    };

    # Dolphin's "Open With" integration depends on the XDG applications menu
    environment.etc."xdg/menus/applications.menu".source =
      "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";

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

    services.dbus.packages = [ pkgs.kdePackages.dolphin ];
  };
}