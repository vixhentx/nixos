{ config, lib, pkgs, ... }:

let
  cfg = config.vix.system.core;
in
{
  options.vix.system.core = {
    enable = lib.mkEnableOption "Core system standards (Polkit, DBus, Dconf)";
  };

  config = lib.mkIf cfg.enable {
    services.dbus.enable = true;
    services.seatd.enable = true;
    security.polkit.enable = true;
    security.rtkit.enable = true;
    programs.dconf.enable = true;
    services.udisks2.enable = true;

    environment.systemPackages = with pkgs; [
      git
      wget
      curl
    ];
  };
}
