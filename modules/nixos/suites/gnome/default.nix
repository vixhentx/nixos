{ config, lib, ... }:

let
  cfg = config.vix.suites.gnome;
in
{
  options.vix.suites.gnome = {
    enable = lib.mkEnableOption "GNOME desktop scenario (NixOS level)";
  };

  config = lib.mkIf cfg.enable {
    vix.desktop.gnome.enable = true;
    vix.suites.desktop.enable = lib.mkDefault true;
  };
}
