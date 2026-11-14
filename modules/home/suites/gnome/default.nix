{ config, lib, pkgs, ... }:

let
  cfg = config.vix.suites.gnome;
in
{
  options.vix.suites.gnome = {
    enable = lib.mkEnableOption "GNOME desktop scenario suite (home level)";
  };

  config = lib.mkIf cfg.enable {
    vix.desktop.gnome.enable = true;
    vix.suites.gnome-apps.enable = true;
  };
}
