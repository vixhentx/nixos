{ config, lib, pkgs, ... }:

let
  cfg = config.vix.system.flatpak;
in
{
  options.vix.system.flatpak = {
    enable = lib.mkEnableOption "Flatpak system daemon and infrastructure";
  };

  config = lib.mkIf cfg.enable {
    services.flatpak.enable = true;

    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };
  };
}
